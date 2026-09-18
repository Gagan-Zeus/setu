import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/seed_data.dart';
import 'package:setu_asha/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedData.seedIfEmpty(db);
  });

  tearDown(() => db.close());

  test('seeds a full caseload', () async {
    final mothers = await db.allMothers();
    expect(mothers.length, 20);
  });

  test('seeds three mothers already carrying red flags', () async {
    final mothers = await db.allMothers();
    final red = mothers.where((m) => m.riskLevel == 'red');
    expect(red.length, 3);
  });

  test('seeds every open task, not just the first', () async {
    final open = await db.watchTasks('open').first;
    expect(open.length, 5);
  });

  test('doctor-assigned tasks sort before system and self', () async {
    final open = await db.watchTasks('open').first;
    expect(open.first.origin, 'doctor');
  });

  test('seeds done and missed tasks too', () async {
    expect((await db.watchTasks('done').first).length, 1);
    expect((await db.watchTasks('missed').first).length, 1);
  });

  test('seeds visits against mothers', () async {
    final visits = await db.visitsFor('m-003');
    expect(visits, isNotEmpty);
  });

  test('seeding twice does not duplicate', () async {
    await SeedData.seedIfEmpty(db);
    expect((await db.allMothers()).length, 20);
  });
}
