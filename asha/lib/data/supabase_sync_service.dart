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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'sync_service.dart';

class SupabaseSyncService implements SyncService {
  SupabaseSyncService(this._client);

  final SupabaseClient _client;

  bool _forceOffline = false;

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
  bool get isOnline => !_forceOffline && _client.auth.currentSession != null;

  /// The signed-in worker's own posting, read once per session.
  ///
  /// A mother has to carry it. Row Level Security scopes an ASHA to
  /// `sub_centre = current_sub_centre()`, so a mother synced without one is
  /// invisible to the very worker who registered her, and can_access_mother
  /// then refuses every visit she tries to add afterwards.
  Map<String, dynamic>? _posting;

  Future<Map<String, dynamic>?> _postingOf() async {
    if (_posting != null) return _posting;
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final staff = await _client
          .from('staff')
          .select('name, sub_centre')
          .eq('auth_user_id', user.id)
          .maybeSingle();
      if (staff == null) return null;

      // asha_workers is the row mothers actually point at; staff is the login.
      final worker = await _client
          .from('asha_workers')
          .select('id')
          .eq('sub_centre_en', staff['sub_centre'] as Object)
          .limit(1)
          .maybeSingle();

      return _posting = {
        'name': staff['name'],
        'sub_centre': staff['sub_centre'],
        'asha_worker_id': worker?['id'],
      };
    } catch (_) {
      return null;
    }
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
      throw SyncFailure('${error.code}: ${error.message}');
    }
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
      'district_en': 'Hassan',
      'lmp': p['lmp'],
      'email': (p['email'] as String?)?.trim().isEmpty ?? true
          ? null
          : (p['email'] as String).trim(),
      'phone': p['phone'],
      'home_lat': p['home_lat'],
      'home_lng': p['home_lng'],
      'gravida': p['gravida'] ?? 1,
      'para': p['para'] ?? 0,
      'height_cm': p['height_cm'],
      'is_bpl': p['is_bpl'] ?? false,
      'blood_group': p['blood_group'],
      'risk_level': p['risk_level'] ?? 'green',
      'abha_id': p['abha_id'],
      'email_verified': p['email_verified'] ?? false,
      // Without these she is registered into nobody's caseload.
      'sub_centre': p['sub_centre'] ?? posting?['sub_centre'],
      'asha_worker_id': posting?['asha_worker_id'],
    }, onConflict: 'id');
  }

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
