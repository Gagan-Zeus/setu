import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/seed_data.dart';
import 'package:setu_asha/db/database.dart';

/// The app used to write twenty invented women into every handset the first
/// time it ran. They were only ever on the phone, so the website showed the
/// mothers who existed and the app showed twenty who did not, and a mother
/// registered for real sat in a list of strangers.
///
/// Removing them is easy to get wrong in two specific ways, both of which
/// follow from keying on the shape of a row's own id instead of on the mother
/// it belongs to. Both are covered here.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedData.seedIfEmpty(db);
  });

  tearDown(() => db.close());

  Future<void> addRealMother(String id) => db.into(db.mothers).insert(
        MothersCompanion.insert(
          id: id,
          name: 'Ganesha',
          age: 28,
          village: 'Taverekere',
          lmp: DateTime(2026, 2, 1),
          createdAt: DateTime(2026, 2, 1),
          subCentre: const Value('Benagalore'),
          workerCreated: const Value(true),
        ),
      );

  test('the practice caseload goes and a real mother stays', () async {
    await addRealMother('m-1755400000000000');
    expect((await db.allMothers()).length, 21);

    final removed = await db.purgePracticeCaseload();

    expect(removed, 20);
    final left = await db.allMothers();
    expect(left.map((m) => m.id), ['m-1755400000000000']);
    expect(left.single.workerCreated, isTrue);
  });

  test('a visit recorded against a practice mother is not left behind',
      () async {
    // 'v-m-003-<microseconds>' — the last '-' group is a microsecond stamp, so
    // the id-shape test reads this as worker-made and would keep it. Its
    // payload carries mother_id 'm-003', which uuidFor maps onto whichever
    // real woman holds that id on the server, and the push then also writes
    // last_visit_date onto her. That is how four flat practice readings once
    // landed in the middle of a real rising blood pressure trend.
    await db.into(db.ancVisits).insert(
          AncVisitsCompanion.insert(
            id: 'v-m-003-1755400000000001',
            motherId: 'm-003',
            visitNo: 5,
            visitDate: DateTime(2026, 2, 1),
            recordedBy: 'Gagana',
            clientCreatedAt: DateTime(2026, 2, 1),
            workerCreated: const Value(true),
          ),
        );
    await db.enqueue(
      entityTable: 'anc_visits',
      recordId: 'v-m-003-1755400000000001',
      operation: 'insert',
      payload: const {'id': 'v-m-003-1755400000000001', 'mother_id': 'm-003'},
    );

    await db.purgePracticeCaseload();

    expect(await db.visitsFor('m-003'), isEmpty);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('a real alert survives, despite its id looking seeded', () async {
    // 'a-<mother>-<micros>-0' — the last '-' group is the alert's index within
    // the visit, so the id-shape test reads every alert as seeded and would
    // throw away a red pre-eclampsia alert for a mother the worker really
    // registered. requeueEverything covers only mothers and visits, so there
    // would be no way to put it back.
    await addRealMother('m-1755400000000000');
    await db.into(db.alerts).insert(
          AlertsCompanion.insert(
            id: 'a-m-1755400000000000-1755400000000002-0',
            motherId: 'm-1755400000000000',
            ruleId: 'preeclampsia',
            severity: 'red',
            messageKn: 'ಅಪಾಯ',
            messageEn: 'Danger',
            createdAt: DateTime(2026, 2, 1),
          ),
        );

    await db.purgePracticeCaseload();

    final left = await db.select(db.alerts).get();
    expect(left.map((a) => a.ruleId), ['preeclampsia']);
  });

  test('a mother pulled from the server is not relabelled as this phone\'s',
      () async {
    // The purge runs on every start. It backfills the provenance flag for rows
    // that predate the column, and if that write is not scoped it relabels
    // every pulled mother as worker-created the next morning — after which
    // requeueEverything pushes all of them back over the server's own copies,
    // overwriting name, sub-centre and assigned ASHA with this handset's.
    await addRealMother('m-1755400000000000');
    await db.purgePracticeCaseload();

    await db.into(db.mothers).insert(
          MothersCompanion.insert(
            id: 'a984a7cb-40f2-5f0d-9a12-6bdc674d8a48',
            name: 'Pulled from the server',
            age: 24,
            village: 'Taverekere',
            lmp: DateTime(2026, 2, 1),
            createdAt: DateTime(2026, 2, 1),
            workerCreated: const Value(false),
          ),
        );

    await db.purgePracticeCaseload();

    final pulled = (await db.allMothers())
        .firstWhere((m) => m.id == 'a984a7cb-40f2-5f0d-9a12-6bdc674d8a48');
    expect(pulled.workerCreated, isFalse);

    await db.requeueEverything();
    expect(
      (await db.pendingOutbox()).map((o) => o.recordId),
      ['m-1755400000000000'],
    );
  });

  test('running it again on a clean phone does nothing', () async {
    await addRealMother('m-1755400000000000');
    await db.purgePracticeCaseload();
    expect(await db.purgePracticeCaseload(), 0);
    expect((await db.allMothers()).length, 1);
  });
}
