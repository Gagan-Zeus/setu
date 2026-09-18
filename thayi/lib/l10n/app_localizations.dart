import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Thayi Setu'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your pregnancy companion'**
  String get appTagline;

  /// No description provided for @langKannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get langKannada;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your information'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get errorBody;

  /// No description provided for @emptyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyGeneric;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @welcomeCongrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get welcomeCongrats;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'You are going to be a mother. This app will walk with you through your pregnancy.'**
  String get welcomeBody;

  /// No description provided for @welcomeHow.
  ///
  /// In en, this message translates to:
  /// **'First we will help you find an ASHA worker near you. Call her, and she will visit you and register you.'**
  String get welcomeHow;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Let us begin'**
  String get welcomeStart;

  /// No description provided for @welcomeAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'My ASHA has already registered me'**
  String get welcomeAlreadyRegistered;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get nameTitle;

  /// No description provided for @nameWhy.
  ///
  /// In en, this message translates to:
  /// **'We use it only to greet you. Nobody else sees this yet.'**
  String get nameWhy;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Lakshmi'**
  String get nameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get locationTitle;

  /// No description provided for @locationWhy.
  ///
  /// In en, this message translates to:
  /// **'We will show you the ASHA workers closest to you, so you can call the right one.'**
  String get locationWhy;

  /// No description provided for @locationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your location is used once, on this phone, to sort the list. It is not saved or sent anywhere.'**
  String get locationPrivacy;

  /// No description provided for @locationAllow.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationAllow;

  /// No description provided for @locationSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip this'**
  String get locationSkip;

  /// No description provided for @ashaNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'ASHA workers near you'**
  String get ashaNearbyTitle;

  /// No description provided for @ashaNearbyIntro.
  ///
  /// In en, this message translates to:
  /// **'These are the ASHA workers closest to you. Call one and tell her you are pregnant.'**
  String get ashaNearbyIntro;

  /// No description provided for @ashaNearbyIntroNoLocation.
  ///
  /// In en, this message translates to:
  /// **'These are the ASHA workers in your area. Call one and tell her you are pregnant.'**
  String get ashaNearbyIntroNoLocation;

  /// No description provided for @ashaNearbyCall.
  ///
  /// In en, this message translates to:
  /// **'Call her'**
  String get ashaNearbyCall;

  /// No description provided for @ashaNearbyWhatToSay.
  ///
  /// In en, this message translates to:
  /// **'Tell her your name, your village, and that you are pregnant. She will come to your home.'**
  String get ashaNearbyWhatToSay;

  /// No description provided for @ashaNearbyDone.
  ///
  /// In en, this message translates to:
  /// **'I have called'**
  String get ashaNearbyDone;

  /// No description provided for @waitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your ASHA will come soon'**
  String get waitingTitle;

  /// No description provided for @waitingTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, your ASHA will come soon'**
  String waitingTitleNamed(String name);

  /// No description provided for @waitingBody.
  ///
  /// In en, this message translates to:
  /// **'She will visit your home, check your reports, and register you. Then you can sign in.'**
  String get waitingBody;

  /// No description provided for @waitingWhatNext.
  ///
  /// In en, this message translates to:
  /// **'WHAT HAPPENS NEXT'**
  String get waitingWhatNext;

  /// No description provided for @waitingStep1.
  ///
  /// In en, this message translates to:
  /// **'You called an ASHA worker'**
  String get waitingStep1;

  /// No description provided for @waitingStep2.
  ///
  /// In en, this message translates to:
  /// **'She visits your home and checks your reports'**
  String get waitingStep2;

  /// No description provided for @waitingStep3.
  ///
  /// In en, this message translates to:
  /// **'She registers you and enters your email address'**
  String get waitingStep3;

  /// No description provided for @waitingStep4.
  ///
  /// In en, this message translates to:
  /// **'You get a message at that email, then sign in here'**
  String get waitingStep4;

  /// No description provided for @waitingHaveEmail.
  ///
  /// In en, this message translates to:
  /// **'I have received the email'**
  String get waitingHaveEmail;

  /// No description provided for @waitingCallAgain.
  ///
  /// In en, this message translates to:
  /// **'Call an ASHA again'**
  String get waitingCallAgain;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will email you a 6 digit code'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10 digits'**
  String get phoneHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 10 digit number'**
  String get phoneInvalid;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a correct email address'**
  String get emailInvalid;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email. The code can take a minute to arrive.'**
  String get checkYourEmail;

  /// No description provided for @emailNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is not registered yet. Your ASHA worker adds it when she registers you — please ask her.'**
  String get emailNotRegistered;

  /// No description provided for @emailChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get emailChecking;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get otpInvalid;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send the code again'**
  String get resendOtp;

  /// No description provided for @otpSending.
  ///
  /// In en, this message translates to:
  /// **'Sending the code…'**
  String get otpSending;

  /// No description provided for @otpVerifying.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get otpVerifying;

  /// No description provided for @otpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'The code could not be sent. Please check your number and try again.'**
  String get otpSendFailed;

  /// No description provided for @otpWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Please check the SMS and try again.'**
  String get otpWrongCode;

  /// No description provided for @noNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet. Please check your connection and try again.'**
  String get noNetwork;

  /// No description provided for @recordNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Your Thayi Card record is not linked to this number yet. Please ask your ASHA worker.'**
  String get recordNotLinked;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'About your information'**
  String get consentTitle;

  /// No description provided for @consentWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What we keep'**
  String get consentWhatTitle;

  /// No description provided for @consentWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Your name, phone number, and the health details written in your Thayi Card.'**
  String get consentWhatBody;

  /// No description provided for @consentWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get consentWhoTitle;

  /// No description provided for @consentWhoBody.
  ///
  /// In en, this message translates to:
  /// **'Only your ASHA worker and the doctors at your health centre.'**
  String get consentWhoBody;

  /// No description provided for @consentWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'You are in control'**
  String get consentWithdrawTitle;

  /// No description provided for @consentWithdrawBody.
  ///
  /// In en, this message translates to:
  /// **'You can take back this permission at any time. Tell your ASHA worker.'**
  String get consentWithdrawBody;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get consentAccept;

  /// No description provided for @consentMustAccept.
  ///
  /// In en, this message translates to:
  /// **'Please agree to continue'**
  String get consentMustAccept;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaskara, {name}'**
  String greeting(String name);

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Your health today'**
  String get homeToday;

  /// No description provided for @weeksPregnantLabel.
  ///
  /// In en, this message translates to:
  /// **'Weeks pregnant'**
  String get weeksPregnantLabel;

  /// No description provided for @weeksValue.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String weeksValue(int weeks);

  /// No description provided for @weeksProgress.
  ///
  /// In en, this message translates to:
  /// **'Week {weeks} of 40'**
  String weeksProgress(int weeks);

  /// No description provided for @eddLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery date'**
  String get eddLabel;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days to go'**
  String daysRemaining(int days);

  /// No description provided for @nextCheckupLabel.
  ///
  /// In en, this message translates to:
  /// **'Next checkup'**
  String get nextCheckupLabel;

  /// No description provided for @checkupOverdueBadge.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get checkupOverdueBadge;

  /// No description provided for @askSetuCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Setu'**
  String get askSetuCardTitle;

  /// No description provided for @askSetuCardBody.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your pregnancy. Speak or type.'**
  String get askSetuCardBody;

  /// No description provided for @exploreLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR RECORD'**
  String get exploreLabel;

  /// No description provided for @moreLabel.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get moreLabel;

  /// No description provided for @navThayiCard.
  ///
  /// In en, this message translates to:
  /// **'My Thayi Card'**
  String get navThayiCard;

  /// No description provided for @navCheckups.
  ///
  /// In en, this message translates to:
  /// **'My Checkups'**
  String get navCheckups;

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'My Health'**
  String get navHealth;

  /// No description provided for @navSchemes.
  ///
  /// In en, this message translates to:
  /// **'My Schemes'**
  String get navSchemes;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My Details'**
  String get navProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Details'**
  String get profileTitle;

  /// No description provided for @photoSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get photoSectionLabel;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from phone'**
  String get chooseFromGallery;

  /// No description provided for @photoPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This photo stays on your phone. It is not sent anywhere.'**
  String get photoPrivacyNote;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be saved. Please try again.'**
  String get photoFailed;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get photoRemoved;

  /// No description provided for @yourDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'YOUR DETAILS'**
  String get yourDetailsSection;

  /// No description provided for @detailsWrittenByAsha.
  ///
  /// In en, this message translates to:
  /// **'These details are written by your ASHA worker. You cannot change them here.'**
  String get detailsWrittenByAsha;

  /// No description provided for @reportMistake.
  ///
  /// In en, this message translates to:
  /// **'Something here is wrong'**
  String get reportMistake;

  /// No description provided for @accessSection.
  ///
  /// In en, this message translates to:
  /// **'WHO WANTS TO SEE YOUR RECORD'**
  String get accessSection;

  /// No description provided for @accessRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to see your health record'**
  String accessRequestFrom(String name);

  /// No description provided for @accessRequestReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String accessRequestReason(String reason);

  /// No description provided for @accessApprove.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get accessApprove;

  /// No description provided for @accessReject.
  ///
  /// In en, this message translates to:
  /// **'Do not allow'**
  String get accessReject;

  /// No description provided for @accessApproved.
  ///
  /// In en, this message translates to:
  /// **'You allowed {name}'**
  String accessApproved(String name);

  /// No description provided for @accessRejected.
  ///
  /// In en, this message translates to:
  /// **'You did not allow {name}'**
  String accessRejected(String name);

  /// No description provided for @accessNone.
  ///
  /// In en, this message translates to:
  /// **'Nobody has asked to see your record'**
  String get accessNone;

  /// No description provided for @accessActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Can see your record now'**
  String get accessActiveTitle;

  /// No description provided for @accessActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String accessActiveUntil(String date);

  /// No description provided for @accessByQr.
  ///
  /// In en, this message translates to:
  /// **'Because you showed your QR code'**
  String get accessByQr;

  /// No description provided for @accessRevoke.
  ///
  /// In en, this message translates to:
  /// **'Stop this'**
  String get accessRevoke;

  /// No description provided for @accessRevoked.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get accessRevoked;

  /// No description provided for @accessExplain.
  ///
  /// In en, this message translates to:
  /// **'A doctor can only open your record if you allow it, or if you show your QR code at the hospital.'**
  String get accessExplain;

  /// No description provided for @consentSection.
  ///
  /// In en, this message translates to:
  /// **'YOUR PERMISSION'**
  String get consentSection;

  /// No description provided for @consentGivenOn.
  ///
  /// In en, this message translates to:
  /// **'You agreed on {date}'**
  String consentGivenOn(String date);

  /// No description provided for @consentNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'No agreement recorded'**
  String get consentNotRecorded;

  /// No description provided for @withdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Take back my permission'**
  String get withdrawConsent;

  /// No description provided for @withdrawConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Take back your permission?'**
  String get withdrawConsentTitle;

  /// No description provided for @withdrawConsentBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out and this phone will stop showing your record. Your ASHA worker and health centre still keep your paper record. You can agree again any time.'**
  String get withdrawConsentBody;

  /// No description provided for @withdrawConsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, take it back'**
  String get withdrawConsentConfirm;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsSection;

  /// No description provided for @navDangerSigns.
  ///
  /// In en, this message translates to:
  /// **'Danger Signs'**
  String get navDangerSigns;

  /// No description provided for @navAsha.
  ///
  /// In en, this message translates to:
  /// **'My ASHA Worker'**
  String get navAsha;

  /// No description provided for @navAfterDelivery.
  ///
  /// In en, this message translates to:
  /// **'After Delivery'**
  String get navAfterDelivery;

  /// No description provided for @emergencyShort.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyShort;

  /// No description provided for @emergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyTitle;

  /// No description provided for @emergencyIntro.
  ///
  /// In en, this message translates to:
  /// **'Show this screen to whoever is helping you.'**
  String get emergencyIntro;

  /// No description provided for @bloodGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroupLabel;

  /// No description provided for @riskFlagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Health warnings'**
  String get riskFlagsLabel;

  /// No description provided for @allergiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesLabel;

  /// No description provided for @noneRecorded.
  ///
  /// In en, this message translates to:
  /// **'None recorded'**
  String get noneRecorded;

  /// No description provided for @callAsha.
  ///
  /// In en, this message translates to:
  /// **'Call ASHA worker'**
  String get callAsha;

  /// No description provided for @callPhc.
  ///
  /// In en, this message translates to:
  /// **'Call health centre'**
  String get callPhc;

  /// No description provided for @callAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Call 108 ambulance'**
  String get callAmbulance;

  /// No description provided for @nearestHospitalLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearest hospital'**
  String get nearestHospitalLabel;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Show the way'**
  String get directions;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String distanceKm(String km);

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dialler'**
  String get callFailed;

  /// No description provided for @thayiCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Thayi Card'**
  String get thayiCardTitle;

  /// No description provided for @qrCaption.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the hospital'**
  String get qrCaption;

  /// No description provided for @worksOffline.
  ///
  /// In en, this message translates to:
  /// **'Works without internet'**
  String get worksOffline;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String ageYears(int age);

  /// No description provided for @fieldGuardian.
  ///
  /// In en, this message translates to:
  /// **'Husband / guardian'**
  String get fieldGuardian;

  /// No description provided for @fieldVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get fieldVillage;

  /// No description provided for @fieldBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get fieldBloodGroup;

  /// No description provided for @fieldEdd.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get fieldEdd;

  /// No description provided for @fieldCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Thayi Card number'**
  String get fieldCardNumber;

  /// No description provided for @fieldAsha.
  ///
  /// In en, this message translates to:
  /// **'ASHA worker'**
  String get fieldAsha;

  /// No description provided for @fieldPhc.
  ///
  /// In en, this message translates to:
  /// **'Health centre'**
  String get fieldPhc;

  /// No description provided for @checkupsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Checkups'**
  String get checkupsTitle;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get tabUpcoming;

  /// No description provided for @tabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tabCompleted;

  /// No description provided for @visitNumber.
  ///
  /// In en, this message translates to:
  /// **'Checkup {number}'**
  String visitNumber(int number);

  /// No description provided for @whatHappensLabel.
  ///
  /// In en, this message translates to:
  /// **'What will be done'**
  String get whatHappensLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get locationLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg'**
  String weightKg(String kg);

  /// No description provided for @bpLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get bpLabel;

  /// No description provided for @bpValue.
  ///
  /// In en, this message translates to:
  /// **'{systolic}/{diastolic}'**
  String bpValue(int systolic, int diastolic);

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by {name}'**
  String recordedBy(String name);

  /// No description provided for @overdueTitle.
  ///
  /// In en, this message translates to:
  /// **'This checkup is overdue'**
  String get overdueTitle;

  /// No description provided for @overdueBody.
  ///
  /// In en, this message translates to:
  /// **'Please do not wait. Talk to your ASHA worker today.'**
  String get overdueBody;

  /// No description provided for @contactAsha.
  ///
  /// In en, this message translates to:
  /// **'Contact your ASHA'**
  String get contactAsha;

  /// No description provided for @emptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No checkups booked yet'**
  String get emptyUpcoming;

  /// No description provided for @emptyCompleted.
  ///
  /// In en, this message translates to:
  /// **'No checkups done yet'**
  String get emptyCompleted;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'My Health'**
  String get healthTitle;

  /// No description provided for @riskFlagsSection.
  ///
  /// In en, this message translates to:
  /// **'BLOOD GROUP AND WARNINGS'**
  String get riskFlagsSection;

  /// No description provided for @noRiskFlags.
  ///
  /// In en, this message translates to:
  /// **'No warnings'**
  String get noRiskFlags;

  /// No description provided for @weightHistory.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightHistory;

  /// No description provided for @bpHistory.
  ///
  /// In en, this message translates to:
  /// **'BLOOD PRESSURE'**
  String get bpHistory;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get diastolic;

  /// No description provided for @weekShort.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String weekShort(int week);

  /// No description provided for @tabletsSection.
  ///
  /// In en, this message translates to:
  /// **'TABLETS TODAY'**
  String get tabletsSection;

  /// No description provided for @tabletIfa.
  ///
  /// In en, this message translates to:
  /// **'Iron tablet (IFA)'**
  String get tabletIfa;

  /// No description provided for @tabletCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium tablet'**
  String get tabletCalcium;

  /// No description provided for @tabletIfaNote.
  ///
  /// In en, this message translates to:
  /// **'One tablet after food'**
  String get tabletIfaNote;

  /// No description provided for @tabletCalciumNote.
  ///
  /// In en, this message translates to:
  /// **'One tablet, not with the iron tablet'**
  String get tabletCalciumNote;

  /// No description provided for @markTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get markTaken;

  /// No description provided for @markNotTaken.
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get markNotTaken;

  /// No description provided for @ttSection.
  ///
  /// In en, this message translates to:
  /// **'TT VACCINE'**
  String get ttSection;

  /// No description provided for @ttDose.
  ///
  /// In en, this message translates to:
  /// **'TT dose {number}'**
  String ttDose(int number);

  /// No description provided for @statusGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get statusGiven;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statusDue;

  /// No description provided for @givenOn.
  ///
  /// In en, this message translates to:
  /// **'Given on {date}'**
  String givenOn(String date);

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get chartNoData;

  /// No description provided for @schemesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Schemes'**
  String get schemesTitle;

  /// No description provided for @badgeEligible.
  ///
  /// In en, this message translates to:
  /// **'You are eligible'**
  String get badgeEligible;

  /// No description provided for @badgeNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Not eligible now'**
  String get badgeNotEligible;

  /// No description provided for @whatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get whatYouGet;

  /// No description provided for @documentsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Papers to carry'**
  String get documentsNeeded;

  /// No description provided for @nearbyHospitals.
  ///
  /// In en, this message translates to:
  /// **'Nearby hospitals'**
  String get nearbyHospitals;

  /// No description provided for @schemesFootnote.
  ///
  /// In en, this message translates to:
  /// **'Benefits and eligibility shown here are indicative only. Please confirm with your ASHA worker or your health centre.'**
  String get schemesFootnote;

  /// No description provided for @schemeThayiBhagyaName.
  ///
  /// In en, this message translates to:
  /// **'Thayi Bhagya'**
  String get schemeThayiBhagyaName;

  /// No description provided for @schemeThayiBhagyaBenefit.
  ///
  /// In en, this message translates to:
  /// **'Free delivery at an approved private hospital when a government hospital is far away.'**
  String get schemeThayiBhagyaBenefit;

  /// No description provided for @schemePmmvyName.
  ///
  /// In en, this message translates to:
  /// **'PMMVY'**
  String get schemePmmvyName;

  /// No description provided for @schemePmmvyBenefit.
  ///
  /// In en, this message translates to:
  /// **'Cash help for your first child, paid into your bank account in instalments after checkups.'**
  String get schemePmmvyBenefit;

  /// No description provided for @schemeJsyName.
  ///
  /// In en, this message translates to:
  /// **'JSY'**
  String get schemeJsyName;

  /// No description provided for @schemeJsyBenefit.
  ///
  /// In en, this message translates to:
  /// **'Cash help when you deliver in a government hospital, given after the delivery.'**
  String get schemeJsyBenefit;

  /// No description provided for @schemePrasootiAraikeName.
  ///
  /// In en, this message translates to:
  /// **'Prasooti Araike'**
  String get schemePrasootiAraikeName;

  /// No description provided for @schemePrasootiAraikeBenefit.
  ///
  /// In en, this message translates to:
  /// **'Help for rest and food during the last months of pregnancy for BPL families.'**
  String get schemePrasootiAraikeBenefit;

  /// No description provided for @schemeMadiluName.
  ///
  /// In en, this message translates to:
  /// **'Madilu Kit'**
  String get schemeMadiluName;

  /// No description provided for @schemeMadiluBenefit.
  ///
  /// In en, this message translates to:
  /// **'A kit of clothes and things for you and the baby, given at the hospital after delivery.'**
  String get schemeMadiluBenefit;

  /// No description provided for @schemeJsskName.
  ///
  /// In en, this message translates to:
  /// **'JSSK'**
  String get schemeJsskName;

  /// No description provided for @schemeJsskBenefit.
  ///
  /// In en, this message translates to:
  /// **'Free delivery, free medicines, free tests, free food and free transport at government hospitals.'**
  String get schemeJsskBenefit;

  /// No description provided for @docThayiCard.
  ///
  /// In en, this message translates to:
  /// **'Thayi Card'**
  String get docThayiCard;

  /// No description provided for @docAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Your Aadhaar card'**
  String get docAadhaar;

  /// No description provided for @docBankPassbook.
  ///
  /// In en, this message translates to:
  /// **'Bank passbook in your name'**
  String get docBankPassbook;

  /// No description provided for @docBplCard.
  ///
  /// In en, this message translates to:
  /// **'BPL / ration card'**
  String get docBplCard;

  /// No description provided for @docHusbandAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Husband\'s Aadhaar card'**
  String get docHusbandAadhaar;

  /// No description provided for @docMchRegistration.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy registration slip'**
  String get docMchRegistration;

  /// No description provided for @docDeliveryProof.
  ///
  /// In en, this message translates to:
  /// **'Delivery discharge paper'**
  String get docDeliveryProof;

  /// No description provided for @askSetuTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Setu'**
  String get askSetuTitle;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Namaskara. Ask me anything about your pregnancy. You can speak or type.'**
  String get chatWelcome;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Write your question'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get chatSpeak;

  /// No description provided for @chatListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get chatListening;

  /// No description provided for @chatThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get chatThinking;

  /// No description provided for @chatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Advice only — not a doctor\'s opinion'**
  String get chatDisclaimer;

  /// No description provided for @suggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get suggestionsLabel;

  /// No description provided for @topicFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get topicFood;

  /// No description provided for @topicRest.
  ///
  /// In en, this message translates to:
  /// **'Rest and work'**
  String get topicRest;

  /// No description provided for @topicAfterDelivery.
  ///
  /// In en, this message translates to:
  /// **'After delivery'**
  String get topicAfterDelivery;

  /// No description provided for @qFood1.
  ///
  /// In en, this message translates to:
  /// **'What should I eat every day?'**
  String get qFood1;

  /// No description provided for @qFood2.
  ///
  /// In en, this message translates to:
  /// **'Can I drink tea and coffee?'**
  String get qFood2;

  /// No description provided for @qFood3.
  ///
  /// In en, this message translates to:
  /// **'I feel sick in the morning. What can I do?'**
  String get qFood3;

  /// No description provided for @qRest1.
  ///
  /// In en, this message translates to:
  /// **'How much should I rest?'**
  String get qRest1;

  /// No description provided for @qRest2.
  ///
  /// In en, this message translates to:
  /// **'Can I do my usual housework?'**
  String get qRest2;

  /// No description provided for @qRest3.
  ///
  /// In en, this message translates to:
  /// **'Can I travel to my mother\'s village?'**
  String get qRest3;

  /// No description provided for @qAfter1.
  ///
  /// In en, this message translates to:
  /// **'When should I start feeding the baby?'**
  String get qAfter1;

  /// No description provided for @qAfter2.
  ///
  /// In en, this message translates to:
  /// **'How long should I rest after delivery?'**
  String get qAfter2;

  /// No description provided for @qAfter3.
  ///
  /// In en, this message translates to:
  /// **'When is the baby\'s first vaccine?'**
  String get qAfter3;

  /// No description provided for @aMedicineRefusal.
  ///
  /// In en, this message translates to:
  /// **'I cannot advise you about medicines or doses. Please ask your ASHA worker or the doctor at your health centre — they know your record.'**
  String get aMedicineRefusal;

  /// No description provided for @contactAshaFromChat.
  ///
  /// In en, this message translates to:
  /// **'Send this to my ASHA'**
  String get contactAshaFromChat;

  /// No description provided for @messageSentToAsha.
  ///
  /// In en, this message translates to:
  /// **'Your question has been noted for {name}. She will call you back.'**
  String messageSentToAsha(String name);

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Setu needs the microphone only to listen to your question and turn it into words. Nothing is recorded or kept.'**
  String get micPermissionBody;

  /// No description provided for @micAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone'**
  String get micAllow;

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone was not allowed. You can still type your question.'**
  String get micDenied;

  /// No description provided for @micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available on this phone. Please type your question.'**
  String get micUnavailable;

  /// No description provided for @dangerInterruptTitle.
  ///
  /// In en, this message translates to:
  /// **'This needs attention now'**
  String get dangerInterruptTitle;

  /// No description provided for @dangerInterruptBody.
  ///
  /// In en, this message translates to:
  /// **'What you described can be serious. Do not wait for an answer here. Call for help now.'**
  String get dangerInterruptBody;

  /// No description provided for @dangerInterruptDismiss.
  ///
  /// In en, this message translates to:
  /// **'I am safe, go back'**
  String get dangerInterruptDismiss;

  /// No description provided for @dangerInterruptNote.
  ///
  /// In en, this message translates to:
  /// **'Your message was not sent. Your safety comes first.'**
  String get dangerInterruptNote;

  /// No description provided for @dangerSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger Signs'**
  String get dangerSignsTitle;

  /// No description provided for @dangerSignsIntro.
  ///
  /// In en, this message translates to:
  /// **'If any of these happen, get help the same hour. Do not wait for the next checkup.'**
  String get dangerSignsIntro;

  /// No description provided for @whatToDoLabel.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get whatToDoLabel;

  /// No description provided for @callMyAsha.
  ///
  /// In en, this message translates to:
  /// **'Call my ASHA'**
  String get callMyAsha;

  /// No description provided for @dsBleedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get dsBleedingTitle;

  /// No description provided for @dsBleedingBody.
  ///
  /// In en, this message translates to:
  /// **'Any bleeding from below during pregnancy, even a small amount.'**
  String get dsBleedingBody;

  /// No description provided for @dsBleedingDo.
  ///
  /// In en, this message translates to:
  /// **'Lie down, do not travel alone, and call your ASHA worker or 108 at once.'**
  String get dsBleedingDo;

  /// No description provided for @dsHeadacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe headache'**
  String get dsHeadacheTitle;

  /// No description provided for @dsHeadacheBody.
  ///
  /// In en, this message translates to:
  /// **'A bad headache that does not go away, especially with swelling.'**
  String get dsHeadacheBody;

  /// No description provided for @dsHeadacheDo.
  ///
  /// In en, this message translates to:
  /// **'Go to the health centre the same day. Your blood pressure must be checked.'**
  String get dsHeadacheDo;

  /// No description provided for @dsVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision'**
  String get dsVisionTitle;

  /// No description provided for @dsVisionBody.
  ///
  /// In en, this message translates to:
  /// **'Things look blurred, or you see flashes or spots before your eyes.'**
  String get dsVisionBody;

  /// No description provided for @dsVisionDo.
  ///
  /// In en, this message translates to:
  /// **'This can come with high blood pressure. Go to the health centre now.'**
  String get dsVisionDo;

  /// No description provided for @dsSwellingTitle.
  ///
  /// In en, this message translates to:
  /// **'Swelling of face and hands'**
  String get dsSwellingTitle;

  /// No description provided for @dsSwellingBody.
  ///
  /// In en, this message translates to:
  /// **'Puffy face, or fingers so swollen that a ring becomes tight.'**
  String get dsSwellingBody;

  /// No description provided for @dsSwellingDo.
  ///
  /// In en, this message translates to:
  /// **'Get your blood pressure and urine checked today.'**
  String get dsSwellingDo;

  /// No description provided for @dsFeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get dsFeverTitle;

  /// No description provided for @dsFeverBody.
  ///
  /// In en, this message translates to:
  /// **'Fever with chills, or a burning feeling when passing urine.'**
  String get dsFeverBody;

  /// No description provided for @dsFeverDo.
  ///
  /// In en, this message translates to:
  /// **'Do not take any tablet on your own. Go to the health centre.'**
  String get dsFeverDo;

  /// No description provided for @dsConvulsionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fits or convulsions'**
  String get dsConvulsionsTitle;

  /// No description provided for @dsConvulsionsBody.
  ///
  /// In en, this message translates to:
  /// **'The body shakes and stiffens, or she becomes unconscious.'**
  String get dsConvulsionsBody;

  /// No description provided for @dsConvulsionsDo.
  ///
  /// In en, this message translates to:
  /// **'This is an emergency. Turn her on her side and call 108 immediately.'**
  String get dsConvulsionsDo;

  /// No description provided for @dsMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby is not moving'**
  String get dsMovementTitle;

  /// No description provided for @dsMovementBody.
  ///
  /// In en, this message translates to:
  /// **'The baby moves less than usual, or you have felt no movement for some hours.'**
  String get dsMovementBody;

  /// No description provided for @dsMovementDo.
  ///
  /// In en, this message translates to:
  /// **'Lie on your left side and count the movements. If still less, go to the health centre now.'**
  String get dsMovementDo;

  /// No description provided for @ashaTitle.
  ///
  /// In en, this message translates to:
  /// **'My ASHA Worker'**
  String get ashaTitle;

  /// No description provided for @ashaRole.
  ///
  /// In en, this message translates to:
  /// **'Your ASHA worker'**
  String get ashaRole;

  /// No description provided for @subCentreLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub-centre'**
  String get subCentreLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get callNow;

  /// No description provided for @ashaNote.
  ///
  /// In en, this message translates to:
  /// **'She writes your record and visits you at home. Ask her anything, at any time.'**
  String get ashaNote;

  /// No description provided for @afterDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'After Delivery'**
  String get afterDeliveryTitle;

  /// No description provided for @afterDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'This is what will happen after your baby is born. Nothing here needs to be done yet.'**
  String get afterDeliveryNote;

  /// No description provided for @immunisationSection.
  ///
  /// In en, this message translates to:
  /// **'BABY\'S VACCINES'**
  String get immunisationSection;

  /// No description provided for @growthSection.
  ///
  /// In en, this message translates to:
  /// **'BABY\'S GROWTH'**
  String get growthSection;

  /// No description provided for @growthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s weight will be written here after birth'**
  String get growthEmpty;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @vacBcg.
  ///
  /// In en, this message translates to:
  /// **'BCG'**
  String get vacBcg;

  /// No description provided for @vacOpv.
  ///
  /// In en, this message translates to:
  /// **'Polio drops (OPV)'**
  String get vacOpv;

  /// No description provided for @vacHepB.
  ///
  /// In en, this message translates to:
  /// **'Hepatitis B'**
  String get vacHepB;

  /// No description provided for @vacPenta.
  ///
  /// In en, this message translates to:
  /// **'Pentavalent'**
  String get vacPenta;

  /// No description provided for @vacRota.
  ///
  /// In en, this message translates to:
  /// **'Rotavirus'**
  String get vacRota;

  /// No description provided for @vacMr.
  ///
  /// In en, this message translates to:
  /// **'Measles-Rubella'**
  String get vacMr;

  /// No description provided for @ageAtBirth.
  ///
  /// In en, this message translates to:
  /// **'At birth'**
  String get ageAtBirth;

  /// No description provided for @age6Weeks.
  ///
  /// In en, this message translates to:
  /// **'6 weeks'**
  String get age6Weeks;

  /// No description provided for @age10Weeks.
  ///
  /// In en, this message translates to:
  /// **'10 weeks'**
  String get age10Weeks;

  /// No description provided for @age14Weeks.
  ///
  /// In en, this message translates to:
  /// **'14 weeks'**
  String get age14Weeks;

  /// No description provided for @age9Months.
  ///
  /// In en, this message translates to:
  /// **'9 months'**
  String get age9Months;

  /// No description provided for @riskAnaemia.
  ///
  /// In en, this message translates to:
  /// **'Low blood (anaemia)'**
  String get riskAnaemia;

  /// No description provided for @riskHighBp.
  ///
  /// In en, this message translates to:
  /// **'High blood pressure'**
  String get riskHighBp;

  /// No description provided for @riskUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Low weight'**
  String get riskUnderweight;

  /// No description provided for @riskPreviousCsection.
  ///
  /// In en, this message translates to:
  /// **'Previous caesarean'**
  String get riskPreviousCsection;

  /// No description provided for @riskAgeRisk.
  ///
  /// In en, this message translates to:
  /// **'Age risk'**
  String get riskAgeRisk;

  /// No description provided for @riskTwins.
  ///
  /// In en, this message translates to:
  /// **'Twins'**
  String get riskTwins;

  /// No description provided for @actWeightBp.
  ///
  /// In en, this message translates to:
  /// **'Weight and blood pressure'**
  String get actWeightBp;

  /// No description provided for @actBloodTest.
  ///
  /// In en, this message translates to:
  /// **'Blood test'**
  String get actBloodTest;

  /// No description provided for @actUrineTest.
  ///
  /// In en, this message translates to:
  /// **'Urine test'**
  String get actUrineTest;

  /// No description provided for @actTtVaccine.
  ///
  /// In en, this message translates to:
  /// **'TT vaccine'**
  String get actTtVaccine;

  /// No description provided for @actIfaTablets.
  ///
  /// In en, this message translates to:
  /// **'Iron tablets given'**
  String get actIfaTablets;

  /// No description provided for @actScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get actScan;

  /// No description provided for @actBabyHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s heartbeat'**
  String get actBabyHeartbeat;

  /// No description provided for @actGeneralCheck.
  ///
  /// In en, this message translates to:
  /// **'General checkup'**
  String get actGeneralCheck;

  /// No description provided for @actDeliveryPlanning.
  ///
  /// In en, this message translates to:
  /// **'Delivery planning'**
  String get actDeliveryPlanning;

  /// Shown in Ask Setu when the assistant cannot answer.
  ///
  /// In en, this message translates to:
  /// **'I could not reach the assistant just now. Please check your connection, or ask your ASHA worker.'**
  String get chatOffline;

  /// Shown in Ask Setu when the assistant cannot answer.
  ///
  /// In en, this message translates to:
  /// **'I do not know the answer to that one. Your ASHA worker can tell you properly.'**
  String get chatNoAnswer;

  /// Shown in Ask Setu when the assistant cannot answer.
  ///
  /// In en, this message translates to:
  /// **'Answers come from government and WHO health guidance.'**
  String get chatSourceNote;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get voiceListen;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceStop;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'Could not play it just now. Check your connection.'**
  String get voiceUnavailable;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'Hold to speak'**
  String get voiceHold;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'Listening… release to send'**
  String get voiceRecording;

  /// Voice input and playback in Ask Setu.
  ///
  /// In en, this message translates to:
  /// **'I did not catch that. Try once more.'**
  String get voiceNothingHeard;

  /// Clearing the saved Ask Setu transcript.
  ///
  /// In en, this message translates to:
  /// **'Clear these messages?'**
  String get chatClearTitle;

  /// Clearing the saved Ask Setu transcript.
  ///
  /// In en, this message translates to:
  /// **'This removes the questions and answers saved on this phone. Nothing else in your record changes.'**
  String get chatClearBody;

  /// Clearing the saved Ask Setu transcript.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatClearConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
