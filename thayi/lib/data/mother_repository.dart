import 'mock_data.dart';
import 'models.dart';

/// The only contract the UI knows about. A Supabase implementation will be
/// dropped in behind this interface later - nothing above this line changes.
abstract class MotherRepository {
  Future<Mother> getMother();
  Future<List<Checkup>> getCheckups();
  Future<HealthRecord> getHealthRecord();
  Future<List<Scheme>> getSchemes();
  Future<BabyRecord> getBabyRecord();
}

class MockMotherRepository implements MotherRepository {
  const MockMotherRepository({this.delay = const Duration(milliseconds: 450)});

  final Duration delay;

  Future<T> _withDelay<T>(T value) => Future.delayed(delay).then((_) => value);

  @override
  Future<Mother> getMother() => _withDelay(MockData.mother);

  @override
  Future<List<Checkup>> getCheckups() => _withDelay(MockData.checkups);

  @override
  Future<HealthRecord> getHealthRecord() => _withDelay(MockData.healthRecord);

  @override
  Future<List<Scheme>> getSchemes() =>
      _withDelay(MockData.schemesFor(MockData.mother));

  @override
  Future<BabyRecord> getBabyRecord() => _withDelay(MockData.babyRecord);
}
