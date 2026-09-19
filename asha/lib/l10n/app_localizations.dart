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
  /// **'ASHA Setu'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your field companion'**
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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

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

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This is needed'**
  String get requiredField;

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

  /// No description provided for @dutyTitle.
  ///
  /// In en, this message translates to:
  /// **'On duty'**
  String get dutyTitle;

  /// No description provided for @dutyOnBody.
  ///
  /// In en, this message translates to:
  /// **'Mothers within 2 km can see that you are available now.'**
  String get dutyOnBody;

  /// No description provided for @dutyOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn this on while you are working, so mothers nearby can find you.'**
  String get dutyOffBody;

  /// No description provided for @dutyNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No GPS — could not go on duty'**
  String get dutyNoLocation;

  /// No description provided for @dutyOffline.
  ///
  /// In en, this message translates to:
  /// **'No signal — could not go on duty'**
  String get dutyOffline;

  /// No description provided for @dutyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The server has not been set up for on-duty yet'**
  String get dutyUnavailable;

  /// No description provided for @dutyNoPosting.
  ///
  /// In en, this message translates to:
  /// **'This login has no ASHA posting yet'**
  String get dutyNoPosting;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @logoutWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutWarningTitle;

  /// No description provided for @logoutWarningBody.
  ///
  /// In en, this message translates to:
  /// **'You will need internet to sign in again. Do not sign out while you are in a village with no network.'**
  String get logoutWarningBody;

  /// No description provided for @logoutPendingWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} entries have not been sent yet. They stay on this phone, but sign in again soon so they can be sent.'**
  String logoutPendingWarning(int count);

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, sign out'**
  String get logoutConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in once. You stay signed in even with no network.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
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

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordInvalid;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {email}'**
  String otpSentTo(String email);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get otpInvalid;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

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
  /// **'The code could not be sent. Please check the address and try again.'**
  String get otpSendFailed;

  /// No description provided for @otpWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Please check your email and try again.'**
  String get otpWrongCode;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Send the code again'**
  String get otpResend;

  /// No description provided for @otpChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get otpChangeEmail;

  /// No description provided for @otpNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet. You need a signal once, to sign in the first time.'**
  String get otpNoNetwork;

  /// No description provided for @otpOfflineFallback.
  ///
  /// In en, this message translates to:
  /// **'No network — signed in on this phone only. Sign in properly when you have a signal.'**
  String get otpOfflineFallback;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Please contact your ANM supervisor to reset your password. Password reset from the app is coming soon.'**
  String get forgotPasswordBody;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please check your email and password.'**
  String get loginFailed;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a 4 digit PIN'**
  String get setPinTitle;

  /// No description provided for @setPinBody.
  ///
  /// In en, this message translates to:
  /// **'This phone may be shared. The PIN keeps other women\'s records private.'**
  String get setPinBody;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get confirmPinTitle;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two PINs do not match. Please try again.'**
  String get pinMismatch;

  /// No description provided for @enterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPinTitle;

  /// No description provided for @enterPinBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4 digit PIN to continue'**
  String get enterPinBody;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Please try again.'**
  String get pinWrong;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaskara, {name}'**
  String greeting(String name);

  /// No description provided for @todaysWork.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S WORK'**
  String get todaysWork;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — {count} entries waiting'**
  String syncOffline(int count);

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count} entries waiting to be sent'**
  String syncPending(int count);

  /// No description provided for @syncAllDone.
  ///
  /// In en, this message translates to:
  /// **'Everything is sent'**
  String get syncAllDone;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get syncing;

  /// No description provided for @statAssigned.
  ///
  /// In en, this message translates to:
  /// **'Mothers'**
  String get statAssigned;

  /// No description provided for @statHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get statHighRisk;

  /// No description provided for @statVisitsDue.
  ///
  /// In en, this message translates to:
  /// **'Visits due'**
  String get statVisitsDue;

  /// No description provided for @registerMother.
  ///
  /// In en, this message translates to:
  /// **'Register a mother'**
  String get registerMother;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No work pending today'**
  String get noTasks;

  /// No description provided for @originDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor assigned'**
  String get originDoctor;

  /// No description provided for @originSystem.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get originSystem;

  /// No description provided for @originSelf.
  ///
  /// In en, this message translates to:
  /// **'My note'**
  String get originSelf;

  /// No description provided for @gestationWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String gestationWeeks(int weeks);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @mothersTitle.
  ///
  /// In en, this message translates to:
  /// **'Mothers'**
  String get mothersTitle;

  /// No description provided for @searchMothers.
  ///
  /// In en, this message translates to:
  /// **'Search by name or village'**
  String get searchMothers;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get tabHighRisk;

  /// No description provided for @tabVisitsDue.
  ///
  /// In en, this message translates to:
  /// **'Visits due'**
  String get tabVisitsDue;

  /// No description provided for @noMothers.
  ///
  /// In en, this message translates to:
  /// **'No mothers registered yet'**
  String get noMothers;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register a mother'**
  String get registerTitle;

  /// No description provided for @scanThayiCard.
  ///
  /// In en, this message translates to:
  /// **'Scan Thayi Card'**
  String get scanThayiCard;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of her paper card'**
  String get scanHint;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter by hand'**
  String get manualEntry;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Reading the card…'**
  String get scanning;

  /// No description provided for @confirmEachField.
  ///
  /// In en, this message translates to:
  /// **'Check every detail below. Correct anything that is wrong before saving.'**
  String get confirmEachField;

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

  /// No description provided for @fieldHusband.
  ///
  /// In en, this message translates to:
  /// **'Husband / guardian'**
  String get fieldHusband;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get fieldEmail;

  /// No description provided for @fieldEmailWhy.
  ///
  /// In en, this message translates to:
  /// **'She signs in to Thayi Setu with this. Without it she cannot open her own record.'**
  String get fieldEmailWhy;

  /// No description provided for @emailInvalidField.
  ///
  /// In en, this message translates to:
  /// **'Please enter a correct email address'**
  String get emailInvalidField;

  /// No description provided for @fieldVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get fieldVillage;

  /// No description provided for @fieldSubCentre.
  ///
  /// In en, this message translates to:
  /// **'Sub-centre'**
  String get fieldSubCentre;

  /// No description provided for @fieldAbha.
  ///
  /// In en, this message translates to:
  /// **'ABHA id'**
  String get fieldAbha;

  /// No description provided for @fieldLmp.
  ///
  /// In en, this message translates to:
  /// **'Last period date (LMP)'**
  String get fieldLmp;

  /// No description provided for @fieldGravida.
  ///
  /// In en, this message translates to:
  /// **'Gravida'**
  String get fieldGravida;

  /// No description provided for @fieldPara.
  ///
  /// In en, this message translates to:
  /// **'Para'**
  String get fieldPara;

  /// No description provided for @fieldBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get fieldBloodGroup;

  /// No description provided for @fieldHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get fieldHeight;

  /// No description provided for @fieldBpl.
  ///
  /// In en, this message translates to:
  /// **'BPL family'**
  String get fieldBpl;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get pickDate;

  /// No description provided for @homeLocationSection.
  ///
  /// In en, this message translates to:
  /// **'HER HOUSE'**
  String get homeLocationSection;

  /// No description provided for @homeLocationCapture.
  ///
  /// In en, this message translates to:
  /// **'Pin this house'**
  String get homeLocationCapture;

  /// No description provided for @homeLocationBusy.
  ///
  /// In en, this message translates to:
  /// **'Finding the location…'**
  String get homeLocationBusy;

  /// No description provided for @homeLocationFound.
  ///
  /// In en, this message translates to:
  /// **'Location pinned'**
  String get homeLocationFound;

  /// No description provided for @homeLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'No location yet — you can pin it on your next visit'**
  String get homeLocationMissing;

  /// No description provided for @homeLocationWhy.
  ///
  /// In en, this message translates to:
  /// **'Pinning it now means you, or anyone covering for you, can navigate straight here next time.'**
  String get homeLocationWhy;

  /// No description provided for @homeLocationDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions to her house'**
  String get homeLocationDirections;

  /// No description provided for @homeLocationStreetView.
  ///
  /// In en, this message translates to:
  /// **'Street view'**
  String get homeLocationStreetView;

  /// No description provided for @homeLocationNoStreetView.
  ///
  /// In en, this message translates to:
  /// **'No street view here. Most villages have no coverage.'**
  String get homeLocationNoStreetView;

  /// No description provided for @homeLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get homeLocationSaved;

  /// No description provided for @homeLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get a location. Try outside the house.'**
  String get homeLocationFailed;

  /// No description provided for @homeLocationOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps'**
  String get homeLocationOpenFailed;

  /// No description provided for @prevComplications.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS COMPLICATIONS'**
  String get prevComplications;

  /// No description provided for @compCSection.
  ///
  /// In en, this message translates to:
  /// **'Caesarean'**
  String get compCSection;

  /// No description provided for @compStillbirth.
  ///
  /// In en, this message translates to:
  /// **'Stillbirth'**
  String get compStillbirth;

  /// No description provided for @compPph.
  ///
  /// In en, this message translates to:
  /// **'Bleeding after delivery'**
  String get compPph;

  /// No description provided for @compHypertension.
  ///
  /// In en, this message translates to:
  /// **'High blood pressure'**
  String get compHypertension;

  /// No description provided for @compGdm.
  ///
  /// In en, this message translates to:
  /// **'Diabetes in pregnancy'**
  String get compGdm;

  /// No description provided for @compAnaemia.
  ///
  /// In en, this message translates to:
  /// **'Anaemia'**
  String get compAnaemia;

  /// No description provided for @eddComputed.
  ///
  /// In en, this message translates to:
  /// **'Delivery date {date}'**
  String eddComputed(String date);

  /// No description provided for @gaComputed.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks {days} days pregnant'**
  String gaComputed(int weeks, int days);

  /// No description provided for @saveMother.
  ///
  /// In en, this message translates to:
  /// **'Save and register'**
  String get saveMother;

  /// No description provided for @motherSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} is registered'**
  String motherSaved(String name);

  /// No description provided for @schemesQualified.
  ///
  /// In en, this message translates to:
  /// **'SHE QUALIFIES FOR'**
  String get schemesQualified;

  /// No description provided for @schemeThayiBhagya.
  ///
  /// In en, this message translates to:
  /// **'Thayi Bhagya'**
  String get schemeThayiBhagya;

  /// No description provided for @schemePmmvy.
  ///
  /// In en, this message translates to:
  /// **'PMMVY'**
  String get schemePmmvy;

  /// No description provided for @schemeJsy.
  ///
  /// In en, this message translates to:
  /// **'JSY'**
  String get schemeJsy;

  /// No description provided for @schemePrasootiAraike.
  ///
  /// In en, this message translates to:
  /// **'Prasooti Araike'**
  String get schemePrasootiAraike;

  /// No description provided for @schemeMadilu.
  ///
  /// In en, this message translates to:
  /// **'Madilu Kit'**
  String get schemeMadilu;

  /// No description provided for @schemeJssk.
  ///
  /// In en, this message translates to:
  /// **'JSSK'**
  String get schemeJssk;

  /// No description provided for @schemesNote.
  ///
  /// In en, this message translates to:
  /// **'Eligibility shown here is indicative. Confirm with the PHC.'**
  String get schemesNote;

  /// No description provided for @profileTabTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get profileTabTimeline;

  /// No description provided for @profileTabVitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get profileTabVitals;

  /// No description provided for @profileTabSchemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get profileTabSchemes;

  /// No description provided for @profileTabQr.
  ///
  /// In en, this message translates to:
  /// **'Her code'**
  String get profileTabQr;

  /// No description provided for @gaLabel.
  ///
  /// In en, this message translates to:
  /// **'GA {weeks}w {days}d'**
  String gaLabel(int weeks, int days);

  /// No description provided for @eddLabel.
  ///
  /// In en, this message translates to:
  /// **'EDD'**
  String get eddLabel;

  /// No description provided for @bloodGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroupLabel;

  /// No description provided for @riskGreen.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get riskGreen;

  /// No description provided for @riskAmber.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get riskAmber;

  /// No description provided for @riskRed.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskRed;

  /// No description provided for @newVisit.
  ///
  /// In en, this message translates to:
  /// **'New visit'**
  String get newVisit;

  /// No description provided for @timelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No visits recorded yet'**
  String get timelineEmpty;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by {name}'**
  String recordedBy(String name);

  /// No description provided for @entryVisit.
  ///
  /// In en, this message translates to:
  /// **'ANC visit'**
  String get entryVisit;

  /// No description provided for @entryAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get entryAlert;

  /// No description provided for @entryReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get entryReferral;

  /// No description provided for @correctionOf.
  ///
  /// In en, this message translates to:
  /// **'Correction of visit {number}'**
  String correctionOf(int number);

  /// No description provided for @vitalsBp.
  ///
  /// In en, this message translates to:
  /// **'BLOOD PRESSURE'**
  String get vitalsBp;

  /// No description provided for @vitalsWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get vitalsWeight;

  /// No description provided for @vitalsHb.
  ///
  /// In en, this message translates to:
  /// **'HAEMOGLOBIN'**
  String get vitalsHb;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get chartNoData;

  /// No description provided for @qrOnHerPhone.
  ///
  /// In en, this message translates to:
  /// **'Her code is on her own phone'**
  String get qrOnHerPhone;

  /// No description provided for @qrWhyNotHere.
  ///
  /// In en, this message translates to:
  /// **'It changes every few minutes, so a photograph of it stops working almost at once. This phone cannot produce it — her holding out her own phone is what gives permission, and that is not something you can do for her.'**
  String get qrWhyNotHere;

  /// No description provided for @qrHelpSignIn.
  ///
  /// In en, this message translates to:
  /// **'She opens Thayi Setu and signs in with {email}, then taps Thayi card.'**
  String qrHelpSignIn(String email);

  /// No description provided for @qrNoEmail.
  ///
  /// In en, this message translates to:
  /// **'There is no email on her record yet, so she cannot sign in to Thayi Setu. Add one and verify it on this visit.'**
  String get qrNoEmail;

  /// No description provided for @qrCaption.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the facility'**
  String get qrCaption;

  /// No description provided for @callMother.
  ///
  /// In en, this message translates to:
  /// **'Call her'**
  String get callMother;

  /// No description provided for @newVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'New ANC visit'**
  String get newVisitTitle;

  /// No description provided for @visitNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Visit {number}'**
  String visitNumberLabel(int number);

  /// No description provided for @sectionBp.
  ///
  /// In en, this message translates to:
  /// **'BLOOD PRESSURE'**
  String get sectionBp;

  /// No description provided for @bpSys.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get bpSys;

  /// No description provided for @bpDia.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get bpDia;

  /// No description provided for @sectionMeasure.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT AND MEASUREMENT'**
  String get sectionMeasure;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @fundalHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Fundal height (cm)'**
  String get fundalHeightLabel;

  /// No description provided for @sectionLab.
  ///
  /// In en, this message translates to:
  /// **'TESTS'**
  String get sectionLab;

  /// No description provided for @hbLabel.
  ///
  /// In en, this message translates to:
  /// **'Haemoglobin (g/dL)'**
  String get hbLabel;

  /// No description provided for @urineAlbuminLabel.
  ///
  /// In en, this message translates to:
  /// **'Urine albumin'**
  String get urineAlbuminLabel;

  /// No description provided for @albuminNil.
  ///
  /// In en, this message translates to:
  /// **'Nil'**
  String get albuminNil;

  /// No description provided for @albuminTrace.
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get albuminTrace;

  /// No description provided for @albuminPlus1.
  ///
  /// In en, this message translates to:
  /// **'+1'**
  String get albuminPlus1;

  /// No description provided for @albuminPlus2.
  ///
  /// In en, this message translates to:
  /// **'+2 or more'**
  String get albuminPlus2;

  /// No description provided for @sectionFetal.
  ///
  /// In en, this message translates to:
  /// **'BABY'**
  String get sectionFetal;

  /// No description provided for @fetalHrLabel.
  ///
  /// In en, this message translates to:
  /// **'Heart rate (per minute)'**
  String get fetalHrLabel;

  /// No description provided for @fetalMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby is moving'**
  String get fetalMovementLabel;

  /// No description provided for @sectionDanger.
  ///
  /// In en, this message translates to:
  /// **'DANGER SIGNS'**
  String get sectionDanger;

  /// No description provided for @dsBleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding'**
  String get dsBleeding;

  /// No description provided for @dsHeadache.
  ///
  /// In en, this message translates to:
  /// **'Severe headache'**
  String get dsHeadache;

  /// No description provided for @dsVision.
  ///
  /// In en, this message translates to:
  /// **'Blurred vision'**
  String get dsVision;

  /// No description provided for @dsSwelling.
  ///
  /// In en, this message translates to:
  /// **'Swelling of face or hands'**
  String get dsSwelling;

  /// No description provided for @dsFever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get dsFever;

  /// No description provided for @dsConvulsions.
  ///
  /// In en, this message translates to:
  /// **'Fits'**
  String get dsConvulsions;

  /// No description provided for @dsNoMovement.
  ///
  /// In en, this message translates to:
  /// **'Baby not moving'**
  String get dsNoMovement;

  /// No description provided for @sectionTablets.
  ///
  /// In en, this message translates to:
  /// **'TABLETS AND VACCINE'**
  String get sectionTablets;

  /// No description provided for @ifaTakenLabel.
  ///
  /// In en, this message translates to:
  /// **'Taking iron tablets'**
  String get ifaTakenLabel;

  /// No description provided for @calciumTakenLabel.
  ///
  /// In en, this message translates to:
  /// **'Taking calcium tablets'**
  String get calciumTakenLabel;

  /// No description provided for @ttDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'TT dose given'**
  String get ttDoseLabel;

  /// No description provided for @ttNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get ttNone;

  /// No description provided for @sectionNotes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get sectionNotes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else worth recording'**
  String get notesHint;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @saveVisit.
  ///
  /// In en, this message translates to:
  /// **'Save visit'**
  String get saveVisit;

  /// No description provided for @visitSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit saved on this phone'**
  String get visitSaved;

  /// No description provided for @rangeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Is this correct?'**
  String get rangeConfirmTitle;

  /// No description provided for @rangeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{value} — is that right?'**
  String rangeConfirmBody(String value);

  /// No description provided for @rangeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, that is right'**
  String get rangeYes;

  /// No description provided for @rangeNo.
  ///
  /// In en, this message translates to:
  /// **'No, let me fix it'**
  String get rangeNo;

  /// No description provided for @riskBannerNormal.
  ///
  /// In en, this message translates to:
  /// **'Nothing worrying so far'**
  String get riskBannerNormal;

  /// No description provided for @gpsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No GPS — the visit was saved anyway'**
  String get gpsUnavailable;

  /// No description provided for @riskAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'This needs attention now'**
  String get riskAlertTitle;

  /// No description provided for @referToPhc.
  ///
  /// In en, this message translates to:
  /// **'Refer to PHC'**
  String get referToPhc;

  /// No description provided for @callPhc.
  ///
  /// In en, this message translates to:
  /// **'Call PHC'**
  String get callPhc;

  /// No description provided for @advisoryFooter.
  ///
  /// In en, this message translates to:
  /// **'Advisory only — not a diagnosis'**
  String get advisoryFooter;

  /// No description provided for @referralCreated.
  ///
  /// In en, this message translates to:
  /// **'Referral saved and queued'**
  String get referralCreated;

  /// No description provided for @dismissAlert.
  ///
  /// In en, this message translates to:
  /// **'I have seen this'**
  String get dismissAlert;

  /// No description provided for @referralTo.
  ///
  /// In en, this message translates to:
  /// **'Referred to {facility}'**
  String referralTo(String facility);

  /// No description provided for @phcName.
  ///
  /// In en, this message translates to:
  /// **'Government PHC, Hosahalli'**
  String get phcName;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dialler'**
  String get callFailed;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get tasksTitle;

  /// No description provided for @tabOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tabOpen;

  /// No description provided for @tabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tabDone;

  /// No description provided for @tabMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get tabMissed;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @taskDoneVia.
  ///
  /// In en, this message translates to:
  /// **'Closed by a visit'**
  String get taskDoneVia;

  /// No description provided for @noTasksHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get noTasksHere;

  /// No description provided for @incentiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Incentive claim sheet'**
  String get incentiveTitle;

  /// No description provided for @incentiveNote.
  ///
  /// In en, this message translates to:
  /// **'This lists activities only. Confirm the current rates with your ANM supervisor before claiming.'**
  String get incentiveNote;

  /// No description provided for @claimableItems.
  ///
  /// In en, this message translates to:
  /// **'{count} claimable activities'**
  String claimableItems(int count);

  /// No description provided for @catRegistration.
  ///
  /// In en, this message translates to:
  /// **'Mother registration'**
  String get catRegistration;

  /// No description provided for @catAncVisit.
  ///
  /// In en, this message translates to:
  /// **'ANC visit'**
  String get catAncVisit;

  /// No description provided for @catReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral to PHC'**
  String get catReferral;

  /// No description provided for @catHighRiskFollowUp.
  ///
  /// In en, this message translates to:
  /// **'High-risk follow-up'**
  String get catHighRiskFollowUp;

  /// No description provided for @incentiveOffline.
  ///
  /// In en, this message translates to:
  /// **'Built from this phone. Works with no network.'**
  String get incentiveOffline;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share summary'**
  String get shareSummary;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncTitle;

  /// No description provided for @retryNow.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get retryNow;

  /// No description provided for @outboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Everything has been sent'**
  String get outboxEmpty;

  /// No description provided for @outStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get outStatusPending;

  /// No description provided for @outStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get outStatusSyncing;

  /// No description provided for @outStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get outStatusSynced;

  /// No description provided for @outStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get outStatusFailed;

  /// No description provided for @retryCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} attempts'**
  String retryCountLabel(int count);

  /// No description provided for @demoOfflineToggle.
  ///
  /// In en, this message translates to:
  /// **'Demo: force offline'**
  String get demoOfflineToggle;

  /// No description provided for @demoOfflineOn.
  ///
  /// In en, this message translates to:
  /// **'Offline mode is on. Nothing will be sent.'**
  String get demoOfflineOn;

  /// No description provided for @recordVisit.
  ///
  /// In en, this message translates to:
  /// **'ANC visit'**
  String get recordVisit;

  /// No description provided for @recordMother.
  ///
  /// In en, this message translates to:
  /// **'Mother registration'**
  String get recordMother;

  /// No description provided for @recordReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get recordReferral;

  /// No description provided for @recordAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get recordAlert;

  /// No description provided for @recordTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get recordTask;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get emailVerifyAction;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get emailVerifiedChip;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Verify when online'**
  String get emailNotVerifiedOffline;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Verify her email'**
  String get emailVerifyTitle;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'A code has been sent to {email}. Ask her to read it out, and type it here.'**
  String emailVerifyBody(String email);

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get emailVerifyConfirm;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Email verified. She can sign in to Thayi Setu with it.'**
  String get emailVerifiedOk;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Code confirmed. It will be saved when her record syncs.'**
  String get emailVerifiedPending;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'That code did not match. Try again.'**
  String get emailVerifyWrongCode;

  /// Verifying a mother email at registration.
  ///
  /// In en, this message translates to:
  /// **'Could not send the code. Check the connection.'**
  String get emailVerifyOffline;

  /// Re-sending records stranded on the phone.
  ///
  /// In en, this message translates to:
  /// **'Send everything again'**
  String get resendEverything;

  /// Re-sending records stranded on the phone.
  ///
  /// In en, this message translates to:
  /// **'{count} records queued to send again'**
  String resendQueued(int count);
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
