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
