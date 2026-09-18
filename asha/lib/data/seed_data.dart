import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Seeds a realistic caseload the first time the app runs.
///
/// A demo with three mothers looks like a toy, so this is a full ASHA
/// caseload: 20 women spread across four villages, at every stage of
/// pregnancy, with three already carrying red flags and a doctor-assigned
/// task waiting on the home screen.
class SeedData {
  SeedData._();

  static const ashaName = 'ಸರೋಜಮ್ಮ';

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existing = await db.allMothers();
    if (existing.isNotEmpty) return;
    await _seed(db);
  }

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static Future<void> _seed(AppDatabase db) async {
    final t = _today;

    // name, age, husband, village, weeksPregnant, gravida, para, blood,
    // bpl, complications, risk
    final people = <_Person>[
      _Person('ಲಕ್ಷ್ಮಿ', 24, 'ಮಂಜುನಾಥ', 'ಹೊಸಳ್ಳಿ', 32, 1, 0, 'B+', true, [],
          'green'),
      _Person('ಸುಮಾ', 23, 'ರಮೇಶ', 'ಹೊಸಳ್ಳಿ', 22, 2, 1, 'O+', true, [], 'green'),
      // Red: severe hypertension recorded at her last visit.
      _Person('ಪಾರ್ವತಿ', 31, 'ಶಿವಣ್ಣ', 'ಕೆಂಪನಹಳ್ಳಿ', 34, 3, 2, 'A+', true,
          ['hypertension'], 'red'),
      _Person('ಗೀತಾ', 27, 'ಬಸವರಾಜು', 'ಕೆಂಪನಹಳ್ಳಿ', 18, 2, 1, 'B+', false, [],
          'green'),
      // Red: severe anaemia.
      _Person('ಶಾರದಾ', 19, 'ಕುಮಾರ', 'ಮಾದಾಪುರ', 28, 1, 0, 'O-', true,
          ['anaemia'], 'red'),
      _Person('ರತ್ನಮ್ಮ', 34, 'ನಾಗರಾಜ', 'ಮಾದಾಪುರ', 12, 4, 3, 'AB+', true, [],
          'amber'),
      // Red: previous caesarean plus raised BP.
      _Person('ಮಂಜುಳಾ', 36, 'ಶ್ರೀನಿವಾಸ', 'ಹೊಸಳ್ಳಿ', 36, 5, 4, 'A-', true,
          ['cSection', 'pph'], 'red'),
      _Person('ನಾಗರತ್ನ', 22, 'ಪ್ರಕಾಶ', 'ಬೀಡನಹಳ್ಳಿ', 8, 1, 0, 'O+', false, [],
          'green'),
      _Person('ಸರಸ್ವತಿ', 29, 'ಮಹೇಶ', 'ಬೀಡನಹಳ್ಳಿ', 26, 2, 1, 'B-', true, [],
          'green'),
      _Person(
          'ಕವಿತಾ', 17, 'ಸತೀಶ', 'ಮಾದಾಪುರ', 20, 1, 0, 'A+', true, [], 'amber'),
      _Person('ಪುಷ್ಪಾ', 30, 'ಗೋವಿಂದ', 'ಹೊಸಳ್ಳಿ', 14, 3, 2, 'O+', false, [],
          'green'),
      _Person('ಅನಸೂಯಾ', 25, 'ರವಿ', 'ಕೆಂಪನಹಳ್ಳಿ', 30, 2, 1, 'B+', true,
          ['anaemia'], 'amber'),
      _Person('ಜಯಮ್ಮ', 33, 'ಚಂದ್ರಶೇಖರ', 'ಬೀಡನಹಳ್ಳಿ', 24, 4, 3, 'A+', true,
          ['stillbirth'], 'amber'),
      _Person(
          'ರೇಣುಕಾ', 21, 'ಹರೀಶ', 'ಮಾದಾಪುರ', 16, 1, 0, 'O+', false, [], 'green'),
      _Person(
          'ಶೋಭಾ', 28, 'ವೆಂಕಟೇಶ', 'ಹೊಸಳ್ಳಿ', 38, 2, 1, 'AB-', true, [], 'green'),
      _Person('ಭಾಗ್ಯ', 26, 'ಸುರೇಶ', 'ಕೆಂಪನಹಳ್ಳಿ', 10, 2, 1, 'B+', true, [],
          'green'),
      _Person(
          'ಯಶೋದಾ', 35, 'ಈಶ್ವರ', 'ಬೀಡನಹಳ್ಳಿ', 33, 3, 2, 'A+', true, [], 'amber'),
      _Person(
          'ಚಂದ್ರಮ್ಮ', 24, 'ಲೋಕೇಶ', 'ಮಾದಾಪುರ', 6, 1, 0, 'O+', true, [], 'green'),
      _Person(
          'ವಿಜಯಾ', 32, 'ಮಂಜು', 'ಹೊಸಳ್ಳಿ', 29, 3, 2, 'B+', false, [], 'green'),
      _Person(
          'ಸವಿತಾ', 20, 'ಅಶೋಕ', 'ಕೆಂಪನಹಳ್ಳಿ', 21, 1, 0, 'A-', true, [], 'green'),
    ];

    await db.batch((batch) {
      for (var i = 0; i < people.length; i++) {
        final p = people[i];
        batch.insert(
          db.mothers,
          MothersCompanion.insert(
            id: 'm-${(i + 1).toString().padLeft(3, '0')}',
            name: p.name,
            age: p.age,
            husbandName: Value(p.husband),
            phone:
                Value('98450${(10000 + i * 137).toString().substring(0, 5)}'),
            village: p.village,
            subCentre: const Value('ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ'),
            lmp: t.subtract(Duration(days: p.weeks * 7)),
            gravida: Value(p.gravida),
            para: Value(p.para),
            bloodGroup: Value(p.blood),
            heightCm: Value(148 + (i % 9).toDouble()),
            isBpl: Value(p.bpl),
            prevComplications: Value(jsonEncode(p.complications)),
            riskLevel: Value(p.risk),
            createdAt: t.subtract(Duration(days: 60 + i)),
            synced: const Value(true),
          ),
        );
      }
    });

    await _seedVisits(db, people, t);
    await _seedTasks(db, t);
  }

  static Future<void> _seedVisits(
      AppDatabase db, List<_Person> people, DateTime t) async {
    await db.batch((batch) {
      for (var i = 0; i < people.length; i++) {
        final p = people[i];
        final motherId = 'm-${(i + 1).toString().padLeft(3, '0')}';
        // Roughly one visit per 8 weeks of pregnancy so far.
        final visitCount = (p.weeks / 8).floor().clamp(0, 4);

        for (var v = 1; v <= visitCount; v++) {
          final weeksAgo = p.weeks - (v * 8);
          final date = t.subtract(Duration(days: weeksAgo * 7));

          // The three red mothers carry the readings that justify their flag.
          var sys = 110 + (i % 5) * 4;
          var dia = 70 + (i % 4) * 3;
          double? hb = 10.5 + (i % 5) * 0.4;
          final signs = <String>[];

          if (p.risk == 'red' && v == visitCount) {
            if (p.name == 'ಪಾರ್ವತಿ') {
              sys = 166;
              dia = 112;
              signs.add('headache');
            } else if (p.name == 'ಶಾರದಾ') {
              hb = 6.4;
            } else if (p.name == 'ಮಂಜುಳಾ') {
              sys = 148;
              dia = 96;
              signs.add('swelling');
            }
          }

          batch.insert(
            db.ancVisits,
            AncVisitsCompanion.insert(
              id: '$motherId-v$v',
              motherId: motherId,
              visitNo: v,
              visitDate: date,
              bpSys: Value(sys),
              bpDia: Value(dia),
              weightKg: Value(46 + i * 0.4 + v * 1.6),
              fundalHeightCm:
                  Value((p.weeks - weeksAgo).toDouble().clamp(10, 40)),
              hb: Value(hb),
              urineAlbumin: const Value('nil'),
              fetalHr: Value(136 + (i % 7)),
              fetalMovement: const Value(true),
              dangerSigns: Value(jsonEncode(signs)),
              ifaTaken: const Value(true),
              calciumTaken: Value(i.isEven),
              recordedBy: ashaName,
              clientCreatedAt: date,
              synced: const Value(true),
            ),
          );
        }
      }
    });
  }

  static Future<void> _seedTasks(AppDatabase db, DateTime t) async {
    // Doctor-assigned work is the point of the platform, so the demo opens
    // with two of them waiting at the top of Today's Work.
    final rows = <TasksCompanion>[
      TasksCompanion.insert(
        id: 'task-001',
        motherId: 'm-003',
        type: 'referralFollowUp',
        instructionKn: const Value(
            'ರಕ್ತದೊತ್ತಡ ಮತ್ತೆ ಪರೀಕ್ಷಿಸಿ. 160/110 ಕ್ಕಿಂತ ಹೆಚ್ಚಿದ್ದರೆ ತಕ್ಷಣ ಕಳುಹಿಸಿ.'),
        instructionEn: const Value(
            'Recheck her blood pressure. If it is above 160/110, refer at once.'),
        dueDate: t,
        priority: const Value('high'),
        origin: const Value('doctor'),
        createdAt: t.subtract(const Duration(days: 1)),
      ),
      TasksCompanion.insert(
        id: 'task-002',
        motherId: 'm-005',
        type: 'labResult',
        instructionKn: const Value(
            'ಹಿಮೋಗ್ಲೋಬಿನ್ 6.4 — ಕಬ್ಬಿಣಾಂಶದ ಚುಚ್ಚುಮದ್ದಿಗೆ ಪಿಎಚ್‌ಸಿಗೆ ಕರೆತನ್ನಿ.'),
        instructionEn: const Value(
            'Haemoglobin is 6.4 — bring her to the PHC for iron injection.'),
        dueDate: t.add(const Duration(days: 1)),
        priority: const Value('high'),
        origin: const Value('doctor'),
        createdAt: t.subtract(const Duration(days: 2)),
      ),
      TasksCompanion.insert(
        id: 'task-003',
        motherId: 'm-007',
        type: 'ancVisit',
        instructionKn: const Value('36 ವಾರದ ತಪಾಸಣೆ ಬಾಕಿ ಇದೆ.'),
        instructionEn: const Value('The 36 week checkup is due.'),
        dueDate: t.subtract(const Duration(days: 3)),
        origin: const Value('system'),
        createdAt: t.subtract(const Duration(days: 3)),
      ),
      TasksCompanion.insert(
        id: 'task-004',
        motherId: 'm-010',
        type: 'counselling',
        instructionKn: const Value('ವಯಸ್ಸು 17 — ಪೌಷ್ಟಿಕ ಆಹಾರದ ಬಗ್ಗೆ ಮಾತನಾಡಿ.'),
        instructionEn: const Value('She is 17 — talk to her about nutrition.'),
        dueDate: t.add(const Duration(days: 2)),
        origin: const Value('self'),
        createdAt: t.subtract(const Duration(days: 1)),
      ),
      TasksCompanion.insert(
        id: 'task-005',
        motherId: 'm-015',
        type: 'ancVisit',
        instructionKn: const Value('38 ವಾರ — ಹೆರಿಗೆ ಸಿದ್ಧತೆ ಪರಿಶೀಲಿಸಿ.'),
        instructionEn:
            const Value('38 weeks — check her delivery preparation.'),
        dueDate: t,
        origin: const Value('system'),
        createdAt: t.subtract(const Duration(days: 1)),
      ),
      TasksCompanion.insert(
        id: 'task-006',
        motherId: 'm-012',
        type: 'followUp',
        instructionKn: const Value('ಕಬ್ಬಿಣಾಂಶದ ಮಾತ್ರೆ ಮುಗಿದಿದೆಯೇ ಕೇಳಿ.'),
        instructionEn: const Value('Ask whether her IFA tablets have run out.'),
        dueDate: t.subtract(const Duration(days: 8)),
        status: const Value('missed'),
        origin: const Value('system'),
        createdAt: t.subtract(const Duration(days: 12)),
      ),
      TasksCompanion.insert(
        id: 'task-007',
        motherId: 'm-002',
        type: 'ancVisit',
        instructionKn: const Value('20 ವಾರದ ತಪಾಸಣೆ.'),
        instructionEn: const Value('The 20 week checkup.'),
        dueDate: t.subtract(const Duration(days: 14)),
        status: const Value('done'),
        origin: const Value('system'),
        createdAt: t.subtract(const Duration(days: 20)),
        closedAt: Value(t.subtract(const Duration(days: 14))),
      ),
    ];

    await db.batch((batch) => batch.insertAll(db.tasks, rows));
  }
}

class _Person {
  const _Person(
    this.name,
    this.age,
    this.husband,
    this.village,
    this.weeks,
    this.gravida,
    this.para,
    this.blood,
    this.bpl,
    this.complications,
    this.risk,
  );

  final String name;
  final int age;
  final String husband;
  final String village;
  final int weeks;
  final int gravida;
  final int para;
  final String blood;
  final bool bpl;
  final List<String> complications;
  final String risk;
}
