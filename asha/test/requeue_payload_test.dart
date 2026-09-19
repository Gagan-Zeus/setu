import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/db/database.dart';

/// "Send everything again" has to send something the server will take.
///
/// It is the one button whose entire job is to rescue rows stranded on a
/// handset, and it queued the visit's timestamp under 'created_at' while
/// _pushVisit reads 'client_created_at' — a NOT NULL column. The push found
/// nothing, sent an explicit null, and every rescued visit was refused with
/// 23502. The rescue button could not rescue a visit, and said it had.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<Map<String, dynamic>> requeuedFor(String table) async {
    final rows = await db.pendingOutbox();
    return jsonDecode(rows.firstWhere((r) => r.entityTable == table).payload)
        as Map<String, dynamic>;
  }

  Future<void> seedOne() async {
    final now = DateTime.now();
    await db.into(db.mothers).insert(
          MothersCompanion.insert(
            id: 'm-1755400000000000',
            name: 'Lakshmi',
            age: 24,
            village: 'Halebeedu',
            lmp: DateTime(2025, 12, 18),
            createdAt: now,
            homeLat: const Value(13.2158),
            homeLng: const Value(75.9932),
            homeNote: const Value('Third house past the temple, blue door'),
            homeLocatedAt: Value(now),
            workerCreated: const Value(true),
          ),
        );
    await db.into(db.ancVisits).insert(
          AncVisitsCompanion.insert(
            id: 'v-m-1755400000000000-1',
            motherId: 'm-1755400000000000',
            visitNo: 1,
            visitDate: DateTime(2026, 7, 9),
            recordedBy: 'Gagana',
            clientCreatedAt: now,
            fetalMovement: const Value(true),
            photoPaths: Value(jsonEncode(const ['/tmp/card.jpg'])),
            workerCreated: const Value(true),
          ),
        );
  }

  test('a re-sent visit carries client_created_at, not created_at', () async {
    await seedOne();
    await db.requeueEverything();
    final payload = await requeuedFor('anc_visits');

    expect(payload.containsKey('client_created_at'), isTrue,
        reason: 'client_created_at is NOT NULL on anc_visits. Queueing it as '
            '"created_at" sends an explicit null and the visit is refused '
            'with 23502 — while the handset reports it sent.');
    expect(payload['client_created_at'], isNotNull);
  });

  test('a re-sent visit does not blank what it cannot see', () async {
    await seedOne();
    await db.requeueEverything();
    final payload = await requeuedFor('anc_visits');

    // The push is a full upsert, so a key it reads and cannot find goes up as
    // a null and erases the server's value.
    expect(payload['fetal_movement'], isTrue);
    expect(payload['photo_paths'], const ['/tmp/card.jpg']);
    expect(payload['danger_signs'], isA<List<dynamic>>());
  });

  test('a re-sent mother carries the landmark and when it was pinned',
      () async {
    await seedOne();
    await db.requeueEverything();
    final payload = await requeuedFor('mothers');

    expect(payload['home_note'], 'Third house past the temple, blue door');
    expect(payload['home_located_at'], isNotNull);
  });
}
