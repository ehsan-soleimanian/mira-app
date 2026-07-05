import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Your second memory is ready'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drop a thought, voice, photo, screenshot or reminder. Mira will connect it to your graph.'**
  String get homeSubtitle;

  /// No description provided for @homeProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira is understanding this'**
  String get homeProcessingTitle;

  /// No description provided for @homeProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extracting meaning, tasks and graph links.'**
  String get homeProcessingSubtitle;

  /// No description provided for @homeQuickCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture anything'**
  String get homeQuickCaptureTitle;

  /// No description provided for @homeQuickCapturePrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a memory, question or reminder'**
  String get homeQuickCapturePrompt;

  /// No description provided for @homeAskStarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get homeAskStarterLabel;

  /// No description provided for @homeAskStarterPrompt.
  ///
  /// In en, this message translates to:
  /// **'What do I know about '**
  String get homeAskStarterPrompt;

  /// No description provided for @homeSaveStarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get homeSaveStarterLabel;

  /// No description provided for @homeSaveStarterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remember that '**
  String get homeSaveStarterPrompt;

  /// No description provided for @homeReminderStarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get homeReminderStarterLabel;

  /// No description provided for @homeReminderStarterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remind me to '**
  String get homeReminderStarterPrompt;

  /// No description provided for @homeTextActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get homeTextActionTitle;

  /// No description provided for @homeTextActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write or ask'**
  String get homeTextActionSubtitle;

  /// No description provided for @homeVoiceActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get homeVoiceActionTitle;

  /// No description provided for @homeVoiceActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally'**
  String get homeVoiceActionSubtitle;

  /// No description provided for @homePhotoActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get homePhotoActionTitle;

  /// No description provided for @homePhotoActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera to graph'**
  String get homePhotoActionSubtitle;

  /// No description provided for @homeScreenshotActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get homeScreenshotActionTitle;

  /// No description provided for @homeScreenshotActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import fast'**
  String get homeScreenshotActionSubtitle;

  /// No description provided for @homeReminderActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get homeReminderActionTitle;

  /// No description provided for @homeReminderActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Say the time'**
  String get homeReminderActionSubtitle;

  /// No description provided for @homeGraphActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get homeGraphActionTitle;

  /// No description provided for @homeGraphActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See links'**
  String get homeGraphActionSubtitle;

  /// No description provided for @homeRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get homeRemindersTitle;

  /// No description provided for @homeRemindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No open reminders yet'**
  String get homeRemindersEmptyTitle;

  /// No description provided for @homeRemindersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tell Mira what you need to do and it will appear here after approval.'**
  String get homeRemindersEmptyBody;

  /// No description provided for @homeOpenDailyBrief.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief'**
  String get homeOpenDailyBrief;

  /// No description provided for @homeMemoryGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory graph'**
  String get homeMemoryGraphTitle;

  /// No description provided for @homeMemoryGraphBody.
  ///
  /// In en, this message translates to:
  /// **'Approved captures become entities, assertions and tasks connected in your graph.'**
  String get homeMemoryGraphBody;

  /// No description provided for @homeOpenGraph.
  ///
  /// In en, this message translates to:
  /// **'Open graph'**
  String get homeOpenGraph;

  /// No description provided for @sharedImportAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Share to Mira'**
  String get sharedImportAppBarTitle;

  /// No description provided for @sharedImportImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Import screenshot or image'**
  String get sharedImportImageTitle;

  /// No description provided for @sharedImportTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Import shared text'**
  String get sharedImportTextTitle;

  /// No description provided for @sharedImportImageBody.
  ///
  /// In en, this message translates to:
  /// **'Mira will read this, extract meaning, and connect it to your memory graph.'**
  String get sharedImportImageBody;

  /// No description provided for @sharedImportTextBody.
  ///
  /// In en, this message translates to:
  /// **'Mira will turn this into a memory, question, task, or reminder.'**
  String get sharedImportTextBody;

  /// No description provided for @sharedImportImageHint.
  ///
  /// In en, this message translates to:
  /// **'Optional note for Mira'**
  String get sharedImportImageHint;

  /// No description provided for @sharedImportTextHint.
  ///
  /// In en, this message translates to:
  /// **'Edit before importing'**
  String get sharedImportTextHint;

  /// No description provided for @sharedImportSave.
  ///
  /// In en, this message translates to:
  /// **'Save to memory'**
  String get sharedImportSave;

  /// No description provided for @sharedImportImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get sharedImportImporting;

  /// No description provided for @sharedImportImportingStatus.
  ///
  /// In en, this message translates to:
  /// **'Importing into Mira...'**
  String get sharedImportImportingStatus;

  /// No description provided for @sharedImportReadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Mira is reading the shared content...'**
  String get sharedImportReadingStatus;

  /// No description provided for @sharedImportAnswerReceived.
  ///
  /// In en, this message translates to:
  /// **'Answer received'**
  String get sharedImportAnswerReceived;

  /// No description provided for @sharedImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed.'**
  String get sharedImportFailed;

  /// No description provided for @sharedImportOversize.
  ///
  /// In en, this message translates to:
  /// **'This file is larger than 10 MB.'**
  String get sharedImportOversize;

  /// No description provided for @sharedImportFallbackFileName.
  ///
  /// In en, this message translates to:
  /// **'Shared image'**
  String get sharedImportFallbackFileName;

  /// No description provided for @sharedImportGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared memory added'**
  String get sharedImportGraphTitle;

  /// No description provided for @sharedImportGraphSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mira connected the import to your graph.'**
  String get sharedImportGraphSubtitle;

  /// No description provided for @captureIntentClarificationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Could you clarify - is this a question or something to save?'**
  String get captureIntentClarificationPrompt;

  /// No description provided for @captureIntentThisIsQuestion.
  ///
  /// In en, this message translates to:
  /// **'This is a question'**
  String get captureIntentThisIsQuestion;

  /// No description provided for @captureIntentSaveToMemory.
  ///
  /// In en, this message translates to:
  /// **'Save to memory'**
  String get captureIntentSaveToMemory;

  /// No description provided for @captureWorkflowComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask, remember, or make a plan'**
  String get captureWorkflowComposeTitle;

  /// No description provided for @captureWorkflowComposeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mira can answer from your graph, save a memory, or turn a thought into a task.'**
  String get captureWorkflowComposeSubtitle;

  /// No description provided for @captureWorkflowComposeHint.
  ///
  /// In en, this message translates to:
  /// **'Type naturally. Mira will ask if it needs to choose question vs memory.'**
  String get captureWorkflowComposeHint;

  /// No description provided for @captureEntityEquivalenceDefaultPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are these the same person in your memory?'**
  String get captureEntityEquivalenceDefaultPrompt;

  /// No description provided for @captureEntityEquivalenceSamePerson.
  ///
  /// In en, this message translates to:
  /// **'Yes, same person'**
  String get captureEntityEquivalenceSamePerson;

  /// No description provided for @captureEntityEquivalenceDifferentPeople.
  ///
  /// In en, this message translates to:
  /// **'No, different people'**
  String get captureEntityEquivalenceDifferentPeople;

  /// No description provided for @graphMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get graphMarkDone;

  /// No description provided for @graphCancelTask.
  ///
  /// In en, this message translates to:
  /// **'Cancel task'**
  String get graphCancelTask;

  /// No description provided for @graphEditMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit memory'**
  String get graphEditMemory;

  /// No description provided for @graphDeleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Delete memory'**
  String get graphDeleteMemory;

  /// No description provided for @graphDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this memory?'**
  String get graphDeleteConfirmTitle;

  /// No description provided for @graphDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the capture from your graph. Related people stay if used elsewhere.'**
  String get graphDeleteConfirmBody;

  /// No description provided for @graphSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get graphSave;

  /// No description provided for @graphCorrectMemoryHint.
  ///
  /// In en, this message translates to:
  /// **'Update what you want Mira to remember'**
  String get graphCorrectMemoryHint;

  /// No description provided for @graphMutationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get graphMutationSuccess;

  /// No description provided for @graphMutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update. Try again.'**
  String get graphMutationFailed;

  /// No description provided for @graphRejectAssertion.
  ///
  /// In en, this message translates to:
  /// **'Reject claim'**
  String get graphRejectAssertion;

  /// No description provided for @appUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get appUpdateTitle;

  /// No description provided for @appUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'You are on {currentVersion}. Mira {latestVersion} (build {latestBuild}) is ready to install.'**
  String appUpdateBody(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  );

  /// No description provided for @appUpdateVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'v{currentVersion} → v{latestVersion} (build {latestBuild})'**
  String appUpdateVersionLabel(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  );

  /// No description provided for @appUpdateProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% downloaded'**
  String appUpdateProgress(int percent);

  /// No description provided for @appUpdateProgressIndeterminate.
  ///
  /// In en, this message translates to:
  /// **'{downloaded} downloaded'**
  String appUpdateProgressIndeterminate(String downloaded);

  /// No description provided for @appUpdateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Opening installer…'**
  String get appUpdateInstalling;

  /// No description provided for @appUpdateInstallStarted.
  ///
  /// In en, this message translates to:
  /// **'Follow the system prompts to finish installing.'**
  String get appUpdateInstallStarted;

  /// No description provided for @appUpdateSignatureMismatch.
  ///
  /// In en, this message translates to:
  /// **'This build was signed differently than the app on your phone. Uninstall Mira first, then download and install again.'**
  String get appUpdateSignatureMismatch;

  /// No description provided for @appUpdateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start installation. Try again or uninstall the old app first.'**
  String get appUpdateInstallFailed;

  /// No description provided for @appUpdateRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appUpdateRetry;

  /// No description provided for @appUpdateOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings to uninstall'**
  String get appUpdateOpenSettings;

  /// No description provided for @appUpdateClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get appUpdateClose;

  /// No description provided for @appUpdateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download update'**
  String get appUpdateDownload;

  /// No description provided for @appUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get appUpdateLater;

  /// No description provided for @appUpdateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get appUpdateDownloadFailed;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
