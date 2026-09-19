import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'care_api.dart';
import 'models.dart';

/// The real platform. Reads the canonical tables defined in core/schema.sql —
/// the same rows the ASHA app writes and the mother sees in Thayi.
///
/// Scope is not decided here. Row Level Security resolves it from the signed-in
/// user's staff row: a doctor sees her whole facility, an ASHA only her
/// sub-centre. This class never filters by user.
class SupabaseCareApi implements CareApi {
  SupabaseCareApi(this._client, {required this.doctorName});

  /// Her name as the database has it, resolved on first use and kept.
  ///
  /// It is a callback rather than a string because apiProvider is synchronous
  /// and the staff row is not: the alternative was passing a constant, which
  /// is how an invented doctor's name came to be written into the record as
  /// the author of real clinical notes and the origin of real tasks.
  String? _authorName;

  /// Resolved once, but only when it actually resolved.
  ///
  /// `_authorName ??= await doctorName()` remembered the stand-in too, so a
  /// single transient failure to read her staff row — a moment offline while
  /// she saved the first note of the shift — made 'Medical officer' the
  /// permanent author of every note and the origin of every task for the rest
  /// of the session, long after the connection came back.
  Future<String> _author() async {
    final known = _authorName;
    if (known != null) return known;
    final name = await doctorName();
    if (name != null && name.trim().isNotEmpty) {
      return _authorName = name.trim();
    }
    // Not cached: the next write tries again.
    return 'Medical officer';
  }

  final SupabaseClient _client;

  /// Null when her name could not be read, rather than a stand-in chosen here.
  final Future<String?> Function() doctorName;

  /// Cached so row lists and the dashboard do not each re-fetch.
  final Map<String, Mother> _cache = {};

  static const _motherColumns = '''
    id, name_en, name_kn, age, guardian_en, phone, village_en, sub_centre,
    asha_worker_id, lmp, gravida, para, blood_group, height_cm, is_bpl,
    prev_complications, risk_level, risk_reasons, last_visit_date,
    asha:asha_workers!mothers_asha_worker_fk (id, name_en)
  ''';

  // ------------------------------------------------------------- mothers

  @override
  Future<List<Mother>> getMothers() async {
    final rows =
        await _client.from('mothers').select(_motherColumns).order('name_en');
    final list = rows.map(_mother).toList();
    for (final m in list) {
      _cache[m.id] = m;
    }
    return list;
  }

  @override
  Future<Mother?> getMother(String id) async {
    final row = await _client
        .from('mothers')
        .select(_motherColumns)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    final m = _mother(row);
    _cache[m.id] = m;
    return m;
  }

  @override
  Mother? motherOf(String id) => _cache[id];

  // -------------------------------------------------------------- visits

  @override
  Future<List<AncVisit>> getVisits(String motherId) async {
    final rows = await _client
        .from('anc_visits')
        .select()
        .eq('mother_id', motherId)
        .order('visit_date', ascending: false);
    return rows.map(_visit).toList();
  }

  // ---------------------------------------------------------------- labs

  @override
  Future<List<Lab>> getLabs(String motherId) async {
    final rows = await _client
        .from('labs')
        .select()
        .eq('mother_id', motherId)
        .order('result_date', ascending: false);
    return rows
        .map((r) => Lab(
              id: r['id'] as String,
              motherId: motherId,
              type: r['type'] as String? ?? '',
              value: r['value'] as String? ?? '',
              unit: r['unit'] as String? ?? '',
              resultDate: _date(r['result_date']) ?? DateTime.now(),
              orderedBy: r['ordered_by'] as String? ?? '',
              reportUrl: r['report_url'] as String?,
            ))
        .toList();
  }

  // --------------------------------------------------------------- notes

  @override
  Future<List<ClinicalNote>> getNotes(String motherId) async {
    final rows = await _client
        .from('clinical_notes')
        .select()
        .eq('mother_id', motherId)
        .order('created_at', ascending: false);
    return rows
        .map((r) => ClinicalNote(
              id: r['id'] as String,
              motherId: motherId,
              authorName: r['author_name'] as String? ?? '',
              body: r['body'] as String? ?? '',
              createdAt: _date(r['created_at']) ?? DateTime.now(),
            ))
        .toList();
  }

  @override
  Future<ClinicalNote> addNote({
    required String motherId,
    required String body,
  }) async {
    final row = await _client
        .from('clinical_notes')
        .insert({
          'mother_id': motherId,
          'author_name': await _author(),
          'body': body,
        })
        .select()
        .single();
    return ClinicalNote(
      id: row['id'] as String,
      motherId: motherId,
      authorName: row['author_name'] as String? ?? '',
      body: row['body'] as String? ?? body,
      createdAt: _date(row['created_at']) ?? DateTime.now(),
    );
  }

  // --------------------------------------------------------------- ashas

  @override
  Future<List<AshaWorker>> getAshas() async {
    final rows = await _client
        .from('asha_workers')
        .select('id, name_en, phone, sub_centre_en, village')
        .order('name_en');

    // Counts come from the same tables the ASHA app writes, so this is her
    // real workload rather than a seeded number.
    final mothers = await getMothers();
    final tasks = await getTasks();
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month);

    final out = <AshaWorker>[];
    final seen = <String>{};
    for (final r in rows) {
      final id = r['id'] as String;
      final name = r['name_en'] as String? ?? '';
      // Earlier per-app seeds left duplicate workers; show each name once.
      if (!seen.add(name)) continue;

      final theirs = mothers.where((m) => m.ashaId == id).toList();
      var visits = 0;
      for (final m in theirs) {
        final vs = await getVisits(m.id);
        visits += vs.where((v) => v.visitDate.isAfter(monthStart)).length;
      }

      out.add(
        AshaWorker(
          id: id,
          name: name,
          phone: r['phone'] as String? ?? '',
          subCentre: r['sub_centre_en'] as String? ?? '',
          village: r['village'] as String? ?? '',
          assignedMotherCount: theirs.length,
          visitsThisMonth: visits,
          openTasks: tasks
              .where((t) =>
                  t.assignedToAshaId == id && t.status == TaskStatus.open)
              .length,
        ),
      );
    }
    return out;
  }

  // --------------------------------------------------------------- tasks

  @override
  Future<List<Task>> getTasks({String? motherId}) async {
    var query = _client.from('tasks').select();
    if (motherId != null) query = query.eq('mother_id', motherId);
    final rows = await query.order('created_at', ascending: false);
    return rows.map(_task).toList();
  }

  /// Writes the row the ASHA app will pull onto her phone. The ASHA is taken
  /// from the mother's assignment; the doctor never picks one.
  @override
  Future<Task> assignTask({
    required String motherId,
    required TaskType type,
    required String instruction,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    final mother = _cache[motherId] ?? await getMother(motherId);
    if (mother == null) {
      throw StateError('No such mother: $motherId');
    }

    final row = await _client
        .from('tasks')
        .insert({
          'mother_id': motherId,
          'created_by': await _author(),
          'assigned_to_asha_id': mother.ashaId.isEmpty ? null : mother.ashaId,
          'assigned_to_asha_name': mother.ashaName,
          'type': type.name,
          'instruction_en': instruction,
          'instruction_kn': instruction,
          'due_date': _dateOnly(dueDate),
          'priority': priority.name,
          'status': 'open',
          'origin': 'doctor',
        })
        .select()
        .single();
    return _task(row);
  }

  // ----------------------------------------------------------- referrals

  @override
  Future<List<Referral>> getReferrals() async {
    final rows = await _client
        .from('referrals')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map((r) => Referral(
              id: r['id'] as String,
              motherId: r['mother_id'] as String,
              fromUser: r['from_user'] as String? ?? '',
              toFacility: r['to_facility'] as String? ?? '',
              reason: r['reason_en'] as String? ?? '',
              status: switch (r['status'] as String? ?? 'open') {
                'arrived' => ReferralStatus.arrived,
                'closed' => ReferralStatus.closed,
                _ => ReferralStatus.open,
              },
              createdAt: _date(r['created_at']) ?? DateTime.now(),
              outcomeNote: r['outcome_note'] as String?,
            ))
        .toList();
  }

  // ----------------------------------------------------------- dashboard

  @override
  Future<DashboardSummary> getDashboard() async {
    final mothers = await getMothers();
    final referrals = await getReferrals();

    final needsAttention =
        mothers.where((m) => m.riskLevel != RiskLevel.green).toList()
          ..sort((a, b) {
            final byRisk = b.riskLevel.index.compareTo(a.riskLevel.index);
            if (byRisk != 0) return byRisk;
            final ad = a.lastVisitDate ?? DateTime(2000);
            final bd = b.lastVisitDate ?? DateTime(2000);
            return ad.compareTo(bd);
          });

    // One query for the feed rather than one per mother.
    final recentRows = await _client
        .from('anc_visits')
        .select()
        .order('visit_date', ascending: false)
        .limit(8);
    final recent = recentRows.map(_visit).toList();

    final byVillage = <String, int>{};
    for (final m in mothers) {
      byVillage[m.village] = (byVillage[m.village] ?? 0) + 1;
    }

    return DashboardSummary(
      totalMothers: mothers.length,
      highRisk: mothers.where((m) => m.riskLevel != RiskLevel.green).length,
      visitsOverdue: mothers.where((m) => m.isOverdue).length,
      openReferrals:
          referrals.where((r) => r.status == ReferralStatus.open).length,
      needsAttention: needsAttention.take(8).toList(),
      recentVisits: recent,
      registrationsByVillage: byVillage,
    );
  }

  // -------------------------------------------------------------- consent

  /// Her record is not open by default. Either she approves a request in Thayi
  /// Setu, or she shows her Thayi Card QR at the hospital — presenting it is
  /// the consent.
  Future<void> requestAccess(String motherId, {String? reason}) =>
      _client.rpc('request_mother_access',
          params: {'p_mother_id': motherId, 'p_reason': reason});

  /// False when the token does not match her card, so a guessed id opens
  /// nothing.
  Future<bool> grantByQr(String motherId, String token) async {
    final ok = await _client.rpc('grant_access_by_qr',
        params: {'p_mother_id': motherId, 'p_token': token});
    return ok == true;
  }

  /// Resolves the short-lived token a mother's phone now shows.
  ///
  /// The signature is an HMAC, which no database function can check, so the
  /// verification happens in an Edge Function that holds the secret. It also
  /// spends the token and opens the same 24-hour grant the card used to, and
  /// gives back the id so the record can be opened.
  ///
  /// Returns a message instead when the code cannot be used, because "expired"
  /// and "already scanned" mean different things to the person holding the
  /// phone: one is solved by her tapping her card again, the other by waiting
  /// for the code to roll over.
  Future<QrScanOutcome> resolveQrToken(String token) async {
    try {
      final res = await _client.functions.invoke(
        'partner-api/qr/resolve',
        body: {'qr_token': token},
      );
      final data = res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : (res.data as Map).cast<String, dynamic>();

      final id = data['mother_id'] as String?;
      if (id != null) return QrScanOutcome.found(id, data['name'] as String?);
      return QrScanOutcome.refused(
          data['message'] as String? ?? 'That code could not be used');
    } catch (error) {
      debugPrint('QR resolve failed: $error');
      return const QrScanOutcome.refused(
          'Could not reach the server. Check the connection and try again.');
    }
  }

  /// none | pending | approved | rejected | expired
  ///
  /// The server's own rule decides first. A consent grant is not the only way
  /// in: public.can_access_mother() also admits the medical officer at the PHC
  /// the mother is registered at, which is the ordinary case and the one the
  /// "read mothers in scope" policy is written around. Reading only
  /// access_grants therefore locked the timeline, vitals, labs and notes of
  /// every woman on her own facility's list behind a consent screen she could
  /// never satisfy — while the dashboard, which is not gated, was already
  /// showing that same woman's visits two taps away.
  Future<String> accessState(String motherId) async {
    try {
      final allowed =
          await _client.rpc('can_access_mother', params: {'m_id': motherId});
      if (allowed == true) return 'approved';
    } catch (error) {
      // Fall through to the grant history rather than locking her out because
      // one call failed.
      debugPrint('can_access_mother check failed: $error');
    }

    final rows = await _client
        .from('access_grants')
        .select('status, expires_at')
        .eq('mother_id', motherId)
        .order('requested_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) return 'none';
    final r = rows.first;
    final status = r['status'] as String? ?? 'none';
    if (status == 'approved') {
      final exp = r['expires_at'] == null
          ? null
          : DateTime.tryParse(r['expires_at'].toString());
      if (exp != null && exp.isBefore(DateTime.now())) return 'expired';
    }
    return status;
  }

  // ------------------------------------------------------------- mapping

  Mother _mother(Map<String, dynamic> r) {
    final asha = r['asha'] as Map<String, dynamic>?;
    return Mother(
      id: r['id'] as String,
      // The console is English; the Kannada name is what Thayi shows her.
      name: (r['name_en'] as String?)?.trim().isNotEmpty == true
          ? r['name_en'] as String
          : (r['name_kn'] as String? ?? ''),
      age: r['age'] as int? ?? 0,
      husbandName: r['guardian_en'] as String? ?? '',
      phone: r['phone'] as String? ?? '',
      village: r['village_en'] as String? ?? '',
      subCentre: r['sub_centre'] as String? ?? '',
      ashaId: r['asha_worker_id'] as String? ?? '',
      ashaName: asha?['name_en'] as String? ?? '',
      lmp: _date(r['lmp']) ?? DateTime.now(),
      gravida: r['gravida'] as int? ?? 1,
      para: r['para'] as int? ?? 0,
      bloodGroup: r['blood_group'] as String? ?? '',
      heightCm: _toDouble(r['height_cm']),
      isBpl: r['is_bpl'] as bool? ?? false,
      prevComplications: _strings(r['prev_complications']),
      riskLevel: riskFromString(r['risk_level'] as String? ?? 'green'),
      riskReasons: _strings(r['risk_reasons']),
      lastVisitDate: _date(r['last_visit_date']),
    );
  }

  AncVisit _visit(Map<String, dynamic> r) => AncVisit(
        id: r['id'] as String,
        motherId: r['mother_id'] as String,
        visitNo: r['visit_no'] as int? ?? 0,
        visitDate: _date(r['visit_date']) ?? DateTime.now(),
        recordedBy: r['recorded_by'] as String? ?? '',
        source: (r['source'] as String? ?? 'asha') == 'doctor'
            ? VisitSource.doctor
            : VisitSource.asha,
        bpSys: r['bp_sys'] as int?,
        bpDia: r['bp_dia'] as int?,
        weightKg: _toDoubleOrNull(r['weight_kg']),
        fundalHeightCm: _toDoubleOrNull(r['fundal_height_cm']),
        hb: _toDoubleOrNull(r['hb']),
        urineAlbumin: r['urine_albumin'] as String?,
        fetalHr: r['fetal_hr'] as int?,
        fetalMovement: r['fetal_movement'] as bool?,
        dangerSigns: _strings(r['danger_signs']),
        ifaTaken: r['ifa_taken'] as bool? ?? false,
        calciumTaken: r['calcium_taken'] as bool? ?? false,
        ttDoseGiven: r['tt_dose_given'] as int?,
        notes: r['notes'] as String?,
      );

  Task _task(Map<String, dynamic> r) => Task(
        id: r['id'] as String,
        motherId: r['mother_id'] as String,
        createdBy: r['created_by'] as String? ?? '',
        assignedToAshaId: r['assigned_to_asha_id'] as String? ?? '',
        assignedToAshaName: r['assigned_to_asha_name'] as String? ?? '',
        type: switch (r['type'] as String? ?? 'revisit') {
          'recheckBp' => TaskType.recheckBp,
          'confirmMedication' => TaskType.confirmMedication,
          'bringToPhc' => TaskType.bringToPhc,
          'counselling' => TaskType.counselling,
          _ => TaskType.revisit,
        },
        instruction: (r['instruction_en'] as String?) ??
            (r['instruction_kn'] as String? ?? ''),
        dueDate: _date(r['due_date']) ?? DateTime.now(),
        priority: (r['priority'] as String? ?? 'normal') == 'high'
            ? TaskPriority.high
            : TaskPriority.normal,
        status: switch (r['status'] as String? ?? 'open') {
          'done' => TaskStatus.done,
          'missed' => TaskStatus.missed,
          _ => TaskStatus.open,
        },
        createdAt: _date(r['created_at']) ?? DateTime.now(),
      );

  static List<String> _strings(Object? v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  static double _toDouble(Object? v) => _toDoubleOrNull(v) ?? 0;

  static double? _toDoubleOrNull(Object? v) => switch (v) {
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      };

  static String _dateOnly(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}


/// What came back from scanning a code.
@immutable
class QrScanOutcome {
  const QrScanOutcome.found(this.motherId, this.name) : message = null;
  const QrScanOutcome.refused(this.message)
      : motherId = null,
        name = null;

  final String? motherId;
  final String? name;

  /// Plain enough to read aloud at a counter, and specific enough to act on.
  final String? message;

  bool get ok => motherId != null;
}
