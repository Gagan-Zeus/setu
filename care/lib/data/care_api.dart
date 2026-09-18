import 'models.dart';
import 'mock_data.dart';

/// The typed API surface every screen talks to. Two implementations sit behind
/// it: [MockCareApi] for a demo with no backend, and SupabaseCareApi for the
/// real shared platform. No screen knows which one it has.
abstract class CareApi {
  Future<List<Mother>> getMothers();
  Future<Mother?> getMother(String id);
  Future<List<AncVisit>> getVisits(String motherId);
  Future<List<Lab>> getLabs(String motherId);
  Future<List<ClinicalNote>> getNotes(String motherId);
  Future<List<AshaWorker>> getAshas();
  Future<List<Task>> getTasks({String? motherId});
  Future<List<Referral>> getReferrals();
  Future<DashboardSummary> getDashboard();

  /// The ASHA is resolved from the mother's assignment, never chosen.
  Future<Task> assignTask({
    required String motherId,
    required TaskType type,
    required String instruction,
    required DateTime dueDate,
    required TaskPriority priority,
  });

  Future<ClinicalNote> addNote({
    required String motherId,
    required String body,
  });

  /// Synchronous lookup for rows already in hand. Null before the list loads.
  Mother? motherOf(String id);
}

/// In-memory demo data, with a short artificial delay. Used when there is no
/// session, so the app still demos with no backend at all.
class MockCareApi implements CareApi {
  MockCareApi() {
    _mothers = MockData.mothers;
    _tasks = MockData.seedTasks(_mothers);
    _referrals = MockData.seedReferrals(_mothers);
    for (final m in _mothers) {
      _visits[m.id] = MockData.visitsFor(m);
      _labs[m.id] = MockData.labsFor(m);
      _notes[m.id] = MockData.notesFor(m);
    }
  }

  static const _latency = Duration(milliseconds: 320);

  late List<Mother> _mothers;
  late List<Task> _tasks;
  late List<Referral> _referrals;
  final Map<String, List<AncVisit>> _visits = {};
  final Map<String, List<Lab>> _labs = {};
  final Map<String, List<ClinicalNote>> _notes = {};

  Future<T> _delayed<T>(T value) => Future.delayed(_latency).then((_) => value);

  @override
  Future<List<Mother>> getMothers() => _delayed(List.unmodifiable(_mothers));

  @override
  Future<Mother?> getMother(String id) =>
      _delayed(_mothers.where((m) => m.id == id).firstOrNull);

  @override
  Future<List<AncVisit>> getVisits(String motherId) =>
      _delayed(List.unmodifiable(_visits[motherId] ?? const []));

  @override
  Future<List<Lab>> getLabs(String motherId) =>
      _delayed(List.unmodifiable(_labs[motherId] ?? const []));

  @override
  Future<List<ClinicalNote>> getNotes(String motherId) =>
      _delayed(List.unmodifiable(_notes[motherId] ?? const []));

  @override
  Future<List<AshaWorker>> getAshas() => _delayed(MockData.ashas);

  @override
  Future<List<Task>> getTasks({String? motherId}) => _delayed(
        List.unmodifiable(
          motherId == null
              ? _tasks
              : _tasks.where((t) => t.motherId == motherId),
        ),
      );

  @override
  Future<Task> assignTask({
    required String motherId,
    required TaskType type,
    required String instruction,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    final mother = _mothers.firstWhere((m) => m.id == motherId);
    final task = Task(
      id: 'task-${DateTime.now().microsecondsSinceEpoch}',
      motherId: motherId,
      createdBy: MockData.doctorName,
      assignedToAshaId: mother.ashaId,
      assignedToAshaName: mother.ashaName,
      type: type,
      instruction: instruction,
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.open,
      createdAt: DateTime.now(),
    );
    await Future.delayed(_latency);
    _tasks = [task, ..._tasks];
    return task;
  }

  @override
  Future<List<Referral>> getReferrals() =>
      _delayed(List.unmodifiable(_referrals));

  @override
  Future<ClinicalNote> addNote({
    required String motherId,
    required String body,
  }) async {
    final note = ClinicalNote(
      id: 'note-${DateTime.now().microsecondsSinceEpoch}',
      motherId: motherId,
      authorName: MockData.doctorName,
      body: body,
      createdAt: DateTime.now(),
    );
    await Future.delayed(_latency);
    _notes[motherId] = [note, ...?_notes[motherId]];
    return note;
  }

  @override
  Future<DashboardSummary> getDashboard() async {
    await Future.delayed(_latency);

    final needsAttention =
        _mothers.where((m) => m.riskLevel != RiskLevel.green).toList()
          // Most severe first, then the longest without a visit.
          ..sort((a, b) {
            final byRisk = b.riskLevel.index.compareTo(a.riskLevel.index);
            if (byRisk != 0) return byRisk;
            final ad = a.lastVisitDate ?? DateTime(2000);
            final bd = b.lastVisitDate ?? DateTime(2000);
            return ad.compareTo(bd);
          });

    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final recent = <AncVisit>[];
    for (final list in _visits.values) {
      recent.addAll(list.where((v) => v.visitDate.isAfter(cutoff)));
    }
    recent.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    // If nothing landed in the last 48 hours the feed would be empty and the
    // panel would look broken, so fall back to the most recent handful.
    if (recent.isEmpty) {
      final all = _visits.values.expand((e) => e).toList()
        ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
      recent.addAll(all.take(8));
    }

    final byVillage = <String, int>{};
    for (final m in _mothers) {
      byVillage[m.village] = (byVillage[m.village] ?? 0) + 1;
    }

    return DashboardSummary(
      totalMothers: _mothers.length,
      highRisk: _mothers.where((m) => m.riskLevel != RiskLevel.green).length,
      visitsOverdue: _mothers.where((m) => m.isOverdue).length,
      openReferrals:
          _referrals.where((r) => r.status == ReferralStatus.open).length,
      needsAttention: needsAttention.take(8).toList(),
      recentVisits: recent.take(8).toList(),
      registrationsByVillage: byVillage,
    );
  }

  @override
  Mother? motherOf(String id) => _mothers.where((m) => m.id == id).firstOrNull;
}
