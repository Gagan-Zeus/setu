import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/db/database.dart';

/// The handset seeds itself with a practice caseload whose ids (`m-001`) are
/// the same ones the server dataset uses. Pushing those rows writes practice
/// readings over a different, real woman who happens to share the id — which is
/// exactly what happened: four flat 110/70 visits landed in the middle of
/// Lakshmi's rising blood pressure and ruined the trend.
///
/// Only rows a worker actually entered may be re-sent. Those carry a
/// microsecond stamp; the seeded ones do not.
void main() {
  test('seeded practice rows are never re-sent', () {
    for (final id in ['m-001', 'm-025', 'v-m-001-1', 'a-m-002-1']) {
      expect(AppDatabase.isWorkerCreatedForTest(id), isFalse, reason: id);
    }
  });

  test('rows the worker created are re-sent', () {
    for (final id in [
      'm-1755400000000000',
      'v-m-1755400000000000-1755400000000001',
      'r-m-1755400000000000-1755400000000002',
    ]) {
      expect(AppDatabase.isWorkerCreatedForTest(id), isTrue, reason: id);
    }
  });

  group('re-sending does not duplicate the queue', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> addMother(String id) => db.into(db.mothers).insert(
          MothersCompanion.insert(
            id: id,
            name: 'Test',
            age: 24,
            village: 'V',
            lmp: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            subCentre: const Value('Benagalore'),
            workerCreated: const Value(true),
          ),
        );

    test('pressing Send everything again twice leaves one entry per record',
        () async {
      // The bug this covers: requeueEverything() called enqueue(), which mints
      // a new outbox id every time, so each press appended a second, third,
      // fourth identical row. Nothing was duplicated on the server — the push
      // is an upsert — but the Sync Status screen, whose entire job is to say
      // what has not been sent, showed the caseload once per press, which
      // reads as the data itself having been duplicated.
      await addMother('m-1755400000000000');
      await addMother('m-1755400000000001');

      await db.requeueEverything();
      await db.requeueEverything();
      await db.requeueEverything();

      final queued = await db.pendingOutbox();
      expect(queued.length, 2);
      expect(
        queued.map((o) => o.recordId).toSet(),
        {'m-1755400000000000', 'm-1755400000000001'},
      );
    });

    test('re-queueing clears the copies an earlier press left behind',
        () async {
      await addMother('m-1755400000000000');

      // Three rows for one mother, as a phone that has been through the old
      // code is carrying right now.
      for (var i = 0; i < 3; i++) {
        await db.enqueue(
          entityTable: 'mothers',
          recordId: 'm-1755400000000000',
          operation: 'insert',
          payload: const {'id': 'm-1755400000000000'},
        );
      }
      expect((await db.pendingOutbox()).length, 3);

      await db.requeueEverything();

      final queued = await db.pendingOutbox();
      expect(queued.length, 1);
      expect(queued.single.status, 'pending');
    });

    test('a mother pulled from the server is never re-sent', () async {
      // She was registered on another handset and arrived in a pull. Pushing
      // her back would write this phone's copy over the server's — including
      // her name, sub-centre and the ASHA she is assigned to. The old rule
      // asked _isWorkerCreated, which reads the last '-' group of the id, and
      // roughly one server uuid in three hundred ends in twelve digits.
      await db.into(db.mothers).insert(
            MothersCompanion.insert(
              id: '69bb75c4-553a-5797-817a-352198664659',
              name: 'Pulled',
              age: 27,
              village: 'V',
              lmp: DateTime(2026, 1, 1),
              createdAt: DateTime(2026, 1, 1),
              workerCreated: const Value(false),
            ),
          );
      await addMother('m-1755400000000000');

      await db.requeueEverything();

      final queued = await db.pendingOutbox();
      expect(queued.map((o) => o.recordId), ['m-1755400000000000']);
    });

    test('a failed row goes back to pending rather than gaining a twin',
        () async {
      await addMother('m-1755400000000000');
      await db.requeueEverything();

      final first = (await db.pendingOutbox()).single;
      await db.bumpRetry(first.id, 'RLS refused it');
      expect((await db.pendingOutbox()).single.status, 'failed');

      await db.requeueEverything();

      final again = await db.pendingOutbox();
      expect(again.length, 1);
      expect(again.single.id, first.id);
      expect(again.single.status, 'pending');
      expect(again.single.retryCount, 0);
      expect(again.single.lastError, isNull);
    });
  });
}
