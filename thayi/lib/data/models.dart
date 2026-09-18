/// Plain data models. Nothing here knows about widgets or localisation —
/// text that the user sees is referenced by id and resolved through
/// `lib/l10n/content.dart`.
library;

class Mother {
  const Mother({
    required this.id,
    required this.qrToken,
    required this.thayiCardNumber,
    required this.nameKn,
    required this.nameEn,
    required this.age,
    required this.guardianKn,
    required this.guardianEn,
    required this.villageKn,
    required this.villageEn,
    required this.districtKn,
    required this.districtEn,
    required this.bloodGroup,
    required this.lmp,
    required this.riskFlagIds,
    required this.allergyIds,
    required this.isBpl,
    required this.deliveryNumber,
    required this.plansInstitutionalDelivery,
    required this.hasBankAccount,
    required this.asha,
    required this.phc,
  });

  /// Opaque id used in the QR payload. Never a name or a phone number.
  final String id;
  final String qrToken;
  final String thayiCardNumber;

  final String nameKn;
  final String nameEn;
  final int age;
  final String guardianKn;
  final String guardianEn;
  final String villageKn;
  final String villageEn;
  final String districtKn;
  final String districtEn;
  final String bloodGroup;

  /// Last menstrual period. Everything about dates is derived from this.
  final DateTime lmp;
  final List<String> riskFlagIds;
  final List<String> allergyIds;

  // Fields the scheme eligibility rules read.
  final bool isBpl;
  final int deliveryNumber;
  final bool plansInstitutionalDelivery;
  final bool hasBankAccount;

  final AshaWorker asha;
  final HealthCentre phc;

  DateTime get edd => lmp.add(const Duration(days: 280));

  int weeksPregnantOn(DateTime now) {
    final days = _dayDiff(lmp, now);
    final weeks = (days / 7).floor();
    return weeks.clamp(0, 42);
  }

  int daysToEddOn(DateTime now) => _dayDiff(now, edd);

  /// The QR payload. Only the id and the token - no personal data, ever.
  String get qrPayload => 'setu://m/$id?t=$qrToken';
}

class AshaWorker {
  const AshaWorker({
    required this.nameKn,
    required this.nameEn,
    required this.phone,
    required this.subCentreKn,
    required this.subCentreEn,
  });

  final String nameKn;
  final String nameEn;
  final String phone;
  final String subCentreKn;
  final String subCentreEn;
}

class HealthCentre {
  const HealthCentre({
    required this.nameKn,
    required this.nameEn,
    required this.phone,
    required this.distanceKm,
    this.latitude,
    this.longitude,
  });

  final String nameKn;
  final String nameEn;
  final String phone;
  final double distanceKm;
  final double? latitude;
  final double? longitude;
}

class Checkup {
  const Checkup({
    required this.visitNumber,
    required this.date,
    required this.locationKn,
    required this.locationEn,
    required this.activityIds,
    required this.completed,
    this.weightKg,
    this.systolic,
    this.diastolic,
    this.recordedByKn,
    this.recordedByEn,
  });

  final int visitNumber;
  final DateTime date;
  final String locationKn;
  final String locationEn;
  final List<String> activityIds;
  final bool completed;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;
  final String? recordedByKn;
  final String? recordedByEn;

  bool isOverdueOn(DateTime now) => !completed && date.isBefore(_dateOnly(now));
}

class WeightEntry {
  const WeightEntry({required this.week, required this.kg});
  final int week;
  final double kg;
}

class BpEntry {
  const BpEntry({
    required this.week,
    required this.systolic,
    required this.diastolic,
  });
  final int week;
  final int systolic;
  final int diastolic;
}

class TtDose {
  const TtDose({required this.number, required this.given, this.givenOn});
  final int number;
  final bool given;
  final DateTime? givenOn;
}

class HealthRecord {
  const HealthRecord({
    required this.weights,
    required this.bloodPressure,
    required this.ttDoses,
  });

  final List<WeightEntry> weights;
  final List<BpEntry> bloodPressure;
  final List<TtDose> ttDoses;
}

/// Ids match the scheme name/benefit keys in the ARB files.
enum SchemeId { thayiBhagya, pmmvy, jsy, prasootiAraike, madilu, jssk }

class Scheme {
  const Scheme({
    required this.id,
    required this.eligible,
    required this.documentIds,
    required this.hospitals,
  });

  final SchemeId id;
  final bool eligible;
  final List<String> documentIds;
  final List<HealthCentre> hospitals;
}

class BabyVaccine {
  const BabyVaccine({
    required this.vaccineId,
    required this.ageId,
    required this.given,
  });
  final String vaccineId;
  final String ageId;
  final bool given;
}

class BabyRecord {
  const BabyRecord({required this.vaccines, required this.growth});
  final List<BabyVaccine> vaccines;
  final List<WeightEntry> growth;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int _dayDiff(DateTime from, DateTime to) =>
    _dateOnly(to).difference(_dateOnly(from)).inDays;
