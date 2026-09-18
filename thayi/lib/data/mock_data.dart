import 'models.dart';

/// Every piece of demo data lives here so it can be edited in one place
/// before a demo. Dates are all relative to "today" so the demo never
/// goes stale: she is always 32 weeks pregnant.
class MockData {
  MockData._();

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// 32 weeks and 0 days pregnant, whenever the demo is run.
  static DateTime get _lmp => _today.subtract(const Duration(days: 224));

  static final asha = AshaWorker(
    nameKn: 'ಸರೋಜಮ್ಮ',
    nameEn: 'Sarojamma',
    phone: '+919845012345',
    subCentreKn: 'ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ',
    subCentreEn: 'Hosahalli Sub-centre',
  );

  static const phc = HealthCentre(
    nameKn: 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ',
    nameEn: 'Government PHC, Hosahalli',
    phone: '+918212345678',
    distanceKm: 3.2,
    latitude: 12.2958,
    longitude: 76.6394,
  );

  static const taluqHospital = HealthCentre(
    nameKn: 'ತಾಲ್ಲೂಕು ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆ, ನಂಜನಗೂಡು',
    nameEn: 'Taluk Government Hospital, Nanjangud',
    phone: '+918221223344',
    distanceKm: 11.4,
    latitude: 12.1167,
    longitude: 76.6833,
  );

  static const districtHospital = HealthCentre(
    nameKn: 'ಜಿಲ್ಲಾ ಆಸ್ಪತ್ರೆ, ಮೈಸೂರು',
    nameEn: 'District Hospital, Mysuru',
    phone: '+918212423456',
    distanceKm: 24.0,
    latitude: 12.3052,
    longitude: 76.6552,
  );

  static Mother get mother => Mother(
        // Opaque - this is all that goes into the QR code.
        id: '7f3a91c4-2b58-4d0e-9a71-6c1e5b8d0a33',
        qrToken: 'k9Rt2Xq7Lm4P',
        thayiCardNumber: 'KA-MYS-2026-004871',
        nameKn: 'ಲಕ್ಷ್ಮಿ',
        nameEn: 'Lakshmi',
        age: 24,
        guardianKn: 'ಮಂಜುನಾಥ',
        guardianEn: 'Manjunatha',
        villageKn: 'ಹೊಸಳ್ಳಿ',
        villageEn: 'Hosahalli',
        districtKn: 'ಮೈಸೂರು',
        districtEn: 'Mysuru',
        bloodGroup: 'B+',
        lmp: _lmp,
        riskFlagIds: const ['anaemia'],
        allergyIds: const [],
        isBpl: true,
        deliveryNumber: 1,
        plansInstitutionalDelivery: true,
        hasBankAccount: true,
        asha: asha,
        phc: phc,
      );

  static List<Checkup> get checkups {
    final t = _today;
    return [
      Checkup(
        visitNumber: 1,
        date: t.subtract(const Duration(days: 154)), // ~week 10
        locationKn: phc.nameKn,
        locationEn: phc.nameEn,
        activityIds: const ['weightBp', 'bloodTest', 'urineTest', 'ifaTablets'],
        completed: true,
        weightKg: 47.5,
        systolic: 112,
        diastolic: 72,
        recordedByKn: asha.nameKn,
        recordedByEn: asha.nameEn,
      ),
      Checkup(
        visitNumber: 2,
        date: t.subtract(const Duration(days: 98)), // ~week 18
        locationKn: phc.nameKn,
        locationEn: phc.nameEn,
        activityIds: const ['weightBp', 'scan', 'ttVaccine'],
        completed: true,
        weightKg: 51.0,
        systolic: 118,
        diastolic: 76,
        recordedByKn: 'ಡಾ. ಶ್ರೀದೇವಿ',
        recordedByEn: 'Dr. Sridevi',
      ),
      Checkup(
        visitNumber: 3,
        date: t.subtract(const Duration(days: 42)), // ~week 26
        locationKn: phc.nameKn,
        locationEn: phc.nameEn,
        activityIds: const ['weightBp', 'babyHeartbeat', 'bloodTest'],
        completed: true,
        weightKg: 54.2,
        systolic: 122,
        diastolic: 78,
        recordedByKn: asha.nameKn,
        recordedByEn: asha.nameEn,
      ),
      // Overdue on purpose - the amber state has to be visible in the demo.
      Checkup(
        visitNumber: 4,
        date: t.subtract(const Duration(days: 5)),
        locationKn: phc.nameKn,
        locationEn: phc.nameEn,
        activityIds: const ['weightBp', 'urineTest', 'babyHeartbeat'],
        completed: false,
      ),
      Checkup(
        visitNumber: 5,
        date: t.add(const Duration(days: 16)),
        locationKn: taluqHospital.nameKn,
        locationEn: taluqHospital.nameEn,
        activityIds: const ['weightBp', 'scan', 'deliveryPlanning'],
        completed: false,
      ),
      Checkup(
        visitNumber: 6,
        date: t.add(const Duration(days: 37)),
        locationKn: phc.nameKn,
        locationEn: phc.nameEn,
        activityIds: const ['weightBp', 'generalCheck', 'deliveryPlanning'],
        completed: false,
      ),
    ];
  }

  static HealthRecord get healthRecord => HealthRecord(
        weights: const [
          WeightEntry(week: 10, kg: 47.5),
          WeightEntry(week: 18, kg: 51.0),
          WeightEntry(week: 22, kg: 52.6),
          WeightEntry(week: 26, kg: 54.2),
          WeightEntry(week: 30, kg: 56.4),
        ],
        bloodPressure: const [
          BpEntry(week: 10, systolic: 112, diastolic: 72),
          BpEntry(week: 18, systolic: 118, diastolic: 76),
          BpEntry(week: 22, systolic: 116, diastolic: 74),
          BpEntry(week: 26, systolic: 122, diastolic: 78),
          BpEntry(week: 30, systolic: 126, diastolic: 82),
        ],
        ttDoses: [
          TtDose(
            number: 1,
            given: true,
            givenOn: _today.subtract(const Duration(days: 126)),
          ),
          TtDose(
            number: 2,
            given: true,
            givenOn: _today.subtract(const Duration(days: 98)),
          ),
        ],
      );

  static const babyRecord = BabyRecord(
    vaccines: [
      BabyVaccine(vaccineId: 'bcg', ageId: 'atBirth', given: false),
      BabyVaccine(vaccineId: 'opv', ageId: 'atBirth', given: false),
      BabyVaccine(vaccineId: 'hepB', ageId: 'atBirth', given: false),
      BabyVaccine(vaccineId: 'penta', ageId: 'w6', given: false),
      BabyVaccine(vaccineId: 'opv', ageId: 'w6', given: false),
      BabyVaccine(vaccineId: 'rota', ageId: 'w6', given: false),
      BabyVaccine(vaccineId: 'penta', ageId: 'w10', given: false),
      BabyVaccine(vaccineId: 'opv', ageId: 'w10', given: false),
      BabyVaccine(vaccineId: 'penta', ageId: 'w14', given: false),
      BabyVaccine(vaccineId: 'opv', ageId: 'w14', given: false),
      BabyVaccine(vaccineId: 'mr', ageId: 'm9', given: false),
    ],
    growth: [],
  );

  /// Eligibility is computed from the profile fields, not hardcoded per
  /// scheme, so editing the mother above changes the badges.
  static List<Scheme> schemesFor(Mother m) {
    return [
      Scheme(
        id: SchemeId.thayiBhagya,
        eligible: m.isBpl && m.plansInstitutionalDelivery,
        documentIds: const ['thayiCard', 'aadhaar', 'bplCard'],
        hospitals: const [taluqHospital, districtHospital],
      ),
      Scheme(
        id: SchemeId.pmmvy,
        eligible: m.deliveryNumber == 1 && m.hasBankAccount,
        documentIds: const [
          'thayiCard',
          'aadhaar',
          'husbandAadhaar',
          'bankPassbook',
          'mchRegistration',
        ],
        hospitals: const [phc, taluqHospital],
      ),
      Scheme(
        id: SchemeId.jsy,
        eligible: m.isBpl && m.plansInstitutionalDelivery,
        documentIds: const [
          'thayiCard',
          'aadhaar',
          'bankPassbook',
          'bplCard',
          'deliveryProof',
        ],
        hospitals: const [phc, taluqHospital, districtHospital],
      ),
      Scheme(
        id: SchemeId.prasootiAraike,
        eligible: m.isBpl && m.deliveryNumber <= 2,
        documentIds: const ['thayiCard', 'bplCard', 'bankPassbook'],
        hospitals: const [phc, taluqHospital],
      ),
      Scheme(
        id: SchemeId.madilu,
        eligible: m.isBpl && m.plansInstitutionalDelivery,
        documentIds: const ['thayiCard', 'bplCard', 'deliveryProof'],
        hospitals: const [taluqHospital, districtHospital],
      ),
      Scheme(
        id: SchemeId.jssk,
        eligible: m.plansInstitutionalDelivery,
        documentIds: const ['thayiCard', 'aadhaar'],
        hospitals: const [phc, taluqHospital, districtHospital],
      ),
    ];
  }
}
