import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @enterEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter email or username'**
  String get enterEmailOrUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @errEnterEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter email or username'**
  String get errEnterEmailOrUsername;

  /// No description provided for @errEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get errEnterPassword;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguageTitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signUpEmailLabel;

  /// No description provided for @signUpEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get signUpEmailHint;

  /// No description provided for @signUpUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Username'**
  String get signUpUsernameLabel;

  /// No description provided for @signUpUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get signUpUsernameHint;

  /// No description provided for @signUpPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get signUpPasswordLabel;

  /// No description provided for @signUpPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signUpPasswordHint;

  /// No description provided for @signUpOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get signUpOrContinueWith;

  /// No description provided for @signUpEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get signUpEmailRequired;

  /// No description provided for @signUpUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get signUpUsernameRequired;

  /// No description provided for @signUpPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get signUpPasswordRequired;

  /// No description provided for @signUpErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'Sign up error'**
  String get signUpErrorDefault;

  /// No description provided for @signUpErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get signUpErrorGeneric;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email or username'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get forgotPasswordNewPasswordLabel;

  /// No description provided for @forgotPasswordConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get forgotPasswordConfirmPasswordLabel;

  /// No description provided for @forgotPasswordPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get forgotPasswordPasswordHint;

  /// No description provided for @forgotPasswordDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get forgotPasswordDoneButton;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or username'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get forgotPasswordNewPasswordRequired;

  /// No description provided for @forgotPasswordConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get forgotPasswordConfirmPasswordRequired;

  /// No description provided for @forgotPasswordPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get forgotPasswordPasswordsDoNotMatch;

  /// No description provided for @forgotPasswordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get forgotPasswordResetEmailSent;

  /// No description provided for @forgotPasswordNoAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email.'**
  String get forgotPasswordNoAccountFound;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get forgotPasswordNetworkError;

  /// No description provided for @forgotPasswordFailedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email.'**
  String get forgotPasswordFailedToSendResetEmail;

  /// No description provided for @forgotPasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get forgotPasswordGenericError;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreMostPopularRoutines.
  ///
  /// In en, this message translates to:
  /// **'Most Popular Routines'**
  String get exploreMostPopularRoutines;

  /// No description provided for @exploreBecomeBetterYou.
  ///
  /// In en, this message translates to:
  /// **'Become Better You'**
  String get exploreBecomeBetterYou;

  /// No description provided for @exploreHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Intelligent\nProjects are\nhere'**
  String get exploreHeroHeadline;

  /// No description provided for @exploreHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create Projects with AI\nTeammates, Notes, Tasks and\nFiles'**
  String get exploreHeroSubtitle;

  /// No description provided for @exploreHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Create free project'**
  String get exploreHeroCta;

  /// No description provided for @exploreRoutineTag.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE'**
  String get exploreRoutineTag;

  /// No description provided for @exploreHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get exploreHabitsTitle;

  /// No description provided for @exploreCopyHabitsButton.
  ///
  /// In en, this message translates to:
  /// **'Copy {count} habits'**
  String exploreCopyHabitsButton(int count);

  /// No description provided for @explorePleaseSignInToCopyHabits.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to copy habits.'**
  String get explorePleaseSignInToCopyHabits;

  /// No description provided for @exploreCopiedHabitsSnack.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} habits'**
  String exploreCopiedHabitsSnack(int count);

  /// No description provided for @exploreCouldNotCopyHabits.
  ///
  /// In en, this message translates to:
  /// **'Could not copy habits. Try again.'**
  String get exploreCouldNotCopyHabits;

  /// No description provided for @exploreConfirmCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy habits?'**
  String get exploreConfirmCopyTitle;

  /// No description provided for @exploreConfirmCopySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} habits will be created.'**
  String exploreConfirmCopySubtitle(int count);

  /// No description provided for @exploreYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get exploreYes;

  /// No description provided for @exploreCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get exploreCancel;

  /// No description provided for @exploreRoutineProcrastinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Overcome\nProcrastination'**
  String get exploreRoutineProcrastinationTitle;

  /// No description provided for @exploreRoutineProcrastinationDescription.
  ///
  /// In en, this message translates to:
  /// **'Procrastination can sabotage your productivity and hinder your success, but it doesn’t have to dictate your future. This routine offers evidence-based strategies to help you overcome procrastination and build momentum.'**
  String get exploreRoutineProcrastinationDescription;

  /// No description provided for @exploreRoutineAnxietyTitle.
  ///
  /// In en, this message translates to:
  /// **'Relieve\nAnxiety'**
  String get exploreRoutineAnxietyTitle;

  /// No description provided for @exploreRoutineAnxietyDescription.
  ///
  /// In en, this message translates to:
  /// **'A practical routine to lower baseline stress and reduce anxious spirals with small daily actions.'**
  String get exploreRoutineAnxietyDescription;

  /// No description provided for @exploreRoutineFocusBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus\nBoost'**
  String get exploreRoutineFocusBoostTitle;

  /// No description provided for @exploreRoutineFocusBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your focus with a compact routine designed for deep work.'**
  String get exploreRoutineFocusBoostDescription;

  /// No description provided for @exploreRoutineMorningMomentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning\nMomentum'**
  String get exploreRoutineMorningMomentumTitle;

  /// No description provided for @exploreRoutineMorningMomentumDescription.
  ///
  /// In en, this message translates to:
  /// **'Start the day with momentum and a clear plan.'**
  String get exploreRoutineMorningMomentumDescription;

  /// No description provided for @exploreHabitPomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Technique'**
  String get exploreHabitPomodoroTitle;

  /// No description provided for @exploreHabitPomodoroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use focused 25-min blocks with short breaks.'**
  String get exploreHabitPomodoroSubtitle;

  /// No description provided for @exploreHabitTimeBlockingTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Blocking'**
  String get exploreHabitTimeBlockingTitle;

  /// No description provided for @exploreHabitTimeBlockingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule your day into clear task windows.'**
  String get exploreHabitTimeBlockingSubtitle;

  /// No description provided for @exploreHabitEatThatFrogTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat That Frog'**
  String get exploreHabitEatThatFrogTitle;

  /// No description provided for @exploreHabitEatThatFrogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do the hardest task first to reduce avoidance.'**
  String get exploreHabitEatThatFrogSubtitle;

  /// No description provided for @exploreHabitBreakTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Break Tasks into Smaller Steps'**
  String get exploreHabitBreakTasksTitle;

  /// No description provided for @exploreHabitBreakTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn big tasks into small, actionable steps.'**
  String get exploreHabitBreakTasksSubtitle;

  /// No description provided for @exploreHabitSmartGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set SMART Goals'**
  String get exploreHabitSmartGoalsTitle;

  /// No description provided for @exploreHabitSmartGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Specific, Measurable, Achievable, Relevant, Time-bound.'**
  String get exploreHabitSmartGoalsSubtitle;

  /// No description provided for @exploreHabitBoxBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get exploreHabitBoxBreathingTitle;

  /// No description provided for @exploreHabitBoxBreathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4-4-4-4 breathing cycle.'**
  String get exploreHabitBoxBreathingSubtitle;

  /// No description provided for @exploreHabitShortWalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Short Walk'**
  String get exploreHabitShortWalkTitle;

  /// No description provided for @exploreHabitShortWalkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10 minutes outside if possible.'**
  String get exploreHabitShortWalkSubtitle;

  /// No description provided for @exploreHabitJournalDumpTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal Dump'**
  String get exploreHabitJournalDumpTitle;

  /// No description provided for @exploreHabitJournalDumpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write thoughts without filtering.'**
  String get exploreHabitJournalDumpSubtitle;

  /// No description provided for @exploreHabitLimitCaffeineTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit Caffeine'**
  String get exploreHabitLimitCaffeineTitle;

  /// No description provided for @exploreHabitLimitCaffeineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce triggers after noon.'**
  String get exploreHabitLimitCaffeineSubtitle;

  /// No description provided for @exploreHabitSleepWindDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Wind-down'**
  String get exploreHabitSleepWindDownTitle;

  /// No description provided for @exploreHabitSleepWindDownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Consistent pre-sleep ritual.'**
  String get exploreHabitSleepWindDownSubtitle;

  /// No description provided for @exploreHabitNoPhoneStartTitle.
  ///
  /// In en, this message translates to:
  /// **'No-Phone Start'**
  String get exploreHabitNoPhoneStartTitle;

  /// No description provided for @exploreHabitNoPhoneStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First 30 mins without scrolling.'**
  String get exploreHabitNoPhoneStartSubtitle;

  /// No description provided for @exploreHabitDeepWorkBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Block'**
  String get exploreHabitDeepWorkBlockTitle;

  /// No description provided for @exploreHabitDeepWorkBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One 45–60 min focus sprint.'**
  String get exploreHabitDeepWorkBlockSubtitle;

  /// No description provided for @exploreHabitSingleTaskListTitle.
  ///
  /// In en, this message translates to:
  /// **'Single Task List'**
  String get exploreHabitSingleTaskListTitle;

  /// No description provided for @exploreHabitSingleTaskListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick 1–3 outcomes max.'**
  String get exploreHabitSingleTaskListSubtitle;

  /// No description provided for @exploreHabitHydrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydrate'**
  String get exploreHabitHydrateTitle;

  /// No description provided for @exploreHabitHydrateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Water before coffee.'**
  String get exploreHabitHydrateSubtitle;

  /// No description provided for @exploreHabitMakeBedTitle.
  ///
  /// In en, this message translates to:
  /// **'Make the Bed'**
  String get exploreHabitMakeBedTitle;

  /// No description provided for @exploreHabitMakeBedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick win to start.'**
  String get exploreHabitMakeBedSubtitle;

  /// No description provided for @exploreHabitTop3PrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Priorities'**
  String get exploreHabitTop3PrioritiesTitle;

  /// No description provided for @exploreHabitTop3PrioritiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write the day’s outcomes.'**
  String get exploreHabitTop3PrioritiesSubtitle;

  /// No description provided for @exploreHabitStretchTitle.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get exploreHabitStretchTitle;

  /// No description provided for @exploreHabitStretchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'2–5 minutes full body.'**
  String get exploreHabitStretchSubtitle;

  /// No description provided for @exploreHabitProteinBreakfastTitle.
  ///
  /// In en, this message translates to:
  /// **'Protein Breakfast'**
  String get exploreHabitProteinBreakfastTitle;

  /// No description provided for @exploreHabitProteinBreakfastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stable energy.'**
  String get exploreHabitProteinBreakfastSubtitle;

  /// No description provided for @exploreRoutineCreativityBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Creativity\nBoosting\nRoutine'**
  String get exploreRoutineCreativityBoostTitle;

  /// No description provided for @exploreRoutineCreativityBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple routine to increase creative output and reduce friction.'**
  String get exploreRoutineCreativityBoostDescription;

  /// No description provided for @exploreRoutineProductivityEnhancerTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity\nEnhancer\nRoutine'**
  String get exploreRoutineProductivityEnhancerTitle;

  /// No description provided for @exploreRoutineProductivityEnhancerDescription.
  ///
  /// In en, this message translates to:
  /// **'Improve output with better planning and execution habits.'**
  String get exploreRoutineProductivityEnhancerDescription;

  /// No description provided for @exploreRoutineBuildConfidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Build\nConfidence'**
  String get exploreRoutineBuildConfidenceTitle;

  /// No description provided for @exploreRoutineBuildConfidenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Small daily actions to build confidence and consistency.'**
  String get exploreRoutineBuildConfidenceDescription;

  /// No description provided for @exploreRoutineBetterSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Better\nSleep'**
  String get exploreRoutineBetterSleepTitle;

  /// No description provided for @exploreRoutineBetterSleepDescription.
  ///
  /// In en, this message translates to:
  /// **'A calming routine to improve sleep quality and recovery.'**
  String get exploreRoutineBetterSleepDescription;

  /// No description provided for @exploreHabitIdeaCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Idea Capture'**
  String get exploreHabitIdeaCaptureTitle;

  /// No description provided for @exploreHabitIdeaCaptureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write 5 ideas daily.'**
  String get exploreHabitIdeaCaptureSubtitle;

  /// No description provided for @exploreHabitCreateBeforeConsumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Before Consume'**
  String get exploreHabitCreateBeforeConsumeTitle;

  /// No description provided for @exploreHabitCreateBeforeConsumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make first, scroll later.'**
  String get exploreHabitCreateBeforeConsumeSubtitle;

  /// No description provided for @exploreHabitInputWalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Input Walk'**
  String get exploreHabitInputWalkTitle;

  /// No description provided for @exploreHabitInputWalkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a walk for inspiration.'**
  String get exploreHabitInputWalkSubtitle;

  /// No description provided for @exploreHabitDailySketchTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Sketch'**
  String get exploreHabitDailySketchTitle;

  /// No description provided for @exploreHabitDailySketchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'2 minutes, no pressure.'**
  String get exploreHabitDailySketchSubtitle;

  /// No description provided for @exploreHabitPlanTomorrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Tomorrow'**
  String get exploreHabitPlanTomorrowTitle;

  /// No description provided for @exploreHabitPlanTomorrowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End-of-day 5-minute plan.'**
  String get exploreHabitPlanTomorrowSubtitle;

  /// No description provided for @exploreHabitInboxZeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox Zero'**
  String get exploreHabitInboxZeroTitle;

  /// No description provided for @exploreHabitInboxZeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear messages in one block.'**
  String get exploreHabitInboxZeroSubtitle;

  /// No description provided for @exploreHabitTwoMinuteRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Minute Rule'**
  String get exploreHabitTwoMinuteRuleTitle;

  /// No description provided for @exploreHabitTwoMinuteRuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do it now if it’s quick.'**
  String get exploreHabitTwoMinuteRuleSubtitle;

  /// No description provided for @exploreHabitShutdownRitualTitle.
  ///
  /// In en, this message translates to:
  /// **'Shutdown Ritual'**
  String get exploreHabitShutdownRitualTitle;

  /// No description provided for @exploreHabitShutdownRitualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close loops, end work cleanly.'**
  String get exploreHabitShutdownRitualSubtitle;

  /// No description provided for @exploreHabitDailyWinTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Win'**
  String get exploreHabitDailyWinTitle;

  /// No description provided for @exploreHabitDailyWinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record one win every day.'**
  String get exploreHabitDailyWinSubtitle;

  /// No description provided for @exploreHabitPracticeSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Skill'**
  String get exploreHabitPracticeSkillTitle;

  /// No description provided for @exploreHabitPracticeSkillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10 minutes deliberate practice.'**
  String get exploreHabitPracticeSkillSubtitle;

  /// No description provided for @exploreHabitPostureResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Posture Reset'**
  String get exploreHabitPostureResetTitle;

  /// No description provided for @exploreHabitPostureResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'2x daily check-in.'**
  String get exploreHabitPostureResetSubtitle;

  /// No description provided for @exploreHabitPositiveReframeTitle.
  ///
  /// In en, this message translates to:
  /// **'Positive Reframe'**
  String get exploreHabitPositiveReframeTitle;

  /// No description provided for @exploreHabitPositiveReframeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rewrite the story in your head.'**
  String get exploreHabitPositiveReframeSubtitle;

  /// No description provided for @exploreHabitNoScreensTitle.
  ///
  /// In en, this message translates to:
  /// **'No Screens'**
  String get exploreHabitNoScreensTitle;

  /// No description provided for @exploreHabitNoScreensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid screens 30 mins before bed.'**
  String get exploreHabitNoScreensSubtitle;

  /// No description provided for @exploreHabitCoolRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Cool Room'**
  String get exploreHabitCoolRoomTitle;

  /// No description provided for @exploreHabitCoolRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lower temp for better sleep.'**
  String get exploreHabitCoolRoomSubtitle;

  /// No description provided for @exploreHabitReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get exploreHabitReadTitle;

  /// No description provided for @exploreHabitReadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10 pages of a book.'**
  String get exploreHabitReadSubtitle;

  /// No description provided for @exploreHabitSameBedtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Same Bedtime'**
  String get exploreHabitSameBedtimeTitle;

  /// No description provided for @exploreHabitSameBedtimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats perfection.'**
  String get exploreHabitSameBedtimeSubtitle;

  /// No description provided for @createHabitCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Habit'**
  String get createHabitCreateTitle;

  /// No description provided for @createHabitEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get createHabitEditTitle;

  /// No description provided for @createHabitColorPicker.
  ///
  /// In en, this message translates to:
  /// **'Color Picker'**
  String get createHabitColorPicker;

  /// No description provided for @createHabitPickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get createHabitPickColorTitle;

  /// No description provided for @createHabitContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get createHabitContinue;

  /// No description provided for @createHabitCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createHabitCancel;

  /// No description provided for @createHabitDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get createHabitDone;

  /// No description provided for @createHabitTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createHabitTitleLabel;

  /// No description provided for @createHabitTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createHabitTitleHint;

  /// No description provided for @createHabitDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createHabitDescriptionLabel;

  /// No description provided for @createHabitDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createHabitDescriptionHint;

  /// No description provided for @createHabitColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get createHabitColorLabel;

  /// No description provided for @createHabitRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get createHabitRepeatLabel;

  /// No description provided for @createHabitDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get createHabitDaily;

  /// No description provided for @createHabitWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get createHabitWeekly;

  /// No description provided for @createHabitMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get createHabitMonthly;

  /// No description provided for @createHabitReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get createHabitReminderLabel;

  /// No description provided for @createHabitSendNotificationAt.
  ///
  /// In en, this message translates to:
  /// **'Send a notification at'**
  String get createHabitSendNotificationAt;

  /// No description provided for @createHabitPickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get createHabitPickTime;

  /// No description provided for @createHabitReminderInfo.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get \"It\'s time for your habit.\" with your habit name.'**
  String get createHabitReminderInfo;

  /// No description provided for @createHabitGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get createHabitGoalLabel;

  /// No description provided for @createHabitEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get createHabitEdit;

  /// No description provided for @createHabitPerDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get createHabitPerDay;

  /// No description provided for @createHabitSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get createHabitSetGoal;

  /// No description provided for @createHabitTrackUnitsHelp.
  ///
  /// In en, this message translates to:
  /// **'Track times, minutes, hours, kg, km, liters, or ounces.'**
  String get createHabitTrackUnitsHelp;

  /// No description provided for @createHabitSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get createHabitSave;

  /// No description provided for @createHabitSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get createHabitSaveChanges;

  /// No description provided for @createHabitTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get createHabitTitleRequired;

  /// No description provided for @createHabitMustBeSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to create a habit.'**
  String get createHabitMustBeSignedIn;

  /// No description provided for @createHabitFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save habit. Please try again.'**
  String get createHabitFailedToSave;

  /// No description provided for @createHabitOnTheseDays.
  ///
  /// In en, this message translates to:
  /// **'On these days'**
  String get createHabitOnTheseDays;

  /// No description provided for @createHabitFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get createHabitFrequency;

  /// No description provided for @createHabitEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get createHabitEveryday;

  /// No description provided for @createHabitDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} days per week'**
  String createHabitDaysPerWeek(int count);

  /// No description provided for @createHabitOnThisDayEachMonth.
  ///
  /// In en, this message translates to:
  /// **'On this day each month'**
  String get createHabitOnThisDayEachMonth;

  /// No description provided for @createHabitMonShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get createHabitMonShort;

  /// No description provided for @createHabitTueShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get createHabitTueShort;

  /// No description provided for @createHabitWedShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get createHabitWedShort;

  /// No description provided for @createHabitThuShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get createHabitThuShort;

  /// No description provided for @createHabitFriShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get createHabitFriShort;

  /// No description provided for @createHabitSatShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get createHabitSatShort;

  /// No description provided for @createHabitSunShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get createHabitSunShort;

  /// No description provided for @createHabitAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get createHabitAm;

  /// No description provided for @createHabitPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get createHabitPm;

  /// No description provided for @createHabitGoalLabelText.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}{plural} per day'**
  String createHabitGoalLabelText(int value, String unit, String plural);

  /// No description provided for @createHabitGoalText.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit} per day'**
  String createHabitGoalText(int value, String unit);

  /// No description provided for @createHabitUnitTime.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get createHabitUnitTime;

  /// No description provided for @createHabitUnitMinute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get createHabitUnitMinute;

  /// No description provided for @createHabitUnitHour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get createHabitUnitHour;

  /// No description provided for @createHabitUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get createHabitUnitKg;

  /// No description provided for @createHabitUnitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get createHabitUnitKm;

  /// No description provided for @createHabitUnitL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get createHabitUnitL;

  /// No description provided for @createHabitUnitOz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get createHabitUnitOz;

  /// No description provided for @habitDetailPleaseSignInHabits.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view habits.'**
  String get habitDetailPleaseSignInHabits;

  /// No description provided for @habitDetailPleaseSignInNotes.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notes.'**
  String get habitDetailPleaseSignInNotes;

  /// No description provided for @habitDetailDefaultHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitDetailDefaultHabitTitle;

  /// No description provided for @habitDetailUpdateProgress.
  ///
  /// In en, this message translates to:
  /// **'Update progress'**
  String get habitDetailUpdateProgress;

  /// No description provided for @habitDetailMarkedIncompleteDay.
  ///
  /// In en, this message translates to:
  /// **'Marked incomplete for that day'**
  String get habitDetailMarkedIncompleteDay;

  /// No description provided for @habitDetailMarkedCompleteDay.
  ///
  /// In en, this message translates to:
  /// **'Marked complete for that day'**
  String get habitDetailMarkedCompleteDay;

  /// No description provided for @habitDetailCouldNotUpdateDay.
  ///
  /// In en, this message translates to:
  /// **'Could not update that day. Try again.'**
  String get habitDetailCouldNotUpdateDay;

  /// No description provided for @habitDetailDeleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitDetailDeleteHabitTitle;

  /// No description provided for @habitDetailDeleteHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the habit and its history.'**
  String get habitDetailDeleteHabitMessage;

  /// No description provided for @habitDetailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get habitDetailCancel;

  /// No description provided for @habitDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitDetailDelete;

  /// No description provided for @habitDetailStatScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get habitDetailStatScore;

  /// No description provided for @habitDetailStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get habitDetailStatTotal;

  /// No description provided for @habitDetailStatBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get habitDetailStatBestStreak;

  /// No description provided for @habitDetailStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get habitDetailStatStreak;

  /// No description provided for @habitDetailScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get habitDetailScoreTitle;

  /// No description provided for @habitDetailAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get habitDetailAnalytics;

  /// No description provided for @habitDetailNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get habitDetailNoDataYet;

  /// No description provided for @habitDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get habitDetailHistory;

  /// No description provided for @habitDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get habitDetailNotes;

  /// No description provided for @habitDetailAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get habitDetailAddNote;

  /// No description provided for @habitDetailCouldNotLoadNotes.
  ///
  /// In en, this message translates to:
  /// **'Could not load notes.'**
  String get habitDetailCouldNotLoadNotes;

  /// No description provided for @habitDetailLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get habitDetailLoading;

  /// No description provided for @habitDetailNoNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get habitDetailNoNotesYet;

  /// No description provided for @habitDetailDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get habitDetailDeleteNoteTitle;

  /// No description provided for @habitDetailDeleteNoteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from both the habit and the journal.'**
  String get habitDetailDeleteNoteMessage;

  /// No description provided for @habitDetailNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get habitDetailNoteDeleted;

  /// No description provided for @habitDetailNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get habitDetailNoteSaved;

  /// No description provided for @habitDetailCouldNotSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Could not save note. Try again.'**
  String get habitDetailCouldNotSaveNote;

  /// No description provided for @habitDetailCouldNotSaveNoteWithCode.
  ///
  /// In en, this message translates to:
  /// **'Could not save note: {code}'**
  String habitDetailCouldNotSaveNoteWithCode(String code);

  /// No description provided for @habitDetailToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get habitDetailToday;

  /// No description provided for @habitDetailTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String habitDetailTodayTime(String time);

  /// No description provided for @habitDetailWhatHappenedToday.
  ///
  /// In en, this message translates to:
  /// **'What happened today?'**
  String get habitDetailWhatHappenedToday;

  /// No description provided for @habitDetailPickerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get habitDetailPickerCancel;

  /// No description provided for @habitDetailPickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habitDetailPickerDone;

  /// No description provided for @habitDetailMonthJanShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get habitDetailMonthJanShort;

  /// No description provided for @habitDetailMonthFebShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get habitDetailMonthFebShort;

  /// No description provided for @habitDetailMonthMarShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get habitDetailMonthMarShort;

  /// No description provided for @habitDetailMonthAprShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get habitDetailMonthAprShort;

  /// No description provided for @habitDetailMonthMayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get habitDetailMonthMayShort;

  /// No description provided for @habitDetailMonthJunShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get habitDetailMonthJunShort;

  /// No description provided for @habitDetailMonthJulShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get habitDetailMonthJulShort;

  /// No description provided for @habitDetailMonthAugShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get habitDetailMonthAugShort;

  /// No description provided for @habitDetailMonthSepShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get habitDetailMonthSepShort;

  /// No description provided for @habitDetailMonthOctShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get habitDetailMonthOctShort;

  /// No description provided for @habitDetailMonthNovShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get habitDetailMonthNovShort;

  /// No description provided for @habitDetailMonthDecShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get habitDetailMonthDecShort;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsSnackHabitCompletedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Habit completed correctly'**
  String get habitsSnackHabitCompletedCorrectly;

  /// No description provided for @habitsSnackProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Progress updated'**
  String get habitsSnackProgressUpdated;

  /// No description provided for @habitsSnackCouldNotUpdateProgress.
  ///
  /// In en, this message translates to:
  /// **'Could not update progress. Try again.'**
  String get habitsSnackCouldNotUpdateProgress;

  /// No description provided for @habitsSnackHabitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get habitsSnackHabitDeleted;

  /// No description provided for @habitsBottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get habitsBottomNavHome;

  /// No description provided for @habitsBottomNavAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get habitsBottomNavAnalytics;

  /// No description provided for @habitsBottomNavExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get habitsBottomNavExplore;

  /// No description provided for @habitsTabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get habitsTabToday;

  /// No description provided for @habitsTabWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get habitsTabWeekly;

  /// No description provided for @habitsTabOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get habitsTabOverall;

  /// No description provided for @habitsNotSignedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get habitsNotSignedInTitle;

  /// No description provided for @habitsNotSignedInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to create habits.'**
  String get habitsNotSignedInSubtitle;

  /// No description provided for @habitsGoodJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Job!'**
  String get habitsGoodJobTitle;

  /// No description provided for @habitsAllSetAndDone.
  ///
  /// In en, this message translates to:
  /// **'All set and done.'**
  String get habitsAllSetAndDone;

  /// No description provided for @habitsGreatButton.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get habitsGreatButton;

  /// No description provided for @habitsProgressCountCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String habitsProgressCountCompleted(int count);

  /// No description provided for @habitsCompletedShown.
  ///
  /// In en, this message translates to:
  /// **'Completed shown'**
  String get habitsCompletedShown;

  /// No description provided for @habitsCompletedHidden.
  ///
  /// In en, this message translates to:
  /// **'Completed hidden'**
  String get habitsCompletedHidden;

  /// No description provided for @habitsShowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get habitsShowCompleted;

  /// No description provided for @habitsCompletionSheetPerDay.
  ///
  /// In en, this message translates to:
  /// **'{current} / {goal} {unit}{plural} per day'**
  String habitsCompletionSheetPerDay(int current, int goal, String unit, String plural);

  /// No description provided for @habitsCompletionSheetMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get habitsCompletionSheetMarkCompleted;

  /// No description provided for @habitsCompletionSheetSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save progress'**
  String get habitsCompletionSheetSaveProgress;

  /// No description provided for @habitsCompletionSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + or - to register the times or units you set.'**
  String get habitsCompletionSheetHint;

  /// No description provided for @habitsDefaultHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitsDefaultHabitTitle;

  /// No description provided for @habitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits for today'**
  String get habitsEmptyTitle;

  /// No description provided for @habitsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There is no habit for today. Create one?'**
  String get habitsEmptySubtitle;

  /// No description provided for @habitsEmptyCreateButton.
  ///
  /// In en, this message translates to:
  /// **'+ Create'**
  String get habitsEmptyCreateButton;

  /// No description provided for @habitsWeeklyCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String habitsWeeklyCompletedCount(int count);

  /// No description provided for @habitsOverallEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get habitsOverallEveryday;

  /// No description provided for @habitsOverallWeeklyHabit.
  ///
  /// In en, this message translates to:
  /// **'Weekly habit'**
  String get habitsOverallWeeklyHabit;

  /// No description provided for @habitsOverallMonthlyHabit.
  ///
  /// In en, this message translates to:
  /// **'Monthly habit'**
  String get habitsOverallMonthlyHabit;

  /// No description provided for @habitsGoalUnitTime.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get habitsGoalUnitTime;

  /// No description provided for @journalSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your journal.'**
  String get journalSignInPrompt;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a note to get started'**
  String get journalEmptySubtitle;

  /// No description provided for @journalAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get journalAddButton;

  /// No description provided for @journalComposerHint.
  ///
  /// In en, this message translates to:
  /// **'What happened today?'**
  String get journalComposerHint;

  /// No description provided for @journalToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get journalToday;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @journalDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get journalDeleteNoteTitle;

  /// No description provided for @journalDeleteNoteBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get journalDeleteNoteBody;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @monthJanuaryShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJanuaryShort;

  /// No description provided for @monthFebruaryShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFebruaryShort;

  /// No description provided for @monthMarchShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMarchShort;

  /// No description provided for @monthAprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthAprilShort;

  /// No description provided for @monthMayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMayShort;

  /// No description provided for @monthJuneShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJuneShort;

  /// No description provided for @monthJulyShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJulyShort;

  /// No description provided for @monthAugustShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAugustShort;

  /// No description provided for @monthSeptemberShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSeptemberShort;

  /// No description provided for @monthOctoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOctoberShort;

  /// No description provided for @monthNovemberShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNovemberShort;

  /// No description provided for @monthDecemberShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDecemberShort;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunShort;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get accountTitle;

  /// No description provided for @accountUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accountUsernameLabel;

  /// No description provided for @accountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPasswordLabel;

  /// No description provided for @accountEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// No description provided for @accountPasswordLeaveBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current'**
  String get accountPasswordLeaveBlankHint;

  /// No description provided for @accountUsernameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get accountUsernameEmptyError;

  /// No description provided for @accountUsernameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Too short.'**
  String get accountUsernameTooShortError;

  /// No description provided for @accountEmailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email.'**
  String get accountEmailEmptyError;

  /// No description provided for @accountEmailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get accountEmailInvalidError;

  /// No description provided for @accountEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get accountEmailVerified;

  /// No description provided for @accountEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get accountEmailNotVerified;

  /// No description provided for @accountSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get accountSendButton;

  /// No description provided for @accountVerificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get accountVerificationEmailSent;

  /// No description provided for @accountVerificationEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification email.'**
  String get accountVerificationEmailFailed;

  /// No description provided for @accountMyHabits.
  ///
  /// In en, this message translates to:
  /// **'My habits'**
  String get accountMyHabits;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteAccount;

  /// No description provided for @accountSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get accountSaving;

  /// No description provided for @accountSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get accountSaveChanges;

  /// No description provided for @accountLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get accountLogOut;

  /// No description provided for @accountChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get accountChangesSaved;

  /// No description provided for @accountChangesSavedEmailVerificationHint.
  ///
  /// In en, this message translates to:
  /// **'Changes saved. Check your inbox if email verification was sent.'**
  String get accountChangesSavedEmailVerificationHint;

  /// No description provided for @accountCouldNotSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Try again.'**
  String get accountCouldNotSaveChanges;

  /// No description provided for @accountDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get accountDeleteDialogTitle;

  /// No description provided for @accountDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your account data.'**
  String get accountDeleteDialogBody;

  /// No description provided for @accountDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeletedSnackbar;

  /// No description provided for @accountCouldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account.'**
  String get accountCouldNotDelete;

  /// No description provided for @accountRequiresRecentLoginError.
  ///
  /// In en, this message translates to:
  /// **'For security, please log in again and retry this change.'**
  String get accountRequiresRecentLoginError;

  /// No description provided for @accountEmailAlreadyInUseError.
  ///
  /// In en, this message translates to:
  /// **'That email is already in use.'**
  String get accountEmailAlreadyInUseError;

  /// No description provided for @accountInvalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get accountInvalidEmailError;

  /// No description provided for @accountWeakPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters.'**
  String get accountWeakPasswordError;

  /// No description provided for @accountWeakPasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'That password is too weak.'**
  String get accountWeakPasswordGenericError;

  /// No description provided for @accountAuthGenericError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error.'**
  String get accountAuthGenericError;

  /// Displayed at the bottom of the hub screen
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String hubVersionLabel(String version);

  /// No description provided for @hubProTitle.
  ///
  /// In en, this message translates to:
  /// **'EcoHabit Pro'**
  String get hubProTitle;

  /// No description provided for @hubProPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Pro Yearly'**
  String get hubProPlanLabel;

  /// No description provided for @hubMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get hubMenuSettings;

  /// No description provided for @hubMenuAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get hubMenuAnalytics;

  /// No description provided for @hubMenuJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get hubMenuJournal;

  /// No description provided for @hubMenuAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get hubMenuAccount;

  /// No description provided for @hubMenuBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get hubMenuBackup;

  /// No description provided for @proPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'EcoHabit Pro'**
  String get proPlanTitle;

  /// No description provided for @proPlanDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Pro Yearly'**
  String get proPlanDefaultLabel;

  /// No description provided for @proPlanSubscribedPrefix.
  ///
  /// In en, this message translates to:
  /// **'You are subscribed to'**
  String get proPlanSubscribedPrefix;

  /// No description provided for @proPlanUpgradePrefix.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to'**
  String get proPlanUpgradePrefix;

  /// No description provided for @proPlanFreeHeader.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get proPlanFreeHeader;

  /// No description provided for @proPlanProHeader.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proPlanProHeader;

  /// No description provided for @proFeatureUnlimitedHabits.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Habits'**
  String get proFeatureUnlimitedHabits;

  /// No description provided for @proFeatureRoutineAi.
  ///
  /// In en, this message translates to:
  /// **'Routine AI'**
  String get proFeatureRoutineAi;

  /// No description provided for @proFeatureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get proFeatureAnalytics;

  /// No description provided for @proFeatureGoalSetting.
  ///
  /// In en, this message translates to:
  /// **'Goal setting'**
  String get proFeatureGoalSetting;

  /// No description provided for @proFeatureJournaling.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get proFeatureJournaling;

  /// No description provided for @proFeatureColorPicker.
  ///
  /// In en, this message translates to:
  /// **'Color Picker'**
  String get proFeatureColorPicker;

  /// No description provided for @proFeatureBackupHabits.
  ///
  /// In en, this message translates to:
  /// **'Backup habits'**
  String get proFeatureBackupHabits;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsAccentColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get settingsAccentColorTitle;

  /// No description provided for @settingsStartWeekOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Start week on'**
  String get settingsStartWeekOnTitle;

  /// No description provided for @settingsStartWeekSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get settingsStartWeekSaturday;

  /// No description provided for @settingsStartWeekSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settingsStartWeekSunday;

  /// No description provided for @settingsStartWeekMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settingsStartWeekMonday;

  /// No description provided for @settingsHabitTabsOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit tabs order'**
  String get settingsHabitTabsOrderTitle;

  /// No description provided for @settingsHabitTabsOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press an item to reorder'**
  String get settingsHabitTabsOrderHint;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view analytics.'**
  String get analyticsSignInPrompt;

  /// No description provided for @analyticsNoHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get analyticsNoHabitsYet;

  /// No description provided for @analyticsHabitFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get analyticsHabitFallbackTitle;

  /// No description provided for @analyticsAllHabitsTab.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get analyticsAllHabitsTab;

  /// No description provided for @analyticsAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get analyticsAverageScore;

  /// No description provided for @analyticsHabitsCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits completed'**
  String get analyticsHabitsCompletedTitle;

  /// No description provided for @analyticsTotalCompletedHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total completed habits'**
  String get analyticsTotalCompletedHabitsSubtitle;

  /// No description provided for @analyticsHabitHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit heatmap'**
  String get analyticsHabitHeatmapTitle;

  /// No description provided for @analyticsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get analyticsStreakTitle;

  /// No description provided for @analyticsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get analyticsBestStreak;

  /// No description provided for @analyticsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get analyticsCurrentStreak;

  /// No description provided for @analyticsWeeklyCompletionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Completions'**
  String get analyticsWeeklyCompletionsTitle;

  /// No description provided for @analyticsScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get analyticsScoreTitle;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get analyticsNoData;

  /// No description provided for @analyticsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get analyticsThisWeek;

  /// No description provided for @analyticsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get analyticsThisMonth;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @weekdayVeryShortMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayVeryShortMon;

  /// No description provided for @weekdayVeryShortTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayVeryShortTue;

  /// No description provided for @weekdayVeryShortWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayVeryShortWed;

  /// No description provided for @weekdayVeryShortThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayVeryShortThu;

  /// No description provided for @weekdayVeryShortFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayVeryShortFri;

  /// No description provided for @weekdayVeryShortSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayVeryShortSat;

  /// No description provided for @weekdayVeryShortSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayVeryShortSun;

  /// No description provided for @monthShortJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthShortJun;

  /// No description provided for @monthShortJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthShortDec;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
