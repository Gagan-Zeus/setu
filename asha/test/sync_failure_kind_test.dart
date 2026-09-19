import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/sync_service.dart';
import 'package:setu_asha/db/database.dart';

/// A row the server refused and a row that never reached the server are not
/// the same thing, and the queue used to show them identically: both went red,
/// both spent a retry. One of them she can do something about — the message
/// now names what — and the other is just a phone with no signal, which is the
/// ordinary state of the job and not a failure to report.
class _Throwing implements SyncService {
  _Throwing(this.error);

  final Object error;
  bool _forceOffline = false;

  @override
  bool get forceOffline => _forceOffline;

  @override
  set forceOffline(bool value) => _forceOffline = value;

  @override
  set networkUp(bool value) {}

  @override
  bool get isOnline => !_forceOffline;

  @override
  Future<void> push(OutboxData item) async => throw error;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.mothers).insert(
          MothersCompanion.insert(
            id: 'm-1755400000000000',
            name: 'Test',
            age: 24,
            village: 'V',
            lmp: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            subCentre: const Value('Benagalore'),
          ),
        );
    await db.requeueEverything();
  });

  tearDown(() => db.close());

  Future<OutboxData> only() async => (await db.select(db.outbox).get()).single;

  test('a row that never reached the server stays pending', () async {
    await SyncWorker(
      db,
      _Throwing(const SyncFailure('SocketException: Failed host lookup')),
    ).drain();

    final row = await only();
    expect(row.status, 'pending');
    expect(row.retryCount, 0);
  });

  test('a row the server refused is marked failed, with the reason', () async {
    await SyncWorker(
      db,
      _Throwing(const SyncFailure(
        'Signed in as someone@example.com, which is not registered as an '
        'ASHA worker.',
      )),
    ).drain();

    final row = await only();
    expect(row.status, 'failed');
    expect(row.retryCount, 1);
    expect(row.lastError, contains('not registered as an ASHA worker'));
  });

  test('forcing offline pushes nothing at all', () async {
    final service = _Throwing(const SyncFailure('should never be reached'))
      ..forceOffline = true;
    expect(service.isOnline, isFalse);
    expect(await SyncWorker(db, service).drain(), 0);
    expect((await only()).status, 'pending');
  });
}
