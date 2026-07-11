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

  /// No description provided for @homeWorkspaceLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeWorkspaceLibrary;

  /// No description provided for @homeWorkspaceCanvas.
  ///
  /// In en, this message translates to:
  /// **'Canvas'**
  String get homeWorkspaceCanvas;

  /// No description provided for @homeAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira found this'**
  String get homeAnswerTitle;

  /// No description provided for @homeAnswerSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved memory'**
  String get homeAnswerSourceLabel;

  /// No description provided for @homeContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the conversation going'**
  String get homeContinueTitle;

  /// No description provided for @homeContinuePrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask a follow-up or add a correction'**
  String get homeContinuePrompt;

  /// No description provided for @homeContinueResponseHint.
  ///
  /// In en, this message translates to:
  /// **'The next answer will update the card above.'**
  String get homeContinueResponseHint;

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

  /// No description provided for @captureApprovalDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Review before saving'**
  String get captureApprovalDraftLabel;

  /// No description provided for @captureApprovalReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Save this memory?'**
  String get captureApprovalReviewTitle;

  /// No description provided for @captureApprovalSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get captureApprovalSourceLabel;

  /// No description provided for @captureApprovalMemoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Memory draft'**
  String get captureApprovalMemoryLabel;

  /// No description provided for @captureApprovalSavedAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Will be saved as'**
  String get captureApprovalSavedAsLabel;

  /// No description provided for @captureApprovalEmptySummary.
  ///
  /// In en, this message translates to:
  /// **'No extracted description yet.'**
  String get captureApprovalEmptySummary;

  /// No description provided for @captureApprovalMoreContext.
  ///
  /// In en, this message translates to:
  /// **'Only the source is clear so far. Add a note below if Mira should remember what this means.'**
  String get captureApprovalMoreContext;

  /// No description provided for @captureApprovalSavePrompt.
  ///
  /// In en, this message translates to:
  /// **'Here is exactly what Mira will save. Tell me what to change before I add it to memory.'**
  String get captureApprovalSavePrompt;

  /// No description provided for @captureApprovalSavedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Saved to memory. Keep chatting if something needs changing.'**
  String get captureApprovalSavedPrompt;

  /// No description provided for @captureApprovalCorrectionHint.
  ///
  /// In en, this message translates to:
  /// **'Correct or ask about this'**
  String get captureApprovalCorrectionHint;

  /// No description provided for @captureApprovalSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save memory'**
  String get captureApprovalSaveAction;

  /// No description provided for @captureApprovalDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get captureApprovalDismissAction;

  /// No description provided for @captureApprovalUpdatingStatus.
  ///
  /// In en, this message translates to:
  /// **'Updating the draft...'**
  String get captureApprovalUpdatingStatus;

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

  /// No description provided for @graphEntityPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get graphEntityPerson;

  /// No description provided for @graphEntityOrganization.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get graphEntityOrganization;

  /// No description provided for @graphEntityProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get graphEntityProject;

  /// No description provided for @graphEntityPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get graphEntityPlace;

  /// No description provided for @graphEntityActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get graphEntityActivity;

  /// No description provided for @graphEntityTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get graphEntityTopic;

  /// No description provided for @graphEntityDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get graphEntityDocument;

  /// No description provided for @graphEntityAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get graphEntityAsset;

  /// No description provided for @graphEntityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get graphEntityUnknown;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsRetry;

  /// No description provided for @settingsLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Login again'**
  String get settingsLoginAgain;

  /// No description provided for @settingsSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get settingsSessionExpired;

  /// No description provided for @settingsLoadHttpError.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings (HTTP {code}).'**
  String settingsLoadHttpError(int code);

  /// No description provided for @settingsLoadConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Mira. Check your connection and try again.'**
  String get settingsLoadConnectionError;

  /// No description provided for @settingsLoadGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings. Please try again.'**
  String get settingsLoadGenericError;

  /// No description provided for @connectorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get connectorsTitle;

  /// No description provided for @connectorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bring work, files, messages, reading, and design context into Mira.'**
  String get connectorsSubtitle;

  /// No description provided for @connectorsAvailableMetric.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get connectorsAvailableMetric;

  /// No description provided for @connectorsConnectedMetric.
  ///
  /// In en, this message translates to:
  /// **'connected'**
  String get connectorsConnectedMetric;

  /// No description provided for @connectorsNativeMetric.
  ///
  /// In en, this message translates to:
  /// **'native'**
  String get connectorsNativeMetric;

  /// No description provided for @connectorsNativeGroup.
  ///
  /// In en, this message translates to:
  /// **'Native sync'**
  String get connectorsNativeGroup;

  /// No description provided for @connectorsAdapterGroup.
  ///
  /// In en, this message translates to:
  /// **'Manual import adapters'**
  String get connectorsAdapterGroup;

  /// No description provided for @connectorsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load connectors'**
  String get connectorsLoadFailed;

  /// No description provided for @connectorsPullToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh and try again.'**
  String get connectorsPullToRetry;

  /// No description provided for @connectorsAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get connectorsAllFilter;

  /// No description provided for @connectorsConnectAction.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectorsConnectAction;

  /// No description provided for @connectorsSyncAction.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get connectorsSyncAction;

  /// No description provided for @connectorsHowToUseAction.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get connectorsHowToUseAction;

  /// No description provided for @connectorsConnectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectorsConnectedStatus;

  /// No description provided for @connectorsNativeStatus.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get connectorsNativeStatus;

  /// No description provided for @connectorsAdapterReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Adapter'**
  String get connectorsAdapterReadyStatus;

  /// No description provided for @connectorsManualImportStatus.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get connectorsManualImportStatus;

  /// No description provided for @connectorsDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Ready for Mira plugin sync.'**
  String get connectorsDefaultDescription;

  /// No description provided for @connectorsManualImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import or share content into Mira, then search and ask from Library.'**
  String get connectorsManualImportSubtitle;

  /// No description provided for @connectorsWhatsappSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export a chat or share messages into Mira; direct personal-chat OAuth is not available.'**
  String get connectorsWhatsappSubtitle;

  /// No description provided for @connectorsWhatsappUsageBody.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp does not expose personal chats through a normal OAuth connector. In v1, Mira uses manual import so the chat becomes searchable memory.'**
  String get connectorsWhatsappUsageBody;

  /// No description provided for @connectorsWhatsappStepExport.
  ///
  /// In en, this message translates to:
  /// **'In WhatsApp, open a chat, choose Export chat, and export without media for the fastest import.'**
  String get connectorsWhatsappStepExport;

  /// No description provided for @connectorsWhatsappStepShare.
  ///
  /// In en, this message translates to:
  /// **'Share the exported .txt file to Mira or upload it from Library.'**
  String get connectorsWhatsappStepShare;

  /// No description provided for @connectorsWhatsappStepUse.
  ///
  /// In en, this message translates to:
  /// **'Mira stores the transcript as a Library item, extracts text, and then you can search or ask questions across it.'**
  String get connectorsWhatsappStepUse;

  /// No description provided for @connectorsAdapterUsageBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is adapter-ready. Use manual import/share first; provider OAuth sync can be enabled later from the same manifest.'**
  String connectorsAdapterUsageBody(String name);

  /// No description provided for @connectorsAdapterStepImport.
  ///
  /// In en, this message translates to:
  /// **'Import a file, export, link, or shared text from the provider into Mira.'**
  String get connectorsAdapterStepImport;

  /// No description provided for @connectorsAdapterStepLibrary.
  ///
  /// In en, this message translates to:
  /// **'The imported content appears in Library with source provenance.'**
  String get connectorsAdapterStepLibrary;

  /// No description provided for @connectorsAdapterStepAsk.
  ///
  /// In en, this message translates to:
  /// **'Use Library search, Assistant, Canvas, or Graph to work with the imported context.'**
  String get connectorsAdapterStepAsk;

  /// No description provided for @connectorsAdapterNote.
  ///
  /// In en, this message translates to:
  /// **'Connecting an adapter does not mean Mira can read that app automatically yet; it means the manifest and Mira-side workflow are ready.'**
  String get connectorsAdapterNote;

  /// No description provided for @connectorsSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} synced into your library.'**
  String connectorsSyncSuccess(String name);

  /// No description provided for @connectorsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'{name} could not sync. Try again.'**
  String connectorsSyncFailed(String name);

  /// No description provided for @connectorsLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync {time}'**
  String connectorsLastSync(String time);

  /// No description provided for @canvasTitle.
  ///
  /// In en, this message translates to:
  /// **'Canvas'**
  String get canvasTitle;

  /// No description provided for @canvasDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira canvas'**
  String get canvasDefaultTitle;

  /// No description provided for @canvasStarterSticky.
  ///
  /// In en, this message translates to:
  /// **'Map the main idea'**
  String get canvasStarterSticky;

  /// No description provided for @canvasStarterText.
  ///
  /// In en, this message translates to:
  /// **'Pin notes, files, and links from Library beside your own thoughts.'**
  String get canvasStarterText;

  /// No description provided for @canvasStarterShape.
  ///
  /// In en, this message translates to:
  /// **'Cluster'**
  String get canvasStarterShape;

  /// No description provided for @canvasNewSticky.
  ///
  /// In en, this message translates to:
  /// **'New sticky'**
  String get canvasNewSticky;

  /// No description provided for @canvasNewText.
  ///
  /// In en, this message translates to:
  /// **'Write here'**
  String get canvasNewText;

  /// No description provided for @canvasNewShape.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get canvasNewShape;

  /// No description provided for @canvasLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load canvas'**
  String get canvasLoadFailed;

  /// No description provided for @canvasSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Canvas could not save. Try again.'**
  String get canvasSaveFailed;

  /// No description provided for @canvasLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Library is empty.'**
  String get canvasLibraryEmpty;

  /// No description provided for @canvasRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get canvasRetry;

  /// No description provided for @canvasNewBoard.
  ///
  /// In en, this message translates to:
  /// **'New board'**
  String get canvasNewBoard;

  /// No description provided for @canvasOpenGraph.
  ///
  /// In en, this message translates to:
  /// **'Open graph'**
  String get canvasOpenGraph;

  /// No description provided for @canvasSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get canvasSaving;

  /// No description provided for @canvasUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get canvasUnsaved;

  /// No description provided for @canvasSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get canvasSaved;

  /// No description provided for @canvasToolSticky.
  ///
  /// In en, this message translates to:
  /// **'Sticky'**
  String get canvasToolSticky;

  /// No description provided for @canvasToolText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get canvasToolText;

  /// No description provided for @canvasToolLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get canvasToolLibrary;

  /// No description provided for @canvasToolShape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get canvasToolShape;

  /// No description provided for @canvasToolArrow.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get canvasToolArrow;

  /// No description provided for @canvasToolSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get canvasToolSave;

  /// No description provided for @canvasEditNode.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get canvasEditNode;

  /// No description provided for @canvasNodeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write on the canvas'**
  String get canvasNodeTextHint;

  /// No description provided for @canvasDeleteNode.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get canvasDeleteNode;

  /// No description provided for @canvasApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get canvasApply;

  /// No description provided for @canvasLibraryPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add from Library'**
  String get canvasLibraryPickerTitle;

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

  /// No description provided for @meetingRecorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Record meeting'**
  String get meetingRecorderTitle;

  /// No description provided for @meetingRecorderDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meetingRecorderDefaultTitle;

  /// No description provided for @meetingRecorderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Meeting title'**
  String get meetingRecorderTitleHint;

  /// No description provided for @meetingRecorderStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting recorder...'**
  String get meetingRecorderStarting;

  /// No description provided for @meetingRecorderRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get meetingRecorderRecording;

  /// No description provided for @meetingRecorderReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to save'**
  String get meetingRecorderReady;

  /// No description provided for @meetingRecorderInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped because Mira was interrupted.'**
  String get meetingRecorderInterrupted;

  /// No description provided for @meetingRecorderInterruptedBody.
  ///
  /// In en, this message translates to:
  /// **'The recorded part is still here. Save it, or discard it and start again.'**
  String get meetingRecorderInterruptedBody;

  /// No description provided for @meetingRecorderBody.
  ///
  /// In en, this message translates to:
  /// **'Mira saves this as a Library item, then transcribes it for search, summaries, decisions, and follow-ups.'**
  String get meetingRecorderBody;

  /// No description provided for @meetingRecorderStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get meetingRecorderStop;

  /// No description provided for @meetingRecorderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get meetingRecorderCancel;

  /// No description provided for @meetingRecorderDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get meetingRecorderDiscard;

  /// No description provided for @meetingRecorderSave.
  ///
  /// In en, this message translates to:
  /// **'Save meeting'**
  String get meetingRecorderSave;

  /// No description provided for @meetingRecorderSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving meeting...'**
  String get meetingRecorderSaving;

  /// No description provided for @meetingRecorderSaved.
  ///
  /// In en, this message translates to:
  /// **'Meeting saved to Library.'**
  String get meetingRecorderSaved;

  /// No description provided for @meetingRecorderStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start recording. Check microphone permission.'**
  String get meetingRecorderStartFailed;

  /// No description provided for @meetingRecorderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this recording. Try again.'**
  String get meetingRecorderSaveFailed;

  /// No description provided for @meetingRecorderNoAudio.
  ///
  /// In en, this message translates to:
  /// **'No audio file was created. Paste a transcript or try recording on your phone.'**
  String get meetingRecorderNoAudio;

  /// No description provided for @meetingRecorderPhoneCallNote.
  ///
  /// In en, this message translates to:
  /// **'If a phone call or app switch interrupts recording, Mira keeps the recorded part before the interruption.'**
  String get meetingRecorderPhoneCallNote;

  /// No description provided for @meetingRecorderDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration {duration}'**
  String meetingRecorderDurationLabel(String duration);

  /// No description provided for @libraryMeetingImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get libraryMeetingImportTitle;

  /// No description provided for @libraryMeetingImportBody.
  ///
  /// In en, this message translates to:
  /// **'Record a live meeting or paste the transcript, decisions, and notes into Library.'**
  String get libraryMeetingImportBody;

  /// No description provided for @libraryMeetingPasteAction.
  ///
  /// In en, this message translates to:
  /// **'Paste meeting notes'**
  String get libraryMeetingPasteAction;

  /// No description provided for @rdNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get rdNavHome;

  /// No description provided for @rdNavLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get rdNavLibrary;

  /// No description provided for @rdNavCanvas.
  ///
  /// In en, this message translates to:
  /// **'Canvas'**
  String get rdNavCanvas;

  /// No description provided for @rdNavBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get rdNavBrief;

  /// No description provided for @rdGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get rdGreetingMorning;

  /// No description provided for @rdGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get rdGreetingAfternoon;

  /// No description provided for @rdGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get rdGreetingEvening;

  /// No description provided for @rdHomeMemoryReady.
  ///
  /// In en, this message translates to:
  /// **'Your memory is\nquiet and ready'**
  String get rdHomeMemoryReady;

  /// No description provided for @rdHomeComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Type or say anything…'**
  String get rdHomeComposerHint;

  /// No description provided for @rdWaitingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR THE RIGHT MOMENT'**
  String get rdWaitingSectionTitle;

  /// No description provided for @rdRecentlyCaptured.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY CAPTURED'**
  String get rdRecentlyCaptured;

  /// No description provided for @rdSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get rdSeeAll;

  /// No description provided for @rdRemindersLink.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get rdRemindersLink;

  /// No description provided for @rdSnoozeUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get rdSnoozeUndo;

  /// No description provided for @rdSnoozeInHour.
  ///
  /// In en, this message translates to:
  /// **'In an hour'**
  String get rdSnoozeInHour;

  /// No description provided for @rdSnoozeEvening.
  ///
  /// In en, this message translates to:
  /// **'This evening'**
  String get rdSnoozeEvening;

  /// No description provided for @rdSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get rdSnoozeTomorrow;

  /// No description provided for @rdSnoozeNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get rdSnoozeNextWeek;

  /// No description provided for @rdWhenMomentRight.
  ///
  /// In en, this message translates to:
  /// **'When the moment is right'**
  String get rdWhenMomentRight;

  /// No description provided for @rdWhenNextSee.
  ///
  /// In en, this message translates to:
  /// **'When you next see {person}'**
  String rdWhenNextSee(String person);

  /// No description provided for @rdListenTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening…'**
  String get rdListenTitle;

  /// No description provided for @rdListenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally — Mira is taking notes'**
  String get rdListenSubtitle;

  /// No description provided for @rdListenTapToStop.
  ///
  /// In en, this message translates to:
  /// **'TAP TO STOP'**
  String get rdListenTapToStop;

  /// No description provided for @rdCanvasBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get rdCanvasBoard;

  /// No description provided for @rdCanvasClusters.
  ///
  /// In en, this message translates to:
  /// **'Clusters'**
  String get rdCanvasClusters;

  /// No description provided for @rdCanvasMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get rdCanvasMap;

  /// No description provided for @rdClusterMemories.
  ///
  /// In en, this message translates to:
  /// **'{count} memories'**
  String rdClusterMemories(int count);

  /// No description provided for @rdOnboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Mira.\nYour second mind.'**
  String get rdOnboardingWelcome;

  /// No description provided for @rdOnboardingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get rdOnboardingSignIn;

  /// No description provided for @rdOnboardingContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get rdOnboardingContinueGoogle;

  /// No description provided for @rdOnboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get rdOnboardingSkip;

  /// No description provided for @rdOnboardingLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get rdOnboardingLater;

  /// No description provided for @rdCaptureEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture a memory'**
  String get rdCaptureEntryTitle;

  /// No description provided for @rdCaptureEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mira will understand it — you confirm before it\'s kept'**
  String get rdCaptureEntrySubtitle;

  /// No description provided for @rdCaptureModeVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get rdCaptureModeVoice;

  /// No description provided for @rdCaptureModeVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Just speak'**
  String get rdCaptureModeVoiceHint;

  /// No description provided for @rdCaptureModePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get rdCaptureModePhoto;

  /// No description provided for @rdCaptureModePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Snap a scene'**
  String get rdCaptureModePhotoHint;

  /// No description provided for @rdCaptureModeScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get rdCaptureModeScreenshot;

  /// No description provided for @rdCaptureModeScreenshotHint.
  ///
  /// In en, this message translates to:
  /// **'From your library'**
  String get rdCaptureModeScreenshotHint;

  /// No description provided for @rdCaptureModeLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get rdCaptureModeLink;

  /// No description provided for @rdCaptureModeLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a URL'**
  String get rdCaptureModeLinkHint;

  /// No description provided for @rdCaptureModeType.
  ///
  /// In en, this message translates to:
  /// **'Type it instead'**
  String get rdCaptureModeType;

  /// No description provided for @rdVoiceSearchListening.
  ///
  /// In en, this message translates to:
  /// **'LISTENING'**
  String get rdVoiceSearchListening;

  /// No description provided for @rdVoiceSearchSearching.
  ///
  /// In en, this message translates to:
  /// **'SEARCHING'**
  String get rdVoiceSearchSearching;

  /// No description provided for @rdVoiceSearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Speak your search'**
  String get rdVoiceSearchPrompt;

  /// No description provided for @rdVoiceSearchBusy.
  ///
  /// In en, this message translates to:
  /// **'One moment…'**
  String get rdVoiceSearchBusy;

  /// No description provided for @rdVoiceSearchCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rdVoiceSearchCancel;

  /// No description provided for @rdVoiceSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get rdVoiceSearchAction;

  /// No description provided for @rdListenTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get rdListenTranscribing;

  /// No description provided for @rdMemoryFlagsAllChecked.
  ///
  /// In en, this message translates to:
  /// **'All checked — thanks'**
  String get rdMemoryFlagsAllChecked;

  /// No description provided for @rdMemoryFlagsUnresolved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word Mira wasn\'t sure of} other{{count} words Mira wasn\'t sure of}}'**
  String rdMemoryFlagsUnresolved(int count);

  /// No description provided for @rdMemoryFlagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a flagged word to jump to it, or edit the transcript directly.'**
  String get rdMemoryFlagsHint;

  /// No description provided for @rdCanvasSuggestConnect.
  ///
  /// In en, this message translates to:
  /// **'These two look related — connect them?'**
  String get rdCanvasSuggestConnect;

  /// No description provided for @rdCanvasSuggestAction.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get rdCanvasSuggestAction;

  /// No description provided for @rdPaywallComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Plus is coming soon — we\'ll let you know.'**
  String get rdPaywallComingSoon;

  /// No description provided for @rdPaywallWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mira Plus ✨'**
  String get rdPaywallWelcome;

  /// No description provided for @rdPaywallCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your Plus membership was cancelled.'**
  String get rdPaywallCancelled;

  /// No description provided for @rdPaywallBadge.
  ///
  /// In en, this message translates to:
  /// **'Mira Plus'**
  String get rdPaywallBadge;

  /// No description provided for @rdPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Give your memory\nroom to grow'**
  String get rdPaywallTitle;

  /// No description provided for @rdPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you capture, held for as long as you need — woven into one calm, connected memory.'**
  String get rdPaywallSubtitle;

  /// No description provided for @rdPaywallPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Plus changes what Mira remembers — never who can see it. Your memory stays private, always.'**
  String get rdPaywallPrivacyNote;

  /// No description provided for @rdPaywallFeatUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited memories'**
  String get rdPaywallFeatUnlimitedTitle;

  /// No description provided for @rdPaywallFeatUnlimitedSub.
  ///
  /// In en, this message translates to:
  /// **'Never hit a cap — Free holds 2,000.'**
  String get rdPaywallFeatUnlimitedSub;

  /// No description provided for @rdPaywallFeatGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'The full memory graph'**
  String get rdPaywallFeatGraphTitle;

  /// No description provided for @rdPaywallFeatGraphSub.
  ///
  /// In en, this message translates to:
  /// **'See every connection, not just recent ones.'**
  String get rdPaywallFeatGraphSub;

  /// No description provided for @rdPaywallFeatVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Longer history & voice'**
  String get rdPaywallFeatVoiceTitle;

  /// No description provided for @rdPaywallFeatVoiceSub.
  ///
  /// In en, this message translates to:
  /// **'Keep years of memories and 10-min captures.'**
  String get rdPaywallFeatVoiceSub;

  /// No description provided for @rdPaywallFeatConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect everything'**
  String get rdPaywallFeatConnectTitle;

  /// No description provided for @rdPaywallFeatConnectSub.
  ///
  /// In en, this message translates to:
  /// **'All your apps — Free links two.'**
  String get rdPaywallFeatConnectSub;

  /// No description provided for @rdPaywallFeatBriefTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief & smart reminders'**
  String get rdPaywallFeatBriefTitle;

  /// No description provided for @rdPaywallFeatBriefSub.
  ///
  /// In en, this message translates to:
  /// **'Mira resurfaces things at the right moment.'**
  String get rdPaywallFeatBriefSub;

  /// No description provided for @rdPaywallPlanAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get rdPaywallPlanAnnual;

  /// No description provided for @rdPaywallPlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rdPaywallPlanMonthly;

  /// No description provided for @rdPaywallPlanMonthlyNote.
  ///
  /// In en, this message translates to:
  /// **'billed monthly'**
  String get rdPaywallPlanMonthlyNote;

  /// No description provided for @rdPaywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Try Plus free for 14 days'**
  String get rdPaywallCtaTrial;

  /// No description provided for @rdPaywallThenAnnual.
  ///
  /// In en, this message translates to:
  /// **'Then \$72/year'**
  String get rdPaywallThenAnnual;

  /// No description provided for @rdPaywallThenMonthly.
  ///
  /// In en, this message translates to:
  /// **'Then \$8/month'**
  String get rdPaywallThenMonthly;

  /// No description provided for @rdPaywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get rdPaywallRestore;

  /// No description provided for @rdPaywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get rdPaywallTerms;

  /// No description provided for @rdPaywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get rdPaywallPrivacy;

  /// No description provided for @rdPaywallTermsToast.
  ///
  /// In en, this message translates to:
  /// **'Terms open in your browser.'**
  String get rdPaywallTermsToast;

  /// No description provided for @rdPaywallPrivacyToast.
  ///
  /// In en, this message translates to:
  /// **'Privacy opens in your browser.'**
  String get rdPaywallPrivacyToast;

  /// No description provided for @rdPaywallActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Mira Plus · Active'**
  String get rdPaywallActiveBadge;

  /// No description provided for @rdPaywallActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'You have room\nto remember'**
  String get rdPaywallActiveTitle;

  /// No description provided for @rdPaywallActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for being on Plus. Everything you capture is held in full — no caps, no forgetting.'**
  String get rdPaywallActiveSubtitle;

  /// No description provided for @rdPaywallManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get rdPaywallManage;

  /// No description provided for @rdPaywallCancelNote.
  ///
  /// In en, this message translates to:
  /// **'If you ever cancel, nothing is deleted — your memories stay, and captures pause at the Free limit.'**
  String get rdPaywallCancelNote;

  /// No description provided for @rdPaywallCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel Plus'**
  String get rdPaywallCancelCta;

  /// No description provided for @rdPaywallDemoFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get rdPaywallDemoFree;

  /// No description provided for @rdPaywallDemoPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus member'**
  String get rdPaywallDemoPlus;

  /// No description provided for @rdCaptureListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get rdCaptureListening;

  /// No description provided for @rdCaptureEntryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get rdCaptureEntryType;

  /// No description provided for @rdCaptureEntryLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get rdCaptureEntryLink;

  /// No description provided for @rdCaptureEntryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get rdCaptureEntryPhoto;

  /// No description provided for @rdCaptureTapWhenFinished.
  ///
  /// In en, this message translates to:
  /// **'Tap ✓ when you\'re finished'**
  String get rdCaptureTapWhenFinished;

  /// No description provided for @rdCaptureUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding'**
  String get rdCaptureUnderstanding;

  /// No description provided for @rdCaptureStepTranscribe.
  ///
  /// In en, this message translates to:
  /// **'Transcribing what you said'**
  String get rdCaptureStepTranscribe;

  /// No description provided for @rdCaptureStepRecognise.
  ///
  /// In en, this message translates to:
  /// **'Recognising type & details'**
  String get rdCaptureStepRecognise;

  /// No description provided for @rdCaptureStepConnections.
  ///
  /// In en, this message translates to:
  /// **'Finding connections in memory'**
  String get rdCaptureStepConnections;

  /// No description provided for @rdCaptureSavedLink.
  ///
  /// In en, this message translates to:
  /// **'Saved link'**
  String get rdCaptureSavedLink;

  /// No description provided for @rdCaptureKeptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Mira kept your photo and will read the details from it when they\'re needed.'**
  String get rdCaptureKeptPhoto;

  /// No description provided for @rdCaptureKeptScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Mira kept your screenshot and will read the details from it when they\'re needed.'**
  String get rdCaptureKeptScreenshot;

  /// No description provided for @rdCaptureYourNote.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get rdCaptureYourNote;

  /// No description provided for @rdCaptureConnectMemory.
  ///
  /// In en, this message translates to:
  /// **'Connect to existing memory'**
  String get rdCaptureConnectMemory;

  /// No description provided for @rdCaptureRelatedMemory.
  ///
  /// In en, this message translates to:
  /// **'Related memory'**
  String get rdCaptureRelatedMemory;

  /// No description provided for @rdCaptureSuggestedActions.
  ///
  /// In en, this message translates to:
  /// **'Suggested actions'**
  String get rdCaptureSuggestedActions;

  /// No description provided for @rdCaptureRemindWeekend.
  ///
  /// In en, this message translates to:
  /// **'Read it later — remind me this weekend'**
  String get rdCaptureRemindWeekend;

  /// No description provided for @rdCaptureRemindLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me about this later'**
  String get rdCaptureRemindLater;

  /// No description provided for @rdCaptureRemindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me before {deadline}'**
  String rdCaptureRemindBefore(String deadline);

  /// No description provided for @rdCaptureActionAddTopic.
  ///
  /// In en, this message translates to:
  /// **'Add to a topic'**
  String get rdCaptureActionAddTopic;

  /// No description provided for @rdCaptureActionAddTopicSub.
  ///
  /// In en, this message translates to:
  /// **'Group with related memories'**
  String get rdCaptureActionAddTopicSub;

  /// No description provided for @rdCaptureActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share it'**
  String get rdCaptureActionShare;

  /// No description provided for @rdCaptureActionShareSub.
  ///
  /// In en, this message translates to:
  /// **'Send to someone who\'d care'**
  String get rdCaptureActionShareSub;

  /// No description provided for @rdCaptureActionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get rdCaptureActionCalendar;

  /// No description provided for @rdCaptureActionCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'From the details Mira read'**
  String get rdCaptureActionCalendarSub;

  /// No description provided for @rdCaptureActionAddPeople.
  ///
  /// In en, this message translates to:
  /// **'Add the people in it'**
  String get rdCaptureActionAddPeople;

  /// No description provided for @rdCaptureActionAddPeopleSub.
  ///
  /// In en, this message translates to:
  /// **'Link the faces Mira sees'**
  String get rdCaptureActionAddPeopleSub;

  /// No description provided for @rdCaptureChangeType.
  ///
  /// In en, this message translates to:
  /// **'Change type'**
  String get rdCaptureChangeType;

  /// No description provided for @rdCaptureFilePrompt.
  ///
  /// In en, this message translates to:
  /// **'How should Mira file this memory?'**
  String get rdCaptureFilePrompt;

  /// No description provided for @rdCaptureAddDetail.
  ///
  /// In en, this message translates to:
  /// **'Add a detail'**
  String get rdCaptureAddDetail;

  /// No description provided for @rdCaptureAddDetailHint.
  ///
  /// In en, this message translates to:
  /// **'# tag or detail'**
  String get rdCaptureAddDetailHint;

  /// No description provided for @rdCaptureReadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Mira read your photo'**
  String get rdCaptureReadPhoto;

  /// No description provided for @rdCaptureReadScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Mira read your screenshot'**
  String get rdCaptureReadScreenshot;

  /// No description provided for @rdCaptureReadPage.
  ///
  /// In en, this message translates to:
  /// **'Mira read the page'**
  String get rdCaptureReadPage;

  /// No description provided for @rdCaptureLinkCrawlReady.
  ///
  /// In en, this message translates to:
  /// **'Page content read with {provider}.'**
  String rdCaptureLinkCrawlReady(String provider);

  /// No description provided for @rdCaptureLinkMetadataOnly.
  ///
  /// In en, this message translates to:
  /// **'The URL is available, but this page did not expose readable content. Mira will keep it honestly as a link.'**
  String get rdCaptureLinkMetadataOnly;

  /// No description provided for @rdCaptureLinkFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira couldn\'t read this link'**
  String get rdCaptureLinkFailedTitle;

  /// No description provided for @rdCaptureLinkFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The page may be private, temporarily unavailable, or blocking readers. Nothing has been added to memory yet.'**
  String get rdCaptureLinkFailedBody;

  /// No description provided for @rdCaptureLinkRetry.
  ///
  /// In en, this message translates to:
  /// **'Try reading again'**
  String get rdCaptureLinkRetry;

  /// No description provided for @rdCaptureLinkReadAction.
  ///
  /// In en, this message translates to:
  /// **'Read this link'**
  String get rdCaptureLinkReadAction;

  /// No description provided for @rdCaptureLinkSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The link is still in review and was not added. Please try again.'**
  String get rdCaptureLinkSaveFailed;

  /// No description provided for @rdCaptureUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Mira understood this'**
  String get rdCaptureUnderstood;

  /// No description provided for @rdCaptureReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get rdCaptureReview;

  /// No description provided for @rdCaptureCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rdCaptureCancel;

  /// No description provided for @rdCaptureDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get rdCaptureDiscard;

  /// No description provided for @rdCaptureDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rdCaptureDone;

  /// No description provided for @rdCaptureKeptTitle.
  ///
  /// In en, this message translates to:
  /// **'Kept in memory'**
  String get rdCaptureKeptTitle;

  /// No description provided for @rdCaptureKeptSafe.
  ///
  /// In en, this message translates to:
  /// **'Kept safely. Mira will bring it back at the right time.'**
  String get rdCaptureKeptSafe;

  /// No description provided for @rdCaptureKeptJoined.
  ///
  /// In en, this message translates to:
  /// **'It\'s {details}. Mira will bring it back at the right time.'**
  String rdCaptureKeptJoined(String details);

  /// No description provided for @rdCaptureAddToMemory.
  ///
  /// In en, this message translates to:
  /// **'Add to memory'**
  String get rdCaptureAddToMemory;

  /// No description provided for @rdCaptureAddLinking.
  ///
  /// In en, this message translates to:
  /// **'Add · linking {count}'**
  String rdCaptureAddLinking(int count);

  /// No description provided for @rdCaptureDetailsExtracted.
  ///
  /// In en, this message translates to:
  /// **'Details Mira extracted'**
  String get rdCaptureDetailsExtracted;

  /// No description provided for @rdCaptureTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get rdCaptureTypeNote;

  /// No description provided for @rdCaptureTypeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get rdCaptureTypeTask;

  /// No description provided for @rdCaptureTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get rdCaptureTypeEvent;

  /// No description provided for @rdCaptureTypePerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get rdCaptureTypePerson;

  /// No description provided for @rdCaptureTypePlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get rdCaptureTypePlace;

  /// No description provided for @rdCaptureTypeLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get rdCaptureTypeLink;

  /// No description provided for @rdCaptureTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get rdCaptureTypeArticle;

  /// No description provided for @rdCaptureTypeIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get rdCaptureTypeIdea;

  /// No description provided for @rdCaptureTypeTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get rdCaptureTypeTravel;

  /// No description provided for @rdCaptureTypeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Type a note'**
  String get rdCaptureTypeSheetTitle;

  /// No description provided for @rdCaptureTypeSheetHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to remember?'**
  String get rdCaptureTypeSheetHint;

  /// No description provided for @rdCaptureLinkSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get rdCaptureLinkSheetTitle;

  /// No description provided for @rdCaptureLinkTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get rdCaptureLinkTitleOptional;

  /// No description provided for @rdCaptureUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://…'**
  String get rdCaptureUrlHint;

  /// No description provided for @rdCaptureLinkBadge.
  ///
  /// In en, this message translates to:
  /// **'Link · {host}'**
  String rdCaptureLinkBadge(String host);

  /// No description provided for @rdCaptureLinkedMemories.
  ///
  /// In en, this message translates to:
  /// **'linked to {count, plural, =1{1 memory} other{{count} memories}}'**
  String rdCaptureLinkedMemories(int count);

  /// No description provided for @rdCaptureHasReminder.
  ///
  /// In en, this message translates to:
  /// **'has a reminder'**
  String get rdCaptureHasReminder;

  /// No description provided for @rdCapturePhotoFrameHint.
  ///
  /// In en, this message translates to:
  /// **'Frame a poster, page, or place'**
  String get rdCapturePhotoFrameHint;

  /// No description provided for @rdCapturePhotoReading.
  ///
  /// In en, this message translates to:
  /// **'Reading this photo…'**
  String get rdCapturePhotoReading;

  /// No description provided for @rdCaptureScreenshotReading.
  ///
  /// In en, this message translates to:
  /// **'Reading screenshot…'**
  String get rdCaptureScreenshotReading;

  /// No description provided for @rdCaptureScreenshotPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a screenshot'**
  String get rdCaptureScreenshotPickTitle;

  /// No description provided for @rdCaptureScreenshotPickSub.
  ///
  /// In en, this message translates to:
  /// **'Mira reads text and details from your image'**
  String get rdCaptureScreenshotPickSub;

  /// No description provided for @rdCaptureScreenshotUse.
  ///
  /// In en, this message translates to:
  /// **'Use screenshot'**
  String get rdCaptureScreenshotUse;

  /// No description provided for @rdCaptureLinkSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a link'**
  String get rdCaptureLinkSaveTitle;

  /// No description provided for @rdCaptureLinkSaveSub.
  ///
  /// In en, this message translates to:
  /// **'Paste a URL — Mira reads the page for you'**
  String get rdCaptureLinkSaveSub;

  /// No description provided for @rdCaptureLinkReading.
  ///
  /// In en, this message translates to:
  /// **'Reading page…'**
  String get rdCaptureLinkReading;

  /// No description provided for @rdCaptureLinkArticleDefault.
  ///
  /// In en, this message translates to:
  /// **'Article from link'**
  String get rdCaptureLinkArticleDefault;

  /// No description provided for @rdCaptureLinkArticleSub.
  ///
  /// In en, this message translates to:
  /// **'Mira will extract the readable text and keep it searchable.'**
  String get rdCaptureLinkArticleSub;

  /// No description provided for @rdCaptureContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get rdCaptureContinue;

  /// No description provided for @rdBriefTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief'**
  String get rdBriefTitle;

  /// No description provided for @rdBriefGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get rdBriefGreetingMorning;

  /// No description provided for @rdBriefGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get rdBriefGreetingAfternoon;

  /// No description provided for @rdBriefGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get rdBriefGreetingEvening;

  /// No description provided for @rdBriefGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String rdBriefGreeting(String greeting, String name);

  /// No description provided for @rdBriefDayEnd.
  ///
  /// In en, this message translates to:
  /// **'That\'s your day.\nEverything else is safe in memory.'**
  String get rdBriefDayEnd;

  /// No description provided for @rdBriefNothingNow.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs you right now.'**
  String get rdBriefNothingNow;

  /// No description provided for @rdBriefSnoozedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until tomorrow'**
  String get rdBriefSnoozedTomorrow;

  /// No description provided for @rdBriefDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rdBriefDone;

  /// No description provided for @rdBriefClearedLater.
  ///
  /// In en, this message translates to:
  /// **'Cleared — Mira will ask again later'**
  String get rdBriefClearedLater;

  /// No description provided for @rdBriefUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get rdBriefUndo;

  /// No description provided for @rdBriefClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get rdBriefClearAll;

  /// No description provided for @rdBriefSeeAllReminders.
  ///
  /// In en, this message translates to:
  /// **'See all reminders'**
  String get rdBriefSeeAllReminders;

  /// No description provided for @rdBriefSectionWaitingMoment.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR THE RIGHT MOMENT'**
  String get rdBriefSectionWaitingMoment;

  /// No description provided for @rdBriefSectionNeedsYou.
  ///
  /// In en, this message translates to:
  /// **'NEEDS YOU'**
  String get rdBriefSectionNeedsYou;

  /// No description provided for @rdBriefSectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get rdBriefSectionToday;

  /// No description provided for @rdBriefSectionHandled.
  ///
  /// In en, this message translates to:
  /// **'HANDLED QUIETLY'**
  String get rdBriefSectionHandled;

  /// No description provided for @rdBriefSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get rdBriefSectionRecent;

  /// No description provided for @rdBriefSectionResurfaced.
  ///
  /// In en, this message translates to:
  /// **'MIRA RESURFACED'**
  String get rdBriefSectionResurfaced;

  /// No description provided for @rdBriefSectionWaitingOnYou.
  ///
  /// In en, this message translates to:
  /// **'WAITING ON YOU'**
  String get rdBriefSectionWaitingOnYou;

  /// No description provided for @rdBriefTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String rdBriefTaskCount(int count);

  /// No description provided for @rdBriefReminderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reminder} other{{count} reminders}}'**
  String rdBriefReminderCount(int count);

  /// No description provided for @rdBriefEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String rdBriefEventsCount(int count);

  /// No description provided for @rdBriefFallbackMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get rdBriefFallbackMemory;

  /// No description provided for @rdBriefFallbackRecentMemory.
  ///
  /// In en, this message translates to:
  /// **'Recent memory'**
  String get rdBriefFallbackRecentMemory;

  /// No description provided for @rdBriefFallbackReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get rdBriefFallbackReminder;

  /// No description provided for @rdBriefFallbackAReminder.
  ///
  /// In en, this message translates to:
  /// **'A reminder'**
  String get rdBriefFallbackAReminder;

  /// No description provided for @rdBriefFallbackTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get rdBriefFallbackTask;

  /// No description provided for @rdBriefFallbackEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get rdBriefFallbackEvent;

  /// No description provided for @rdBriefFallbackUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled memory'**
  String get rdBriefFallbackUntitled;

  /// No description provided for @rdBriefFallbackAMemory.
  ///
  /// In en, this message translates to:
  /// **'A memory'**
  String get rdBriefFallbackAMemory;

  /// No description provided for @rdBriefOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get rdBriefOverdue;

  /// No description provided for @rdBriefOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get rdBriefOpen;

  /// No description provided for @rdBriefDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {when}'**
  String rdBriefDueOn(String when);

  /// No description provided for @rdBriefDueEarlierToday.
  ///
  /// In en, this message translates to:
  /// **'Due earlier today'**
  String get rdBriefDueEarlierToday;

  /// No description provided for @rdBriefDueYesterday.
  ///
  /// In en, this message translates to:
  /// **'Due yesterday'**
  String get rdBriefDueYesterday;

  /// No description provided for @rdBriefDueDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Due {days} days ago'**
  String rdBriefDueDaysAgo(int days);

  /// No description provided for @rdBriefToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rdBriefToday;

  /// No description provided for @rdBriefYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rdBriefYesterday;

  /// No description provided for @rdBriefTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get rdBriefTomorrow;

  /// No description provided for @rdBriefHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String rdBriefHoursAgo(int hours);

  /// No description provided for @rdBriefDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String rdBriefDaysAgo(int days);

  /// No description provided for @rdBriefBroughtBack.
  ///
  /// In en, this message translates to:
  /// **'Brought back for you'**
  String get rdBriefBroughtBack;

  /// No description provided for @rdBriefSavedToMemory.
  ///
  /// In en, this message translates to:
  /// **'Saved to your memory'**
  String get rdBriefSavedToMemory;

  /// No description provided for @rdBriefOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get rdBriefOpenAction;

  /// No description provided for @rdBriefRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get rdBriefRemindMe;

  /// No description provided for @rdBriefReminderSetThursday.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for Thursday'**
  String get rdBriefReminderSetThursday;

  /// No description provided for @rdBriefMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get rdBriefMarkedDone;

  /// No description provided for @rdBriefDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get rdBriefDismissed;

  /// No description provided for @rdBriefUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get rdBriefUpdated;

  /// No description provided for @rdBriefWelcomeBadge.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO MIRA'**
  String get rdBriefWelcomeBadge;

  /// No description provided for @rdBriefFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Brief fills in\nas you capture'**
  String get rdBriefFirstTitle;

  /// No description provided for @rdBriefFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a thought, task, or link — Mira will surface what matters here each morning.'**
  String get rdBriefFirstSubtitle;

  /// No description provided for @rdBriefFirstStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Speak or type anything'**
  String get rdBriefFirstStep1Title;

  /// No description provided for @rdBriefFirstStep1Sub.
  ///
  /// In en, this message translates to:
  /// **'Mira understands before it\'s kept'**
  String get rdBriefFirstStep1Sub;

  /// No description provided for @rdBriefFirstStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Confirm what matters'**
  String get rdBriefFirstStep2Title;

  /// No description provided for @rdBriefFirstStep2Sub.
  ///
  /// In en, this message translates to:
  /// **'You stay in control of memory'**
  String get rdBriefFirstStep2Sub;

  /// No description provided for @rdBriefFirstStep3Title.
  ///
  /// In en, this message translates to:
  /// **'See it here tomorrow'**
  String get rdBriefFirstStep3Title;

  /// No description provided for @rdBriefFirstStep3Sub.
  ///
  /// In en, this message translates to:
  /// **'Tasks, reminders, and resurfaced memories'**
  String get rdBriefFirstStep3Sub;

  /// No description provided for @rdBriefOverdueSummary.
  ///
  /// In en, this message translates to:
  /// **'A few things slipped past while you were busy. Nothing\'s lost — I held onto them. Let\'s clear them together, no rush.'**
  String get rdBriefOverdueSummary;

  /// No description provided for @rdBriefSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get rdBriefSnooze;

  /// No description provided for @rdBriefDoItNow.
  ///
  /// In en, this message translates to:
  /// **'Do it now'**
  String get rdBriefDoItNow;

  /// No description provided for @rdBriefEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs you today'**
  String get rdBriefEmptyTitle;

  /// No description provided for @rdBriefEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your day is open and no memory is waiting on you. I\'ll keep everything safe and speak up the moment something matters.'**
  String get rdBriefEmptyBody;

  /// No description provided for @rdBriefMemoriesHeldSafe.
  ///
  /// In en, this message translates to:
  /// **'memories held safe'**
  String get rdBriefMemoriesHeldSafe;

  /// No description provided for @rdBriefRemindersDue.
  ///
  /// In en, this message translates to:
  /// **'reminders due'**
  String get rdBriefRemindersDue;

  /// No description provided for @rdBriefCaptureThought.
  ///
  /// In en, this message translates to:
  /// **'Capture a thought'**
  String get rdBriefCaptureThought;

  /// No description provided for @rdBriefCaptureSub.
  ///
  /// In en, this message translates to:
  /// **'Drop anything on your mind — I\'ll hold it for you.'**
  String get rdBriefCaptureSub;

  /// No description provided for @rdOnboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'A second mind. For when you don\'t want to forget anything.'**
  String get rdOnboardingTagline;

  /// No description provided for @rdOnboardingSeeHow.
  ///
  /// In en, this message translates to:
  /// **'See how it works'**
  String get rdOnboardingSeeHow;

  /// No description provided for @rdOnboardingAuthInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get rdOnboardingAuthInvalidEmail;

  /// No description provided for @rdOnboardingAuthCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send a code. Try again.'**
  String get rdOnboardingAuthCodeFailed;

  /// No description provided for @rdOnboardingGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get rdOnboardingGoogleFailed;

  /// No description provided for @rdOnboardingAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Login or sign up'**
  String get rdOnboardingAuthTitle;

  /// No description provided for @rdOnboardingEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get rdOnboardingEmailHint;

  /// No description provided for @rdOnboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get rdOnboardingContinue;

  /// No description provided for @rdOnboardingApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get rdOnboardingApple;

  /// No description provided for @rdOnboardingAppleSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is coming soon.'**
  String get rdOnboardingAppleSoon;

  /// No description provided for @rdOnboardingLegal.
  ///
  /// In en, this message translates to:
  /// **'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.'**
  String get rdOnboardingLegal;

  /// No description provided for @rdOnboardingInviteRequired.
  ///
  /// In en, this message translates to:
  /// **'You need an invite code to join Mira.'**
  String get rdOnboardingInviteRequired;

  /// No description provided for @rdOnboardingInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your invite code'**
  String get rdOnboardingInviteHint;

  /// No description provided for @rdOnboardingInviteEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your invite code.'**
  String get rdOnboardingInviteEmpty;

  /// No description provided for @rdOnboardingInviteInvalid.
  ///
  /// In en, this message translates to:
  /// **'That invite code was not accepted.'**
  String get rdOnboardingInviteInvalid;

  /// No description provided for @rdOnboardingInviteVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the code. Try again.'**
  String get rdOnboardingInviteVerifyFailed;

  /// No description provided for @rdOnboardingOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we emailed you.'**
  String get rdOnboardingOtpRequired;

  /// No description provided for @rdOnboardingOtpMismatch.
  ///
  /// In en, this message translates to:
  /// **'That code did not match. Try again.'**
  String get rdOnboardingOtpMismatch;

  /// No description provided for @rdOnboardingOtpResent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code.'**
  String get rdOnboardingOtpResent;

  /// No description provided for @rdOnboardingOtpResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not resend the code.'**
  String get rdOnboardingOtpResendFailed;

  /// No description provided for @rdOnboardingCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get rdOnboardingCheckEmail;

  /// No description provided for @rdOnboardingOtpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a 6-digit code'**
  String get rdOnboardingOtpSent;

  /// No description provided for @rdOnboardingOtpResendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code? '**
  String get rdOnboardingOtpResendPrompt;

  /// No description provided for @rdOnboardingResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get rdOnboardingResend;

  /// No description provided for @rdOnboardingEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get rdOnboardingEnter;

  /// No description provided for @rdOnboardingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get rdOnboardingDetailsTitle;

  /// No description provided for @rdOnboardingDetailsDesc.
  ///
  /// In en, this message translates to:
  /// **'This is how Mira will greet you. You can change it later in Settings.'**
  String get rdOnboardingDetailsDesc;

  /// No description provided for @rdOnboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get rdOnboardingNameHint;

  /// No description provided for @rdOnboardingRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want Mira to remember?'**
  String get rdOnboardingRememberTitle;

  /// No description provided for @rdOnboardingRememberSub.
  ///
  /// In en, this message translates to:
  /// **'Anything you don\'t want to forget. An idea. A task. A link. Even a feeling.'**
  String get rdOnboardingRememberSub;

  /// No description provided for @rdOnboardingRememberHint.
  ///
  /// In en, this message translates to:
  /// **'Press the button and speak or type'**
  String get rdOnboardingRememberHint;

  /// No description provided for @rdOnboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get rdOnboardingNext;

  /// No description provided for @rdOnboardingUnderstoodBrand.
  ///
  /// In en, this message translates to:
  /// **'MIRA understands you'**
  String get rdOnboardingUnderstoodBrand;

  /// No description provided for @rdCommonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get rdCommonUndo;

  /// No description provided for @rdCommonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rdCommonCancel;

  /// No description provided for @rdCommonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get rdCommonSave;

  /// No description provided for @rdCommonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rdCommonDone;

  /// No description provided for @rdCommonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get rdCommonView;

  /// No description provided for @rdCommonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get rdCommonClear;

  /// No description provided for @rdCommonAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get rdCommonAccount;

  /// No description provided for @rdCommonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get rdCommonComingSoon;

  /// No description provided for @rdCommonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get rdCommonSettings;

  /// No description provided for @rdCommonConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get rdCommonConnect;

  /// No description provided for @rdCommonConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get rdCommonConnected;

  /// No description provided for @rdCommonManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get rdCommonManage;

  /// No description provided for @rdCommonUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get rdCommonUpgrade;

  /// No description provided for @rdCommonAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get rdCommonAm;

  /// No description provided for @rdCommonPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get rdCommonPm;

  /// No description provided for @rdRootTitleMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get rdRootTitleMemory;

  /// No description provided for @rdRootTitleCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get rdRootTitleCapture;

  /// No description provided for @rdRootTitleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rdRootTitleNotifications;

  /// No description provided for @rdRootTitleConnectedApps.
  ///
  /// In en, this message translates to:
  /// **'Connected apps'**
  String get rdRootTitleConnectedApps;

  /// No description provided for @rdRootTitleListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get rdRootTitleListening;

  /// No description provided for @rdRootTitleChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get rdRootTitleChat;

  /// No description provided for @rdRootTitleSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get rdRootTitleSetup;

  /// No description provided for @rdAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your memory'**
  String get rdAskTitle;

  /// No description provided for @rdAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask across everything…'**
  String get rdAskHint;

  /// No description provided for @rdAskSectionTry.
  ///
  /// In en, this message translates to:
  /// **'Try asking'**
  String get rdAskSectionTry;

  /// No description provided for @rdAskSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get rdAskSectionRecent;

  /// No description provided for @rdAskSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching your memory…'**
  String get rdAskSearching;

  /// No description provided for @rdAskSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Ask something else'**
  String get rdAskSomethingElse;

  /// No description provided for @rdAskErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t reach your memory just now. Check your connection and try again.'**
  String get rdAskErrorConnection;

  /// No description provided for @rdAskSuggestionRecent.
  ///
  /// In en, this message translates to:
  /// **'What did I save recently?'**
  String get rdAskSuggestionRecent;

  /// No description provided for @rdAskSuggestionFollowUp.
  ///
  /// In en, this message translates to:
  /// **'What should I follow up on?'**
  String get rdAskSuggestionFollowUp;

  /// No description provided for @rdAskSuggestionSummariseWeek.
  ///
  /// In en, this message translates to:
  /// **'Summarise this week'**
  String get rdAskSuggestionSummariseWeek;

  /// No description provided for @rdAskSuggestionFindByTopic.
  ///
  /// In en, this message translates to:
  /// **'Find a note by topic'**
  String get rdAskSuggestionFindByTopic;

  /// No description provided for @rdAskDrawnFrom.
  ///
  /// In en, this message translates to:
  /// **'Drawn from {count, plural, =1{1 memory} other{{count} memories}}'**
  String rdAskDrawnFrom(int count);

  /// No description provided for @rdCollectionAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get rdCollectionAddTitle;

  /// No description provided for @rdCollectionNew.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get rdCollectionNew;

  /// No description provided for @rdCollectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get rdCollectionNameHint;

  /// No description provided for @rdLibraryYourMemory.
  ///
  /// In en, this message translates to:
  /// **'YOUR MEMORY'**
  String get rdLibraryYourMemory;

  /// No description provided for @rdLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get rdLibraryTitle;

  /// No description provided for @rdLibraryKeptCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 memory, all held safe} other{{count} memories, all held safe}}'**
  String rdLibraryKeptCount(int count);

  /// No description provided for @rdLibrarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your memory…'**
  String get rdLibrarySearchHint;

  /// No description provided for @rdLibraryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rdLibraryFilterAll;

  /// No description provided for @rdLibraryFilterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rdLibraryFilterNotes;

  /// No description provided for @rdLibraryFilterVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get rdLibraryFilterVoice;

  /// No description provided for @rdLibraryFilterPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get rdLibraryFilterPhotos;

  /// No description provided for @rdLibraryFilterLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get rdLibraryFilterLinks;

  /// No description provided for @rdLibraryFilterEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get rdLibraryFilterEvents;

  /// No description provided for @rdLibraryNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get rdLibraryNoMatches;

  /// No description provided for @rdLibrarySearchFor.
  ///
  /// In en, this message translates to:
  /// **' for \"{query}\"'**
  String rdLibrarySearchFor(String query);

  /// No description provided for @rdLibrarySearchIn.
  ///
  /// In en, this message translates to:
  /// **' in {name}'**
  String rdLibrarySearchIn(String name);

  /// No description provided for @rdLibraryMemoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 memory} other{{count} memories}}'**
  String rdLibraryMemoryCount(int count);

  /// No description provided for @rdLibraryGroupedForYou.
  ///
  /// In en, this message translates to:
  /// **'MIRA GROUPED FOR YOU'**
  String get rdLibraryGroupedForYou;

  /// No description provided for @rdLibraryNoCollectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet.'**
  String get rdLibraryNoCollectionsYet;

  /// No description provided for @rdLibraryCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get rdLibraryCollections;

  /// No description provided for @rdLibraryArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get rdLibraryArchivedTitle;

  /// No description provided for @rdLibraryOutOfTheWay.
  ///
  /// In en, this message translates to:
  /// **'Out of the way'**
  String get rdLibraryOutOfTheWay;

  /// No description provided for @rdLibraryArchivedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived.\nArchived memories rest here, out of the way.'**
  String get rdLibraryArchivedEmpty;

  /// No description provided for @rdLibraryRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get rdLibraryRestore;

  /// No description provided for @rdLibraryDayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rdLibraryDayToday;

  /// No description provided for @rdLibraryDayThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rdLibraryDayThisWeek;

  /// No description provided for @rdLibraryDayEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get rdLibraryDayEarlier;

  /// No description provided for @rdLibraryEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing here under this filter.\nEverything you capture will settle in quietly.'**
  String get rdLibraryEmptyFilter;

  /// No description provided for @rdLibraryEndMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You\'ve kept 1 memory.\nMira holds them so you don\'t have to.} other{You\'ve kept {count} memories.\nMira holds them so you don\'t have to.}}'**
  String rdLibraryEndMessage(int count);

  /// No description provided for @rdLibrarySelectMemories.
  ///
  /// In en, this message translates to:
  /// **'Select memories'**
  String get rdLibrarySelectMemories;

  /// No description provided for @rdLibrarySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String rdLibrarySelectedCount(int count);

  /// No description provided for @rdLibrarySelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get rdLibrarySelectAll;

  /// No description provided for @rdLibraryDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get rdLibraryDeselectAll;

  /// No description provided for @rdLibraryActionCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get rdLibraryActionCollection;

  /// No description provided for @rdLibraryActionBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get rdLibraryActionBoard;

  /// No description provided for @rdLibraryActionPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get rdLibraryActionPin;

  /// No description provided for @rdLibraryActionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get rdLibraryActionArchive;

  /// No description provided for @rdLibraryActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get rdLibraryActionDelete;

  /// No description provided for @rdLibraryUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get rdLibraryUntitled;

  /// No description provided for @rdLibraryTypeVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get rdLibraryTypeVoice;

  /// No description provided for @rdLibraryTypeLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get rdLibraryTypeLink;

  /// No description provided for @rdLibraryTypePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get rdLibraryTypePhoto;

  /// No description provided for @rdLibraryTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get rdLibraryTypeEvent;

  /// No description provided for @rdLibraryTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get rdLibraryTypeNote;

  /// No description provided for @rdLibraryTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get rdLibraryTimeJustNow;

  /// No description provided for @rdLibraryTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String rdLibraryTimeMinutesAgo(int minutes);

  /// No description provided for @rdLibraryTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String rdLibraryTimeHoursAgo(int hours);

  /// No description provided for @rdLibraryTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rdLibraryTimeYesterday;

  /// No description provided for @rdLibraryTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String rdLibraryTimeDaysAgo(int days);

  /// No description provided for @rdLibraryTimeDate.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}'**
  String rdLibraryTimeDate(int month, int day);

  /// No description provided for @rdLibraryAddedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added {count} to \"{name}\"'**
  String rdLibraryAddedToCollection(int count, String name);

  /// No description provided for @rdLibraryAddToCollectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to collection. Check your connection.'**
  String get rdLibraryAddToCollectionFailed;

  /// No description provided for @rdLibraryAddedToBoard.
  ///
  /// In en, this message translates to:
  /// **'Added {count} to \"{board}\"'**
  String rdLibraryAddedToBoard(int count, String board);

  /// No description provided for @rdLibraryAddToBoardFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to board. Check your connection.'**
  String get rdLibraryAddToBoardFailed;

  /// No description provided for @rdLibraryDeletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 memory} other{Deleted {count} memories}}'**
  String rdLibraryDeletedCount(int count);

  /// No description provided for @rdLibraryArchivedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Archived 1 memory} other{Archived {count} memories}}'**
  String rdLibraryArchivedCount(int count);

  /// No description provided for @rdLibraryPinnedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pinned 1 memory} other{Pinned {count} memories}}'**
  String rdLibraryPinnedCount(int count);

  /// No description provided for @rdLibraryRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored \"{title}\"'**
  String rdLibraryRestored(String title);

  /// No description provided for @rdLibraryCouldntOpenCollection.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open \"{name}\".'**
  String rdLibraryCouldntOpenCollection(String name);

  /// No description provided for @rdLibraryAddToBoard.
  ///
  /// In en, this message translates to:
  /// **'Add to board'**
  String get rdLibraryAddToBoard;

  /// No description provided for @rdLibraryUntitledBoard.
  ///
  /// In en, this message translates to:
  /// **'Untitled board'**
  String get rdLibraryUntitledBoard;

  /// No description provided for @rdLibraryCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String rdLibraryCardCount(int count);

  /// No description provided for @rdLibraryNewBoard.
  ///
  /// In en, this message translates to:
  /// **'New board'**
  String get rdLibraryNewBoard;

  /// No description provided for @rdLibraryBoardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Board name'**
  String get rdLibraryBoardNameHint;

  /// No description provided for @rdLibraryFallbackBoard.
  ///
  /// In en, this message translates to:
  /// **'board'**
  String get rdLibraryFallbackBoard;

  /// No description provided for @rdMemoryConnectedMemory.
  ///
  /// In en, this message translates to:
  /// **'Connected memory'**
  String get rdMemoryConnectedMemory;

  /// No description provided for @rdMemoryLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get rdMemoryLinked;

  /// No description provided for @rdMemoryInsightLinked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{linked it to 1 related memory} other{linked it to {count} related memories}}'**
  String rdMemoryInsightLinked(int count);

  /// No description provided for @rdMemoryInsightConnected.
  ///
  /// In en, this message translates to:
  /// **'connected {names}'**
  String rdMemoryInsightConnected(String names);

  /// No description provided for @rdMemoryInsightTagged.
  ///
  /// In en, this message translates to:
  /// **'tagged it {tags}'**
  String rdMemoryInsightTagged(String tags);

  /// No description provided for @rdMemoryInsightSummary.
  ///
  /// In en, this message translates to:
  /// **'I read through this and {details} so it stays easy to find.'**
  String rdMemoryInsightSummary(String details);

  /// No description provided for @rdMemoryPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get rdMemoryPinned;

  /// No description provided for @rdMemoryUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get rdMemoryUnpinned;

  /// No description provided for @rdMemoryVoiceNoteBadge.
  ///
  /// In en, this message translates to:
  /// **'Voice note · {duration}'**
  String rdMemoryVoiceNoteBadge(String duration);

  /// No description provided for @rdMemoryEditedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Edited just now · today, 4:12 PM'**
  String get rdMemoryEditedJustNow;

  /// No description provided for @rdMemoryRecordedAgo.
  ///
  /// In en, this message translates to:
  /// **'Recorded 2h ago · today, 4:12 PM'**
  String get rdMemoryRecordedAgo;

  /// No description provided for @rdMemoryCapturedAgo.
  ///
  /// In en, this message translates to:
  /// **'Captured 2h ago · today, 4:12 PM'**
  String get rdMemoryCapturedAgo;

  /// No description provided for @rdMemoryEditTranscriptHint.
  ///
  /// In en, this message translates to:
  /// **'Editing the transcript — Mira will re-read it and refresh connections when you save.'**
  String get rdMemoryEditTranscriptHint;

  /// No description provided for @rdMemoryEditNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Editing note — Mira will re-read it and refresh connections when you save.'**
  String get rdMemoryEditNoteHint;

  /// No description provided for @rdMemoryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get rdMemoryTitleHint;

  /// No description provided for @rdMemoryTranscriptHint.
  ///
  /// In en, this message translates to:
  /// **'Transcript…'**
  String get rdMemoryTranscriptHint;

  /// No description provided for @rdMemoryWriteNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note…'**
  String get rdMemoryWriteNoteHint;

  /// No description provided for @rdMemoryTranscribedByMira.
  ///
  /// In en, this message translates to:
  /// **'TRANSCRIBED BY MIRA'**
  String get rdMemoryTranscribedByMira;

  /// No description provided for @rdMemoryMiraNoticed.
  ///
  /// In en, this message translates to:
  /// **'Mira noticed'**
  String get rdMemoryMiraNoticed;

  /// No description provided for @rdMemoryReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get rdMemoryReminder;

  /// No description provided for @rdMemoryReminderOnBrief.
  ///
  /// In en, this message translates to:
  /// **'On — tracked in your Brief'**
  String get rdMemoryReminderOnBrief;

  /// No description provided for @rdMemoryReminderOnBringUp.
  ///
  /// In en, this message translates to:
  /// **'On — Mira will bring this up'**
  String get rdMemoryReminderOnBringUp;

  /// No description provided for @rdMemoryReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off — tap to remind me'**
  String get rdMemoryReminderOff;

  /// No description provided for @rdMemoryConnectedMemories.
  ///
  /// In en, this message translates to:
  /// **'Connected memories'**
  String get rdMemoryConnectedMemories;

  /// No description provided for @rdMemorySeeInCanvas.
  ///
  /// In en, this message translates to:
  /// **'See in Canvas'**
  String get rdMemorySeeInCanvas;

  /// No description provided for @rdMemoryPeopleAndTags.
  ///
  /// In en, this message translates to:
  /// **'People & entities'**
  String get rdMemoryPeopleAndTags;

  /// No description provided for @rdMemorySourceVoice.
  ///
  /// In en, this message translates to:
  /// **'Recorded on Home · iPhone · not shared'**
  String get rdMemorySourceVoice;

  /// No description provided for @rdMemorySourceNote.
  ///
  /// In en, this message translates to:
  /// **'Typed on Home · iPhone · not shared'**
  String get rdMemorySourceNote;

  /// No description provided for @rdMemorySaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get rdMemorySaveChanges;

  /// No description provided for @rdMemoryAskMiraAboutThis.
  ///
  /// In en, this message translates to:
  /// **'Ask Mira about this'**
  String get rdMemoryAskMiraAboutThis;

  /// No description provided for @rdMemoryPinToTop.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get rdMemoryPinToTop;

  /// No description provided for @rdMemoryUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get rdMemoryUnpin;

  /// No description provided for @rdMemoryEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get rdMemoryEditNote;

  /// No description provided for @rdMemoryShareMemory.
  ///
  /// In en, this message translates to:
  /// **'Share memory'**
  String get rdMemoryShareMemory;

  /// No description provided for @rdMemorySavedTranscript.
  ///
  /// In en, this message translates to:
  /// **'Saved — Mira re-read your transcript'**
  String get rdMemorySavedTranscript;

  /// No description provided for @rdMemorySavedNote.
  ///
  /// In en, this message translates to:
  /// **'Saved — Mira re-read this note'**
  String get rdMemorySavedNote;

  /// No description provided for @rdMemoryAddedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added to “{name}”'**
  String rdMemoryAddedToCollection(String name);

  /// No description provided for @rdMemoryLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get rdMemoryLinkCopied;

  /// No description provided for @rdMemoryCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get rdMemoryCopyLink;

  /// No description provided for @rdMemoryCopyAsText.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get rdMemoryCopyAsText;

  /// No description provided for @rdMemoryEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get rdMemoryEmail;

  /// No description provided for @rdMemoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get rdMemoryMessage;

  /// No description provided for @rdMemoryCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get rdMemoryCopiedToClipboard;

  /// No description provided for @rdMemoryNoAppAvailable.
  ///
  /// In en, this message translates to:
  /// **'No app available for that'**
  String get rdMemoryNoAppAvailable;

  /// No description provided for @rdMemoryDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” and its {connections, plural, =1{1 connection} other{{connections} connections}} will be removed from your Library. This can\'t be undone.'**
  String rdMemoryDeleteConfirmBody(String title, int connections);

  /// No description provided for @rdMemoryKeepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get rdMemoryKeepIt;

  /// No description provided for @rdChatOpening.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your memories — what you saved, what to follow up on, or I can draft something for you.'**
  String get rdChatOpening;

  /// No description provided for @rdChatOpeningAnchored.
  ///
  /// In en, this message translates to:
  /// **'This one\'s about “{title}.” Ask me anything about it — what\'s open, how it connects, or I can draft something for you.'**
  String rdChatOpeningAnchored(String title);

  /// No description provided for @rdChatStarterDraftReminder.
  ///
  /// In en, this message translates to:
  /// **'Draft a reminder'**
  String get rdChatStarterDraftReminder;

  /// No description provided for @rdChatStarterHowConnect.
  ///
  /// In en, this message translates to:
  /// **'How does this connect?'**
  String get rdChatStarterHowConnect;

  /// No description provided for @rdChatStarterSummarise.
  ///
  /// In en, this message translates to:
  /// **'Summarise this'**
  String get rdChatStarterSummarise;

  /// No description provided for @rdChatFollowUpDefault.
  ///
  /// In en, this message translates to:
  /// **'Follow up on this'**
  String get rdChatFollowUpDefault;

  /// No description provided for @rdChatEmptyAnswer.
  ///
  /// In en, this message translates to:
  /// **'I looked, but I don\'t have anything on that yet — capture it and I\'ll connect it here.'**
  String get rdChatEmptyAnswer;

  /// No description provided for @rdChatOfflineFallback.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t reach your memory just now. Try again in a moment.'**
  String get rdChatOfflineFallback;

  /// No description provided for @rdChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Mira'**
  String get rdChatTitle;

  /// No description provided for @rdChatAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About “{title}”'**
  String rdChatAboutTitle(String title);

  /// No description provided for @rdChatGroundedInMemories.
  ///
  /// In en, this message translates to:
  /// **'Grounded in your memories'**
  String get rdChatGroundedInMemories;

  /// No description provided for @rdChatFromYourMemories.
  ///
  /// In en, this message translates to:
  /// **'FROM YOUR MEMORIES'**
  String get rdChatFromYourMemories;

  /// No description provided for @rdChatReminderAdded.
  ///
  /// In en, this message translates to:
  /// **'Reminder added'**
  String get rdChatReminderAdded;

  /// No description provided for @rdChatSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Set this reminder'**
  String get rdChatSetReminder;

  /// No description provided for @rdChatComposeHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your memories…'**
  String get rdChatComposeHint;

  /// No description provided for @rdChatCiteVoiceSub.
  ///
  /// In en, this message translates to:
  /// **'Voice · read by Mira'**
  String get rdChatCiteVoiceSub;

  /// No description provided for @rdChatCitePhotoSub.
  ///
  /// In en, this message translates to:
  /// **'Photo · read by Mira'**
  String get rdChatCitePhotoSub;

  /// No description provided for @rdAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get rdAccountTitle;

  /// No description provided for @rdAccountPlaceholderName.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get rdAccountPlaceholderName;

  /// No description provided for @rdAccountSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get rdAccountSignedOut;

  /// No description provided for @rdAccountSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get rdAccountSectionProfile;

  /// No description provided for @rdAccountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get rdAccountName;

  /// No description provided for @rdAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get rdAccountEmail;

  /// No description provided for @rdAccountPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get rdAccountPhone;

  /// No description provided for @rdAccountSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get rdAccountSectionSecurity;

  /// No description provided for @rdAccountFaceIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID unlock'**
  String get rdAccountFaceIdTitle;

  /// No description provided for @rdAccountFaceIdSub.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID to open Mira'**
  String get rdAccountFaceIdSub;

  /// No description provided for @rdAccountAutoLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get rdAccountAutoLockTitle;

  /// No description provided for @rdAccountAutoLockSub.
  ///
  /// In en, this message translates to:
  /// **'Lock after 5 minutes idle'**
  String get rdAccountAutoLockSub;

  /// No description provided for @rdAccountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get rdAccountChangePassword;

  /// No description provided for @rdAccountSectionPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get rdAccountSectionPlan;

  /// No description provided for @rdAccountMiraPlus.
  ///
  /// In en, this message translates to:
  /// **'Mira Plus'**
  String get rdAccountMiraPlus;

  /// No description provided for @rdAccountMiraFree.
  ///
  /// In en, this message translates to:
  /// **'Mira Free'**
  String get rdAccountMiraFree;

  /// No description provided for @rdAccountPlusActiveSub.
  ///
  /// In en, this message translates to:
  /// **'Active · \$8 / month'**
  String get rdAccountPlusActiveSub;

  /// No description provided for @rdAccountFreeUsageSub.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} memories used'**
  String rdAccountFreeUsageSub(int used, int limit);

  /// No description provided for @rdAccountSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get rdAccountSectionPreferences;

  /// No description provided for @rdAccountNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rdAccountNotificationsTitle;

  /// No description provided for @rdAccountNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Brief, reminders & quiet hours'**
  String get rdAccountNotificationsSub;

  /// No description provided for @rdAccountRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get rdAccountRemindersTitle;

  /// No description provided for @rdAccountRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Everything Mira is holding for you'**
  String get rdAccountRemindersSub;

  /// No description provided for @rdAccountAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get rdAccountAppearanceTitle;

  /// No description provided for @rdAccountAppearanceSub.
  ///
  /// In en, this message translates to:
  /// **'Theme, accent, text size & motion'**
  String get rdAccountAppearanceSub;

  /// No description provided for @rdAccountConnectedAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected apps'**
  String get rdAccountConnectedAppsTitle;

  /// No description provided for @rdAccountConnectedAppsSub.
  ///
  /// In en, this message translates to:
  /// **'Calendar, Notes, Photos & more'**
  String get rdAccountConnectedAppsSub;

  /// No description provided for @rdAccountSectionMemoryData.
  ///
  /// In en, this message translates to:
  /// **'Memory & data'**
  String get rdAccountSectionMemoryData;

  /// No description provided for @rdAccountExportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get rdAccountExportData;

  /// No description provided for @rdAccountExportDataSub.
  ///
  /// In en, this message translates to:
  /// **'Download everything Mira holds'**
  String get rdAccountExportDataSub;

  /// No description provided for @rdAccountMemoryHistory.
  ///
  /// In en, this message translates to:
  /// **'Memory history'**
  String get rdAccountMemoryHistory;

  /// No description provided for @rdAccountMemoryHistorySub.
  ///
  /// In en, this message translates to:
  /// **'See what was captured & when'**
  String get rdAccountMemoryHistorySub;

  /// No description provided for @rdAccountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get rdAccountSignOut;

  /// No description provided for @rdAccountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get rdAccountDeleteAccount;

  /// No description provided for @rdAccountFootVersion.
  ///
  /// In en, this message translates to:
  /// **'Mira · Version 1.0'**
  String get rdAccountFootVersion;

  /// No description provided for @rdAccountAllMemoriesSynced.
  ///
  /// In en, this message translates to:
  /// **'All memories synced'**
  String get rdAccountAllMemoriesSynced;

  /// No description provided for @rdAccountStorageHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count} memories'**
  String rdAccountStorageHeadline(int count);

  /// No description provided for @rdAccountStorageSubline.
  ///
  /// In en, this message translates to:
  /// **'of {limit} · plenty of room'**
  String rdAccountStorageSubline(int limit);

  /// No description provided for @rdNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rdNotificationsTitle;

  /// No description provided for @rdNotificationsIntro.
  ///
  /// In en, this message translates to:
  /// **'Mira stays quiet by default — and only speaks up when it truly helps.'**
  String get rdNotificationsIntro;

  /// No description provided for @rdNotificationsSectionDailyBrief.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief'**
  String get rdNotificationsSectionDailyBrief;

  /// No description provided for @rdNotificationsMorningBrief.
  ///
  /// In en, this message translates to:
  /// **'Morning brief'**
  String get rdNotificationsMorningBrief;

  /// No description provided for @rdNotificationsMorningBriefSub.
  ///
  /// In en, this message translates to:
  /// **'A calm summary to start the day'**
  String get rdNotificationsMorningBriefSub;

  /// No description provided for @rdNotificationsBriefTime.
  ///
  /// In en, this message translates to:
  /// **'Brief time'**
  String get rdNotificationsBriefTime;

  /// No description provided for @rdNotificationsResurfaceMemory.
  ///
  /// In en, this message translates to:
  /// **'Resurface a memory'**
  String get rdNotificationsResurfaceMemory;

  /// No description provided for @rdNotificationsResurfaceMemorySub.
  ///
  /// In en, this message translates to:
  /// **'Occasionally revisit something worth holding'**
  String get rdNotificationsResurfaceMemorySub;

  /// No description provided for @rdNotificationsSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get rdNotificationsSectionReminders;

  /// No description provided for @rdNotificationsTimeSensitive.
  ///
  /// In en, this message translates to:
  /// **'Time-sensitive reminders'**
  String get rdNotificationsTimeSensitive;

  /// No description provided for @rdNotificationsTimeSensitiveSub.
  ///
  /// In en, this message translates to:
  /// **'Dates, tickets, and things that expire'**
  String get rdNotificationsTimeSensitiveSub;

  /// No description provided for @rdNotificationsGentleNudges.
  ///
  /// In en, this message translates to:
  /// **'Gentle nudges'**
  String get rdNotificationsGentleNudges;

  /// No description provided for @rdNotificationsGentleNudgesSub.
  ///
  /// In en, this message translates to:
  /// **'Soft prompts for unfinished threads'**
  String get rdNotificationsGentleNudgesSub;

  /// No description provided for @rdNotificationsSectionCaptures.
  ///
  /// In en, this message translates to:
  /// **'Captures'**
  String get rdNotificationsSectionCaptures;

  /// No description provided for @rdNotificationsConfirmBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Confirm before saving'**
  String get rdNotificationsConfirmBeforeSaving;

  /// No description provided for @rdNotificationsConfirmBeforeSavingSub.
  ///
  /// In en, this message translates to:
  /// **'Ask before adding a capture to your graph'**
  String get rdNotificationsConfirmBeforeSavingSub;

  /// No description provided for @rdNotificationsWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'Weekly recap'**
  String get rdNotificationsWeeklyRecap;

  /// No description provided for @rdNotificationsWeeklyRecapSub.
  ///
  /// In en, this message translates to:
  /// **'A Sunday look back at the week'**
  String get rdNotificationsWeeklyRecapSub;

  /// No description provided for @rdNotificationsSectionQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get rdNotificationsSectionQuietHours;

  /// No description provided for @rdNotificationsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get rdNotificationsQuietHours;

  /// No description provided for @rdNotificationsQuietHoursSub.
  ///
  /// In en, this message translates to:
  /// **'Hold all notifications while you rest'**
  String get rdNotificationsQuietHoursSub;

  /// No description provided for @rdNotificationsSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get rdNotificationsSchedule;

  /// No description provided for @rdNotificationsQuietStartHelp.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours start'**
  String get rdNotificationsQuietStartHelp;

  /// No description provided for @rdNotificationsQuietEndHelp.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours end'**
  String get rdNotificationsQuietEndHelp;

  /// No description provided for @rdNotificationsSectionDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get rdNotificationsSectionDelivery;

  /// No description provided for @rdNotificationsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get rdNotificationsSound;

  /// No description provided for @rdNotificationsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get rdNotificationsHaptics;

  /// No description provided for @rdNotificationsFoot.
  ///
  /// In en, this message translates to:
  /// **'Mira notifies you gently, or not at all.'**
  String get rdNotificationsFoot;

  /// No description provided for @rdConnectedAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected apps'**
  String get rdConnectedAppsTitle;

  /// No description provided for @rdConnectedAppsIntro.
  ///
  /// In en, this message translates to:
  /// **'Mira quietly weaves these sources into your memory — nothing leaves without your say.'**
  String get rdConnectedAppsIntro;

  /// No description provided for @rdConnectedAppsSectionConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get rdConnectedAppsSectionConnected;

  /// No description provided for @rdConnectedAppsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get rdConnectedAppsCalendar;

  /// No description provided for @rdConnectedAppsCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'Synced 2m ago · feeds your Brief'**
  String get rdConnectedAppsCalendarSub;

  /// No description provided for @rdConnectedAppsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rdConnectedAppsNotes;

  /// No description provided for @rdConnectedAppsNotesSub.
  ///
  /// In en, this message translates to:
  /// **'Synced 1h ago · 128 notes'**
  String get rdConnectedAppsNotesSub;

  /// No description provided for @rdConnectedAppsPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get rdConnectedAppsPhotos;

  /// No description provided for @rdConnectedAppsPhotosSub.
  ///
  /// In en, this message translates to:
  /// **'Synced today · screenshots & scans'**
  String get rdConnectedAppsPhotosSub;

  /// No description provided for @rdConnectedAppsSectionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get rdConnectedAppsSectionAvailable;

  /// No description provided for @rdConnectedAppsGmail.
  ///
  /// In en, this message translates to:
  /// **'Gmail'**
  String get rdConnectedAppsGmail;

  /// No description provided for @rdConnectedAppsGmailSub.
  ///
  /// In en, this message translates to:
  /// **'Turn important mail into memories'**
  String get rdConnectedAppsGmailSub;

  /// No description provided for @rdConnectedAppsSafari.
  ///
  /// In en, this message translates to:
  /// **'Safari'**
  String get rdConnectedAppsSafari;

  /// No description provided for @rdConnectedAppsSafariSub.
  ///
  /// In en, this message translates to:
  /// **'Save pages & highlights as you browse'**
  String get rdConnectedAppsSafariSub;

  /// No description provided for @rdConnectedAppsReadwise.
  ///
  /// In en, this message translates to:
  /// **'Readwise'**
  String get rdConnectedAppsReadwise;

  /// No description provided for @rdConnectedAppsReadwiseSub.
  ///
  /// In en, this message translates to:
  /// **'Import book & article highlights'**
  String get rdConnectedAppsReadwiseSub;

  /// No description provided for @rdConnectedAppsVoiceMemos.
  ///
  /// In en, this message translates to:
  /// **'Voice Memos'**
  String get rdConnectedAppsVoiceMemos;

  /// No description provided for @rdConnectedAppsVoiceMemosSub.
  ///
  /// In en, this message translates to:
  /// **'Transcribe recordings into your graph'**
  String get rdConnectedAppsVoiceMemosSub;

  /// No description provided for @rdConnectedAppsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Mira only reads what you connect, and processes it privately. Disconnect anytime.'**
  String get rdConnectedAppsPrivacy;

  /// No description provided for @rdConnectedAppsFoot.
  ///
  /// In en, this message translates to:
  /// **'{count} sources available to connect'**
  String rdConnectedAppsFoot(int count);

  /// No description provided for @rdAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get rdAppearanceTitle;

  /// No description provided for @rdAppearanceIntro.
  ///
  /// In en, this message translates to:
  /// **'Make Mira feel like yours — colour, contrast and calm.'**
  String get rdAppearanceIntro;

  /// No description provided for @rdAppearanceSectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get rdAppearanceSectionTheme;

  /// No description provided for @rdAppearanceThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get rdAppearanceThemeSystem;

  /// No description provided for @rdAppearanceThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get rdAppearanceThemeLight;

  /// No description provided for @rdAppearanceThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get rdAppearanceThemeDark;

  /// No description provided for @rdAppearanceDarkModeHint.
  ///
  /// In en, this message translates to:
  /// **'Dark mode is on — tuned for calm, low-light reading.'**
  String get rdAppearanceDarkModeHint;

  /// No description provided for @rdAppearanceSectionAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get rdAppearanceSectionAccent;

  /// No description provided for @rdAppearanceAccentPeriwinkle.
  ///
  /// In en, this message translates to:
  /// **'Periwinkle'**
  String get rdAppearanceAccentPeriwinkle;

  /// No description provided for @rdAppearanceAccentSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get rdAppearanceAccentSage;

  /// No description provided for @rdAppearanceAccentClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get rdAppearanceAccentClay;

  /// No description provided for @rdAppearanceAccentPlum.
  ///
  /// In en, this message translates to:
  /// **'Plum'**
  String get rdAppearanceAccentPlum;

  /// No description provided for @rdAppearanceAccentCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rdAppearanceAccentCustom;

  /// No description provided for @rdAppearanceSectionTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get rdAppearanceSectionTextSize;

  /// No description provided for @rdAppearanceTextSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get rdAppearanceTextSmall;

  /// No description provided for @rdAppearanceTextDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get rdAppearanceTextDefault;

  /// No description provided for @rdAppearanceTextLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get rdAppearanceTextLarge;

  /// No description provided for @rdAppearancePreviewText.
  ///
  /// In en, this message translates to:
  /// **'Mira keeps your memories clear and readable.'**
  String get rdAppearancePreviewText;

  /// No description provided for @rdAppearanceReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get rdAppearanceReduceMotion;

  /// No description provided for @rdAppearanceReduceMotionSub.
  ///
  /// In en, this message translates to:
  /// **'Calmer transitions and less movement'**
  String get rdAppearanceReduceMotionSub;

  /// No description provided for @rdAppearanceSectionAppIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get rdAppearanceSectionAppIcon;

  /// No description provided for @rdAppearanceIconDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get rdAppearanceIconDefault;

  /// No description provided for @rdAppearanceIconSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get rdAppearanceIconSage;

  /// No description provided for @rdAppearanceIconDusk.
  ///
  /// In en, this message translates to:
  /// **'Dusk'**
  String get rdAppearanceIconDusk;

  /// No description provided for @rdAppearanceFoot.
  ///
  /// In en, this message translates to:
  /// **'Appearance changes apply instantly.'**
  String get rdAppearanceFoot;

  /// No description provided for @rdStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get rdStorageTitle;

  /// No description provided for @rdStorageIntro.
  ///
  /// In en, this message translates to:
  /// **'What Mira is holding, and how much room is left.'**
  String get rdStorageIntro;

  /// No description provided for @rdStorageUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating usage…'**
  String get rdStorageUpdating;

  /// No description provided for @rdStorageSectionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get rdStorageSectionBreakdown;

  /// No description provided for @rdStorageSectionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get rdStorageSectionManage;

  /// No description provided for @rdStorageClearArchived.
  ///
  /// In en, this message translates to:
  /// **'Clear archived'**
  String get rdStorageClearArchived;

  /// No description provided for @rdStorageClearArchivedSub.
  ///
  /// In en, this message translates to:
  /// **'Remove captures you have archived'**
  String get rdStorageClearArchivedSub;

  /// No description provided for @rdStorageOffloadCloud.
  ///
  /// In en, this message translates to:
  /// **'Offload originals to cloud'**
  String get rdStorageOffloadCloud;

  /// No description provided for @rdStorageOffloadCloudSub.
  ///
  /// In en, this message translates to:
  /// **'Keep full-quality copies in a connected service'**
  String get rdStorageOffloadCloudSub;

  /// No description provided for @rdStorageFoot.
  ///
  /// In en, this message translates to:
  /// **'Mira keeps only what you approve.'**
  String get rdStorageFoot;

  /// No description provided for @rdStorageCategoryPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get rdStorageCategoryPhotos;

  /// No description provided for @rdStorageCategoryVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get rdStorageCategoryVoice;

  /// No description provided for @rdStorageCategoryScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get rdStorageCategoryScreenshots;

  /// No description provided for @rdStorageCategoryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rdStorageCategoryNotes;

  /// No description provided for @rdStorageCategoryLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get rdStorageCategoryLinks;

  /// No description provided for @rdStorageCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rdStorageCategoryOther;

  /// No description provided for @rdStorageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get rdStorageEmpty;

  /// No description provided for @rdStorageItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String rdStorageItemCount(int count);

  /// No description provided for @rdStorageOfQuota.
  ///
  /// In en, this message translates to:
  /// **'of {quota}'**
  String rdStorageOfQuota(String quota);

  /// No description provided for @rdStorageNoArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived items to clear'**
  String get rdStorageNoArchived;

  /// No description provided for @rdStorageCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {count, plural, =1{1 archived item} other{{count} archived items}}{freed}'**
  String rdStorageCleared(int count, String freed);

  /// No description provided for @rdStorageFreedSuffix.
  ///
  /// In en, this message translates to:
  /// **' · {amount} freed'**
  String rdStorageFreedSuffix(String amount);

  /// No description provided for @rdStorageClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear archived items'**
  String get rdStorageClearFailed;

  /// No description provided for @rdRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get rdRemindersTitle;

  /// No description provided for @rdRemindersSubtitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting on you'**
  String get rdRemindersSubtitleEmpty;

  /// No description provided for @rdRemindersSubtitleOne.
  ///
  /// In en, this message translates to:
  /// **'1 thing Mira is holding for you'**
  String get rdRemindersSubtitleOne;

  /// No description provided for @rdRemindersSubtitleMany.
  ///
  /// In en, this message translates to:
  /// **'{count} things Mira is holding for you'**
  String rdRemindersSubtitleMany(int count);

  /// No description provided for @rdRemindersSectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get rdRemindersSectionOverdue;

  /// No description provided for @rdRemindersSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rdRemindersSectionToday;

  /// No description provided for @rdRemindersSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get rdRemindersSectionUpcoming;

  /// No description provided for @rdRemindersSectionWaiting.
  ///
  /// In en, this message translates to:
  /// **'When the moment\'s right'**
  String get rdRemindersSectionWaiting;

  /// No description provided for @rdRemindersSectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rdRemindersSectionDone;

  /// No description provided for @rdRemindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get rdRemindersEmptyTitle;

  /// No description provided for @rdRemindersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Ask Mira to remind you about something,\nand it will settle in here.'**
  String get rdRemindersEmptyBody;

  /// No description provided for @rdRemindersMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get rdRemindersMarkedDone;

  /// No description provided for @rdRemindersBackOnList.
  ///
  /// In en, this message translates to:
  /// **'Back on your list'**
  String get rdRemindersBackOnList;

  /// No description provided for @rdRemindersSnoozedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until tomorrow'**
  String get rdRemindersSnoozedTomorrow;

  /// No description provided for @rdRemindersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get rdRemindersDeleted;

  /// No description provided for @rdRemindersSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get rdRemindersSet;

  /// No description provided for @rdRemindersUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled reminder'**
  String get rdRemindersUntitled;

  /// No description provided for @rdRemindersFromMemory.
  ///
  /// In en, this message translates to:
  /// **'From a memory'**
  String get rdRemindersFromMemory;

  /// No description provided for @rdRemindersDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rdRemindersDone;

  /// No description provided for @rdRemindersSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get rdRemindersSnooze;

  /// No description provided for @rdRemindersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get rdRemindersOverdue;

  /// No description provided for @rdRemindersOverdueByHours.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {hours}h'**
  String rdRemindersOverdueByHours(int hours);

  /// No description provided for @rdRemindersOverdueSinceYesterday.
  ///
  /// In en, this message translates to:
  /// **'Overdue since yesterday'**
  String get rdRemindersOverdueSinceYesterday;

  /// No description provided for @rdRemindersOverdueByDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days}d'**
  String rdRemindersOverdueByDays(int days);

  /// No description provided for @rdRemindersNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get rdRemindersNow;

  /// No description provided for @rdRemindersInMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutes}m'**
  String rdRemindersInMinutes(int minutes);

  /// No description provided for @rdRemindersInHours.
  ///
  /// In en, this message translates to:
  /// **'In {hours}h'**
  String rdRemindersInHours(int hours);

  /// No description provided for @rdRemindersTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get rdRemindersTomorrow;

  /// No description provided for @rdRemindersInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String rdRemindersInDays(int days);

  /// No description provided for @rdRemindersComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get rdRemindersComposeTitle;

  /// No description provided for @rdRemindersComposeHint.
  ///
  /// In en, this message translates to:
  /// **'Remind me to…'**
  String get rdRemindersComposeHint;

  /// No description provided for @rdRemindersWhenLabel.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get rdRemindersWhenLabel;

  /// No description provided for @rdRemindersLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get rdRemindersLaterToday;

  /// No description provided for @rdRemindersThisEvening.
  ///
  /// In en, this message translates to:
  /// **'This evening'**
  String get rdRemindersThisEvening;

  /// No description provided for @rdRemindersNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get rdRemindersNextWeek;

  /// No description provided for @rdRemindersPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get rdRemindersPickDateTime;

  /// No description provided for @rdRemindersSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get rdRemindersSetReminder;

  /// No description provided for @rdRemindersTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get rdRemindersTranscribing;

  /// No description provided for @rdHomeRecentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your recent memories will appear here.'**
  String get rdHomeRecentsEmpty;

  /// No description provided for @rdHomeRemindAgain.
  ///
  /// In en, this message translates to:
  /// **'Remind again…'**
  String get rdHomeRemindAgain;

  /// No description provided for @rdHomeSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed · {label}'**
  String rdHomeSnoozed(String label);

  /// No description provided for @rdHomeLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get rdHomeLaterToday;

  /// No description provided for @rdHomeInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String rdHomeInDays(int days);

  /// No description provided for @rdHomeKindNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get rdHomeKindNote;

  /// No description provided for @rdHomeKindVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get rdHomeKindVoice;

  /// No description provided for @rdHomeLinksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} links'**
  String rdHomeLinksCount(int count);

  /// No description provided for @rdCanvasMapContext.
  ///
  /// In en, this message translates to:
  /// **'Your memory · {memories} memories · {connections} connections'**
  String rdCanvasMapContext(int memories, int connections);

  /// No description provided for @rdCanvasClusterContext.
  ///
  /// In en, this message translates to:
  /// **'{clusters} clusters · {memories} memories'**
  String rdCanvasClusterContext(int clusters, int memories);

  /// No description provided for @rdCanvasMergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Memories merged'**
  String get rdCanvasMergeSuccess;

  /// No description provided for @rdCanvasMergeFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t merge those'**
  String get rdCanvasMergeFail;

  /// No description provided for @rdCanvasUnlinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection removed'**
  String get rdCanvasUnlinkSuccess;

  /// No description provided for @rdCanvasUnlinkFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove that connection'**
  String get rdCanvasUnlinkFail;

  /// No description provided for @rdCanvasMyBoard.
  ///
  /// In en, this message translates to:
  /// **'My board'**
  String get rdCanvasMyBoard;

  /// No description provided for @rdCanvasNewBoard.
  ///
  /// In en, this message translates to:
  /// **'New board'**
  String get rdCanvasNewBoard;

  /// No description provided for @rdCanvasBoardDefault.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get rdCanvasBoardDefault;

  /// No description provided for @rdCanvasBoardLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 card} other{{count} cards}}'**
  String rdCanvasBoardLabel(String name, int count);

  /// No description provided for @rdCanvasRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename board'**
  String get rdCanvasRenameTitle;

  /// No description provided for @rdCanvasBoardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Board name'**
  String get rdCanvasBoardNameHint;

  /// No description provided for @rdCanvasLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get rdCanvasLoading;

  /// No description provided for @rdCanvasBoardsHeader.
  ///
  /// In en, this message translates to:
  /// **'BOARDS'**
  String get rdCanvasBoardsHeader;

  /// No description provided for @rdCanvasUntitledBoard.
  ///
  /// In en, this message translates to:
  /// **'Untitled board'**
  String get rdCanvasUntitledBoard;

  /// No description provided for @rdCanvasCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String rdCanvasCardCount(int count);

  /// No description provided for @rdCanvasLinkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} linked {count, plural, =1{memory} other{memories}}.'**
  String rdCanvasLinkedCount(int count);

  /// No description provided for @rdCanvasNodePerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get rdCanvasNodePerson;

  /// No description provided for @rdCanvasNodeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get rdCanvasNodeTask;

  /// No description provided for @rdCanvasNodeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get rdCanvasNodeEvent;

  /// No description provided for @rdCanvasNodeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get rdCanvasNodeNote;

  /// No description provided for @rdCanvasNodeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get rdCanvasNodeBook;

  /// No description provided for @rdCanvasNodeIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get rdCanvasNodeIdea;

  /// No description provided for @rdCanvasNodeTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get rdCanvasNodeTopic;

  /// No description provided for @rdCanvasNodeOrganization.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get rdCanvasNodeOrganization;

  /// No description provided for @rdCanvasNodeProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get rdCanvasNodeProject;

  /// No description provided for @rdCanvasNodePlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get rdCanvasNodePlace;

  /// No description provided for @rdCanvasClusterTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get rdCanvasClusterTasks;

  /// No description provided for @rdCanvasClusterBooks.
  ///
  /// In en, this message translates to:
  /// **'Books & ideas'**
  String get rdCanvasClusterBooks;

  /// No description provided for @rdCanvasClusterEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get rdCanvasClusterEvents;

  /// No description provided for @rdCanvasClusterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes & memories'**
  String get rdCanvasClusterNotes;

  /// No description provided for @rdCanvasNoClusters.
  ///
  /// In en, this message translates to:
  /// **'No clusters yet'**
  String get rdCanvasNoClusters;

  /// No description provided for @rdCanvasGraphEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your memory graph is empty'**
  String get rdCanvasGraphEmpty;

  /// No description provided for @rdCanvasFocusedOn.
  ///
  /// In en, this message translates to:
  /// **'Focused on {label}'**
  String rdCanvasFocusedOn(String label);

  /// No description provided for @rdCanvasTapExplore.
  ///
  /// In en, this message translates to:
  /// **'Tap a memory · drag to explore'**
  String get rdCanvasTapExplore;

  /// No description provided for @rdCanvasMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into \"{label}\"'**
  String rdCanvasMergeInto(String label);

  /// No description provided for @rdCanvasMergePickDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Pick the duplicate to fold in — it keeps every connection.'**
  String get rdCanvasMergePickDuplicate;

  /// No description provided for @rdCanvasFocusConstellation.
  ///
  /// In en, this message translates to:
  /// **'Focus this constellation'**
  String get rdCanvasFocusConstellation;

  /// No description provided for @rdCanvasMergeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Merge a duplicate'**
  String get rdCanvasMergeDuplicate;

  /// No description provided for @rdCanvasConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED TO {count}'**
  String rdCanvasConnectedTo(int count);

  /// No description provided for @rdCanvasCardRemoved.
  ///
  /// In en, this message translates to:
  /// **'Card removed'**
  String get rdCanvasCardRemoved;

  /// No description provided for @rdCanvasNewNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get rdCanvasNewNoteTitle;

  /// No description provided for @rdCanvasNewNoteSub.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit later.'**
  String get rdCanvasNewNoteSub;

  /// No description provided for @rdCanvasEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get rdCanvasEditCard;

  /// No description provided for @rdCanvasEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get rdCanvasEditTitle;

  /// No description provided for @rdCanvasEditNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get rdCanvasEditNoteOptional;

  /// No description provided for @rdCanvasBoardEmpty.
  ///
  /// In en, this message translates to:
  /// **'This board is empty'**
  String get rdCanvasBoardEmpty;

  /// No description provided for @rdCanvasConnectTapSecond.
  ///
  /// In en, this message translates to:
  /// **'Now tap another card to connect them'**
  String get rdCanvasConnectTapSecond;

  /// No description provided for @rdCanvasConnectMode.
  ///
  /// In en, this message translates to:
  /// **'Connect mode · tap two cards to link them'**
  String get rdCanvasConnectMode;

  /// No description provided for @rdCanvasAddMode.
  ///
  /// In en, this message translates to:
  /// **'Add mode · tap anywhere to drop a card'**
  String get rdCanvasAddMode;

  /// No description provided for @rdCanvasEdgeWithPerson.
  ///
  /// In en, this message translates to:
  /// **'with {person}'**
  String rdCanvasEdgeWithPerson(String person);

  /// No description provided for @rdCanvasEdgeReminder.
  ///
  /// In en, this message translates to:
  /// **'reminder'**
  String get rdCanvasEdgeReminder;

  /// No description provided for @rdCanvasEdgeToRead.
  ///
  /// In en, this message translates to:
  /// **'to read'**
  String get rdCanvasEdgeToRead;

  /// No description provided for @rdCanvasEdgeRelated.
  ///
  /// In en, this message translates to:
  /// **'related'**
  String get rdCanvasEdgeRelated;

  /// No description provided for @rdPaywallPlanSaveBadge.
  ///
  /// In en, this message translates to:
  /// **'2 months free'**
  String get rdPaywallPlanSaveBadge;

  /// No description provided for @rdPaywallPlanPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get rdPaywallPlanPerMonth;

  /// No description provided for @rdPaywallPlanAnnualNote.
  ///
  /// In en, this message translates to:
  /// **'\$72 billed yearly'**
  String get rdPaywallPlanAnnualNote;

  /// No description provided for @rdPaywallFinePrint.
  ///
  /// In en, this message translates to:
  /// **'{then} · cancel anytime.\nNo charge today — we\'ll remind you before it ends.'**
  String rdPaywallFinePrint(String then);

  /// No description provided for @rdPaywallMemPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get rdPaywallMemPlan;

  /// No description provided for @rdPaywallMemPlanValue.
  ///
  /// In en, this message translates to:
  /// **'Annual · \$6/mo'**
  String get rdPaywallMemPlanValue;

  /// No description provided for @rdPaywallMemRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get rdPaywallMemRenews;

  /// No description provided for @rdPaywallMemRenewsValue.
  ///
  /// In en, this message translates to:
  /// **'Aug 12, 2025'**
  String get rdPaywallMemRenewsValue;

  /// No description provided for @rdPaywallMemPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get rdPaywallMemPayment;

  /// No description provided for @rdPaywallMemPaymentValue.
  ///
  /// In en, this message translates to:
  /// **'Apple ID'**
  String get rdPaywallMemPaymentValue;

  /// No description provided for @rdPaywallMemoriesHeld.
  ///
  /// In en, this message translates to:
  /// **'Memories held'**
  String get rdPaywallMemoriesHeld;

  /// No description provided for @rdPaywallMemoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} · unlimited'**
  String rdPaywallMemoriesCount(String count);

  /// No description provided for @rdPaywallMemoriesGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growing calmly. On Free this would have stopped at 2,000.'**
  String get rdPaywallMemoriesGrowth;

  /// No description provided for @rdPaywallPerksLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR PLUS PERKS'**
  String get rdPaywallPerksLabel;

  /// No description provided for @rdPaywallPerkUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited memories'**
  String get rdPaywallPerkUnlimited;

  /// No description provided for @rdPaywallPerkGraph.
  ///
  /// In en, this message translates to:
  /// **'Full memory graph'**
  String get rdPaywallPerkGraph;

  /// No description provided for @rdPaywallPerkVoice.
  ///
  /// In en, this message translates to:
  /// **'Longer history & 10-min voice'**
  String get rdPaywallPerkVoice;

  /// No description provided for @rdPaywallPerkConnect.
  ///
  /// In en, this message translates to:
  /// **'Unlimited connected apps'**
  String get rdPaywallPerkConnect;

  /// No description provided for @rdSetupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get rdSetupSkip;

  /// No description provided for @rdSetupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get rdSetupContinue;

  /// No description provided for @rdSetupPickFew.
  ///
  /// In en, this message translates to:
  /// **'Pick a few'**
  String get rdSetupPickFew;

  /// No description provided for @rdSetupWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up\nyour second mind.'**
  String get rdSetupWelcomeTitle;

  /// No description provided for @rdSetupWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions so Mira remembers the way you do. About two minutes — and you can change any of it later.'**
  String get rdSetupWelcomeDesc;

  /// No description provided for @rdSetupBeginSetup.
  ///
  /// In en, this message translates to:
  /// **'Begin setup'**
  String get rdSetupBeginSetup;

  /// No description provided for @rdSetupSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get rdSetupSkipForNow;

  /// No description provided for @rdSetupAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'What should Mira\ncall you?'**
  String get rdSetupAddressTitle;

  /// No description provided for @rdSetupAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'This is how your Brief and reminders will greet you.'**
  String get rdSetupAddressDesc;

  /// No description provided for @rdSetupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get rdSetupNameHint;

  /// No description provided for @rdSetupToneLabel.
  ///
  /// In en, this message translates to:
  /// **'And how should it speak?'**
  String get rdSetupToneLabel;

  /// No description provided for @rdSetupToneCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get rdSetupToneCalm;

  /// No description provided for @rdSetupToneCalmSub.
  ///
  /// In en, this message translates to:
  /// **'Gentle, unhurried'**
  String get rdSetupToneCalmSub;

  /// No description provided for @rdSetupToneConcise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get rdSetupToneConcise;

  /// No description provided for @rdSetupToneConciseSub.
  ///
  /// In en, this message translates to:
  /// **'Short and clear'**
  String get rdSetupToneConciseSub;

  /// No description provided for @rdSetupToneWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get rdSetupToneWarm;

  /// No description provided for @rdSetupToneWarmSub.
  ///
  /// In en, this message translates to:
  /// **'Friendly, personal'**
  String get rdSetupToneWarmSub;

  /// No description provided for @rdSetupFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'What matters\nto you?'**
  String get rdSetupFocusTitle;

  /// No description provided for @rdSetupFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Mira will cluster your memories around these. Choose any that fit.'**
  String get rdSetupFocusDesc;

  /// No description provided for @rdSetupFocusWork.
  ///
  /// In en, this message translates to:
  /// **'Work & projects'**
  String get rdSetupFocusWork;

  /// No description provided for @rdSetupFocusIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas & sparks'**
  String get rdSetupFocusIdeas;

  /// No description provided for @rdSetupFocusPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get rdSetupFocusPeople;

  /// No description provided for @rdSetupFocusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading & links'**
  String get rdSetupFocusReading;

  /// No description provided for @rdSetupFocusHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get rdSetupFocusHealth;

  /// No description provided for @rdSetupFocusMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get rdSetupFocusMoney;

  /// No description provided for @rdSetupFocusTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & places'**
  String get rdSetupFocusTravel;

  /// No description provided for @rdSetupFocusLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get rdSetupFocusLearning;

  /// No description provided for @rdSetupPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s important\nto you?'**
  String get rdSetupPeopleTitle;

  /// No description provided for @rdSetupPeopleDesc.
  ///
  /// In en, this message translates to:
  /// **'Mira links what you capture to the people in your life. Add a few — first names are enough.'**
  String get rdSetupPeopleDesc;

  /// No description provided for @rdSetupPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Add a name'**
  String get rdSetupPeopleHint;

  /// No description provided for @rdSetupPeopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one yet — Mira will still learn as you capture.'**
  String get rdSetupPeopleEmpty;

  /// No description provided for @rdSetupRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'When should your\nBrief arrive?'**
  String get rdSetupRhythmTitle;

  /// No description provided for @rdSetupRhythmDesc.
  ///
  /// In en, this message translates to:
  /// **'A calm once-a-day summary of what needs you — nothing more.'**
  String get rdSetupRhythmDesc;

  /// No description provided for @rdSetupRhythmMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get rdSetupRhythmMorning;

  /// No description provided for @rdSetupRhythmMidday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get rdSetupRhythmMidday;

  /// No description provided for @rdSetupRhythmEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get rdSetupRhythmEvening;

  /// No description provided for @rdSetupQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get rdSetupQuietHours;

  /// No description provided for @rdSetupQuietHoursSub.
  ///
  /// In en, this message translates to:
  /// **'No nudges 22:00 – 07:00'**
  String get rdSetupQuietHoursSub;

  /// No description provided for @rdSetupPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your memory\nstays yours.'**
  String get rdSetupPrivacyTitle;

  /// No description provided for @rdSetupPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'Before you connect anything, here\'s the promise Mira is built on.'**
  String get rdSetupPrivacyDesc;

  /// No description provided for @rdSetupPrivacyProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed privately'**
  String get rdSetupPrivacyProcessed;

  /// No description provided for @rdSetupPrivacyProcessedSub.
  ///
  /// In en, this message translates to:
  /// **'Your captures are analysed on-device whenever possible.'**
  String get rdSetupPrivacyProcessedSub;

  /// No description provided for @rdSetupPrivacyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted end-to-end'**
  String get rdSetupPrivacyEncrypted;

  /// No description provided for @rdSetupPrivacyEncryptedSub.
  ///
  /// In en, this message translates to:
  /// **'Only you can read your memories — not even Mira can.'**
  String get rdSetupPrivacyEncryptedSub;

  /// No description provided for @rdSetupPrivacyNeverSold.
  ///
  /// In en, this message translates to:
  /// **'Never sold, ever'**
  String get rdSetupPrivacyNeverSold;

  /// No description provided for @rdSetupPrivacyNeverSoldSub.
  ///
  /// In en, this message translates to:
  /// **'We don\'t sell or share your data. No ads, no exceptions.'**
  String get rdSetupPrivacyNeverSoldSub;

  /// No description provided for @rdSetupChoicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get rdSetupChoicesLabel;

  /// No description provided for @rdSetupSyncDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync across my devices'**
  String get rdSetupSyncDevices;

  /// No description provided for @rdSetupSyncDevicesSub.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup so your memory follows you.'**
  String get rdSetupSyncDevicesSub;

  /// No description provided for @rdSetupHelpImprove.
  ///
  /// In en, this message translates to:
  /// **'Help improve Mira'**
  String get rdSetupHelpImprove;

  /// No description provided for @rdSetupHelpImproveSub.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous, aggregated usage — never your content.'**
  String get rdSetupHelpImproveSub;

  /// No description provided for @rdSetupSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect\nyour world.'**
  String get rdSetupSourcesTitle;

  /// No description provided for @rdSetupSourcesDesc.
  ///
  /// In en, this message translates to:
  /// **'Give Mira a head start. It only reads what you connect, and processes it privately.'**
  String get rdSetupSourcesDesc;

  /// No description provided for @rdSetupSourceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get rdSetupSourceCalendar;

  /// No description provided for @rdSetupSourceCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'Meetings feed your Brief'**
  String get rdSetupSourceCalendarSub;

  /// No description provided for @rdSetupSourceNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rdSetupSourceNotes;

  /// No description provided for @rdSetupSourceNotesSub.
  ///
  /// In en, this message translates to:
  /// **'Your written thoughts'**
  String get rdSetupSourceNotesSub;

  /// No description provided for @rdSetupSourcePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get rdSetupSourcePhotos;

  /// No description provided for @rdSetupSourcePhotosSub.
  ///
  /// In en, this message translates to:
  /// **'Screenshots & scans'**
  String get rdSetupSourcePhotosSub;

  /// No description provided for @rdSetupSourceGmail.
  ///
  /// In en, this message translates to:
  /// **'Gmail'**
  String get rdSetupSourceGmail;

  /// No description provided for @rdSetupSourceGmailSub.
  ///
  /// In en, this message translates to:
  /// **'Important mail'**
  String get rdSetupSourceGmailSub;

  /// No description provided for @rdSetupImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your\nnotes with you.'**
  String get rdSetupImportTitle;

  /// No description provided for @rdSetupImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Already keep notes elsewhere? Import them once and Mira will weave them into your graph. Nothing is deleted from the original app.'**
  String get rdSetupImportDesc;

  /// No description provided for @rdSetupImportNotesFound.
  ///
  /// In en, this message translates to:
  /// **'~{count} notes found'**
  String rdSetupImportNotesFound(String count);

  /// No description provided for @rdSetupImportLater.
  ///
  /// In en, this message translates to:
  /// **'You can also import later from Settings.'**
  String get rdSetupImportLater;

  /// No description provided for @rdSetupImportBackground.
  ///
  /// In en, this message translates to:
  /// **'Mira will import in the background — you can start using it right away.'**
  String get rdSetupImportBackground;

  /// No description provided for @rdSetupImportCta.
  ///
  /// In en, this message translates to:
  /// **'Import {count} notes'**
  String rdSetupImportCta(String count);

  /// No description provided for @rdSetupPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Mira\nhelp quietly.'**
  String get rdSetupPermissionsTitle;

  /// No description provided for @rdSetupPermissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Two permissions, both optional. Turn off anything, anytime.'**
  String get rdSetupPermissionsDesc;

  /// No description provided for @rdSetupMicTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get rdSetupMicTitle;

  /// No description provided for @rdSetupMicSub.
  ///
  /// In en, this message translates to:
  /// **'So you can speak a memory anytime'**
  String get rdSetupMicSub;

  /// No description provided for @rdSetupNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rdSetupNotifTitle;

  /// No description provided for @rdSetupNotifSub.
  ///
  /// In en, this message translates to:
  /// **'Only your Brief and reminders you set'**
  String get rdSetupNotifSub;

  /// No description provided for @rdSetupWeavingTitle.
  ///
  /// In en, this message translates to:
  /// **'Weaving your\nmemory…'**
  String get rdSetupWeavingTitle;

  /// No description provided for @rdSetupWeavingDesc.
  ///
  /// In en, this message translates to:
  /// **'Mira is arranging {line} into the shape of your mind.'**
  String rdSetupWeavingDesc(String line);

  /// No description provided for @rdSetupWeavingPreferences.
  ///
  /// In en, this message translates to:
  /// **'your preferences'**
  String get rdSetupWeavingPreferences;

  /// No description provided for @rdSetupWeavingFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 focus area} other{{count} focus areas}}'**
  String rdSetupWeavingFocusAreas(int count);

  /// No description provided for @rdSetupWeavingPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String rdSetupWeavingPeople(int count);

  /// No description provided for @rdSetupWeavingSources.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source} other{{count} sources}}'**
  String rdSetupWeavingSources(int count);

  /// No description provided for @rdSetupWeavingImported.
  ///
  /// In en, this message translates to:
  /// **'{count} imported notes'**
  String rdSetupWeavingImported(String count);

  /// No description provided for @rdSetupReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your second\nmind is ready.'**
  String get rdSetupReadyTitle;

  /// No description provided for @rdSetupReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Everything you capture from here, {name}, has a place to live — and a way back to you.'**
  String rdSetupReadyDesc(String name);

  /// No description provided for @rdSetupReadyYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get rdSetupReadyYou;

  /// No description provided for @rdSetupTakeTour.
  ///
  /// In en, this message translates to:
  /// **'Take a quick tour'**
  String get rdSetupTakeTour;

  /// No description provided for @rdSetupSkipTour.
  ///
  /// In en, this message translates to:
  /// **'Skip the tour'**
  String get rdSetupSkipTour;

  /// No description provided for @rdSetupTour1Title.
  ///
  /// In en, this message translates to:
  /// **'One place to capture'**
  String get rdSetupTour1Title;

  /// No description provided for @rdSetupTour1Body.
  ///
  /// In en, this message translates to:
  /// **'Type, speak, or snap a photo — everything you save starts right here.'**
  String get rdSetupTour1Body;

  /// No description provided for @rdSetupTour2Title.
  ///
  /// In en, this message translates to:
  /// **'Everything lands here'**
  String get rdSetupTour2Title;

  /// No description provided for @rdSetupTour2Body.
  ///
  /// In en, this message translates to:
  /// **'Each capture joins your timeline, already linked to what it relates to.'**
  String get rdSetupTour2Body;

  /// No description provided for @rdSetupTour3Title.
  ///
  /// In en, this message translates to:
  /// **'Capture from anywhere'**
  String get rdSetupTour3Title;

  /// No description provided for @rdSetupTour3Body.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic any time — even mid-conversation — to save a thought in a breath.'**
  String get rdSetupTour3Body;

  /// No description provided for @rdSetupTour4Title.
  ///
  /// In en, this message translates to:
  /// **'Move around calmly'**
  String get rdSetupTour4Title;

  /// No description provided for @rdSetupTour4Body.
  ///
  /// In en, this message translates to:
  /// **'Home, Library, Canvas and your Daily Brief all live down here.'**
  String get rdSetupTour4Body;

  /// No description provided for @rdSetupTourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get rdSetupTourSkip;

  /// No description provided for @rdSetupTourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get rdSetupTourNext;

  /// No description provided for @rdSetupTourFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get rdSetupTourFinish;

  /// No description provided for @rdSetupInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Give someone a\ncalmer mind.'**
  String get rdSetupInviteTitle;

  /// No description provided for @rdSetupInviteDesc.
  ///
  /// In en, this message translates to:
  /// **'Mira is better with the people you think alongside. Invite a few — they skip the waitlist, and you both get a month of Plus.'**
  String get rdSetupInviteDesc;

  /// No description provided for @rdSetupInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR INVITE CODE'**
  String get rdSetupInviteCodeLabel;

  /// No description provided for @rdSetupCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get rdSetupCopy;

  /// No description provided for @rdSetupCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get rdSetupCopied;

  /// No description provided for @rdSetupChannelMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get rdSetupChannelMessages;

  /// No description provided for @rdSetupChannelMail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get rdSetupChannelMail;

  /// No description provided for @rdSetupChannelCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get rdSetupChannelCopyLink;

  /// No description provided for @rdSetupShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share your invite'**
  String get rdSetupShareInvite;

  /// No description provided for @rdSetupMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get rdSetupMaybeLater;
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
