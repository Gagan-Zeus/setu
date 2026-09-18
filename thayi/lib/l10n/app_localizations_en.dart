// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Thayi Setu';

  @override
  String get appTagline => 'Your pregnancy companion';

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
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading…';

  @override
  String get errorTitle => 'Could not load your information';

  @override
  String get errorBody => 'Please try again in a moment.';

  @override
  String get emptyGeneric => 'Nothing here yet';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get logout => 'Sign out';

  @override
  String get welcomeCongrats => 'Congratulations';

  @override
  String get welcomeBody =>
      'You are going to be a mother. This app will walk with you through your pregnancy.';

  @override
  String get welcomeHow =>
      'First we will help you find an ASHA worker near you. Call her, and she will visit you and register you.';

  @override
  String get welcomeStart => 'Let us begin';

  @override
  String get welcomeAlreadyRegistered => 'My ASHA has already registered me';

  @override
  String get nameTitle => 'What is your name?';

  @override
  String get nameWhy =>
      'We use it only to greet you. Nobody else sees this yet.';

  @override
  String get nameLabel => 'Your name';

  @override
  String get nameHint => 'For example, Lakshmi';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get locationTitle => 'Where are you?';

  @override
  String get locationWhy =>
      'We will show you the ASHA workers closest to you, so you can call the right one.';

  @override
  String get locationPrivacy =>
      'Your location is used once, on this phone, to sort the list. It is not saved or sent anywhere.';

  @override
  String get locationAllow => 'Use my location';

  @override
  String get locationSkip => 'Skip this';

  @override
  String get ashaNearbyTitle => 'ASHA workers near you';

  @override
  String get ashaNearbyIntro =>
      'These are the ASHA workers closest to you. Call one and tell her you are pregnant.';

  @override
  String get ashaNearbyIntroNoLocation =>
      'These are the ASHA workers in your area. Call one and tell her you are pregnant.';

  @override
  String get ashaNearbyCall => 'Call her';

  @override
  String get ashaNearbyWhatToSay =>
      'Tell her your name, your village, and that you are pregnant. She will come to your home.';

  @override
  String get ashaNearbyDone => 'I have called';

  @override
  String get waitingTitle => 'Your ASHA will come soon';

  @override
  String waitingTitleNamed(String name) {
    return '$name, your ASHA will come soon';
  }

  @override
  String get waitingBody =>
      'She will visit your home, check your reports, and register you. Then you can sign in.';

  @override
  String get waitingWhatNext => 'WHAT HAPPENS NEXT';

  @override
  String get waitingStep1 => 'You called an ASHA worker';

  @override
  String get waitingStep2 => 'She visits your home and checks your reports';

  @override
  String get waitingStep3 => 'She registers you and enters your email address';

  @override
  String get waitingStep4 =>
      'You get a message at that email, then sign in here';

  @override
  String get waitingHaveEmail => 'I have received the email';

  @override
  String get waitingCallAgain => 'Call an ASHA again';

  @override
  String get loginTitle => 'Enter your email address';

  @override
  String get loginSubtitle => 'We will email you a 6 digit code';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneHint => '10 digits';

  @override
  String get phoneInvalid => 'Please enter a 10 digit number';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get emailInvalid => 'Please enter a correct email address';

  @override
  String get checkYourEmail =>
      'Check your email. The code can take a minute to arrive.';

  @override
  String get emailNotRegistered =>
      'This email is not registered yet. Your ASHA worker adds it when she registers you — please ask her.';

  @override
  String get emailChecking => 'Checking…';

  @override
  String get sendOtp => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSentTo(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get otpInvalid => 'Please enter all 6 digits';

  @override
  String get verify => 'Verify';

  @override
  String get changeNumber => 'Change number';

  @override
  String get resendOtp => 'Send the code again';

  @override
  String get otpSending => 'Sending the code…';

  @override
  String get otpVerifying => 'Checking…';

  @override
  String get otpSendFailed =>
      'The code could not be sent. Please check your number and try again.';

  @override
  String get otpWrongCode =>
      'That code is not right. Please check the SMS and try again.';

  @override
  String get noNetwork =>
      'No internet. Please check your connection and try again.';

  @override
  String get recordNotLinked =>
      'Your Thayi Card record is not linked to this number yet. Please ask your ASHA worker.';

  @override
  String get consentTitle => 'About your information';

  @override
  String get consentWhatTitle => 'What we keep';

  @override
  String get consentWhatBody =>
      'Your name, phone number, and the health details written in your Thayi Card.';

  @override
  String get consentWhoTitle => 'Who can see it';

  @override
  String get consentWhoBody =>
      'Only your ASHA worker and the doctors at your health centre.';

  @override
  String get consentWithdrawTitle => 'You are in control';

  @override
  String get consentWithdrawBody =>
      'You can take back this permission at any time. Tell your ASHA worker.';

  @override
  String get consentAccept => 'I understand and agree';

  @override
  String get consentMustAccept => 'Please agree to continue';

  @override
  String greeting(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get homeToday => 'Your health today';

  @override
  String get weeksPregnantLabel => 'Weeks pregnant';

  @override
  String weeksValue(int weeks) {
    return '$weeks weeks';
  }

  @override
  String weeksProgress(int weeks) {
    return 'Week $weeks of 40';
  }

  @override
  String get eddLabel => 'Expected delivery date';

  @override
  String daysRemaining(int days) {
    return '$days days to go';
  }

  @override
  String get nextCheckupLabel => 'Next checkup';

  @override
  String get checkupOverdueBadge => 'Overdue';

  @override
  String get askSetuCardTitle => 'Ask Setu';

  @override
  String get askSetuCardBody =>
      'Ask anything about your pregnancy. Speak or type.';

  @override
  String get exploreLabel => 'YOUR RECORD';

  @override
  String get moreLabel => 'MORE';

  @override
  String get navThayiCard => 'My Thayi Card';

  @override
  String get navCheckups => 'My Checkups';

  @override
  String get navHealth => 'My Health';

  @override
  String get navSchemes => 'My Schemes';

  @override
  String get navProfile => 'My Details';

  @override
  String get profileTitle => 'My Details';

  @override
  String get photoSectionLabel => 'PHOTO';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from phone';

  @override
  String get photoPrivacyNote =>
      'This photo stays on your phone. It is not sent anywhere.';

  @override
  String get photoFailed => 'The photo could not be saved. Please try again.';

  @override
  String get photoRemoved => 'Photo removed';

  @override
  String get yourDetailsSection => 'YOUR DETAILS';

  @override
  String get detailsWrittenByAsha =>
      'These details are written by your ASHA worker. You cannot change them here.';

  @override
  String get reportMistake => 'Something here is wrong';

  @override
  String get accessSection => 'WHO WANTS TO SEE YOUR RECORD';

  @override
  String accessRequestFrom(String name) {
    return '$name wants to see your health record';
  }

  @override
  String accessRequestReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get accessApprove => 'Allow';

  @override
  String get accessReject => 'Do not allow';

  @override
  String accessApproved(String name) {
    return 'You allowed $name';
  }

  @override
  String accessRejected(String name) {
    return 'You did not allow $name';
  }

  @override
  String get accessNone => 'Nobody has asked to see your record';

  @override
  String get accessActiveTitle => 'Can see your record now';

  @override
  String accessActiveUntil(String date) {
    return 'Until $date';
  }

  @override
  String get accessByQr => 'Because you showed your QR code';

  @override
  String get accessRevoke => 'Stop this';

  @override
  String get accessRevoked => 'Stopped';

  @override
  String get accessExplain =>
      'A doctor can only open your record if you allow it, or if you show your QR code at the hospital.';

  @override
  String get consentSection => 'YOUR PERMISSION';

  @override
  String consentGivenOn(String date) {
    return 'You agreed on $date';
  }

  @override
  String get consentNotRecorded => 'No agreement recorded';

  @override
  String get withdrawConsent => 'Take back my permission';

  @override
  String get withdrawConsentTitle => 'Take back your permission?';

  @override
  String get withdrawConsentBody =>
      'You will be signed out and this phone will stop showing your record. Your ASHA worker and health centre still keep your paper record. You can agree again any time.';

  @override
  String get withdrawConsentConfirm => 'Yes, take it back';

  @override
  String get settingsSection => 'SETTINGS';

  @override
  String get navDangerSigns => 'Danger Signs';

  @override
  String get navAsha => 'My ASHA Worker';

  @override
  String get navAfterDelivery => 'After Delivery';

  @override
  String get emergencyShort => 'Emergency';

  @override
  String get emergencyTitle => 'Emergency';

  @override
  String get emergencyIntro => 'Show this screen to whoever is helping you.';

  @override
  String get bloodGroupLabel => 'Blood group';

  @override
  String get riskFlagsLabel => 'Health warnings';

  @override
  String get allergiesLabel => 'Allergies';

  @override
  String get noneRecorded => 'None recorded';

  @override
  String get callAsha => 'Call ASHA worker';

  @override
  String get callPhc => 'Call health centre';

  @override
  String get callAmbulance => 'Call 108 ambulance';

  @override
  String get nearestHospitalLabel => 'Nearest hospital';

  @override
  String get directions => 'Show the way';

  @override
  String distanceKm(String km) {
    return '$km km away';
  }

  @override
  String get callFailed => 'Could not open the dialler';

  @override
  String get thayiCardTitle => 'My Thayi Card';

  @override
  String get qrCaption => 'Show this code at the hospital';

  @override
  String get worksOffline => 'Works without internet';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldAge => 'Age';

  @override
  String ageYears(int age) {
    return '$age years';
  }

  @override
  String get fieldGuardian => 'Husband / guardian';

  @override
  String get fieldVillage => 'Village';

  @override
  String get fieldBloodGroup => 'Blood group';

  @override
  String get fieldEdd => 'Delivery date';

  @override
  String get fieldCardNumber => 'Thayi Card number';

  @override
  String get fieldAsha => 'ASHA worker';

  @override
  String get fieldPhc => 'Health centre';

  @override
  String get checkupsTitle => 'My Checkups';

  @override
  String get tabUpcoming => 'Coming up';

  @override
  String get tabCompleted => 'Done';

  @override
  String visitNumber(int number) {
    return 'Checkup $number';
  }

  @override
  String get whatHappensLabel => 'What will be done';

  @override
  String get locationLabel => 'Where';

  @override
  String get weightLabel => 'Weight';

  @override
  String weightKg(String kg) {
    return '$kg kg';
  }

  @override
  String get bpLabel => 'Blood pressure';

  @override
  String bpValue(int systolic, int diastolic) {
    return '$systolic/$diastolic';
  }

  @override
  String recordedBy(String name) {
    return 'Recorded by $name';
  }

  @override
  String get overdueTitle => 'This checkup is overdue';

  @override
  String get overdueBody =>
      'Please do not wait. Talk to your ASHA worker today.';

  @override
  String get contactAsha => 'Contact your ASHA';

  @override
  String get emptyUpcoming => 'No checkups booked yet';

  @override
  String get emptyCompleted => 'No checkups done yet';

  @override
  String get healthTitle => 'My Health';

  @override
  String get riskFlagsSection => 'BLOOD GROUP AND WARNINGS';

  @override
  String get noRiskFlags => 'No warnings';

  @override
  String get weightHistory => 'WEIGHT';

  @override
  String get bpHistory => 'BLOOD PRESSURE';

  @override
  String get systolic => 'Upper';

  @override
  String get diastolic => 'Lower';

  @override
  String weekShort(int week) {
    return 'W$week';
  }

  @override
  String get tabletsSection => 'TABLETS TODAY';

  @override
  String get tabletIfa => 'Iron tablet (IFA)';

  @override
  String get tabletCalcium => 'Calcium tablet';

  @override
  String get tabletIfaNote => 'One tablet after food';

  @override
  String get tabletCalciumNote => 'One tablet, not with the iron tablet';

  @override
  String get markTaken => 'Taken';

  @override
  String get markNotTaken => 'Not taken';

  @override
  String get ttSection => 'TT VACCINE';

  @override
  String ttDose(int number) {
    return 'TT dose $number';
  }

  @override
  String get statusGiven => 'Given';

  @override
  String get statusDue => 'Due';

  @override
  String givenOn(String date) {
    return 'Given on $date';
  }

  @override
  String get chartNoData => 'No readings yet';

  @override
  String get schemesTitle => 'My Schemes';

  @override
  String get badgeEligible => 'You are eligible';

  @override
  String get badgeNotEligible => 'Not eligible now';

  @override
  String get whatYouGet => 'What you get';

  @override
  String get documentsNeeded => 'Papers to carry';

  @override
  String get nearbyHospitals => 'Nearby hospitals';

  @override
  String get schemesFootnote =>
      'Benefits and eligibility shown here are indicative only. Please confirm with your ASHA worker or your health centre.';

  @override
  String get schemeThayiBhagyaName => 'Thayi Bhagya';

  @override
  String get schemeThayiBhagyaBenefit =>
      'Free delivery at an approved private hospital when a government hospital is far away.';

  @override
  String get schemePmmvyName => 'PMMVY';

  @override
  String get schemePmmvyBenefit =>
      'Cash help for your first child, paid into your bank account in instalments after checkups.';

  @override
  String get schemeJsyName => 'JSY';

  @override
  String get schemeJsyBenefit =>
      'Cash help when you deliver in a government hospital, given after the delivery.';

  @override
  String get schemePrasootiAraikeName => 'Prasooti Araike';

  @override
  String get schemePrasootiAraikeBenefit =>
      'Help for rest and food during the last months of pregnancy for BPL families.';

  @override
  String get schemeMadiluName => 'Madilu Kit';

  @override
  String get schemeMadiluBenefit =>
      'A kit of clothes and things for you and the baby, given at the hospital after delivery.';

  @override
  String get schemeJsskName => 'JSSK';

  @override
  String get schemeJsskBenefit =>
      'Free delivery, free medicines, free tests, free food and free transport at government hospitals.';

  @override
  String get docThayiCard => 'Thayi Card';

  @override
  String get docAadhaar => 'Your Aadhaar card';

  @override
  String get docBankPassbook => 'Bank passbook in your name';

  @override
  String get docBplCard => 'BPL / ration card';

  @override
  String get docHusbandAadhaar => 'Husband\'s Aadhaar card';

  @override
  String get docMchRegistration => 'Pregnancy registration slip';

  @override
  String get docDeliveryProof => 'Delivery discharge paper';

  @override
  String get askSetuTitle => 'Ask Setu';

  @override
  String get chatWelcome =>
      'Namaskara. Ask me anything about your pregnancy. You can speak or type.';

  @override
  String get chatHint => 'Write your question';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSpeak => 'Speak';

  @override
  String get chatListening => 'Listening…';

  @override
  String get chatThinking => 'Thinking…';

  @override
  String get chatDisclaimer => 'Advice only — not a doctor\'s opinion';

  @override
  String get suggestionsLabel => 'Common questions';

  @override
  String get topicFood => 'Food';

  @override
  String get topicRest => 'Rest and work';

  @override
  String get topicAfterDelivery => 'After delivery';

  @override
  String get qFood1 => 'What should I eat every day?';

  @override
  String get qFood2 => 'Can I drink tea and coffee?';

  @override
  String get qFood3 => 'I feel sick in the morning. What can I do?';

  @override
  String get qRest1 => 'How much should I rest?';

  @override
  String get qRest2 => 'Can I do my usual housework?';

  @override
  String get qRest3 => 'Can I travel to my mother\'s village?';

  @override
  String get qAfter1 => 'When should I start feeding the baby?';

  @override
  String get qAfter2 => 'How long should I rest after delivery?';

  @override
  String get qAfter3 => 'When is the baby\'s first vaccine?';

  @override
  String get aMedicineRefusal =>
      'I cannot advise you about medicines or doses. Please ask your ASHA worker or the doctor at your health centre — they know your record.';

  @override
  String get contactAshaFromChat => 'Send this to my ASHA';

  @override
  String messageSentToAsha(String name) {
    return 'Your question has been noted for $name. She will call you back.';
  }

  @override
  String get micPermissionTitle => 'Microphone permission';

  @override
  String get micPermissionBody =>
      'Setu needs the microphone only to listen to your question and turn it into words. Nothing is recorded or kept.';

  @override
  String get micAllow => 'Allow microphone';

  @override
  String get micDenied =>
      'Microphone was not allowed. You can still type your question.';

  @override
  String get micUnavailable =>
      'Voice input is not available on this phone. Please type your question.';

  @override
  String get dangerInterruptTitle => 'This needs attention now';

  @override
  String get dangerInterruptBody =>
      'What you described can be serious. Do not wait for an answer here. Call for help now.';

  @override
  String get dangerInterruptDismiss => 'I am safe, go back';

  @override
  String get dangerInterruptNote =>
      'Your message was not sent. Your safety comes first.';

  @override
  String get dangerSignsTitle => 'Danger Signs';

  @override
  String get dangerSignsIntro =>
      'If any of these happen, get help the same hour. Do not wait for the next checkup.';

  @override
  String get whatToDoLabel => 'What to do';

  @override
  String get callMyAsha => 'Call my ASHA';

  @override
  String get dsBleedingTitle => 'Bleeding';

  @override
  String get dsBleedingBody =>
      'Any bleeding from below during pregnancy, even a small amount.';

  @override
  String get dsBleedingDo =>
      'Lie down, do not travel alone, and call your ASHA worker or 108 at once.';

  @override
  String get dsHeadacheTitle => 'Severe headache';

  @override
  String get dsHeadacheBody =>
      'A bad headache that does not go away, especially with swelling.';

  @override
  String get dsHeadacheDo =>
      'Go to the health centre the same day. Your blood pressure must be checked.';

  @override
  String get dsVisionTitle => 'Blurred vision';

  @override
  String get dsVisionBody =>
      'Things look blurred, or you see flashes or spots before your eyes.';

  @override
  String get dsVisionDo =>
      'This can come with high blood pressure. Go to the health centre now.';

  @override
  String get dsSwellingTitle => 'Swelling of face and hands';

  @override
  String get dsSwellingBody =>
      'Puffy face, or fingers so swollen that a ring becomes tight.';

  @override
  String get dsSwellingDo => 'Get your blood pressure and urine checked today.';

  @override
  String get dsFeverTitle => 'Fever';

  @override
  String get dsFeverBody =>
      'Fever with chills, or a burning feeling when passing urine.';

  @override
  String get dsFeverDo =>
      'Do not take any tablet on your own. Go to the health centre.';

  @override
  String get dsConvulsionsTitle => 'Fits or convulsions';

  @override
  String get dsConvulsionsBody =>
      'The body shakes and stiffens, or she becomes unconscious.';

  @override
  String get dsConvulsionsDo =>
      'This is an emergency. Turn her on her side and call 108 immediately.';

  @override
  String get dsMovementTitle => 'Baby is not moving';

  @override
  String get dsMovementBody =>
      'The baby moves less than usual, or you have felt no movement for some hours.';

  @override
  String get dsMovementDo =>
      'Lie on your left side and count the movements. If still less, go to the health centre now.';

  @override
  String get ashaTitle => 'My ASHA Worker';

  @override
  String get ashaRole => 'Your ASHA worker';

  @override
  String get subCentreLabel => 'Sub-centre';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get callNow => 'Call now';

  @override
  String get ashaNote =>
      'She writes your record and visits you at home. Ask her anything, at any time.';

  @override
  String get afterDeliveryTitle => 'After Delivery';

  @override
  String get afterDeliveryNote =>
      'This is what will happen after your baby is born. Nothing here needs to be done yet.';

  @override
  String get immunisationSection => 'BABY\'S VACCINES';

  @override
  String get growthSection => 'BABY\'S GROWTH';

  @override
  String get growthEmpty =>
      'Your baby\'s weight will be written here after birth';

  @override
  String get statusPending => 'Pending';

  @override
  String get vacBcg => 'BCG';

  @override
  String get vacOpv => 'Polio drops (OPV)';

  @override
  String get vacHepB => 'Hepatitis B';

  @override
  String get vacPenta => 'Pentavalent';

  @override
  String get vacRota => 'Rotavirus';

  @override
  String get vacMr => 'Measles-Rubella';

  @override
  String get ageAtBirth => 'At birth';

  @override
  String get age6Weeks => '6 weeks';

  @override
  String get age10Weeks => '10 weeks';

  @override
  String get age14Weeks => '14 weeks';

  @override
  String get age9Months => '9 months';

  @override
  String get riskAnaemia => 'Low blood (anaemia)';

  @override
  String get riskHighBp => 'High blood pressure';

  @override
  String get riskUnderweight => 'Low weight';

  @override
  String get riskPreviousCsection => 'Previous caesarean';

  @override
  String get riskAgeRisk => 'Age risk';

  @override
  String get riskTwins => 'Twins';

  @override
  String get actWeightBp => 'Weight and blood pressure';

  @override
  String get actBloodTest => 'Blood test';

  @override
  String get actUrineTest => 'Urine test';

  @override
  String get actTtVaccine => 'TT vaccine';

  @override
  String get actIfaTablets => 'Iron tablets given';

  @override
  String get actScan => 'Scan';

  @override
  String get actBabyHeartbeat => 'Baby\'s heartbeat';

  @override
  String get actGeneralCheck => 'General checkup';

  @override
  String get actDeliveryPlanning => 'Delivery planning';

  @override
  String get chatOffline =>
      'I could not reach the assistant just now. Please check your connection, or ask your ASHA worker.';

  @override
  String get chatNoAnswer =>
      'I do not know the answer to that one. Your ASHA worker can tell you properly.';

  @override
  String get chatSourceNote =>
      'Answers come from government and WHO health guidance.';

  @override
  String get voiceListen => 'Listen';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voiceUnavailable =>
      'Could not play it just now. Check your connection.';

  @override
  String get voiceHold => 'Hold to speak';

  @override
  String get voiceRecording => 'Listening… release to send';

  @override
  String get voiceNothingHeard => 'I did not catch that. Try once more.';

  @override
  String get chatClearTitle => 'Clear these messages?';

  @override
  String get chatClearBody =>
      'This removes the questions and answers saved on this phone. Nothing else in your record changes.';

  @override
  String get chatClearConfirm => 'Clear';
}
