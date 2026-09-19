// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'ಆಶಾ ಸೇತು';

  @override
  String get appTagline => 'ನಿಮ್ಮ ಕ್ಷೇತ್ರ ಸಂಗಾತಿ';

  @override
  String get langKannada => 'ಕನ್ನಡ';

  @override
  String get langEnglish => 'English';

  @override
  String get chooseLanguage => 'ನಿಮ್ಮ ಭಾಷೆ ಆರಿಸಿ';

  @override
  String get languageLabel => 'ಭಾಷೆ';

  @override
  String get continueLabel => 'ಮುಂದೆ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get cancel => 'ಬೇಡ';

  @override
  String get ok => 'ಸರಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get optional => 'ಬೇಕಿದ್ದರೆ';

  @override
  String get loading => 'ಬರುತ್ತಿದೆ…';

  @override
  String get errorTitle => 'ಏನೋ ತೊಂದರೆ ಆಯಿತು';

  @override
  String get emptyGeneric => 'ಇಲ್ಲಿ ಇನ್ನೂ ಏನೂ ಇಲ್ಲ';

  @override
  String get notRecorded => 'ಬರೆದಿಲ್ಲ';

  @override
  String get requiredField => 'ಇದು ಬೇಕೇ ಬೇಕು';

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String get logout => 'ಹೊರಗೆ ಬನ್ನಿ';

  @override
  String get accountSection => 'ಖಾತೆ';

  @override
  String signedInAs(String email) {
    return '$email ಆಗಿ ಒಳಗಿದ್ದೀರಿ';
  }

  @override
  String get logoutWarningTitle => 'ಹೊರಗೆ ಬರಬೇಕೇ?';

  @override
  String get logoutWarningBody =>
      'ಮತ್ತೆ ಒಳಗೆ ಬರಲು ಇಂಟರ್ನೆಟ್ ಬೇಕು. ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲದ ಊರಿನಲ್ಲಿ ಇದ್ದಾಗ ಹೊರಗೆ ಬರಬೇಡಿ.';

  @override
  String logoutPendingWarning(int count) {
    return '$count ನಮೂದುಗಳು ಇನ್ನೂ ಕಳುಹಿಸಿಲ್ಲ. ಅವು ಈ ಫೋನಿನಲ್ಲೇ ಇರುತ್ತವೆ, ಆದರೆ ಬೇಗ ಮತ್ತೆ ಒಳಗೆ ಬಂದು ಕಳುಹಿಸಿ.';
  }

  @override
  String get logoutConfirm => 'ಹೌದು, ಹೊರಗೆ ಬರುತ್ತೇನೆ';

  @override
  String get loginTitle => 'ಒಳಗೆ ಬನ್ನಿ';

  @override
  String get loginSubtitle =>
      'ಒಮ್ಮೆ ಒಳಗೆ ಬಂದರೆ ಸಾಕು. ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲದಿದ್ದರೂ ಒಳಗೇ ಇರುತ್ತೀರಿ.';

  @override
  String get emailLabel => 'ಇಮೇಲ್';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get emailInvalid => 'ಸರಿಯಾದ ಇಮೇಲ್ ವಿಳಾಸ ಹಾಕಿ';

  @override
  String get passwordLabel => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get passwordInvalid => 'ಪಾಸ್‌ವರ್ಡ್ ಹಾಕಿ';

  @override
  String get signIn => 'ಒಳಗೆ ಬನ್ನಿ';

  @override
  String get otpTitle => 'ಕೋಡ್ ಹಾಕಿ';

  @override
  String otpSentTo(String email) {
    return '$email ಗೆ ಕಳುಹಿಸಿದ್ದೇವೆ';
  }

  @override
  String get otpInvalid => '6 ಅಂಕಿಗಳನ್ನೂ ಹಾಕಿ';

  @override
  String get otpVerify => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get otpSending => 'ಕೋಡ್ ಕಳುಹಿಸುತ್ತಿದ್ದೇವೆ…';

  @override
  String get otpVerifying => 'ಪರಿಶೀಲಿಸುತ್ತಿದ್ದೇವೆ…';

  @override
  String get otpSendFailed =>
      'ಕೋಡ್ ಕಳುಹಿಸಲು ಆಗಲಿಲ್ಲ. ವಿಳಾಸ ಸರಿ ಇದೆಯೇ ನೋಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get otpWrongCode => 'ಈ ಕೋಡ್ ಸರಿಯಿಲ್ಲ. ಇಮೇಲ್ ನೋಡಿ ಮತ್ತೆ ಹಾಕಿ.';

  @override
  String get otpResend => 'ಕೋಡ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String get otpChangeEmail => 'ಇಮೇಲ್ ಬದಲಿಸಿ';

  @override
  String get otpNoNetwork =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲ. ಮೊದಲ ಸಲ ಒಳಗೆ ಬರಲು ಒಮ್ಮೆ ನೆಟ್‌ವರ್ಕ್ ಬೇಕು.';

  @override
  String get otpOfflineFallback =>
      'ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲ — ಈ ಫೋನಿನಲ್ಲಿ ಮಾತ್ರ ಒಳಗೆ ಬಂದಿದ್ದೀರಿ. ಸಿಗ್ನಲ್ ಸಿಕ್ಕಾಗ ಸರಿಯಾಗಿ ಒಳಗೆ ಬನ್ನಿ.';

  @override
  String get forgotPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?';

  @override
  String get forgotPasswordTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ';

  @override
  String get forgotPasswordBody =>
      'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಿಸಲು ನಿಮ್ಮ ಎಎನ್‌ಎಂ ಅವರನ್ನು ಸಂಪರ್ಕಿಸಿ. ಆ್ಯಪ್‌ನಲ್ಲೇ ಬದಲಿಸುವ ಸೌಲಭ್ಯ ಶೀಘ್ರದಲ್ಲಿ ಬರುತ್ತದೆ.';

  @override
  String get loginFailed => 'ಒಳಗೆ ಬರಲು ಆಗಲಿಲ್ಲ. ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ನೋಡಿ.';

  @override
  String get setPinTitle => '4 ಅಂಕಿಯ ಪಿನ್ ಇಡಿ';

  @override
  String get setPinBody =>
      'ಈ ಫೋನ್ ಬೇರೆಯವರೂ ಬಳಸಬಹುದು. ಪಿನ್ ಇತರ ತಾಯಂದಿರ ಮಾಹಿತಿಯನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಇಡುತ್ತದೆ.';

  @override
  String get confirmPinTitle => 'ಪಿನ್ ಮತ್ತೊಮ್ಮೆ ಹಾಕಿ';

  @override
  String get pinMismatch => 'ಎರಡು ಪಿನ್ ಒಂದೇ ಆಗಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get enterPinTitle => 'ನಿಮ್ಮ ಪಿನ್ ಹಾಕಿ';

  @override
  String get enterPinBody => 'ಮುಂದೆ ಹೋಗಲು 4 ಅಂಕಿಯ ಪಿನ್ ಹಾಕಿ';

  @override
  String get pinWrong => 'ಪಿನ್ ಸರಿಯಿಲ್ಲ. ಮತ್ತೆ ಹಾಕಿ.';

  @override
  String get unlock => 'ತೆರೆಯಿರಿ';

  @override
  String greeting(String name) {
    return 'ನಮಸ್ಕಾರ, $name';
  }

  @override
  String get todaysWork => 'ಇಂದಿನ ಕೆಲಸ';

  @override
  String syncOffline(int count) {
    return 'ಆಫ್‌ಲೈನ್ — $count ನಮೂದುಗಳು ಕಾಯುತ್ತಿವೆ';
  }

  @override
  String syncPending(int count) {
    return '$count ನಮೂದುಗಳು ಕಳುಹಿಸಲು ಬಾಕಿ';
  }

  @override
  String get syncAllDone => 'ಎಲ್ಲವೂ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get syncing => 'ಕಳುಹಿಸುತ್ತಿದೆ…';

  @override
  String get statAssigned => 'ತಾಯಂದಿರು';

  @override
  String get statHighRisk => 'ಅಧಿಕ ಅಪಾಯ';

  @override
  String get statVisitsDue => 'ಬಾಕಿ ಭೇಟಿ';

  @override
  String get registerMother => 'ಹೊಸ ತಾಯಿ ನೋಂದಣಿ';

  @override
  String get noTasks => 'ಇಂದು ಬಾಕಿ ಕೆಲಸ ಇಲ್ಲ';

  @override
  String get originDoctor => 'ವೈದ್ಯರು ನೀಡಿದ್ದು';

  @override
  String get originSystem => 'ತಡವಾಗಿದೆ';

  @override
  String get originSelf => 'ನನ್ನ ಟಿಪ್ಪಣಿ';

  @override
  String gestationWeeks(int weeks) {
    return '$weeks ವಾರ';
  }

  @override
  String dueOn(String date) {
    return '$date ರೊಳಗೆ';
  }

  @override
  String get overdue => 'ತಡವಾಗಿದೆ';

  @override
  String get mothersTitle => 'ತಾಯಂದಿರು';

  @override
  String get searchMothers => 'ಹೆಸರು ಅಥವಾ ಗ್ರಾಮ ಹುಡುಕಿ';

  @override
  String get tabAll => 'ಎಲ್ಲರೂ';

  @override
  String get tabHighRisk => 'ಅಧಿಕ ಅಪಾಯ';

  @override
  String get tabVisitsDue => 'ಬಾಕಿ ಭೇಟಿ';

  @override
  String get noMothers => 'ಇನ್ನೂ ಯಾರೂ ನೋಂದಣಿ ಆಗಿಲ್ಲ';

  @override
  String get registerTitle => 'ಹೊಸ ತಾಯಿ ನೋಂದಣಿ';

  @override
  String get scanThayiCard => 'ತಾಯಿ ಕಾರ್ಡ್ ಸ್ಕ್ಯಾನ್';

  @override
  String get scanHint => 'ಅವರ ಕಾಗದದ ಕಾರ್ಡಿನ ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get manualEntry => 'ಕೈಯಿಂದ ಬರೆಯಿರಿ';

  @override
  String get scanning => 'ಕಾರ್ಡ್ ಓದುತ್ತಿದೆ…';

  @override
  String get confirmEachField =>
      'ಕೆಳಗಿನ ಪ್ರತಿ ವಿವರವನ್ನೂ ಪರಿಶೀಲಿಸಿ. ತಪ್ಪಿದ್ದರೆ ಸರಿಪಡಿಸಿ ನಂತರ ಉಳಿಸಿ.';

  @override
  String get fieldName => 'ಹೆಸರು';

  @override
  String get fieldAge => 'ವಯಸ್ಸು';

  @override
  String get fieldHusband => 'ಪತಿ / ಪಾಲಕರು';

  @override
  String get fieldPhone => 'ಫೋನ್ ನಂಬರ್';

  @override
  String get fieldEmail => 'ಇಮೇಲ್ ವಿಳಾಸ';

  @override
  String get fieldEmailWhy =>
      'ಇದರಿಂದಲೇ ಅವರು ತಾಯಿ ಸೇತು ಆ್ಯಪ್‌ಗೆ ಒಳಗೆ ಬರುತ್ತಾರೆ. ಇದಿಲ್ಲದೆ ಅವರು ತಮ್ಮ ದಾಖಲೆ ನೋಡಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get emailInvalidField => 'ಸರಿಯಾದ ಇಮೇಲ್ ವಿಳಾಸ ಹಾಕಿ';

  @override
  String get fieldVillage => 'ಗ್ರಾಮ';

  @override
  String get fieldSubCentre => 'ಉಪ ಕೇಂದ್ರ';

  @override
  String get fieldAbha => 'ಆಭಾ ಸಂಖ್ಯೆ';

  @override
  String get fieldLmp => 'ಕೊನೆಯ ಮುಟ್ಟಿನ ದಿನ (LMP)';

  @override
  String get fieldGravida => 'ಗರ್ಭಧಾರಣೆ ಸಂಖ್ಯೆ';

  @override
  String get fieldPara => 'ಹೆರಿಗೆ ಸಂಖ್ಯೆ';

  @override
  String get fieldBloodGroup => 'ರಕ್ತದ ಗುಂಪು';

  @override
  String get fieldHeight => 'ಎತ್ತರ (ಸೆ.ಮೀ.)';

  @override
  String get fieldBpl => 'ಬಿ.ಪಿ.ಎಲ್. ಕುಟುಂಬ';

  @override
  String get pickDate => 'ದಿನ ಆರಿಸಿ';

  @override
  String get homeLocationSection => 'ಅವರ ಮನೆ';

  @override
  String get homeLocationCapture => 'ಈ ಮನೆಯ ಸ್ಥಳ ಗುರುತಿಸಿ';

  @override
  String get homeLocationBusy => 'ಸ್ಥಳ ಹುಡುಕುತ್ತಿದೆ…';

  @override
  String get homeLocationFound => 'ಸ್ಥಳ ಗುರುತಿಸಲಾಗಿದೆ';

  @override
  String get homeLocationMissing =>
      'ಇನ್ನೂ ಸ್ಥಳ ಇಲ್ಲ — ಮುಂದಿನ ಭೇಟಿಯಲ್ಲಿ ಗುರುತಿಸಬಹುದು';

  @override
  String get homeLocationWhy =>
      'ಈಗ ಗುರುತಿಸಿದರೆ, ಮುಂದಿನ ಸಲ ನೀವು ಅಥವಾ ನಿಮ್ಮ ಬದಲಿಗೆ ಬರುವವರು ನೇರವಾಗಿ ಇಲ್ಲಿಗೆ ಬರಬಹುದು.';

  @override
  String get homeLocationDirections => 'ಅವರ ಮನೆಗೆ ದಾರಿ';

  @override
  String get homeLocationStreetView => 'ಬೀದಿ ನೋಟ';

  @override
  String get homeLocationNoStreetView =>
      'ಇಲ್ಲಿ ಬೀದಿ ನೋಟ ಇಲ್ಲ. ಹೆಚ್ಚಿನ ಹಳ್ಳಿಗಳಲ್ಲಿ ಇದು ಸಿಗುವುದಿಲ್ಲ.';

  @override
  String get homeLocationSaved => 'ಸ್ಥಳ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get homeLocationFailed =>
      'ಸ್ಥಳ ಸಿಗಲಿಲ್ಲ. ಮನೆಯ ಹೊರಗೆ ನಿಂತು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get homeLocationOpenFailed => 'ನಕ್ಷೆ ತೆರೆಯಲು ಆಗಲಿಲ್ಲ';

  @override
  String get prevComplications => 'ಹಿಂದಿನ ತೊಂದರೆಗಳು';

  @override
  String get compCSection => 'ಸಿಸೇರಿಯನ್';

  @override
  String get compStillbirth => 'ಮೃತ ಶಿಶು ಜನನ';

  @override
  String get compPph => 'ಹೆರಿಗೆ ನಂತರ ರಕ್ತಸ್ರಾವ';

  @override
  String get compHypertension => 'ಅಧಿಕ ರಕ್ತದೊತ್ತಡ';

  @override
  String get compGdm => 'ಗರ್ಭಾವಸ್ಥೆಯ ಸಕ್ಕರೆ ಕಾಯಿಲೆ';

  @override
  String get compAnaemia => 'ರಕ್ತಹೀನತೆ';

  @override
  String eddComputed(String date) {
    return 'ಹೆರಿಗೆ ದಿನ $date';
  }

  @override
  String gaComputed(int weeks, int days) {
    return '$weeks ವಾರ $days ದಿನ ಗರ್ಭಿಣಿ';
  }

  @override
  String get saveMother => 'ಉಳಿಸಿ ಮತ್ತು ನೋಂದಾಯಿಸಿ';

  @override
  String motherSaved(String name) {
    return '$name ನೋಂದಣಿ ಆಗಿದೆ';
  }

  @override
  String get schemesQualified => 'ಈ ಯೋಜನೆಗಳಿಗೆ ಅರ್ಹರು';

  @override
  String get schemeThayiBhagya => 'ತಾಯಿ ಭಾಗ್ಯ';

  @override
  String get schemePmmvy => 'ಪಿ.ಎಂ.ಎಂ.ವಿ.ವೈ';

  @override
  String get schemeJsy => 'ಜನನಿ ಸುರಕ್ಷಾ ಯೋಜನೆ';

  @override
  String get schemePrasootiAraike => 'ಪ್ರಸೂತಿ ಆರೈಕೆ';

  @override
  String get schemeMadilu => 'ಮಡಿಲು ಕಿಟ್';

  @override
  String get schemeJssk => 'ಜೆ.ಎಸ್.ಎಸ್.ಕೆ';

  @override
  String get schemesNote =>
      'ಇಲ್ಲಿ ತೋರಿಸಿರುವ ಅರ್ಹತೆ ಸೂಚನೆ ಮಾತ್ರ. ಪಿಎಚ್‌ಸಿಯಲ್ಲಿ ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.';

  @override
  String get profileTabTimeline => 'ಕಾಲಪಟ್ಟಿ';

  @override
  String get profileTabVitals => 'ಅಳತೆಗಳು';

  @override
  String get profileTabSchemes => 'ಯೋಜನೆ';

  @override
  String get profileTabQr => 'ಅವರ ಕೋಡ್';

  @override
  String gaLabel(int weeks, int days) {
    return 'GA $weeks ವಾರ $days ದಿನ';
  }

  @override
  String get eddLabel => 'ಹೆರಿಗೆ ದಿನ';

  @override
  String get bloodGroupLabel => 'ರಕ್ತದ ಗುಂಪು';

  @override
  String get riskGreen => 'ಸಾಮಾನ್ಯ';

  @override
  String get riskAmber => 'ಗಮನ ಬೇಕು';

  @override
  String get riskRed => 'ಅಧಿಕ ಅಪಾಯ';

  @override
  String get newVisit => 'ಹೊಸ ಭೇಟಿ';

  @override
  String get timelineEmpty => 'ಇನ್ನೂ ಯಾವ ಭೇಟಿಯೂ ದಾಖಲಾಗಿಲ್ಲ';

  @override
  String recordedBy(String name) {
    return '$name ದಾಖಲಿಸಿದ್ದಾರೆ';
  }

  @override
  String get entryVisit => 'ಎಎನ್‌ಸಿ ಭೇಟಿ';

  @override
  String get entryAlert => 'ಎಚ್ಚರಿಕೆ';

  @override
  String get entryReferral => 'ಉಲ್ಲೇಖ';

  @override
  String correctionOf(int number) {
    return '$numberನೇ ಭೇಟಿಯ ತಿದ್ದುಪಡಿ';
  }

  @override
  String get vitalsBp => 'ರಕ್ತದೊತ್ತಡ';

  @override
  String get vitalsWeight => 'ತೂಕ';

  @override
  String get vitalsHb => 'ಹಿಮೋಗ್ಲೋಬಿನ್';

  @override
  String get chartNoData => 'ಇನ್ನೂ ಅಳತೆ ಆಗಿಲ್ಲ';

  @override
  String get qrOnHerPhone => 'ಕೋಡ್ ಅವರ ಸ್ವಂತ ಫೋನ್‌ನಲ್ಲಿ ಇರುತ್ತದೆ';

  @override
  String get qrWhyNotHere =>
      'ಕೆಲವು ನಿಮಿಷಕ್ಕೊಮ್ಮೆ ಅದು ಬದಲಾಗುತ್ತದೆ, ಹಾಗಾಗಿ ಫೋಟೋ ತೆಗೆದರೂ ಬೇಗನೆ ನಿಷ್ಪ್ರಯೋಜಕವಾಗುತ್ತದೆ. ಈ ಫೋನ್‌ನಲ್ಲಿ ಅದನ್ನು ಮಾಡಲು ಆಗುವುದಿಲ್ಲ — ಅವರೇ ತಮ್ಮ ಫೋನ್ ತೋರಿಸುವುದೇ ಅನುಮತಿ, ಅದನ್ನು ನೀವು ಅವರ ಪರವಾಗಿ ಮಾಡಲಾಗದು.';

  @override
  String qrHelpSignIn(String email) {
    return 'ಅವರು ತಾಯಿ ಸೇತು ತೆರೆದು $email ಮೂಲಕ ಸೈನ್ ಇನ್ ಮಾಡಿ, ನಂತರ ತಾಯಿ ಕಾರ್ಡ್ ಒತ್ತಲಿ.';
  }

  @override
  String get qrNoEmail =>
      'ಅವರ ದಾಖಲೆಯಲ್ಲಿ ಇಮೇಲ್ ಇಲ್ಲ, ಹಾಗಾಗಿ ತಾಯಿ ಸೇತುಗೆ ಸೈನ್ ಇನ್ ಮಾಡಲು ಆಗುವುದಿಲ್ಲ. ಈ ಭೇಟಿಯಲ್ಲೇ ಒಂದು ಸೇರಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get qrCaption => 'ಆಸ್ಪತ್ರೆಯಲ್ಲಿ ಈ ಕೋಡ್ ತೋರಿಸಿ';

  @override
  String get callMother => 'ಅವರಿಗೆ ಕರೆ ಮಾಡಿ';

  @override
  String get newVisitTitle => 'ಹೊಸ ಎಎನ್‌ಸಿ ಭೇಟಿ';

  @override
  String visitNumberLabel(int number) {
    return '$numberನೇ ಭೇಟಿ';
  }

  @override
  String get sectionBp => 'ರಕ್ತದೊತ್ತಡ';

  @override
  String get bpSys => 'ಮೇಲಿನದು';

  @override
  String get bpDia => 'ಕೆಳಗಿನದು';

  @override
  String get sectionMeasure => 'ತೂಕ ಮತ್ತು ಅಳತೆ';

  @override
  String get weightKgLabel => 'ತೂಕ (ಕೆ.ಜಿ.)';

  @override
  String get fundalHeightLabel => 'ಗರ್ಭದ ಎತ್ತರ (ಸೆ.ಮೀ.)';

  @override
  String get sectionLab => 'ಪರೀಕ್ಷೆಗಳು';

  @override
  String get hbLabel => 'ಹಿಮೋಗ್ಲೋಬಿನ್ (g/dL)';

  @override
  String get urineAlbuminLabel => 'ಮೂತ್ರದ ಅಲ್ಬುಮಿನ್';

  @override
  String get albuminNil => 'ಇಲ್ಲ';

  @override
  String get albuminTrace => 'ಸ್ವಲ್ಪ';

  @override
  String get albuminPlus1 => '+1';

  @override
  String get albuminPlus2 => '+2 ಅಥವಾ ಹೆಚ್ಚು';

  @override
  String get sectionFetal => 'ಮಗುವಿನ ಸ್ಥಿತಿ';

  @override
  String get fetalHrLabel => 'ಹೃದಯ ಬಡಿತ (ನಿಮಿಷಕ್ಕೆ)';

  @override
  String get fetalMovementLabel => 'ಮಗು ಆಡುತ್ತಿದೆ';

  @override
  String get sectionDanger => 'ಅಪಾಯದ ಲಕ್ಷಣಗಳು';

  @override
  String get dsBleeding => 'ರಕ್ತಸ್ರಾವ';

  @override
  String get dsHeadache => 'ತೀವ್ರ ತಲೆನೋವು';

  @override
  String get dsVision => 'ಕಣ್ಣು ಮಂಜಾಗುವುದು';

  @override
  String get dsSwelling => 'ಮುಖ ಅಥವಾ ಕೈ ಊತ';

  @override
  String get dsFever => 'ಜ್ವರ';

  @override
  String get dsConvulsions => 'ಸೆಳೆತ';

  @override
  String get dsNoMovement => 'ಮಗು ಆಡುತ್ತಿಲ್ಲ';

  @override
  String get sectionTablets => 'ಮಾತ್ರೆ ಮತ್ತು ಲಸಿಕೆ';

  @override
  String get ifaTakenLabel => 'ಕಬ್ಬಿಣಾಂಶದ ಮಾತ್ರೆ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದ್ದಾರೆ';

  @override
  String get calciumTakenLabel => 'ಕ್ಯಾಲ್ಸಿಯಂ ಮಾತ್ರೆ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದ್ದಾರೆ';

  @override
  String get ttDoseLabel => 'ಟಿ.ಟಿ. ಡೋಸ್ ಹಾಕಲಾಗಿದೆ';

  @override
  String get ttNone => 'ಇಲ್ಲ';

  @override
  String get sectionNotes => 'ಟಿಪ್ಪಣಿ';

  @override
  String get notesHint => 'ಬೇರೆ ಏನಾದರೂ ಬರೆಯಬೇಕಿದ್ದರೆ';

  @override
  String get addPhoto => 'ಫೋಟೋ ಸೇರಿಸಿ';

  @override
  String get photoAdded => 'ಫೋಟೋ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get saveVisit => 'ಭೇಟಿ ಉಳಿಸಿ';

  @override
  String get visitSaved => 'ಭೇಟಿ ಈ ಫೋನಿನಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get rangeConfirmTitle => 'ಇದು ಸರಿಯೇ?';

  @override
  String rangeConfirmBody(String value) {
    return '$value — ಇದು ಸರಿಯೇ?';
  }

  @override
  String get rangeYes => 'ಹೌದು, ಸರಿ ಇದೆ';

  @override
  String get rangeNo => 'ಇಲ್ಲ, ತಿದ್ದುತ್ತೇನೆ';

  @override
  String get riskBannerNormal => 'ಇಲ್ಲಿಯವರೆಗೆ ಚಿಂತೆಯ ವಿಷಯ ಇಲ್ಲ';

  @override
  String get gpsUnavailable => 'ಜಿಪಿಎಸ್ ಸಿಗಲಿಲ್ಲ — ಭೇಟಿ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get riskAlertTitle => 'ಈಗಲೇ ಗಮನ ಬೇಕು';

  @override
  String get referToPhc => 'ಪಿಎಚ್‌ಸಿಗೆ ಕಳುಹಿಸಿ';

  @override
  String get callPhc => 'ಪಿಎಚ್‌ಸಿಗೆ ಕರೆ';

  @override
  String get advisoryFooter => 'ಸಲಹೆ ಮಾತ್ರ — ರೋಗನಿರ್ಣಯವಲ್ಲ';

  @override
  String get referralCreated => 'ಉಲ್ಲೇಖ ಉಳಿಸಲಾಗಿದೆ, ಕಳುಹಿಸಲು ಸಾಲಿನಲ್ಲಿದೆ';

  @override
  String get dismissAlert => 'ನಾನು ನೋಡಿದೆ';

  @override
  String referralTo(String facility) {
    return '$facility ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ';
  }

  @override
  String get phcName => 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ';

  @override
  String get callFailed => 'ಕರೆ ಮಾಡಲು ಆಗಲಿಲ್ಲ';

  @override
  String get tasksTitle => 'ನನ್ನ ಕೆಲಸಗಳು';

  @override
  String get tabOpen => 'ಬಾಕಿ';

  @override
  String get tabDone => 'ಮುಗಿದವು';

  @override
  String get tabMissed => 'ತಪ್ಪಿದವು';

  @override
  String get markDone => 'ಮುಗಿಯಿತು ಎಂದು ಗುರುತಿಸಿ';

  @override
  String get taskDoneVia => 'ಭೇಟಿಯಿಂದ ಮುಗಿದಿದೆ';

  @override
  String get noTasksHere => 'ಇಲ್ಲಿ ಏನೂ ಇಲ್ಲ';

  @override
  String get incentiveTitle => 'ಪ್ರೋತ್ಸಾಹ ಧನ ಪಟ್ಟಿ';

  @override
  String get incentiveNote =>
      'ಇಲ್ಲಿ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾತ್ರ ತೋರಿಸಲಾಗಿದೆ. ಕ್ಲೈಮ್ ಮಾಡುವ ಮೊದಲು ಈಗಿನ ದರಗಳನ್ನು ನಿಮ್ಮ ಎಎನ್‌ಎಂ ಅವರಲ್ಲಿ ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.';

  @override
  String claimableItems(int count) {
    return '$count ಚಟುವಟಿಕೆಗಳು ಕ್ಲೈಮ್‌ಗೆ ಅರ್ಹ';
  }

  @override
  String get catRegistration => 'ತಾಯಿ ನೋಂದಣಿ';

  @override
  String get catAncVisit => 'ಎಎನ್‌ಸಿ ಭೇಟಿ';

  @override
  String get catReferral => 'ಪಿಎಚ್‌ಸಿಗೆ ಉಲ್ಲೇಖ';

  @override
  String get catHighRiskFollowUp => 'ಅಧಿಕ ಅಪಾಯದ ಅನುಸರಣೆ';

  @override
  String get incentiveOffline =>
      'ಈ ಫೋನಿನ ಮಾಹಿತಿಯಿಂದ ತಯಾರಿಸಲಾಗಿದೆ. ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲದೆಯೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ.';

  @override
  String get shareSummary => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get syncTitle => 'ಸಿಂಕ್ ಸ್ಥಿತಿ';

  @override
  String get retryNow => 'ಈಗ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get outboxEmpty => 'ಎಲ್ಲವೂ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get outStatusPending => 'ಕಾಯುತ್ತಿದೆ';

  @override
  String get outStatusSyncing => 'ಕಳುಹಿಸುತ್ತಿದೆ';

  @override
  String get outStatusSynced => 'ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get outStatusFailed => 'ವಿಫಲವಾಗಿದೆ';

  @override
  String retryCountLabel(int count) {
    return '$count ಪ್ರಯತ್ನ';
  }

  @override
  String get demoOfflineToggle => 'ಡೆಮೊ: ಆಫ್‌ಲೈನ್ ಮಾಡಿ';

  @override
  String get demoOfflineOn => 'ಆಫ್‌ಲೈನ್ ಮೋಡ್ ಚಾಲೂ ಇದೆ. ಏನೂ ಕಳುಹಿಸುವುದಿಲ್ಲ.';

  @override
  String get recordVisit => 'ಎಎನ್‌ಸಿ ಭೇಟಿ';

  @override
  String get recordMother => 'ತಾಯಿ ನೋಂದಣಿ';

  @override
  String get recordReferral => 'ಉಲ್ಲೇಖ';

  @override
  String get recordAlert => 'ಎಚ್ಚರಿಕೆ';

  @override
  String get recordTask => 'ಕೆಲಸ';

  @override
  String get emailVerifyAction => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get emailVerifiedChip => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get emailNotVerifiedOffline => 'ಇಂಟರ್ನೆಟ್ ಇದ್ದಾಗ ಪರಿಶೀಲಿಸಿ';

  @override
  String get emailVerifyTitle => 'ಅವರ ಇಮೇಲ್ ಪರಿಶೀಲಿಸಿ';

  @override
  String emailVerifyBody(String email) {
    return '$email ಗೆ ಕೋಡ್ ಕಳುಹಿಸಲಾಗಿದೆ. ಅವರನ್ನು ಓದಲು ಹೇಳಿ, ಇಲ್ಲಿ ನಮೂದಿಸಿ.';
  }

  @override
  String get emailVerifyConfirm => 'ಖಚಿತಪಡಿಸಿ';

  @override
  String get emailVerifiedOk =>
      'ಇಮೇಲ್ ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಇದರಿಂದ ಅವರು ತಾಯಿ ಸೇತು ಆ್ಯಪ್‌ಗೆ ಲಾಗಿನ್ ಮಾಡಬಹುದು.';

  @override
  String get emailVerifiedPending =>
      'ಕೋಡ್ ಸರಿಯಾಗಿದೆ. ಅವರ ದಾಖಲೆ ಸಿಂಕ್ ಆದಾಗ ಉಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get emailVerifyWrongCode => 'ಕೋಡ್ ತಾಳೆಯಾಗಲಿಲ್ಲ. ಇನ್ನೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get emailVerifyOffline =>
      'ಕೋಡ್ ಕಳುಹಿಸಲು ಆಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get resendEverything => 'ಎಲ್ಲವನ್ನೂ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String resendQueued(int count) {
    return '$count ದಾಖಲೆಗಳನ್ನು ಮತ್ತೆ ಕಳುಹಿಸಲು ಸಾಲಿಗೆ ಸೇರಿಸಲಾಗಿದೆ';
  }
}
