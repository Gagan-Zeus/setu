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
}
