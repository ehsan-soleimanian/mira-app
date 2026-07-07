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
