// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ASHA Setu';

  @override
  String get appTagline => 'Your field companion';

  @override
  String get langKannada => 'ಕನ್ನಡ';

  @override
  String get langEnglish => 'English';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageLabel => 'Language';

  @override
  String get continueLabel => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get optional => 'optional';

  @override
  String get loading => 'Loading…';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get emptyGeneric => 'Nothing here yet';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get requiredField => 'This is needed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get logout => 'Sign out';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get logoutWarningTitle => 'Sign out?';

  @override
  String get logoutWarningBody =>
      'You will need internet to sign in again. Do not sign out while you are in a village with no network.';

  @override
  String logoutPendingWarning(int count) {
    return '$count entries have not been sent yet. They stay on this phone, but sign in again soon so they can be sent.';
  }

  @override
  String get logoutConfirm => 'Yes, sign out';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'Sign in once. You stay signed in even with no network.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get emailInvalid => 'Please enter a correct email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordInvalid => 'Please enter your password';

  @override
  String get signIn => 'Sign in';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSentTo(String email) {
    return 'Sent to $email';
  }

  @override
  String get otpInvalid => 'Please enter all 6 digits';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpSending => 'Sending the code…';

  @override
  String get otpVerifying => 'Checking…';

  @override
  String get otpSendFailed =>
      'The code could not be sent. Please check the address and try again.';

  @override
  String get otpWrongCode =>
      'That code is not right. Please check your email and try again.';

  @override
  String get otpResend => 'Send the code again';

  @override
  String get otpChangeEmail => 'Change email';

  @override
  String get otpNoNetwork =>
      'No internet. You need a signal once, to sign in the first time.';

  @override
  String get otpOfflineFallback =>
      'No network — signed in on this phone only. Sign in properly when you have a signal.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordBody =>
      'Please contact your ANM supervisor to reset your password. Password reset from the app is coming soon.';

  @override
  String get loginFailed =>
      'Could not sign in. Please check your email and password.';

  @override
  String get setPinTitle => 'Set a 4 digit PIN';

  @override
  String get setPinBody =>
      'This phone may be shared. The PIN keeps other women\'s records private.';

  @override
  String get confirmPinTitle => 'Enter the PIN again';

  @override
  String get pinMismatch => 'The two PINs do not match. Please try again.';

  @override
  String get enterPinTitle => 'Enter your PIN';

  @override
  String get enterPinBody => 'Enter your 4 digit PIN to continue';

  @override
  String get pinWrong => 'Wrong PIN. Please try again.';

  @override
  String get unlock => 'Unlock';

  @override
  String greeting(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get todaysWork => 'TODAY\'S WORK';

  @override
  String syncOffline(int count) {
    return 'Offline — $count entries waiting';
  }

  @override
  String syncPending(int count) {
    return '$count entries waiting to be sent';
  }

  @override
  String get syncAllDone => 'Everything is sent';

  @override
  String get syncing => 'Sending…';

  @override
  String get statAssigned => 'Mothers';

  @override
  String get statHighRisk => 'High risk';

  @override
  String get statVisitsDue => 'Visits due';

  @override
  String get registerMother => 'Register a mother';

  @override
  String get noTasks => 'No work pending today';

  @override
  String get originDoctor => 'Doctor assigned';

  @override
  String get originSystem => 'Overdue';

  @override
  String get originSelf => 'My note';

  @override
  String gestationWeeks(int weeks) {
    return '$weeks weeks';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get mothersTitle => 'Mothers';

  @override
  String get searchMothers => 'Search by name or village';

  @override
  String get tabAll => 'All';

  @override
  String get tabHighRisk => 'High risk';

  @override
  String get tabVisitsDue => 'Visits due';

  @override
  String get noMothers => 'No mothers registered yet';

  @override
  String get registerTitle => 'Register a mother';

  @override
  String get scanThayiCard => 'Scan Thayi Card';

  @override
  String get scanHint => 'Take a photo of her paper card';

  @override
  String get manualEntry => 'Enter by hand';

  @override
  String get scanning => 'Reading the card…';

  @override
  String get confirmEachField =>
      'Check every detail below. Correct anything that is wrong before saving.';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldHusband => 'Husband / guardian';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldEmail => 'Email address';

  @override
  String get fieldEmailWhy =>
      'She signs in to Thayi Setu with this. Without it she cannot open her own record.';

  @override
  String get emailInvalidField => 'Please enter a correct email address';

  @override
  String get fieldVillage => 'Village';

  @override
  String get fieldSubCentre => 'Sub-centre';

  @override
  String get fieldAbha => 'ABHA id';

  @override
  String get fieldLmp => 'Last period date (LMP)';

  @override
  String get fieldGravida => 'Gravida';

  @override
  String get fieldPara => 'Para';

  @override
  String get fieldBloodGroup => 'Blood group';

  @override
  String get fieldHeight => 'Height (cm)';

  @override
  String get fieldBpl => 'BPL family';

  @override
  String get pickDate => 'Choose date';

  @override
  String get homeLocationSection => 'HER HOUSE';

  @override
  String get homeLocationCapture => 'Pin this house';

  @override
  String get homeLocationBusy => 'Finding the location…';

  @override
  String get homeLocationFound => 'Location pinned';

  @override
  String get homeLocationMissing =>
      'No location yet — you can pin it on your next visit';

  @override
  String get homeLocationWhy =>
      'Pinning it now means you, or anyone covering for you, can navigate straight here next time.';

  @override
  String get homeLocationDirections => 'Directions to her house';

  @override
  String get homeLocationStreetView => 'Street view';

  @override
  String get homeLocationNoStreetView =>
      'No street view here. Most villages have no coverage.';

  @override
  String get homeLocationSaved => 'Location saved';

  @override
  String get homeLocationFailed =>
      'Could not get a location. Try outside the house.';

  @override
  String get homeLocationOpenFailed => 'Could not open maps';

  @override
  String get prevComplications => 'PREVIOUS COMPLICATIONS';

  @override
  String get compCSection => 'Caesarean';

  @override
  String get compStillbirth => 'Stillbirth';

  @override
  String get compPph => 'Bleeding after delivery';

  @override
  String get compHypertension => 'High blood pressure';

  @override
  String get compGdm => 'Diabetes in pregnancy';

  @override
  String get compAnaemia => 'Anaemia';

  @override
  String eddComputed(String date) {
    return 'Delivery date $date';
  }

  @override
  String gaComputed(int weeks, int days) {
    return '$weeks weeks $days days pregnant';
  }

  @override
  String get saveMother => 'Save and register';

  @override
  String motherSaved(String name) {
    return '$name is registered';
  }

  @override
  String get schemesQualified => 'SHE QUALIFIES FOR';

  @override
  String get schemeThayiBhagya => 'Thayi Bhagya';

  @override
  String get schemePmmvy => 'PMMVY';

  @override
  String get schemeJsy => 'JSY';

  @override
  String get schemePrasootiAraike => 'Prasooti Araike';

  @override
  String get schemeMadilu => 'Madilu Kit';

  @override
  String get schemeJssk => 'JSSK';

  @override
  String get schemesNote =>
      'Eligibility shown here is indicative. Confirm with the PHC.';

  @override
  String get profileTabTimeline => 'Timeline';

  @override
  String get profileTabVitals => 'Vitals';

  @override
  String get profileTabSchemes => 'Schemes';

  @override
  String get profileTabQr => 'Her code';

  @override
  String gaLabel(int weeks, int days) {
    return 'GA ${weeks}w ${days}d';
  }

  @override
  String get eddLabel => 'EDD';

  @override
  String get bloodGroupLabel => 'Blood group';

  @override
  String get riskGreen => 'Normal';

  @override
  String get riskAmber => 'Needs attention';

  @override
  String get riskRed => 'High risk';

  @override
  String get newVisit => 'New visit';

  @override
  String get timelineEmpty => 'No visits recorded yet';

  @override
  String recordedBy(String name) {
    return 'Recorded by $name';
  }

  @override
  String get entryVisit => 'ANC visit';

  @override
  String get entryAlert => 'Alert';

  @override
  String get entryReferral => 'Referral';

  @override
  String correctionOf(int number) {
    return 'Correction of visit $number';
  }

  @override
  String get vitalsBp => 'BLOOD PRESSURE';

  @override
  String get vitalsWeight => 'WEIGHT';

  @override
  String get vitalsHb => 'HAEMOGLOBIN';

  @override
  String get chartNoData => 'No readings yet';

  @override
  String get qrOnHerPhone => 'Her code is on her own phone';

  @override
  String get qrWhyNotHere =>
      'It changes every few minutes, so a photograph of it stops working almost at once. This phone cannot produce it — her holding out her own phone is what gives permission, and that is not something you can do for her.';

  @override
  String qrHelpSignIn(String email) {
    return 'She opens Thayi Setu and signs in with $email, then taps Thayi card.';
  }

  @override
  String get qrNoEmail =>
      'There is no email on her record yet, so she cannot sign in to Thayi Setu. Add one and verify it on this visit.';

  @override
  String get qrCaption => 'Show this code at the facility';

  @override
  String get callMother => 'Call her';

  @override
  String get newVisitTitle => 'New ANC visit';

  @override
  String visitNumberLabel(int number) {
    return 'Visit $number';
  }

  @override
  String get sectionBp => 'BLOOD PRESSURE';

  @override
  String get bpSys => 'Upper';

  @override
  String get bpDia => 'Lower';

  @override
  String get sectionMeasure => 'WEIGHT AND MEASUREMENT';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get fundalHeightLabel => 'Fundal height (cm)';

  @override
  String get sectionLab => 'TESTS';

  @override
  String get hbLabel => 'Haemoglobin (g/dL)';

  @override
  String get urineAlbuminLabel => 'Urine albumin';

  @override
  String get albuminNil => 'Nil';

  @override
  String get albuminTrace => 'Trace';

  @override
  String get albuminPlus1 => '+1';

  @override
  String get albuminPlus2 => '+2 or more';

  @override
  String get sectionFetal => 'BABY';

  @override
  String get fetalHrLabel => 'Heart rate (per minute)';

  @override
  String get fetalMovementLabel => 'Baby is moving';

  @override
  String get sectionDanger => 'DANGER SIGNS';

  @override
  String get dsBleeding => 'Bleeding';

  @override
  String get dsHeadache => 'Severe headache';

  @override
  String get dsVision => 'Blurred vision';

  @override
  String get dsSwelling => 'Swelling of face or hands';

  @override
  String get dsFever => 'Fever';

  @override
  String get dsConvulsions => 'Fits';

  @override
  String get dsNoMovement => 'Baby not moving';

  @override
  String get sectionTablets => 'TABLETS AND VACCINE';

  @override
  String get ifaTakenLabel => 'Taking iron tablets';

  @override
  String get calciumTakenLabel => 'Taking calcium tablets';

  @override
  String get ttDoseLabel => 'TT dose given';

  @override
  String get ttNone => 'None';

  @override
  String get sectionNotes => 'NOTES';

  @override
  String get notesHint => 'Anything else worth recording';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get saveVisit => 'Save visit';

  @override
  String get visitSaved => 'Visit saved on this phone';

  @override
  String get rangeConfirmTitle => 'Is this correct?';

  @override
  String rangeConfirmBody(String value) {
    return '$value — is that right?';
  }

  @override
  String get rangeYes => 'Yes, that is right';

  @override
  String get rangeNo => 'No, let me fix it';

  @override
  String get riskBannerNormal => 'Nothing worrying so far';

  @override
  String get gpsUnavailable => 'No GPS — the visit was saved anyway';

  @override
  String get riskAlertTitle => 'This needs attention now';

  @override
  String get referToPhc => 'Refer to PHC';

  @override
  String get callPhc => 'Call PHC';

  @override
  String get advisoryFooter => 'Advisory only — not a diagnosis';

  @override
  String get referralCreated => 'Referral saved and queued';

  @override
  String get dismissAlert => 'I have seen this';

  @override
  String referralTo(String facility) {
    return 'Referred to $facility';
  }

  @override
  String get phcName => 'Government PHC, Hosahalli';

  @override
  String get callFailed => 'Could not open the dialler';

  @override
  String get tasksTitle => 'My tasks';

  @override
  String get tabOpen => 'Open';

  @override
  String get tabDone => 'Done';

  @override
  String get tabMissed => 'Missed';

  @override
  String get markDone => 'Mark done';

  @override
  String get taskDoneVia => 'Closed by a visit';

  @override
  String get noTasksHere => 'Nothing here';

  @override
  String get incentiveTitle => 'Incentive claim sheet';

  @override
  String get incentiveNote =>
      'This lists activities only. Confirm the current rates with your ANM supervisor before claiming.';

  @override
  String claimableItems(int count) {
    return '$count claimable activities';
  }

  @override
  String get catRegistration => 'Mother registration';

  @override
  String get catAncVisit => 'ANC visit';

  @override
  String get catReferral => 'Referral to PHC';

  @override
  String get catHighRiskFollowUp => 'High-risk follow-up';

  @override
  String get incentiveOffline =>
      'Built from this phone. Works with no network.';

  @override
  String get shareSummary => 'Share summary';

  @override
  String get syncTitle => 'Sync status';

  @override
  String get retryNow => 'Retry now';

  @override
  String get outboxEmpty => 'Everything has been sent';

  @override
  String get outStatusPending => 'Waiting';

  @override
  String get outStatusSyncing => 'Sending';

  @override
  String get outStatusSynced => 'Sent';

  @override
  String get outStatusFailed => 'Failed';

  @override
  String retryCountLabel(int count) {
    return '$count attempts';
  }

  @override
  String get demoOfflineToggle => 'Demo: force offline';

  @override
  String get demoOfflineOn => 'Offline mode is on. Nothing will be sent.';

  @override
  String get recordVisit => 'ANC visit';

  @override
  String get recordMother => 'Mother registration';

  @override
  String get recordReferral => 'Referral';

  @override
  String get recordAlert => 'Alert';

  @override
  String get recordTask => 'Task';

  @override
  String get emailVerifyAction => 'Verify';

  @override
  String get emailVerifiedChip => 'Verified';

  @override
  String get emailNotVerifiedOffline => 'Verify when online';

  @override
  String get emailVerifyTitle => 'Verify her email';

  @override
  String emailVerifyBody(String email) {
    return 'A code has been sent to $email. Ask her to read it out, and type it here.';
  }

  @override
  String get emailVerifyConfirm => 'Confirm';

  @override
  String get emailVerifiedOk =>
      'Email verified. She can sign in to Thayi Setu with it.';

  @override
  String get emailVerifiedPending =>
      'Code confirmed. It will be saved when her record syncs.';

  @override
  String get emailVerifyWrongCode => 'That code did not match. Try again.';

  @override
  String get emailVerifyOffline =>
      'Could not send the code. Check the connection.';

  @override
  String get resendEverything => 'Send everything again';

  @override
  String resendQueued(int count) {
    return '$count records queued to send again';
  }
}
