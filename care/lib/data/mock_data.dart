import 'dart:math';

import 'models.dart';

/// All demo data lives here so it can be edited in one place before a demo.
/// 25 mothers across 4 villages: 4 red, 6 amber, the rest green, each with
/// 4-8 visits of realistic vitals.
class MockData {
  MockData._();

  static const facility = 'PHC Hosahalli, Nanjangud Taluk';
  static const doctorName = 'Dr. Sridevi R';
  static const doctorDesignation = 'Medical Officer';

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static final ashas = <AshaWorker>[
    const AshaWorker(
      id: 'a-1',
      name: 'Sarojamma',
      phone: '+91 98450 12345',
      subCentre: 'Hosahalli Sub-centre',
      village: 'Hosahalli',
      assignedMotherCount: 7,
      visitsThisMonth: 11,
      openTasks: 3,
    ),
    const AshaWorker(
      id: 'a-2',
      name: 'Geethamma',
      phone: '+91 98450 67123',
      subCentre: 'Kempanahalli Sub-centre',
      village: 'Kempanahalli',
      assignedMotherCount: 6,
      visitsThisMonth: 9,
      openTasks: 2,
    ),
    const AshaWorker(
      id: 'a-3',
      name: 'Sharadamma',
      phone: '+91 98450 98456',
      subCentre: 'Madapura Sub-centre',
      village: 'Madapura',
      assignedMotherCount: 6,
      visitsThisMonth: 8,
      openTasks: 1,
    ),
    const AshaWorker(
      id: 'a-4',
      name: 'Nagarathna',
      phone: '+91 98450 33210',
      subCentre: 'Beedanahalli Sub-centre',
      village: 'Beedanahalli',
      assignedMotherCount: 6,
      visitsThisMonth: 7,
      openTasks: 2,
    ),
  ];

  // name, age, husband, ashaIndex, weeks, gravida, para, blood, bpl, risk,
  // reasons, complications
  static final List<_Seed> _seeds = [
    // ---- red (4)
    _Seed('Parvathi', 31, 'Shivanna', 1, 34, 3, 2, 'A+', true, RiskLevel.red,
        ['BP 166/112 at last visit', 'Headache reported'], ['hypertension']),
    _Seed('Sharada', 19, 'Kumara', 2, 28, 1, 0, 'O-', true, RiskLevel.red,
        ['Haemoglobin 6.4 g/dL'], ['anaemia']),
    _Seed('Manjula', 36, 'Srinivas', 0, 36, 5, 4, 'A-', true, RiskLevel.red,
        ['Previous caesarean and PPH', 'BP 148/96'], ['cSection', 'pph']),
    _Seed('Kamalamma', 33, 'Devaraj', 3, 31, 4, 3, 'B+', true, RiskLevel.red,
        ['Reduced fetal movement reported'], ['stillbirth']),
    // ---- amber (6)
    _Seed('Ratnamma', 34, 'Nagaraj', 2, 12, 4, 3, 'AB+', true, RiskLevel.amber,
        ['Age 34 with gravida 4'], []),
    _Seed('Kavita', 17, 'Satish', 2, 20, 1, 0, 'A+', true, RiskLevel.amber,
        ['Age under 18'], []),
    _Seed('Anasuya', 25, 'Ravi', 1, 30, 2, 1, 'B+', true, RiskLevel.amber,
        ['Haemoglobin 8.6 g/dL'], ['anaemia']),
    _Seed('Jayamma', 33, 'Chandrashekar', 3, 24, 4, 3, 'A+', true,
        RiskLevel.amber, ['Previous stillbirth'], ['stillbirth']),
    _Seed('Yashoda', 35, 'Eshwar', 3, 33, 3, 2, 'A+', true, RiskLevel.amber,
        ['Age 35'], []),
    _Seed('Lalitha', 29, 'Basavaraj', 0, 26, 2, 1, 'O+', false, RiskLevel.amber,
        ['No visit in 34 days'], []),
    // ---- green (15)
    _Seed('Lakshmi', 24, 'Manjunatha', 0, 32, 1, 0, 'B+', true, RiskLevel.green,
        [], []),
    _Seed(
        'Suma', 23, 'Ramesh', 0, 22, 2, 1, 'O+', true, RiskLevel.green, [], []),
    _Seed('Geeta', 27, 'Basavaraju', 1, 18, 2, 1, 'B+', false, RiskLevel.green,
        [], []),
    _Seed('Nagarathna', 22, 'Prakash', 3, 8, 1, 0, 'O+', false, RiskLevel.green,
        [], []),
    _Seed('Saraswati', 29, 'Mahesh', 3, 26, 2, 1, 'B-', true, RiskLevel.green,
        [], []),
    _Seed('Pushpa', 30, 'Govinda', 0, 14, 3, 2, 'O+', false, RiskLevel.green,
        [], []),
    _Seed('Renuka', 21, 'Harish', 2, 16, 1, 0, 'O+', false, RiskLevel.green, [],
        []),
    _Seed('Shobha', 28, 'Venkatesh', 0, 38, 2, 1, 'AB-', true, RiskLevel.green,
        [], []),
    _Seed('Bhagya', 26, 'Suresh', 1, 10, 2, 1, 'B+', true, RiskLevel.green, [],
        []),
    _Seed('Chandramma', 24, 'Lokesh', 2, 6, 1, 0, 'O+', true, RiskLevel.green,
        [], []),
    _Seed('Vijaya', 32, 'Manju', 0, 29, 3, 2, 'B+', false, RiskLevel.green, [],
        []),
    _Seed('Savita', 20, 'Ashok', 1, 21, 1, 0, 'A-', true, RiskLevel.green, [],
        []),
    _Seed('Pallavi', 22, 'Kiran', 2, 36, 1, 0, 'A+', true, RiskLevel.green, [],
        []),
    _Seed('Roopa', 26, 'Ganesh', 3, 19, 2, 1, 'O+', false, RiskLevel.green, [],
        []),
    _Seed('Ambika', 31, 'Naveen', 1, 27, 3, 2, 'AB+', true, RiskLevel.green, [],
        []),
  ];

  static List<Mother> get mothers {
    final t = _today;
    return [
      for (var i = 0; i < _seeds.length; i++)
        () {
          final s = _seeds[i];
          final asha = ashas[s.ashaIndex];
          // Lalitha is the overdue case, so the dashboard tile is never zero.
          final daysSinceVisit = s.name == 'Lalitha' ? 34 : 6 + (i % 18);
          return Mother(
            id: 'm-${(i + 1).toString().padLeft(3, '0')}',
            name: s.name,
            age: s.age,
            husbandName: s.husband,
            phone: '+91 9845${(100000 + i * 1379).toString().substring(0, 6)}',
            village: asha.village,
            subCentre: asha.subCentre,
            ashaId: asha.id,
            ashaName: asha.name,
            lmp: t.subtract(Duration(days: s.weeks * 7)),
            gravida: s.gravida,
            para: s.para,
            bloodGroup: s.blood,
            heightCm: 148 + (i % 11).toDouble(),
            isBpl: s.bpl,
            prevComplications: s.complications,
            riskLevel: s.risk,
            riskReasons: s.reasons,
            lastVisitDate:
                s.weeks < 8 ? null : t.subtract(Duration(days: daysSinceVisit)),
          );
        }(),
    ];
  }

  /// 4-8 visits each, with vitals that justify the risk flag on the ones that
  /// carry it. Deterministic: the same demo every run.
  static List<AncVisit> visitsFor(Mother m) {
    final rng = Random(m.id.hashCode);
    final weeks = m.gestationalWeeks;
    if (weeks < 8) return const [];

    final count = (4 + rng.nextInt(5)).clamp(4, 8);
    final firstWeek = 8;
    final span = (weeks - firstWeek).clamp(1, 40);
    final step = span / count;

    final out = <AncVisit>[];
    for (var v = 1; v <= count; v++) {
      final atWeek = (firstWeek + step * v).round().clamp(8, weeks);
      final date = m.lmp.add(Duration(days: atWeek * 7));
      if (date.isAfter(DateTime.now())) break;

      var sys = 108 + rng.nextInt(12);
      var dia = 68 + rng.nextInt(10);
      var hb = 10.2 + rng.nextDouble() * 1.8;
      final signs = <String>[];
      final isLast = v == count;

      // The four red mothers carry readings that explain their flag.
      if (isLast && m.riskLevel == RiskLevel.red) {
        switch (m.name) {
          case 'Parvathi':
            sys = 166;
            dia = 112;
            signs.add('headache');
          case 'Sharada':
            hb = 6.4;
          case 'Manjula':
            sys = 148;
            dia = 96;
            signs.add('swelling');
          case 'Kamalamma':
            signs.add('reducedFetalMovement');
        }
      }
      if (isLast && m.name == 'Anasuya') hb = 8.6;

      out.add(
        AncVisit(
          id: '${m.id}-v$v',
          motherId: m.id,
          visitNo: v,
          visitDate: DateTime(date.year, date.month, date.day),
          recordedBy: m.ashaName,
          // Doctors record the occasional visit at the clinic.
          source: v == count && rng.nextInt(4) == 0
              ? VisitSource.doctor
              : VisitSource.asha,
          bpSys: sys,
          bpDia: dia,
          weightKg: 46 + atWeek * 0.32 + (m.id.hashCode % 7),
          fundalHeightCm: atWeek.toDouble().clamp(10, 40),
          hb: double.parse(hb.toStringAsFixed(1)),
          urineAlbumin: signs.contains('swelling') ? 'trace' : 'nil',
          fetalHr: 132 + rng.nextInt(12),
          fetalMovement: !signs.contains('reducedFetalMovement'),
          dangerSigns: signs,
          ifaTaken: rng.nextInt(5) != 0,
          calciumTaken: rng.nextInt(3) != 0,
          ttDoseGiven: v == 2 ? 1 : (v == 4 ? 2 : null),
          notes: isLast && m.riskLevel == RiskLevel.red
              ? 'Advised immediate review at PHC.'
              : null,
        ),
      );
    }
    return out.reversed.toList();
  }

  static List<Lab> labsFor(Mother m) {
    final t = _today;
    return [
      Lab(
        id: '${m.id}-l1',
        motherId: m.id,
        type: 'Haemoglobin',
        value: m.name == 'Sharada' ? '6.4' : '11.2',
        unit: 'g/dL',
        resultDate: t.subtract(const Duration(days: 21)),
        orderedBy: doctorName,
        reportUrl: 'report://cbc',
      ),
      Lab(
        id: '${m.id}-l2',
        motherId: m.id,
        type: 'Blood group',
        value: m.bloodGroup,
        unit: '',
        resultDate: t.subtract(const Duration(days: 120)),
        orderedBy: m.ashaName,
      ),
      Lab(
        id: '${m.id}-l3',
        motherId: m.id,
        type: 'Urine albumin',
        value: m.riskLevel == RiskLevel.red ? 'Trace' : 'Nil',
        unit: '',
        resultDate: t.subtract(const Duration(days: 21)),
        orderedBy: doctorName,
      ),
    ];
  }

  static List<ClinicalNote> notesFor(Mother m) {
    final t = _today;
    if (m.riskLevel == RiskLevel.green) return const [];
    return [
      ClinicalNote(
        id: '${m.id}-n1',
        motherId: m.id,
        authorName: doctorName,
        body: m.riskReasons.isEmpty
            ? 'Reviewed. Continue routine antenatal care.'
            : '${m.riskReasons.first}. Reviewed and flagged for close follow-up.',
        createdAt: t.subtract(const Duration(days: 9)),
      ),
    ];
  }

  /// Seeded tasks. New ones from the Assign Task modal are prepended in memory.
  static List<Task> seedTasks(List<Mother> mothers) {
    final t = _today;
    final byName = {for (final m in mothers) m.name: m};
    final out = <Task>[];

    void add(String name, TaskType type, String instruction, int dueInDays,
        TaskPriority priority, TaskStatus status) {
      final m = byName[name];
      if (m == null) return;
      out.add(
        Task(
          id: 'task-${out.length + 1}',
          motherId: m.id,
          createdBy: doctorName,
          assignedToAshaId: m.ashaId,
          assignedToAshaName: m.ashaName,
          type: type,
          instruction: instruction,
          dueDate: t.add(Duration(days: dueInDays)),
          priority: priority,
          status: status,
          createdAt: t.subtract(const Duration(days: 1)),
        ),
      );
    }

    add(
        'Parvathi',
        TaskType.recheckBp,
        'Recheck her blood pressure. If it is above 160/110, refer at once.',
        0,
        TaskPriority.high,
        TaskStatus.open);
    add(
        'Sharada',
        TaskType.bringToPhc,
        'Haemoglobin is 6.4 — bring her to the PHC for iron injection.',
        1,
        TaskPriority.high,
        TaskStatus.open);
    add(
        'Kavita',
        TaskType.counselling,
        'She is 17 — talk to her about nutrition.',
        2,
        TaskPriority.normal,
        TaskStatus.open);
    add('Lalitha', TaskType.revisit, 'No visit in 34 days. Home visit due.', -3,
        TaskPriority.normal, TaskStatus.open);
    add(
        'Anasuya',
        TaskType.confirmMedication,
        'Confirm she is taking her IFA tablets daily.',
        -8,
        TaskPriority.normal,
        TaskStatus.missed);
    add('Suma', TaskType.revisit, '20 week checkup.', -14, TaskPriority.normal,
        TaskStatus.done);
    return out;
  }

  static List<Referral> seedReferrals(List<Mother> mothers) {
    final t = _today;
    final byName = {for (final m in mothers) m.name: m};
    final out = <Referral>[];

    void add(String name, String facility, String reason, ReferralStatus status,
        int daysAgo) {
      final m = byName[name];
      if (m == null) return;
      out.add(
        Referral(
          id: 'ref-${out.length + 1}',
          motherId: m.id,
          fromUser: m.ashaName,
          toFacility: facility,
          reason: reason,
          status: status,
          createdAt: t.subtract(Duration(days: daysAgo)),
        ),
      );
    }

    add(
        'Parvathi',
        'Taluk Government Hospital, Nanjangud',
        'BP 166/112 with headache — suspected pre-eclampsia',
        ReferralStatus.open,
        1);
    add('Sharada', 'District Hospital, Mysuru',
        'Severe anaemia, haemoglobin 6.4 g/dL', ReferralStatus.arrived, 4);
    add('Manjula', 'Taluk Government Hospital, Nanjangud',
        'Previous caesarean with raised BP', ReferralStatus.open, 2);
    add('Kamalamma', 'District Hospital, Mysuru', 'Reduced fetal movement',
        ReferralStatus.closed, 12);
    return out;
  }
}

class _Seed {
  const _Seed(
    this.name,
    this.age,
    this.husband,
    this.ashaIndex,
    this.weeks,
    this.gravida,
    this.para,
    this.blood,
    this.bpl,
    this.risk,
    this.reasons,
    this.complications,
  );

  final String name;
  final int age;
  final String husband;
  final int ashaIndex;
  final int weeks;
  final int gravida;
  final int para;
  final String blood;
  final bool bpl;
  final RiskLevel risk;
  final List<String> reasons;
  final List<String> complications;
}
