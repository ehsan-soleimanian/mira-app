// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mira';

  @override
  String get homeGreeting => 'Your second memory is ready';

  @override
  String get homeSubtitle =>
      'Drop a thought, voice, photo, screenshot or reminder. Mira will connect it to your graph.';

  @override
  String get homeProcessingTitle => 'Mira is understanding this';

  @override
  String get homeProcessingSubtitle =>
      'Extracting meaning, tasks and graph links.';

  @override
  String get homeQuickCaptureTitle => 'Capture anything';

  @override
  String get homeQuickCapturePrompt => 'Type a memory, question or reminder';

  @override
  String get homeAskStarterLabel => 'Ask';

  @override
  String get homeAskStarterPrompt => 'What do I know about ';

  @override
  String get homeSaveStarterLabel => 'Remember';

  @override
  String get homeSaveStarterPrompt => 'Remember that ';

  @override
  String get homeReminderStarterLabel => 'Remind';

  @override
  String get homeReminderStarterPrompt => 'Remind me to ';

  @override
  String get homeTextActionTitle => 'Text';

  @override
  String get homeTextActionSubtitle => 'Write or ask';

  @override
  String get homeVoiceActionTitle => 'Voice';

  @override
  String get homeVoiceActionSubtitle => 'Speak naturally';

  @override
  String get homePhotoActionTitle => 'Photo';

  @override
  String get homePhotoActionSubtitle => 'Camera to graph';

  @override
  String get homeScreenshotActionTitle => 'Screenshot';

  @override
  String get homeScreenshotActionSubtitle => 'Import fast';

  @override
  String get homeReminderActionTitle => 'Reminder';

  @override
  String get homeReminderActionSubtitle => 'Say the time';

  @override
  String get homeGraphActionTitle => 'Graph';

  @override
  String get homeGraphActionSubtitle => 'See links';

  @override
  String get homeRemindersTitle => 'Reminders';

  @override
  String get homeRemindersEmptyTitle => 'No open reminders yet';

  @override
  String get homeRemindersEmptyBody =>
      'Tell Mira what you need to do and it will appear here after approval.';

  @override
  String get homeOpenDailyBrief => 'Daily Brief';

  @override
  String get homeMemoryGraphTitle => 'Memory graph';

  @override
  String get homeMemoryGraphBody =>
      'Approved captures become entities, assertions and tasks connected in your graph.';

  @override
  String get homeOpenGraph => 'Open graph';

  @override
  String get sharedImportAppBarTitle => 'Share to Mira';

  @override
  String get sharedImportImageTitle => 'Import screenshot or image';

  @override
  String get sharedImportTextTitle => 'Import shared text';

  @override
  String get sharedImportImageBody =>
      'Mira will read this, extract meaning, and connect it to your memory graph.';

  @override
  String get sharedImportTextBody =>
      'Mira will turn this into a memory, question, task, or reminder.';

  @override
  String get sharedImportImageHint => 'Optional note for Mira';

  @override
  String get sharedImportTextHint => 'Edit before importing';

  @override
  String get sharedImportSave => 'Save to memory';

  @override
  String get sharedImportImporting => 'Importing...';

  @override
  String get sharedImportImportingStatus => 'Importing into Mira...';

  @override
  String get sharedImportReadingStatus =>
      'Mira is reading the shared content...';

  @override
  String get sharedImportAnswerReceived => 'Answer received';

  @override
  String get sharedImportFailed => 'Import failed.';

  @override
  String get sharedImportOversize => 'This file is larger than 10 MB.';

  @override
  String get sharedImportFallbackFileName => 'Shared image';

  @override
  String get sharedImportGraphTitle => 'Shared memory added';

  @override
  String get sharedImportGraphSubtitle =>
      'Mira connected the import to your graph.';

  @override
  String get captureIntentClarificationPrompt =>
      'Could you clarify - is this a question or something to save?';

  @override
  String get captureIntentThisIsQuestion => 'This is a question';

  @override
  String get captureIntentSaveToMemory => 'Save to memory';

  @override
  String get captureWorkflowComposeTitle => 'Ask, remember, or make a plan';

  @override
  String get captureWorkflowComposeSubtitle =>
      'Mira can answer from your graph, save a memory, or turn a thought into a task.';

  @override
  String get captureWorkflowComposeHint =>
      'Type naturally. Mira will ask if it needs to choose question vs memory.';

  @override
  String get captureApprovalDraftLabel => 'Mira understood';

  @override
  String get captureApprovalSavePrompt =>
      'I drafted this memory. Want me to adjust anything before I save it?';

  @override
  String get captureApprovalSavedPrompt =>
      'Saved to memory. Keep chatting if something needs changing.';

  @override
  String get captureApprovalCorrectionHint => 'Correct or ask about this';

  @override
  String get captureApprovalSaveAction => 'Save memory';

  @override
  String get captureApprovalDismissAction => 'Discard';

  @override
  String get captureApprovalUpdatingStatus => 'Updating the draft...';

  @override
  String get captureEntityEquivalenceDefaultPrompt =>
      'Are these the same person in your memory?';

  @override
  String get captureEntityEquivalenceSamePerson => 'Yes, same person';

  @override
  String get captureEntityEquivalenceDifferentPeople => 'No, different people';

  @override
  String get graphMarkDone => 'Mark done';

  @override
  String get graphCancelTask => 'Cancel task';

  @override
  String get graphEditMemory => 'Edit memory';

  @override
  String get graphDeleteMemory => 'Delete memory';

  @override
  String get graphDeleteConfirmTitle => 'Delete this memory?';

  @override
  String get graphDeleteConfirmBody =>
      'This removes the capture from your graph. Related people stay if used elsewhere.';

  @override
  String get graphSave => 'Save';

  @override
  String get graphCorrectMemoryHint => 'Update what you want Mira to remember';

  @override
  String get graphMutationSuccess => 'Updated';

  @override
  String get graphMutationFailed => 'Could not update. Try again.';

  @override
  String get graphRejectAssertion => 'Reject claim';

  @override
  String get connectorsTitle => 'Connectors';

  @override
  String get connectorsSubtitle =>
      'Bring work, files, messages, reading, and design context into Mira.';

  @override
  String get connectorsAvailableMetric => 'available';

  @override
  String get connectorsConnectedMetric => 'connected';

  @override
  String get connectorsNativeMetric => 'native';

  @override
  String get connectorsNativeGroup => 'Native sync';

  @override
  String get connectorsAdapterGroup => 'Manual import adapters';

  @override
  String get connectorsLoadFailed => 'Could not load connectors';

  @override
  String get connectorsPullToRetry => 'Pull down to refresh and try again.';

  @override
  String get connectorsAllFilter => 'All';

  @override
  String get connectorsConnectAction => 'Connect';

  @override
  String get connectorsSyncAction => 'Sync';

  @override
  String get connectorsHowToUseAction => 'How to use';

  @override
  String get connectorsConnectedStatus => 'Connected';

  @override
  String get connectorsNativeStatus => 'Native';

  @override
  String get connectorsAdapterReadyStatus => 'Adapter';

  @override
  String get connectorsManualImportStatus => 'Manual';

  @override
  String get connectorsDefaultDescription => 'Ready for Mira plugin sync.';

  @override
  String get connectorsManualImportSubtitle =>
      'Import or share content into Mira, then search and ask from Library.';

  @override
  String get connectorsWhatsappSubtitle =>
      'Export a chat or share messages into Mira; direct personal-chat OAuth is not available.';

  @override
  String get connectorsWhatsappUsageBody =>
      'WhatsApp does not expose personal chats through a normal OAuth connector. In v1, Mira uses manual import so the chat becomes searchable memory.';

  @override
  String get connectorsWhatsappStepExport =>
      'In WhatsApp, open a chat, choose Export chat, and export without media for the fastest import.';

  @override
  String get connectorsWhatsappStepShare =>
      'Share the exported .txt file to Mira or upload it from Library.';

  @override
  String get connectorsWhatsappStepUse =>
      'Mira stores the transcript as a Library item, extracts text, and then you can search or ask questions across it.';

  @override
  String connectorsAdapterUsageBody(String name) {
    return '$name is adapter-ready. Use manual import/share first; provider OAuth sync can be enabled later from the same manifest.';
  }

  @override
  String get connectorsAdapterStepImport =>
      'Import a file, export, link, or shared text from the provider into Mira.';

  @override
  String get connectorsAdapterStepLibrary =>
      'The imported content appears in Library with source provenance.';

  @override
  String get connectorsAdapterStepAsk =>
      'Use Library search, Assistant, Canvas, or Graph to work with the imported context.';

  @override
  String get connectorsAdapterNote =>
      'Connecting an adapter does not mean Mira can read that app automatically yet; it means the manifest and Mira-side workflow are ready.';

  @override
  String connectorsSyncSuccess(String name) {
    return '$name synced into your library.';
  }

  @override
  String connectorsSyncFailed(String name) {
    return '$name could not sync. Try again.';
  }

  @override
  String connectorsLastSync(String time) {
    return 'Last sync $time';
  }

  @override
  String get canvasTitle => 'Canvas';

  @override
  String get canvasDefaultTitle => 'Mira canvas';

  @override
  String get canvasStarterSticky => 'Map the main idea';

  @override
  String get canvasStarterText =>
      'Pin notes, files, and links from Library beside your own thoughts.';

  @override
  String get canvasStarterShape => 'Cluster';

  @override
  String get canvasNewSticky => 'New sticky';

  @override
  String get canvasNewText => 'Write here';

  @override
  String get canvasNewShape => 'Group';

  @override
  String get canvasLoadFailed => 'Could not load canvas';

  @override
  String get canvasSaveFailed => 'Canvas could not save. Try again.';

  @override
  String get canvasLibraryEmpty => 'Your Library is empty.';

  @override
  String get canvasRetry => 'Retry';

  @override
  String get canvasNewBoard => 'New board';

  @override
  String get canvasOpenGraph => 'Open graph';

  @override
  String get canvasSaving => 'Saving...';

  @override
  String get canvasUnsaved => 'Unsaved changes';

  @override
  String get canvasSaved => 'Saved';

  @override
  String get canvasToolSticky => 'Sticky';

  @override
  String get canvasToolText => 'Text';

  @override
  String get canvasToolLibrary => 'Library';

  @override
  String get canvasToolShape => 'Shape';

  @override
  String get canvasToolArrow => 'Arrow';

  @override
  String get canvasToolSave => 'Save';

  @override
  String get canvasEditNode => 'Edit item';

  @override
  String get canvasNodeTextHint => 'Write on the canvas';

  @override
  String get canvasDeleteNode => 'Delete';

  @override
  String get canvasApply => 'Apply';

  @override
  String get canvasLibraryPickerTitle => 'Add from Library';

  @override
  String get appUpdateTitle => 'Update available';

  @override
  String appUpdateBody(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  ) {
    return 'You are on $currentVersion. Mira $latestVersion (build $latestBuild) is ready to install.';
  }

  @override
  String appUpdateVersionLabel(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  ) {
    return 'v$currentVersion → v$latestVersion (build $latestBuild)';
  }

  @override
  String appUpdateProgress(int percent) {
    return '$percent% downloaded';
  }

  @override
  String appUpdateProgressIndeterminate(String downloaded) {
    return '$downloaded downloaded';
  }

  @override
  String get appUpdateInstalling => 'Opening installer…';

  @override
  String get appUpdateInstallStarted =>
      'Follow the system prompts to finish installing.';

  @override
  String get appUpdateSignatureMismatch =>
      'This build was signed differently than the app on your phone. Uninstall Mira first, then download and install again.';

  @override
  String get appUpdateInstallFailed =>
      'Could not start installation. Try again or uninstall the old app first.';

  @override
  String get appUpdateRetry => 'Try again';

  @override
  String get appUpdateOpenSettings => 'Open app settings to uninstall';

  @override
  String get appUpdateClose => 'Close';

  @override
  String get appUpdateDownload => 'Download update';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appUpdateDownloadFailed =>
      'Download failed. Check your connection and try again.';
}
