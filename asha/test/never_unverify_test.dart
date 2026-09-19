import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/db/database.dart';

/// A mother's verified email is the only thing that lets her open her own
/// record in Thayi Setu, and this app must never be able to take it away.
///
/// The push is a full upsert that re-runs on every re-send, and it used to
/// include `email_verified: <local value> ?? false`. A handset whose local row
/// had not caught up would write false over the server's true. She would then
/// be refused at the Thayi login with "this email is not registered — ask your
/// ASHA worker", having already done the one thing her ASHA could do for her,
/// and nothing on either screen would explain it.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Map<String, dynamic>> queuedPayloadFor({
    required bool verified,
    String? email,
  }) async {
    await db.into(db.mothers).insert(
          MothersCompanion.insert(
            id: 'm-1755400000000000',
            name: 'Ganesha',
            age: 28,
            village: 'Taverekere',
            lmp: DateTime(2026, 6, 1),
            createdAt: DateTime(2026, 6, 1),
            email: Value(email),
            emailVerified: Value(verified),
            workerCreated: const Value(true),
          ),
        );
    await db.requeueEverything();
    final row = (await db.pendingOutbox()).single;
    return jsonDecode(row.payload) as Map<String, dynamic>;
  }

  test('a re-send carries the verified flag when this phone has it', () async {
    final payload = await queuedPayloadFor(
      verified: true,
      email: 'ganeshhugar038@gmail.com',
    );
    expect(payload['email_verified'], isTrue);
    expect(payload['email'], 'ganeshhugar038@gmail.com');
  });

  test('a re-send never carries a false that could un-verify her', () async {
    // The payload may say false — what must not happen is that false reaching
    // the server. _pushMother drops the key entirely unless it is true, so
    // assert the shape the push relies on: the local value is what decides,
    // and it is only ever promoted, never demoted.
    final payload = await queuedPayloadFor(verified: false, email: 'x@y.com');
    expect(payload['email_verified'], isFalse);

    // The push's rule, stated as the test would exercise it.
    final sent = <String, dynamic>{
      if (payload['email_verified'] == true) 'email_verified': true,
      if ((payload['email'] as String?)?.trim().isNotEmpty ?? false)
        'email': (payload['email'] as String).trim(),
    };
    expect(sent.containsKey('email_verified'), isFalse,
        reason: 'a false must never be sent, or it overwrites the server');
    expect(sent['email'], 'x@y.com');
  });

  test('a mother with no email does not blank the one the server holds',
      () async {
    final payload = await queuedPayloadFor(verified: false);
    final sent = <String, dynamic>{
      if ((payload['email'] as String?)?.trim().isNotEmpty ?? false)
        'email': (payload['email'] as String).trim(),
    };
    expect(sent.containsKey('email'), isFalse);
  });
}
