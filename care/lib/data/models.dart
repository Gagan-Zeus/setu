/// Data shapes exactly as specified in the brief. Nothing here knows about
/// widgets or about a backend.
library;

enum RiskLevel { green, amber, red }

RiskLevel riskFromString(String value) => switch (value) {
      'red' => RiskLevel.red,
      'amber' => RiskLevel.amber,
      _ => RiskLevel.green,
    };

class Mother {
  const Mother({
    required this.id,
    required this.name,
    required this.age,
    required this.husbandName,
    required this.phone,
    required this.village,
    required this.subCentre,
    required this.ashaId,
    required this.ashaName,
    required this.lmp,
    required this.gravida,
    required this.para,
    required this.bloodGroup,
    required this.heightCm,
    required this.isBpl,
    required this.prevComplications,
    required this.riskLevel,
    required this.riskReasons,
    required this.lastVisitDate,
  });

  final String id;
  final String name;
  final int age;
  final String husbandName;
  final String phone;
  final String village;
  final String subCentre;
  final String ashaId;
  final String ashaName;
  final DateTime lmp;
  final int gravida;
  final int para;
  final String bloodGroup;
  final double heightCm;
  final bool isBpl;
  final List<String> prevComplications;
  final RiskLevel riskLevel;
  final List<String> riskReasons;
  final DateTime? lastVisitDate;

  DateTime get edd => lmp.add(const Duration(days: 280));

  int get gestationalWeeks =>
      (DateTime.now().difference(lmp).inDays / 7).floor().clamp(0, 45);

  int get gestationalDays =>
      DateTime.now().difference(lmp).inDays.remainder(7).clamp(0, 6);

  /// A visit is overdue once nothing has been recorded for 30 days.
  bool get isOverdue {
    final last = lastVisitDate;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 30;
  }
}

enum VisitSource { asha, doctor }

class AncVisit {
  const AncVisit({
    required this.id,
    required this.motherId,
    required this.visitNo,
    required this.visitDate,
    required this.recordedBy,
    required this.source,
    this.bpSys,
    this.bpDia,
    this.weightKg,
    this.fundalHeightCm,
    this.hb,
    this.urineAlbumin,
    this.fetalHr,
    this.fetalMovement,
    this.dangerSigns = const [],
    this.ifaTaken = false,
    this.calciumTaken = false,
    this.ttDoseGiven,
    this.notes,
  });

  final String id;
  final String motherId;
  final int visitNo;
  final DateTime visitDate;
  final String recordedBy;
  final VisitSource source;
  final int? bpSys;
  final int? bpDia;
  final double? weightKg;
  final double? fundalHeightCm;
  final double? hb;
  final String? urineAlbumin;
  final int? fetalHr;
  final bool? fetalMovement;
  final List<String> dangerSigns;
  final bool ifaTaken;
  final bool calciumTaken;
  final int? ttDoseGiven;
  final String? notes;
}

class Lab {
  const Lab({
    required this.id,
    required this.motherId,
    required this.type,
    required this.value,
    required this.unit,
    required this.resultDate,
    required this.orderedBy,
    this.reportUrl,
  });

  final String id;
  final String motherId;
  final String type;
  final String value;
  final String unit;
  final DateTime resultDate;
  final String orderedBy;
  final String? reportUrl;
}

enum TaskStatus { open, done, missed }

enum TaskPriority { normal, high }

/// The five task types the brief specifies for the assign modal.
enum TaskType { revisit, recheckBp, confirmMedication, bringToPhc, counselling }

String taskTypeLabel(TaskType t) => switch (t) {
      TaskType.revisit => 'Revisit',
      TaskType.recheckBp => 'Recheck BP',
      TaskType.confirmMedication => 'Confirm medication taken',
      TaskType.bringToPhc => 'Bring to PHC',
      TaskType.counselling => 'Counselling',
    };

class Task {
  const Task({
    required this.id,
    required this.motherId,
    required this.createdBy,
    required this.assignedToAshaId,
    required this.assignedToAshaName,
    required this.type,
    required this.instruction,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String motherId;
  final String createdBy;
  final String assignedToAshaId;
  final String assignedToAshaName;
  final TaskType type;
  final String instruction;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
}

enum ReferralStatus { open, arrived, closed }

class Referral {
  const Referral({
    required this.id,
    required this.motherId,
    required this.fromUser,
    required this.toFacility,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.outcomeNote,
  });

  final String id;
  final String motherId;
  final String fromUser;
  final String toFacility;
  final String reason;
  final ReferralStatus status;
  final DateTime createdAt;
  final String? outcomeNote;
}

class AshaWorker {
  const AshaWorker({
    required this.id,
    required this.name,
    required this.phone,
    required this.subCentre,
    required this.village,
    required this.assignedMotherCount,
    required this.visitsThisMonth,
    required this.openTasks,
  });

  final String id;
  final String name;
  final String phone;
  final String subCentre;
  final String village;
  final int assignedMotherCount;
  final int visitsThisMonth;
  final int openTasks;
}

class ClinicalNote {
  const ClinicalNote({
    required this.id,
    required this.motherId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String motherId;
  final String authorName;
  final String body;
  final DateTime createdAt;
}

/// Everything the dashboard needs, resolved in one call.
class DashboardSummary {
  const DashboardSummary({
    required this.totalMothers,
    required this.highRisk,
    required this.visitsOverdue,
    required this.openReferrals,
    required this.needsAttention,
    required this.recentVisits,
    required this.registrationsByVillage,
  });

  final int totalMothers;
  final int highRisk;
  final int visitsOverdue;
  final int openReferrals;
  final List<Mother> needsAttention;
  final List<AncVisit> recentVisits;
  final Map<String, int> registrationsByVillage;
}
