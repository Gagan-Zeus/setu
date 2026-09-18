import 'package:intl/intl.dart';

import '../data/chat_service.dart';
import '../data/models.dart';
import '../safety/danger_sign_detector.dart';
import 'app_localizations.dart';

/// Resolves the ids used in the data layer into localised text.
/// Screens never build display strings themselves.
extension SetuContent on AppLocalizations {
  bool get isKannada => localeName.startsWith('kn');

  String riskFlag(String id) => switch (id) {
        'anaemia' => riskAnaemia,
        'highBp' => riskHighBp,
        'underweight' => riskUnderweight,
        'previousCsection' => riskPreviousCsection,
        'ageRisk' => riskAgeRisk,
        'twins' => riskTwins,
        _ => id,
      };

  String checkupActivity(String id) => switch (id) {
        'weightBp' => actWeightBp,
        'bloodTest' => actBloodTest,
        'urineTest' => actUrineTest,
        'ttVaccine' => actTtVaccine,
        'ifaTablets' => actIfaTablets,
        'scan' => actScan,
        'babyHeartbeat' => actBabyHeartbeat,
        'generalCheck' => actGeneralCheck,
        'deliveryPlanning' => actDeliveryPlanning,
        _ => id,
      };

  String schemeName(SchemeId id) => switch (id) {
        SchemeId.thayiBhagya => schemeThayiBhagyaName,
        SchemeId.pmmvy => schemePmmvyName,
        SchemeId.jsy => schemeJsyName,
        SchemeId.prasootiAraike => schemePrasootiAraikeName,
        SchemeId.madilu => schemeMadiluName,
        SchemeId.jssk => schemeJsskName,
      };

  String schemeBenefit(SchemeId id) => switch (id) {
        SchemeId.thayiBhagya => schemeThayiBhagyaBenefit,
        SchemeId.pmmvy => schemePmmvyBenefit,
        SchemeId.jsy => schemeJsyBenefit,
        SchemeId.prasootiAraike => schemePrasootiAraikeBenefit,
        SchemeId.madilu => schemeMadiluBenefit,
        SchemeId.jssk => schemeJsskBenefit,
      };

  String document(String id) => switch (id) {
        'thayiCard' => docThayiCard,
        'aadhaar' => docAadhaar,
        'bankPassbook' => docBankPassbook,
        'bplCard' => docBplCard,
        'husbandAadhaar' => docHusbandAadhaar,
        'mchRegistration' => docMchRegistration,
        'deliveryProof' => docDeliveryProof,
        _ => id,
      };

  String vaccine(String id) => switch (id) {
        'bcg' => vacBcg,
        'opv' => vacOpv,
        'hepB' => vacHepB,
        'penta' => vacPenta,
        'rota' => vacRota,
        'mr' => vacMr,
        _ => id,
      };

  String babyAge(String id) => switch (id) {
        'atBirth' => ageAtBirth,
        'w6' => age6Weeks,
        'w10' => age10Weeks,
        'w14' => age14Weeks,
        'm9' => age9Months,
        _ => id,
      };

  String suggestedQuestion(String id) => switch (id) {
        'qFood1' => qFood1,
        'qFood2' => qFood2,
        'qFood3' => qFood3,
        'qRest1' => qRest1,
        'qRest2' => qRest2,
        'qRest3' => qRest3,
        'qAfter1' => qAfter1,
        'qAfter2' => qAfter2,
        'qAfter3' => qAfter3,
        _ => id,
      };

  /// The assistant writes its own answers now. These are only the sentences
  /// shown when it cannot answer — each one hands her to her ASHA worker.
  String chatFailure(ChatFailure failure) => switch (failure) {
        ChatFailure.medicine => aMedicineRefusal,
        ChatFailure.offline => chatOffline,
        ChatFailure.noAnswer => chatNoAnswer,
      };

  String chatTopic(ChatTopic topic) => switch (topic) {
        ChatTopic.food => topicFood,
        ChatTopic.rest => topicRest,
        ChatTopic.afterDelivery => topicAfterDelivery,
      };

  String dangerSignTitle(DangerSign sign) => switch (sign) {
        DangerSign.bleeding => dsBleedingTitle,
        DangerSign.severeHeadache => dsHeadacheTitle,
        DangerSign.blurredVision => dsVisionTitle,
        DangerSign.swelling => dsSwellingTitle,
        DangerSign.fever => dsFeverTitle,
        DangerSign.convulsions => dsConvulsionsTitle,
        DangerSign.reducedFetalMovement => dsMovementTitle,
      };

  String dangerSignBody(DangerSign sign) => switch (sign) {
        DangerSign.bleeding => dsBleedingBody,
        DangerSign.severeHeadache => dsHeadacheBody,
        DangerSign.blurredVision => dsVisionBody,
        DangerSign.swelling => dsSwellingBody,
        DangerSign.fever => dsFeverBody,
        DangerSign.convulsions => dsConvulsionsBody,
        DangerSign.reducedFetalMovement => dsMovementBody,
      };

  String dangerSignDo(DangerSign sign) => switch (sign) {
        DangerSign.bleeding => dsBleedingDo,
        DangerSign.severeHeadache => dsHeadacheDo,
        DangerSign.blurredVision => dsVisionDo,
        DangerSign.swelling => dsSwellingDo,
        DangerSign.fever => dsFeverDo,
        DangerSign.convulsions => dsConvulsionsDo,
        DangerSign.reducedFetalMovement => dsMovementDo,
      };

  // Names are stored in both scripts in the record, the way the paper
  // Thayi Card carries them.
  String motherName(Mother m) => isKannada ? m.nameKn : m.nameEn;
  String guardian(Mother m) => isKannada ? m.guardianKn : m.guardianEn;
  String village(Mother m) => isKannada ? m.villageKn : m.villageEn;
  String district(Mother m) => isKannada ? m.districtKn : m.districtEn;
  String ashaName(AshaWorker a) => isKannada ? a.nameKn : a.nameEn;
  String subCentre(AshaWorker a) => isKannada ? a.subCentreKn : a.subCentreEn;
  String centreName(HealthCentre h) => isKannada ? h.nameKn : h.nameEn;
  String checkupLocation(Checkup c) => isKannada ? c.locationKn : c.locationEn;
  String? checkupRecordedBy(Checkup c) =>
      isKannada ? c.recordedByKn : c.recordedByEn;

  /// One date format for the whole app.
  String formatDate(DateTime date) =>
      DateFormat('d MMM yyyy', localeName).format(date);

  String formatShortDate(DateTime date) =>
      DateFormat('d MMM', localeName).format(date);
}
