import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/seed_data.dart';
import 'package:setu_asha/db/database.dart';
import 'package:setu_asha/providers.dart';
import 'package:setu_asha/risk/risk_engine.dart';

/// What a queued row has to carry for the server to accept it.
///
/// Every visit an ASHA recorded was refused with 23502 and never reached the
/// doctor, because saveVisit queued nine keys while _pushVisit read
/// twenty-two. The thirteen it could not find went up as an explicit null, and
/// an explicit null does not fall back to a column default — it violates the
/// constraint. Her phone reported the visit sent either way.
///
/// The symptom in the field is silence, so the contract is asserted here
/// rather than discovered in a village. These lists are the columns
/// SupabaseSyncService sends; when a column is added to one of these tables it
/// belongs in the payload, in the push, and in the list below.
void main() {
  late AppDatabase db;
  late VisitRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedData.seedIfEmpty(db);
    repo = VisitRepository(db);
  });

  tearDown(() => db.close());

  Future<Map<String, dynamic>> queuedFor(String table) async {
    final rows = await db.pendingOutbox();
    final row = rows.firstWhere((r) => r.entityTable == table);
    return jsonDecode(row.payload) as Map<String, dynamic>;
  }

  /// NOT NULL on public.anc_visits, so a null here is a refused write rather
  /// than a missing value.
  const visitNotNull = [
    'id',
    'mother_id',
    'visit_no',
    'visit_date',
    'ifa_taken',
    'calcium_taken',
    'recorded_by',
    'client_created_at',
  ];

  /// Nullable, but recorded at the doorstep. A missing key here is silent data
  /// loss: the value stays on the handset and no one else ever sees it.
  const visitRecorded = [
    'bp_sys',
    'bp_dia',
    'weight_kg',
    'hb',
    'fundal_height_cm',
    'urine_albumin',
    'fetal_hr',
    'fetal_movement',
    'danger_signs',
    'tt_dose_given',
    'notes',
    'gps_lat',
    'gps_lng',
    'photo_paths',
    'corrects_id',
  ];

  Future<void> saveOne() => repo.saveVisit(
        motherId: 'm-001',
        visitNo: 2,
        recordedBy: 'Gagana',
        bpSys: 138,
        bpDia: 88,
        weightKg: 57.5,
        hb: 10.4,
        fundalHeightCm: 24,
        urineAlbumin: 'trace',
        fetalHr: 142,
        fetalMovement: true,
        dangerSigns: const ['headache'],
        ifaTaken: true,
        calciumTaken: true,
        ttDoseGiven: 2,
        notes: 'Advised iron-rich food',
        gpsLat: 12.97,
        gpsLng: 77.59,
        photoPaths: const ['/tmp/card.jpg'],
      );

  test('a queued visit carries every not-null column', () async {
    await saveOne();
    final payload = await queuedFor('anc_visits');

    for (final key in visitNotNull) {
      expect(payload.containsKey(key), isTrue,
          reason: '$key is NOT NULL on anc_visits. Queueing without it sends '
              'an explicit null and the whole visit is refused with 23502.');
      expect(payload[key], isNotNull, reason: '$key must not be queued as null');
    }
  });

  test('a queued visit carries everything she recorded', () async {
    await saveOne();
    final payload = await queuedFor('anc_visits');

    for (final key in visitRecorded) {
      expect(payload.containsKey(key), isTrue,
          reason: '$key was recorded at the doorstep. Leaving it out of the '
              'payload drops it silently — the local row keeps it and nobody '
              'else ever sees it.');
    }
  });

  test('the visit date is queued, not recomputed on the way out', () async {
    await saveOne();
    final payload = await queuedFor('anc_visits');
    // visit_date used to be computed inline for the local row and never
    // queued, so the push fell back to a key that did not exist either.
    expect(payload['visit_date'], isNotNull);
    expect(DateTime.parse(payload['visit_date'] as String).isAfter(
        DateTime.now().subtract(const Duration(days: 1))), isTrue);
  });

  test('an alert carries the message, not just a severity', () async {
    await repo.saveAlerts('m-001', null, [
      const RiskAlert(
        ruleId: 'R1',
        severity: Severity.red,
        titleKn: 'ಅಧಿಕ ರಕ್ತದೊತ್ತಡ',
        titleEn: 'High blood pressure',
        messageKn: 'ರಕ್ತದೊತ್ತಡ ತುಂಬಾ ಹೆಚ್ಚಿದೆ',
        messageEn: 'Blood pressure is very high',
      ),
    ]);
    final payload = await queuedFor('alerts');

    // Without these the push substituted '' and the doctor received a red
    // alert with a severity and no reason.
    expect(payload['message_kn'], 'ರಕ್ತದೊತ್ತಡ ತುಂಬಾ ಹೆಚ್ಚಿದೆ');
    expect(payload['message_en'], 'Blood pressure is very high');
    expect(payload['rule_id'], 'R1');
    expect(payload['severity'], 'red');
  });
}
