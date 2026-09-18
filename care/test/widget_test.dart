import 'package:flutter_test/flutter_test.dart';
import 'package:setu_care/data/care_api.dart';
import 'package:setu_care/data/models.dart';

void main() {
  late MockCareApi api;

  setUp(() => api = MockCareApi());

  group('seed data', () {
    test('25 mothers across 4 villages', () async {
      final mothers = await api.getMothers();
      expect(mothers, hasLength(25));
      expect({for (final m in mothers) m.village}, hasLength(4));
    });

    test('four red and six amber, the rest green', () async {
      final mothers = await api.getMothers();
      expect(mothers.where((m) => m.riskLevel == RiskLevel.red), hasLength(4));
      expect(
          mothers.where((m) => m.riskLevel == RiskLevel.amber), hasLength(6));
      expect(
          mothers.where((m) => m.riskLevel == RiskLevel.green), hasLength(15));
    });

    test('every flagged mother says why she is flagged', () async {
      final mothers = await api.getMothers();
      for (final m in mothers.where((m) => m.riskLevel != RiskLevel.green)) {
        expect(m.riskReasons, isNotEmpty, reason: m.name);
      }
    });

    test('mothers past the first trimester have 4-8 visits', () async {
      final mothers = await api.getMothers();
      for (final m in mothers.where((m) => m.gestationalWeeks >= 16)) {
        final visits = await api.getVisits(m.id);
        expect(visits.length, inInclusiveRange(4, 8), reason: m.name);
      }
    });

    test('the red mothers carry readings that justify the flag', () async {
      final mothers = await api.getMothers();
      final parvathi = mothers.firstWhere((m) => m.name == 'Parvathi');
      final latest = (await api.getVisits(parvathi.id)).first;
      expect(latest.bpSys, greaterThanOrEqualTo(160));
      expect(latest.dangerSigns, contains('headache'));

      final sharada = mothers.firstWhere((m) => m.name == 'Sharada');
      expect((await api.getVisits(sharada.id)).first.hb, lessThan(7));
    });
  });

  group('assign task', () {
    // The rule the brief says to check: the ASHA is resolved from the
    // mother's assignment, never picked by the doctor.
    test('resolves the ASHA from the mother, not from a choice', () async {
      final mothers = await api.getMothers();
      final mother = mothers.firstWhere((m) => m.name == 'Parvathi');

      final task = await api.assignTask(
        motherId: mother.id,
        type: TaskType.recheckBp,
        instruction: 'Recheck BP today.',
        dueDate: DateTime.now(),
        priority: TaskPriority.high,
      );

      expect(task.assignedToAshaId, mother.ashaId);
      expect(task.assignedToAshaName, mother.ashaName);
    });

    test('a task for a different mother goes to a different ASHA', () async {
      final mothers = await api.getMothers();
      final a = mothers.firstWhere((m) => m.village == 'Hosahalli');
      final b = mothers.firstWhere((m) => m.village == 'Madapura');
      expect(a.ashaId, isNot(b.ashaId));

      final ta = await api.assignTask(
        motherId: a.id,
        type: TaskType.revisit,
        instruction: 'x',
        dueDate: DateTime.now(),
        priority: TaskPriority.normal,
      );
      final tb = await api.assignTask(
        motherId: b.id,
        type: TaskType.revisit,
        instruction: 'x',
        dueDate: DateTime.now(),
        priority: TaskPriority.normal,
      );
      expect(ta.assignedToAshaId, a.ashaId);
      expect(tb.assignedToAshaId, b.ashaId);
    });

    test('the new task appears against that mother immediately', () async {
      final mothers = await api.getMothers();
      final mother = mothers.first;
      final before = (await api.getTasks(motherId: mother.id)).length;

      await api.assignTask(
        motherId: mother.id,
        type: TaskType.counselling,
        instruction: 'Talk about nutrition.',
        dueDate: DateTime.now(),
        priority: TaskPriority.normal,
      );

      final after = await api.getTasks(motherId: mother.id);
      expect(after.length, before + 1);
      expect(after.first.createdBy, isNotEmpty);
    });
  });

  group('dashboard', () {
    test('counts match the underlying data', () async {
      final d = await api.getDashboard();
      final mothers = await api.getMothers();
      expect(d.totalMothers, mothers.length);
      expect(d.highRisk,
          mothers.where((m) => m.riskLevel != RiskLevel.green).length);
      expect(d.openReferrals, greaterThan(0));
    });

    test('needs-attention is most severe first', () async {
      final d = await api.getDashboard();
      expect(d.needsAttention.first.riskLevel, RiskLevel.red);
      for (final m in d.needsAttention) {
        expect(m.riskLevel, isNot(RiskLevel.green));
      }
    });

    test('recent activity is never empty', () async {
      // An empty feed reads as broken on a projector.
      final d = await api.getDashboard();
      expect(d.recentVisits, isNotEmpty);
    });
  });
}
