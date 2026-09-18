import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/seed_data.dart';
import 'package:setu_asha/data/sync_service.dart';
import 'package:setu_asha/db/database.dart';
import 'package:setu_asha/providers.dart';
import 'package:setu_asha/risk/risk_engine.dart';

/// The sequence the brief calls the only thing that matters:
///
///   force offline → record BP 165/110 with a headache → the red
///   pre-eclampsia alert fires anyway → the referral saves → the outbox shows
///   the pending count → go online → the outbox drains.
///
/// Driven through the real repository, the real risk engine and a real
/// SQLite database, so it fails if any part of that chain regresses.
void main() {
  late AppDatabase db;
  late VisitRepository repo;
  late RiskEngine engine;
  late MockSyncService sync;
  late SyncWorker worker;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedData.seedIfEmpty(db);
    repo = VisitRepository(db);
    engine = RiskEngine.fromJson(
      File('assets/rules/risk_rules.json').readAsStringSync(),
    );
    // No latency and no random failures: this test is about the sequence,
    // not about retry behaviour, and must never be flaky.
    sync = MockSyncService(latency: Duration.zero, failurePercent: 0);
    worker = SyncWorker(db, sync);
  });

  tearDown(() => db.close());

  test('a dangerous visit recorded offline still fires, then syncs', () async {
    sync.forceOffline = true;
    expect(sync.isOnline, isFalse);

    final mother = (await db.allMothers()).firstWhere((m) => m.id == 'm-001');
    final profile = RiskProfile(
      age: mother.age,
      gravida: mother.gravida,
      prevComplications: const [],
      lmp: mother.lmp,
    );

    // 1. The alert is computed on-device, with no network involved at all.
    final alerts = engine.evaluateVisit(
      const RiskInput(bpSys: 165, bpDia: 110, dangerSigns: ['headache']),
      profile,
    );
    expect(alerts.any((a) => a.ruleId == 'R2' && a.isRed), isTrue,
        reason: 'the red pre-eclampsia rule must fire offline');
    expect(RiskEngine.levelOf(alerts), 'red');

    // 2. The visit writes to SQLite and returns without awaiting anything.
    final visitId = await repo.saveVisit(
      motherId: mother.id,
      visitNo: 99,
      recordedBy: SeedData.ashaName,
      bpSys: 165,
      bpDia: 110,
      dangerSigns: const ['headache'],
    );
    expect(await db.lastVisit(mother.id), isNotNull);

    await repo.saveAlerts(mother.id, visitId, alerts);
    expect((await db.findMother(mother.id))!.riskLevel, 'red');

    // 3. The referral is created locally and works fully offline.
    await repo.createReferral(
      motherId: mother.id,
      facility: 'Government PHC, Hosahalli',
      reasonKn: alerts.first.messageKn,
      reasonEn: alerts.first.messageEn,
      visitId: visitId,
    );
    final referrals = await db.select(db.referrals).get();
    expect(referrals, hasLength(1));

    // 4. Everything is queued, and the home banner count reflects it.
    final pendingBefore = await db.watchPendingCount().first;
    expect(pendingBefore, greaterThanOrEqualTo(3),
        reason: 'visit, alert and referral must all be queued');

    // Draining while offline must move nothing.
    expect(await worker.drain(), 0);
    expect(await db.watchPendingCount().first, pendingBefore);

    // 5. Come back online and the queue drains.
    sync.forceOffline = false;
    expect(sync.isOnline, isTrue);
    await worker.drain();

    expect(await db.watchPendingCount().first, 0,
        reason: 'the outbox must be empty once back online');
    expect((await db.lastVisit(mother.id))!.synced, isTrue);
  });

  test('a visit is never blocked by missing GPS', () async {
    final id = await repo.saveVisit(
      motherId: 'm-002',
      visitNo: 99,
      recordedBy: SeedData.ashaName,
      bpSys: 118,
      bpDia: 74,
      gpsLat: null,
      gpsLng: null,
    );
    final visit = await db.lastVisit('m-002');
    expect(visit!.id, id);
    expect(visit.gpsLat, isNull);
  });

  test('a correction is a new row, never an update', () async {
    final first = await repo.saveVisit(
      motherId: 'm-004',
      visitNo: 99,
      recordedBy: SeedData.ashaName,
      bpSys: 200,
      bpDia: 60,
    );
    final corrected = await repo.saveVisit(
      motherId: 'm-004',
      visitNo: 99,
      recordedBy: SeedData.ashaName,
      bpSys: 120,
      bpDia: 80,
      correctsId: first,
    );

    final all = await db.visitsFor('m-004');
    // Both rows survive — that is the medico-legal audit trail.
    expect(all.where((v) => v.id == first), hasLength(1));
    expect(all.where((v) => v.id == corrected), hasLength(1));
    expect(all.firstWhere((v) => v.id == corrected).correctsId, first);
  });
}
