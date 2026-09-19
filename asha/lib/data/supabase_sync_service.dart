/// Pushes what she recorded in the village up to the shared record.
///
/// Until this existed the outbox queued perfectly and then threw the work away:
/// `MockSyncService.push` slept and called debugPrint. Everything an ASHA
/// entered — a new mother, her email, a visit, an alert — stayed on her handset,
/// so a woman she had just registered could not sign in to Thayi Setu and the
/// doctor never saw the visit. The offline half of the design was real; the
/// other half was a stub.
///
/// Two things make this safe to retry, which matters because it runs on a
/// connection that drops mid-request:
///
///  * Local ids are text (`m-1755364…`) and Supabase keys on uuid, so every id
///    is mapped through uuid v5. The same local row always resolves to the same
///    uuid on every device and every attempt.
///  * Every write is an upsert. A push that succeeded server-side but lost its
///    reply gets retried and lands on the same row rather than a duplicate.
library;

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'sync_service.dart';

class SupabaseSyncService implements SyncService {
  SupabaseSyncService(this._client);

  final SupabaseClient _client;

  bool _forceOffline = false;
  bool _networkUp = true;

  /// Fixed namespace, so a local id maps to the same uuid on every handset.
  /// Changing it would orphan everything already synced.
  static const _namespace = '5e70de00-0000-4000-8000-000000000000';
  static const _uuid = Uuid();

  static String uuidFor(String localId) {
    // Ids that are already uuids — anything that came down from the server —
    // must pass through untouched, or an update would create a new row.
    if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-').hasMatch(localId)) {
      return localId;
    }
    return _uuid.v5(_namespace, localId);
  }

  @override
  bool get forceOffline => _forceOffline;

  @override
  set forceOffline(bool value) => _forceOffline = value;

  @override
  set networkUp(bool value) => _networkUp = value;

  @override
  bool get isOnline =>
      !_forceOffline && _networkUp && _client.auth.currentSession != null;

  /// The signed-in worker's own posting, read once per session.
  ///
  /// A mother has to carry it. Row Level Security scopes an ASHA to
  /// `sub_centre = current_sub_centre()`, so a mother synced without one is
  /// invisible to the very worker who registered her, and can_access_mother
  /// then refuses every visit she tries to add afterwards.
  ///
  /// This used to end in `catch (_) { return null; }`, and the mother was
  /// pushed anyway. Every way of holding the wrong identity — no Supabase
  /// session at all, a session left behind by a different account, an account
  /// never registered as staff — arrived at the same place: the insert went
  /// up, `current_role_name()` came back null, the "staff insert mothers"
  /// policy refused the row, and the worker was shown a flat "failed to sync"
  /// naming none of it. Each case now says which one it is, because the thing
  /// she has to do about it is different in each and only she can do it.
  Map<String, dynamic>? _posting;

  /// Whose posting [_posting] holds, so signing in as somebody else cannot
  /// keep filing mothers under the previous worker's sub-centre.
  String? _postingFor;

  Future<Map<String, dynamic>> _postingOf() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const SyncFailure(
        'This phone is not signed in to the health record. Sign out, then '
        'sign in again with your ASHA email.',
      );
    }
    if (_posting != null && _postingFor == user.id) return _posting!;

    final Map<String, dynamic>? staff;
    try {
      staff = await _client
          .from('staff')
          .select('name, sub_centre, facility')
          .eq('auth_user_id', user.id)
          .maybeSingle();
    } on PostgrestException catch (error) {
      throw SyncFailure('Could not read your worker profile: ${error.message}');
    }

    if (staff == null) {
      throw SyncFailure(
        'Signed in as ${user.email ?? 'this account'}, which is not registered '
        'as an ASHA worker. Ask your supervisor to add you in the admin '
        'portal, then sign out and sign in again on this phone.',
      );
    }

    final subCentre = (staff['sub_centre'] as String?)?.trim();
    if (subCentre == null || subCentre.isEmpty) {
      throw SyncFailure(
        '${staff['name'] ?? 'Your account'} has no sub-centre. A mother has to '
        'belong to one, or nobody — including you — can open her afterwards. '
        'Ask your supervisor to set it in the admin portal.',
      );
    }

    // asha_workers is the row mothers actually point at; staff is the login.
    // Matched on the sub-centre rather than the name, because two workers can
    // share a name and only one can hold a posting.
    final worker = await _client
        .from('asha_workers')
        .select('id')
        .eq('sub_centre_en', subCentre)
        .limit(1)
        .maybeSingle();

    // Her facility, so the mother lands inside a PHC that the admin portal and
    // the doctor can both see. district_en was the literal string 'Hassan' for
    // every mother ever registered, wherever she lived; it comes from the
    // facility now, and stays null rather than guessed if that is unknown.
    Map<String, dynamic>? centre;
    final facility = (staff['facility'] as String?)?.trim();
    if (facility != null && facility.isNotEmpty) {
      try {
        centre = await _client
            .from('health_centres')
            .select('id, districts(name, name_kn)')
            .eq('name_en', facility)
            .limit(1)
            .maybeSingle();
      } on PostgrestException {
        // Not being able to name her district is not a reason to strand her
        // on the handset. The columns it fills are nullable.
        centre = null;
      }
    }

    _postingFor = user.id;
    return _posting = {
      'name': staff['name'],
      'sub_centre': subCentre,
      'asha_worker_id': worker?['id'],
      'phc_id': centre?['id'],
      // districts names its columns `name`/`name_kn`, not the `_en`/`_kn` pair
      // mothers uses.
      'district_en': (centre?['districts'] as Map?)?['name'],
      'district_kn': (centre?['districts'] as Map?)?['name_kn'],
    };
  }

  @override
  Future<void> push(OutboxData item) async {
    if (!isOnline) throw const SyncFailure('offline');

    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    try {
      switch (item.entityTable) {
        case 'mothers':
          await _pushMother(payload, isInsert: item.operation == 'insert');
        case 'anc_visits':
          await _pushVisit(payload);
        case 'alerts':
          await _pushAlert(payload);
        case 'referrals':
          await _pushReferral(payload);
        case 'tasks':
          await _pushTask(payload);
        default:
          // An unknown table is a programming error, not a network one. Saying
          // so is better than retrying it forever.
          throw SyncFailure('nothing knows how to sync ${item.entityTable}');
      }
    } on PostgrestException catch (error) {
      // 4xx from PostgREST is our bug or a rejected value — retrying will not
      // fix it, but the worker still records it against the row so it shows up
      // on the Sync Status screen rather than vanishing.
      throw SyncFailure(_plainly(error));
    }
  }

  /// PostgREST's own words are accurate and unreadable at a doorstep.
  ///
  /// `42501: new row violates row-level security policy for table "mothers"`
  /// is what the worker was actually shown, under a red "Failed", with no way
  /// to tell from it that the phone was signed in as the wrong account.
  static String _plainly(PostgrestException error) {
    if (error.code == '42501' ||
        error.message.contains('row-level security')) {
      return 'The server would not accept this from the account signed in on '
          'this phone. Sign out and sign in again with your ASHA email; if it '
          'is still refused, ask your supervisor to check that you are '
          'registered as an ASHA worker.';
    }
    if (error.code == '23505') {
      return 'A record with these details is already on the server.';
    }
    if (error.code == '23514') {
      // A check constraint. The one that actually fires is age, which the
      // server holds between 10 and 60.
      return 'The server would not accept one of these values. Check her age '
          'and date of last period, then send again.';
    }
    return error.message;
  }

  // ------------------------------------------------------------- mothers

  Future<void> _pushMother(
    Map<String, dynamic> p, {
    required bool isInsert,
  }) async {
    final id = uuidFor(p['id'] as String);

    if (!isInsert) {
      // A correction to a row that is already up there: send only what changed
      // so a stale local copy cannot overwrite a newer server value.
      final patch = <String, dynamic>{
        for (final key in [
          'home_lat',
          'home_lng',
          'home_note',
          'risk_level',
          'email',
          'email_verified',
        ])
          if (p.containsKey(key)) key: p[key],
      };
      if (patch.isEmpty) return;
      await _client.from('mothers').update(patch).eq('id', id);
      return;
    }

    final name = (p['name'] as String?)?.trim() ?? '';
    final village = (p['village'] as String?)?.trim() ?? '';
    final posting = await _postingOf();

    await _client.from('mothers').upsert({
      'id': id,
      // The card number keeps her readable id, so the row can still be traced
      // back to the handset that created it.
      'thayi_card_number': p['id'],
      // Nothing may be null here: these columns are NOT NULL server-side, and
      // an ASHA registering at a doorstep does not have all of them.
      'qr_token': uuidFor('qr:${p['id']}').replaceAll('-', '').substring(0, 24),
      'name_en': name,
      'name_kn': name,
      'age': p['age'] ?? 0,
      'village_en': village,
      'village_kn': village,
      'district_en': posting['district_en'],
      'district_kn': posting['district_kn'],
      'phc_id': posting['phc_id'],
      'lmp': p['lmp'],
      // Only ever sent when this handset has one. An insert is a full upsert,
      // so a null here would blank an address the server already holds — and
      // her address is the only way she can reach her own record.
      if ((p['email'] as String?)?.trim().isNotEmpty ?? false)
        'email': (p['email'] as String).trim(),
      'phone': p['phone'],
      // Never sent before, so these three existed only on the handset that
      // typed them — and a pull would have read the server's nulls back over
      // them. guardian_* is where the server keeps the husband's name.
      'guardian_en': p['husband_name'],
      'guardian_kn': p['husband_name'],
      'prev_complications': _asList(p['prev_complications']),
      'home_note': p['home_note'],
      'home_lat': p['home_lat'],
      'home_lng': p['home_lng'],
      'gravida': p['gravida'] ?? 1,
      'para': p['para'] ?? 0,
      'height_cm': p['height_cm'],
      'is_bpl': p['is_bpl'] ?? false,
      'blood_group': p['blood_group'],
      'risk_level': p['risk_level'] ?? 'green',
      'abha_id': p['abha_id'],
      // Sent only when true. This is a full upsert and it re-runs on every
      // re-send, so a local false would write over the server's true and
      // un-verify her — after which Thayi Setu refuses her sign-in with "this
      // email is not registered", and nothing on either screen explains why.
      // Nothing in this app has the authority to un-verify an address: only
      // mark_email_verified sets the flag, and only she can prove it.
      if (p['email_verified'] == true) 'email_verified': true,
      // Without these she is registered into nobody's caseload. The worker's
      // own posting wins over whatever the form held: an ASHA may only
      // register into the sub-centre she is posted to, and that field was
      // pre-filled from the practice data, so mothers were being filed into a
      // sub-centre the worker who entered them could not read back.
      'sub_centre': posting['sub_centre'],
      'asha_worker_id': posting['asha_worker_id'],
    }, onConflict: 'id');
  }

  // ---------------------------------------------------------------- pull

  /// Reads her caseload down from the server.
  ///
  /// The app was push-only. Everything a worker saw came from a caseload of
  /// twenty invented women written into the handset's own database the first
  /// time it ran, so the phone and the website disagreed permanently: the
  /// portal showed the mothers who existed and the phone showed twenty who did
  /// not. A mother registered on another handset, or by a supervisor, could
  /// never appear here at all.
  ///
  /// Row Level Security already scopes the read — `sub_centre =
  /// current_sub_centre()` — so this asks for her sub-centre explicitly only
  /// to keep the request small and the intent legible.
  @override
  Future<int> pull(AppDatabase db) async {
    if (!isOnline) return 0;
    final posting = await _postingOf();
    final subCentre = posting['sub_centre'] as String;

    final List<dynamic> rows;
    try {
      rows = await _client
          .from('mothers')
          .select('id, name_en, name_kn, age, guardian_en, guardian_kn, phone, '
              'email, email_verified, village_en, village_kn, sub_centre, '
              'abha_id, lmp, gravida, para, blood_group, height_cm, is_bpl, '
              'prev_complications, risk_level, home_lat, home_lng, home_note, '
              'created_at')
          .eq('sub_centre', subCentre)
          .eq('active', true);
    } on PostgrestException catch (error) {
      throw SyncFailure(_plainly(error));
    }

    // uuidFor is one-way, so hashing every local id forward is the only way to
    // recognise a woman this handset already holds. Without this index a
    // mother registered here comes back down under her server uuid as a
    // second, identical row — the duplication this app was reported for.
    final local = await db.allMothers();
    final byServerId = {for (final m in local) uuidFor(m.id): m};
    final unsent = await db.unsentRecordIds();

    var touched = 0;
    final motherLocalId = <String, String>{};
    await db.transaction(() async {
      for (final raw in rows) {
        final row = raw as Map<String, dynamic>;
        final serverId = row['id'] as String;
        final existing = byServerId[serverId];

        // A row created here keeps the local id it was created with, so every
        // visit, alert and referral already pointing at it stays pointing at
        // it. Only a mother this phone has never seen is keyed by her uuid.
        final localId = existing?.id ?? serverId;
        if (unsent.contains(localId)) continue;

        final lmp = _dateFrom(row['lmp']) ?? existing?.lmp;
        if (lmp == null) continue; // not a usable record without it

        await db.into(db.mothers).insertOnConflictUpdate(
              MothersCompanion.insert(
                id: localId,
                name: _text(row['name_kn']) ??
                    _text(row['name_en']) ??
                    existing?.name ??
                    '',
                age: (row['age'] as int?) ?? existing?.age ?? 0,
                village: _text(row['village_kn']) ??
                    _text(row['village_en']) ??
                    existing?.village ??
                    '',
                lmp: lmp,
                createdAt:
                    _dateFrom(row['created_at']) ?? existing?.createdAt ?? lmp,
                // Every nullable field falls back to what is already here
                // rather than to null: the push does not carry all of them, so
                // a server null often means "never sent" and not "cleared".
                husbandName: Value(_text(row['guardian_kn']) ??
                    _text(row['guardian_en']) ??
                    existing?.husbandName),
                phone: Value(_text(row['phone']) ?? existing?.phone),
                email: Value(_text(row['email']) ?? existing?.email),
                emailVerified: Value(
                    (row['email_verified'] as bool?) ??
                        existing?.emailVerified ??
                        false),
                homeLat: Value(_number(row['home_lat']) ?? existing?.homeLat),
                homeLng: Value(_number(row['home_lng']) ?? existing?.homeLng),
                homeNote: Value(_text(row['home_note']) ?? existing?.homeNote),
                homeLocatedAt: Value(existing?.homeLocatedAt),
                subCentre:
                    Value(_text(row['sub_centre']) ?? existing?.subCentre),
                abhaId: Value(_text(row['abha_id']) ?? existing?.abhaId),
                gravida:
                    Value((row['gravida'] as int?) ?? existing?.gravida ?? 1),
                para: Value((row['para'] as int?) ?? existing?.para ?? 0),
                bloodGroup:
                    Value(_text(row['blood_group']) ?? existing?.bloodGroup),
                heightCm:
                    Value(_number(row['height_cm']) ?? existing?.heightCm),
                isBpl: Value((row['is_bpl'] as bool?) ?? existing?.isBpl ?? false),
                prevComplications: Value(jsonEncode(_asList(
                  row['prev_complications'],
                ))),
                riskLevel: Value(
                    _text(row['risk_level']) ?? existing?.riskLevel ?? 'green'),
                // It is on the server, so it is synced by definition. And it
                // is this phone's own only if it already was — a pulled row
                // must never be re-pushed over the server's copy.
                synced: const Value(true),
                workerCreated: Value(existing?.workerCreated ?? false),
              ),
            );
        touched++;
        motherLocalId[serverId] = localId;
      }
    });

    if (motherLocalId.isNotEmpty) {
      await _pullVisits(db, motherLocalId, unsent);
      await _pullTasks(db, motherLocalId, unsent);
    }
    return touched;
  }

  /// Her visit history, so the next visit is numbered from what actually
  /// happened rather than from what this handset happens to remember.
  ///
  /// Without it a mother pulled down starts again at visit 1, and a reading
  /// taken by whoever covered the sub-centre last month is invisible.
  Future<void> _pullVisits(
    AppDatabase db,
    Map<String, String> motherLocalId,
    Set<String> unsent,
  ) async {
    final List<dynamic> rows;
    try {
      rows = await _client
          .from('anc_visits')
          .select('id, mother_id, visit_no, visit_date, bp_sys, bp_dia, '
              'weight_kg, fundal_height_cm, hb, urine_albumin, fetal_hr, '
              'fetal_movement, danger_signs, ifa_taken, calcium_taken, '
              'tt_dose_given, notes, gps_lat, gps_lng, recorded_by, '
              'corrects_id, client_created_at')
          .inFilter('mother_id', motherLocalId.keys.toList());
    } on PostgrestException {
      return; // the caseload is the part that matters; history can wait
    }

    final existing = {
      for (final v in await db.select(db.ancVisits).get()) uuidFor(v.id): v
    };

    await db.transaction(() async {
      for (final raw in rows) {
        final row = raw as Map<String, dynamic>;
        final serverId = row['id'] as String;
        final motherId = motherLocalId[row['mother_id'] as String];
        if (motherId == null) continue;

        final here = existing[serverId];
        final localId = here?.id ?? serverId;
        if (unsent.contains(localId)) continue;

        final date = _dateFrom(row['visit_date']) ?? here?.visitDate;
        if (date == null) continue;

        await db.into(db.ancVisits).insertOnConflictUpdate(
              AncVisitsCompanion.insert(
                id: localId,
                motherId: motherId,
                visitNo: (row['visit_no'] as int?) ?? here?.visitNo ?? 1,
                visitDate: date,
                recordedBy: _text(row['recorded_by']) ?? here?.recordedBy ?? '',
                clientCreatedAt:
                    _dateFrom(row['client_created_at']) ?? date,
                bpSys: Value((row['bp_sys'] as int?) ?? here?.bpSys),
                bpDia: Value((row['bp_dia'] as int?) ?? here?.bpDia),
                weightKg: Value(_number(row['weight_kg']) ?? here?.weightKg),
                fundalHeightCm: Value(
                    _number(row['fundal_height_cm']) ?? here?.fundalHeightCm),
                hb: Value(_number(row['hb']) ?? here?.hb),
                urineAlbumin: Value(
                    _text(row['urine_albumin']) ?? here?.urineAlbumin),
                fetalHr: Value((row['fetal_hr'] as int?) ?? here?.fetalHr),
                fetalMovement: Value(
                    (row['fetal_movement'] as bool?) ?? here?.fetalMovement),
                dangerSigns: Value(jsonEncode(_asList(row['danger_signs']))),
                ifaTaken:
                    Value((row['ifa_taken'] as bool?) ?? here?.ifaTaken ?? false),
                calciumTaken: Value((row['calcium_taken'] as bool?) ??
                    here?.calciumTaken ??
                    false),
                ttDoseGiven:
                    Value((row['tt_dose_given'] as int?) ?? here?.ttDoseGiven),
                notes: Value(_text(row['notes']) ?? here?.notes),
                gpsLat: Value(_number(row['gps_lat']) ?? here?.gpsLat),
                gpsLng: Value(_number(row['gps_lng']) ?? here?.gpsLng),
                correctsId: Value(_text(row['corrects_id']) ?? here?.correctsId),
                synced: const Value(true),
                workerCreated: Value(here?.workerCreated ?? false),
              ),
            );
      }
    });
  }

  /// The work a doctor assigned her.
  ///
  /// This is the point of the product — a doctor in Setu Care assigns a visit
  /// and it lands on the ASHA's phone — and it did not work at all: the app
  /// could close a task but had no way to ever receive one.
  Future<void> _pullTasks(
    AppDatabase db,
    Map<String, String> motherLocalId,
    Set<String> unsent,
  ) async {
    final List<dynamic> rows;
    try {
      rows = await _client
          .from('tasks')
          .select('id, mother_id, type, instruction_kn, instruction_en, '
              'due_date, priority, status, origin, closed_by_visit_id, '
              'created_at, closed_at')
          .inFilter('mother_id', motherLocalId.keys.toList());
    } on PostgrestException {
      return;
    }

    final existing = {
      for (final t in await db.select(db.tasks).get()) uuidFor(t.id): t
    };

    await db.transaction(() async {
      for (final raw in rows) {
        final row = raw as Map<String, dynamic>;
        final serverId = row['id'] as String;
        final motherId = motherLocalId[row['mother_id'] as String];
        if (motherId == null) continue;

        final here = existing[serverId];
        final localId = here?.id ?? serverId;
        // She may have marked it done with no signal. Her answer is the newer
        // one; overwriting it with the server's 'open' would ask her twice.
        if (unsent.contains(localId)) continue;

        final due = _dateFrom(row['due_date']) ?? here?.dueDate;
        if (due == null) continue;

        await db.into(db.tasks).insertOnConflictUpdate(
              TasksCompanion.insert(
                id: localId,
                motherId: motherId,
                type: _text(row['type']) ?? here?.type ?? 'followUp',
                dueDate: due,
                createdAt: _dateFrom(row['created_at']) ?? due,
                instructionKn: Value(
                    _text(row['instruction_kn']) ?? here?.instructionKn),
                instructionEn: Value(
                    _text(row['instruction_en']) ?? here?.instructionEn),
                priority: Value(
                    _text(row['priority']) ?? here?.priority ?? 'normal'),
                status:
                    Value(_text(row['status']) ?? here?.status ?? 'open'),
                origin:
                    Value(_text(row['origin']) ?? here?.origin ?? 'doctor'),
                closedByVisitId: Value(
                    _text(row['closed_by_visit_id']) ?? here?.closedByVisitId),
                closedAt: Value(_dateFrom(row['closed_at']) ?? here?.closedAt),
              ),
            );
      }
    });
  }

  static String? _text(Object? raw) {
    final text = raw?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _number(Object? raw) =>
      raw == null ? null : double.tryParse(raw.toString());

  static DateTime? _dateFrom(Object? raw) =>
      raw == null ? null : DateTime.tryParse(raw.toString());

  // -------------------------------------------------------------- visits

  Future<void> _pushVisit(Map<String, dynamic> p) async {
    await _client.from('anc_visits').upsert({
      'id': uuidFor(p['id'] as String),
      'mother_id': uuidFor(p['mother_id'] as String),
      'visit_no': p['visit_no'],
      'visit_date': p['visit_date'] ?? p['created_at'],
      'bp_sys': p['bp_sys'],
      'bp_dia': p['bp_dia'],
      'weight_kg': p['weight_kg'],
      'hb': p['hb'],
      'fundal_height_cm': p['fundal_height_cm'],
      'fetal_hr': p['fetal_hr'],
      'urine_albumin': p['urine_albumin'],
      'danger_signs': _asList(p['danger_signs']),
      'ifa_taken': p['ifa_taken'],
      'calcium_taken': p['calcium_taken'],
      'tt_dose_given': p['tt_dose_given'],
      'notes': p['notes'],
      'gps_lat': p['gps_lat'],
      'gps_lng': p['gps_lng'],
      'recorded_by': p['recorded_by'],
      'source': 'asha_app',
      // The correction chain has to survive the trip, or the append-only
      // history means nothing once it is on the server.
      'corrects_id':
          p['corrects_id'] == null ? null : uuidFor(p['corrects_id'] as String),
      'client_created_at': p['created_at'],
    }, onConflict: 'id');

    // Her latest visit date drives "overdue" on the doctor's dashboard.
    final visitDate = p['visit_date'] ?? p['created_at'];
    if (visitDate != null) {
      await _client
          .from('mothers')
          .update({'last_visit_date': _dateOnly(visitDate)}).eq(
              'id', uuidFor(p['mother_id'] as String));
    }
  }

  // -------------------------------------------------------------- alerts

  Future<void> _pushAlert(Map<String, dynamic> p) async {
    await _client.from('alerts').upsert({
      'id': uuidFor(p['id'] as String),
      'mother_id': uuidFor(p['mother_id'] as String),
      'rule_id': p['rule_id'],
      'severity': p['severity'],
      'message_kn': p['message_kn'] ?? '',
      'message_en': p['message_en'] ?? '',
      'visit_id':
          p['visit_id'] == null ? null : uuidFor(p['visit_id'] as String),
      'created_at': p['created_at'],
    }, onConflict: 'id');

    // An alert she raised is the reason the mother's risk changed; the list
    // the doctor triages is sorted by it.
    if (p['severity'] != null) {
      await _client.from('mothers').update({'risk_level': p['severity']}).eq(
          'id', uuidFor(p['mother_id'] as String));
    }
  }

  Future<void> _pushReferral(Map<String, dynamic> p) async {
    await _client.from('referrals').upsert({
      'id': uuidFor(p['id'] as String),
      'mother_id': uuidFor(p['mother_id'] as String),
      'from_user': p['from_user'] ?? p['referred_by'],
      'to_facility': p['to_facility'] ?? p['referred_to'],
      'reason_en': p['reason_en'] ?? p['reason'],
      'reason_kn': p['reason_kn'] ?? p['reason'],
      'status': p['status'] ?? 'open',
      'visit_id':
          p['visit_id'] == null ? null : uuidFor(p['visit_id'] as String),
      'created_at': p['created_at'],
    }, onConflict: 'id');
  }

  Future<void> _pushTask(Map<String, dynamic> p) async {
    // Tasks originate with the doctor, so an ASHA only ever closes one.
    await _client.from('tasks').update({
      'status': p['status'],
      if (p['closed_at'] != null) 'closed_at': p['closed_at'],
    }).eq('id', uuidFor(p['id'] as String));
  }

  // ------------------------------------------------------------- helpers

  static List<String> _asList(Object? raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return [raw];
      }
    }
    return const [];
  }

  static String? _dateOnly(Object? raw) {
    if (raw == null) return null;
    final text = raw.toString();
    return text.length >= 10 ? text.substring(0, 10) : text;
  }
}
