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
  String get homeWorkspaceLibrary => 'Library';

  @override
  String get homeWorkspaceCanvas => 'Canvas';

  @override
  String get homeAnswerTitle => 'Mira found this';

  @override
  String get homeAnswerSourceLabel => 'Approved memory';

  @override
  String get homeContinueTitle => 'Keep the conversation going';

  @override
  String get homeContinuePrompt => 'Ask a follow-up or add a correction';

  @override
  String get homeContinueResponseHint =>
      'The next answer will update the card above.';

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
  String get captureApprovalDraftLabel => 'Review before saving';

  @override
  String get captureApprovalReviewTitle => 'Save this memory?';

  @override
  String get captureApprovalSourceLabel => 'Source';

  @override
  String get captureApprovalMemoryLabel => 'Memory draft';

  @override
  String get captureApprovalSavedAsLabel => 'Will be saved as';

  @override
  String get captureApprovalEmptySummary => 'No extracted description yet.';

  @override
  String get captureApprovalMoreContext =>
      'Only the source is clear so far. Add a note below if Mira should remember what this means.';

  @override
  String get captureApprovalSavePrompt =>
      'Here is exactly what Mira will save. Tell me what to change before I add it to memory.';

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
  String get graphEntityPerson => 'Person';

  @override
  String get graphEntityOrganization => 'Company';

  @override
  String get graphEntityProject => 'Project';

  @override
  String get graphEntityPlace => 'Place';

  @override
  String get graphEntityActivity => 'Activity';

  @override
  String get graphEntityTopic => 'Topic';

  @override
  String get graphEntityDocument => 'Document';

  @override
  String get graphEntityAsset => 'Asset';

  @override
  String get graphEntityUnknown => 'Entity';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsRetry => 'Retry';

  @override
  String get settingsLoginAgain => 'Login again';

  @override
  String get settingsSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String settingsLoadHttpError(int code) {
    return 'Could not load settings (HTTP $code).';
  }

  @override
  String get settingsLoadConnectionError =>
      'Could not reach Mira. Check your connection and try again.';

  @override
  String get settingsLoadGenericError =>
      'Could not load settings. Please try again.';

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

  @override
  String get meetingRecorderTitle => 'Record meeting';

  @override
  String get meetingRecorderDefaultTitle => 'Meeting';

  @override
  String get meetingRecorderTitleHint => 'Meeting title';

  @override
  String get meetingRecorderStarting => 'Starting recorder...';

  @override
  String get meetingRecorderRecording => 'Recording';

  @override
  String get meetingRecorderReady => 'Ready to save';

  @override
  String get meetingRecorderInterrupted =>
      'Recording stopped because Mira was interrupted.';

  @override
  String get meetingRecorderInterruptedBody =>
      'The recorded part is still here. Save it, or discard it and start again.';

  @override
  String get meetingRecorderBody =>
      'Mira saves this as a Library item, then transcribes it for search, summaries, decisions, and follow-ups.';

  @override
  String get meetingRecorderStop => 'Stop';

  @override
  String get meetingRecorderCancel => 'Cancel';

  @override
  String get meetingRecorderDiscard => 'Discard';

  @override
  String get meetingRecorderSave => 'Save meeting';

  @override
  String get meetingRecorderSaving => 'Saving meeting...';

  @override
  String get meetingRecorderSaved => 'Meeting saved to Library.';

  @override
  String get meetingRecorderStartFailed =>
      'Could not start recording. Check microphone permission.';

  @override
  String get meetingRecorderSaveFailed =>
      'Could not save this recording. Try again.';

  @override
  String get meetingRecorderNoAudio =>
      'No audio file was created. Paste a transcript or try recording on your phone.';

  @override
  String get meetingRecorderPhoneCallNote =>
      'If a phone call or app switch interrupts recording, Mira keeps the recorded part before the interruption.';

  @override
  String meetingRecorderDurationLabel(String duration) {
    return 'Duration $duration';
  }

  @override
  String get libraryMeetingImportTitle => 'Meetings';

  @override
  String get libraryMeetingImportBody =>
      'Record a live meeting or paste the transcript, decisions, and notes into Library.';

  @override
  String get libraryMeetingPasteAction => 'Paste meeting notes';

  @override
  String get rdNavHome => 'Home';

  @override
  String get rdNavLibrary => 'Library';

  @override
  String get rdNavCanvas => 'Canvas';

  @override
  String get rdNavBrief => 'Brief';

  @override
  String get rdGreetingMorning => 'Good morning';

  @override
  String get rdGreetingAfternoon => 'Good afternoon';

  @override
  String get rdGreetingEvening => 'Good evening';

  @override
  String get rdHomeMemoryReady => 'Your memory is\nquiet and ready';

  @override
  String get rdHomeComposerHint => 'Type or say anything…';

  @override
  String get rdWaitingSectionTitle => 'WAITING FOR THE RIGHT MOMENT';

  @override
  String get rdRecentlyCaptured => 'RECENTLY CAPTURED';

  @override
  String get rdSeeAll => 'See all';

  @override
  String get rdRemindersLink => 'Reminders';

  @override
  String get rdSnoozeUndo => 'Undo';

  @override
  String get rdSnoozeInHour => 'In an hour';

  @override
  String get rdSnoozeEvening => 'This evening';

  @override
  String get rdSnoozeTomorrow => 'Tomorrow';

  @override
  String get rdSnoozeNextWeek => 'Next week';

  @override
  String get rdWhenMomentRight => 'When the moment is right';

  @override
  String rdWhenNextSee(String person) {
    return 'When you next see $person';
  }

  @override
  String get rdListenTitle => 'I\'m listening…';

  @override
  String get rdListenSubtitle => 'Speak naturally — Mira is taking notes';

  @override
  String get rdListenTapToStop => 'TAP TO STOP';

  @override
  String get rdCanvasBoard => 'Board';

  @override
  String get rdCanvasClusters => 'Clusters';

  @override
  String get rdCanvasMap => 'Map';

  @override
  String rdClusterMemories(int count) {
    return '$count memories';
  }

  @override
  String get rdOnboardingWelcome => 'Mira.\nYour second mind.';

  @override
  String get rdOnboardingSignIn => 'Sign in';

  @override
  String get rdOnboardingContinueGoogle => 'Continue with Google';

  @override
  String get rdOnboardingSkip => 'Skip';

  @override
  String get rdOnboardingLater => 'I\'ll do it later';

  @override
  String get rdCaptureEntryTitle => 'Capture a memory';

  @override
  String get rdCaptureEntrySubtitle =>
      'Mira will understand it — you confirm before it\'s kept';

  @override
  String get rdCaptureModeVoice => 'Voice';

  @override
  String get rdCaptureModeVoiceHint => 'Just speak';

  @override
  String get rdCaptureModePhoto => 'Photo';

  @override
  String get rdCaptureModePhotoHint => 'Snap a scene';

  @override
  String get rdCaptureModeScreenshot => 'Screenshot';

  @override
  String get rdCaptureModeScreenshotHint => 'From your library';

  @override
  String get rdCaptureModeLink => 'Link';

  @override
  String get rdCaptureModeLinkHint => 'Paste a URL';

  @override
  String get rdCaptureModeType => 'Type it instead';

  @override
  String get rdVoiceSearchListening => 'LISTENING';

  @override
  String get rdVoiceSearchSearching => 'SEARCHING';

  @override
  String get rdVoiceSearchPrompt => 'Speak your search';

  @override
  String get rdVoiceSearchBusy => 'One moment…';

  @override
  String get rdVoiceSearchCancel => 'Cancel';

  @override
  String get rdVoiceSearchAction => 'Search';

  @override
  String get rdListenTranscribing => 'Transcribing…';

  @override
  String get rdMemoryFlagsAllChecked => 'All checked — thanks';

  @override
  String rdMemoryFlagsUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words Mira wasn\'t sure of',
      one: '1 word Mira wasn\'t sure of',
    );
    return '$_temp0';
  }

  @override
  String get rdMemoryFlagsHint =>
      'Tap a flagged word to jump to it, or edit the transcript directly.';

  @override
  String get rdCanvasSuggestConnect => 'These two look related — connect them?';

  @override
  String get rdCanvasSuggestAction => 'Connect';

  @override
  String get rdPaywallComingSoon =>
      'Plus is coming soon — we\'ll let you know.';

  @override
  String get rdPaywallWelcome => 'Welcome to Mira Plus ✨';

  @override
  String get rdPaywallCancelled => 'Your Plus membership was cancelled.';

  @override
  String get rdPaywallBadge => 'Mira Plus';

  @override
  String get rdPaywallTitle => 'Give your memory\nroom to grow';

  @override
  String get rdPaywallSubtitle =>
      'Everything you capture, held for as long as you need — woven into one calm, connected memory.';

  @override
  String get rdPaywallPrivacyNote =>
      'Plus changes what Mira remembers — never who can see it. Your memory stays private, always.';

  @override
  String get rdPaywallFeatUnlimitedTitle => 'Unlimited memories';

  @override
  String get rdPaywallFeatUnlimitedSub => 'Never hit a cap — Free holds 2,000.';

  @override
  String get rdPaywallFeatGraphTitle => 'The full memory graph';

  @override
  String get rdPaywallFeatGraphSub =>
      'See every connection, not just recent ones.';

  @override
  String get rdPaywallFeatVoiceTitle => 'Longer history & voice';

  @override
  String get rdPaywallFeatVoiceSub =>
      'Keep years of memories and 10-min captures.';

  @override
  String get rdPaywallFeatConnectTitle => 'Connect everything';

  @override
  String get rdPaywallFeatConnectSub => 'All your apps — Free links two.';

  @override
  String get rdPaywallFeatBriefTitle => 'Daily Brief & smart reminders';

  @override
  String get rdPaywallFeatBriefSub =>
      'Mira resurfaces things at the right moment.';

  @override
  String get rdPaywallPlanAnnual => 'Annual';

  @override
  String get rdPaywallPlanMonthly => 'Monthly';

  @override
  String get rdPaywallPlanMonthlyNote => 'billed monthly';

  @override
  String get rdPaywallCtaTrial => 'Try Plus free for 14 days';

  @override
  String get rdPaywallThenAnnual => 'Then \$72/year';

  @override
  String get rdPaywallThenMonthly => 'Then \$8/month';

  @override
  String get rdPaywallRestore => 'Restore purchase';

  @override
  String get rdPaywallTerms => 'Terms';

  @override
  String get rdPaywallPrivacy => 'Privacy';

  @override
  String get rdPaywallTermsToast => 'Terms open in your browser.';

  @override
  String get rdPaywallPrivacyToast => 'Privacy opens in your browser.';

  @override
  String get rdPaywallActiveBadge => 'Mira Plus · Active';

  @override
  String get rdPaywallActiveTitle => 'You have room\nto remember';

  @override
  String get rdPaywallActiveSubtitle =>
      'Thank you for being on Plus. Everything you capture is held in full — no caps, no forgetting.';

  @override
  String get rdPaywallManage => 'Manage subscription';

  @override
  String get rdPaywallCancelNote =>
      'If you ever cancel, nothing is deleted — your memories stay, and captures pause at the Free limit.';

  @override
  String get rdPaywallCancelCta => 'Cancel Plus';

  @override
  String get rdPaywallDemoFree => 'Free';

  @override
  String get rdPaywallDemoPlus => 'Plus member';

  @override
  String get rdCaptureListening => 'Listening…';

  @override
  String get rdCaptureEntryType => 'Type';

  @override
  String get rdCaptureEntryLink => 'Link';

  @override
  String get rdCaptureEntryPhoto => 'Photo';

  @override
  String get rdCaptureTapWhenFinished => 'Tap ✓ when you\'re finished';

  @override
  String get rdCaptureUnderstanding => 'Understanding';

  @override
  String get rdCaptureStepTranscribe => 'Transcribing what you said';

  @override
  String get rdCaptureStepRecognise => 'Recognising type & details';

  @override
  String get rdCaptureStepConnections => 'Finding connections in memory';

  @override
  String get rdCaptureSavedLink => 'Saved link';

  @override
  String get rdCaptureKeptPhoto =>
      'Mira kept your photo and will read the details from it when they\'re needed.';

  @override
  String get rdCaptureKeptScreenshot =>
      'Mira kept your screenshot and will read the details from it when they\'re needed.';

  @override
  String get rdCaptureYourNote => 'Your note';

  @override
  String get rdCaptureConnectMemory => 'Connect to existing memory';

  @override
  String get rdCaptureRelatedMemory => 'Related memory';

  @override
  String get rdCaptureSuggestedActions => 'Suggested actions';

  @override
  String get rdCaptureRemindWeekend => 'Read it later — remind me this weekend';

  @override
  String get rdCaptureRemindLater => 'Remind me about this later';

  @override
  String rdCaptureRemindBefore(String deadline) {
    return 'Remind me before $deadline';
  }

  @override
  String get rdCaptureActionAddTopic => 'Add to a topic';

  @override
  String get rdCaptureActionAddTopicSub => 'Group with related memories';

  @override
  String get rdCaptureActionShare => 'Share it';

  @override
  String get rdCaptureActionShareSub => 'Send to someone who\'d care';

  @override
  String get rdCaptureActionCalendar => 'Add to calendar';

  @override
  String get rdCaptureActionCalendarSub => 'From the details Mira read';

  @override
  String get rdCaptureActionAddPeople => 'Add the people in it';

  @override
  String get rdCaptureActionAddPeopleSub => 'Link the faces Mira sees';

  @override
  String get rdCaptureChangeType => 'Change type';

  @override
  String get rdCaptureFilePrompt => 'How should Mira file this memory?';

  @override
  String get rdCaptureAddDetail => 'Add a detail';

  @override
  String get rdCaptureAddDetailHint => '# tag or detail';

  @override
  String get rdCaptureReadPhoto => 'Mira read your photo';

  @override
  String get rdCaptureReadScreenshot => 'Mira read your screenshot';

  @override
  String get rdCaptureReadPage => 'Mira read the page';

  @override
  String get rdCaptureUnderstood => 'Mira understood this';

  @override
  String get rdCaptureReview => 'Review';

  @override
  String get rdCaptureCancel => 'Cancel';

  @override
  String get rdCaptureDiscard => 'Discard';

  @override
  String get rdCaptureDone => 'Done';

  @override
  String get rdCaptureKeptTitle => 'Kept in memory';

  @override
  String get rdCaptureKeptSafe =>
      'Kept safely. Mira will bring it back at the right time.';

  @override
  String rdCaptureKeptJoined(String details) {
    return 'It\'s $details. Mira will bring it back at the right time.';
  }

  @override
  String get rdCaptureAddToMemory => 'Add to memory';

  @override
  String rdCaptureAddLinking(int count) {
    return 'Add · linking $count';
  }

  @override
  String get rdCaptureDetailsExtracted => 'Details Mira extracted';

  @override
  String get rdCaptureTypeNote => 'Note';

  @override
  String get rdCaptureTypeTask => 'Task';

  @override
  String get rdCaptureTypeEvent => 'Event';

  @override
  String get rdCaptureTypePerson => 'Person';

  @override
  String get rdCaptureTypePlace => 'Place';

  @override
  String get rdCaptureTypeLink => 'Link';

  @override
  String get rdCaptureTypeArticle => 'Article';

  @override
  String get rdCaptureTypeIdea => 'Idea';

  @override
  String get rdCaptureTypeTravel => 'Travel';

  @override
  String get rdCaptureTypeSheetTitle => 'Type a note';

  @override
  String get rdCaptureTypeSheetHint => 'What do you want to remember?';

  @override
  String get rdCaptureLinkSheetTitle => 'Add a link';

  @override
  String get rdCaptureLinkTitleOptional => 'Title (optional)';

  @override
  String get rdCaptureUrlHint => 'https://…';

  @override
  String rdCaptureLinkBadge(String host) {
    return 'Link · $host';
  }

  @override
  String rdCaptureLinkedMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories',
      one: '1 memory',
    );
    return 'linked to $_temp0';
  }

  @override
  String get rdCaptureHasReminder => 'has a reminder';

  @override
  String get rdCapturePhotoFrameHint => 'Frame a poster, page, or place';

  @override
  String get rdCapturePhotoReading => 'Reading this photo…';

  @override
  String get rdCaptureScreenshotReading => 'Reading screenshot…';

  @override
  String get rdCaptureScreenshotPickTitle => 'Pick a screenshot';

  @override
  String get rdCaptureScreenshotPickSub =>
      'Mira reads text and details from your image';

  @override
  String get rdCaptureScreenshotUse => 'Use screenshot';

  @override
  String get rdCaptureLinkSaveTitle => 'Save a link';

  @override
  String get rdCaptureLinkSaveSub =>
      'Paste a URL — Mira reads the page for you';

  @override
  String get rdCaptureLinkReading => 'Reading page…';

  @override
  String get rdCaptureLinkArticleDefault => 'Article from link';

  @override
  String get rdCaptureLinkArticleSub =>
      'Mira will extract the readable text and keep it searchable.';

  @override
  String get rdCaptureContinue => 'Continue';

  @override
  String get rdBriefTitle => 'Daily Brief';

  @override
  String get rdBriefGreetingMorning => 'Good morning';

  @override
  String get rdBriefGreetingAfternoon => 'Good afternoon';

  @override
  String get rdBriefGreetingEvening => 'Good evening';

  @override
  String rdBriefGreeting(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get rdBriefDayEnd =>
      'That\'s your day.\nEverything else is safe in memory.';

  @override
  String get rdBriefNothingNow => 'Nothing needs you right now.';

  @override
  String get rdBriefSnoozedTomorrow => 'Snoozed until tomorrow';

  @override
  String get rdBriefDone => 'Done';

  @override
  String get rdBriefClearedLater => 'Cleared — Mira will ask again later';

  @override
  String get rdBriefUndo => 'Undo';

  @override
  String get rdBriefClearAll => 'Clear all';

  @override
  String get rdBriefSeeAllReminders => 'See all reminders';

  @override
  String get rdBriefSectionWaitingMoment => 'WAITING FOR THE RIGHT MOMENT';

  @override
  String get rdBriefSectionNeedsYou => 'NEEDS YOU';

  @override
  String get rdBriefSectionToday => 'TODAY';

  @override
  String get rdBriefSectionHandled => 'HANDLED QUIETLY';

  @override
  String get rdBriefSectionRecent => 'RECENT';

  @override
  String get rdBriefSectionResurfaced => 'MIRA RESURFACED';

  @override
  String get rdBriefSectionWaitingOnYou => 'WAITING ON YOU';

  @override
  String rdBriefTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String rdBriefReminderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders',
      one: '1 reminder',
    );
    return '$_temp0';
  }

  @override
  String rdBriefEventsCount(int count) {
    return '$count events';
  }

  @override
  String get rdBriefFallbackMemory => 'Memory';

  @override
  String get rdBriefFallbackRecentMemory => 'Recent memory';

  @override
  String get rdBriefFallbackReminder => 'Reminder';

  @override
  String get rdBriefFallbackAReminder => 'A reminder';

  @override
  String get rdBriefFallbackTask => 'Task';

  @override
  String get rdBriefFallbackEvent => 'Event';

  @override
  String get rdBriefFallbackUntitled => 'Untitled memory';

  @override
  String get rdBriefFallbackAMemory => 'A memory';

  @override
  String get rdBriefOverdue => 'Overdue';

  @override
  String get rdBriefOpen => 'Open';

  @override
  String rdBriefDueOn(String when) {
    return 'Due $when';
  }

  @override
  String get rdBriefDueEarlierToday => 'Due earlier today';

  @override
  String get rdBriefDueYesterday => 'Due yesterday';

  @override
  String rdBriefDueDaysAgo(int days) {
    return 'Due $days days ago';
  }

  @override
  String get rdBriefToday => 'Today';

  @override
  String get rdBriefYesterday => 'Yesterday';

  @override
  String get rdBriefTomorrow => 'Tomorrow';

  @override
  String rdBriefHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String rdBriefDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get rdBriefBroughtBack => 'Brought back for you';

  @override
  String get rdBriefSavedToMemory => 'Saved to your memory';

  @override
  String get rdBriefOpenAction => 'Open';

  @override
  String get rdBriefRemindMe => 'Remind me';

  @override
  String get rdBriefReminderSetThursday => 'Reminder set for Thursday';

  @override
  String get rdBriefMarkedDone => 'Marked done';

  @override
  String get rdBriefDismissed => 'Dismissed';

  @override
  String get rdBriefUpdated => 'Updated';

  @override
  String get rdBriefWelcomeBadge => 'WELCOME TO MIRA';

  @override
  String get rdBriefFirstTitle => 'Your Brief fills in\nas you capture';

  @override
  String get rdBriefFirstSubtitle =>
      'Save a thought, task, or link — Mira will surface what matters here each morning.';

  @override
  String get rdBriefFirstStep1Title => 'Speak or type anything';

  @override
  String get rdBriefFirstStep1Sub => 'Mira understands before it\'s kept';

  @override
  String get rdBriefFirstStep2Title => 'Confirm what matters';

  @override
  String get rdBriefFirstStep2Sub => 'You stay in control of memory';

  @override
  String get rdBriefFirstStep3Title => 'See it here tomorrow';

  @override
  String get rdBriefFirstStep3Sub =>
      'Tasks, reminders, and resurfaced memories';

  @override
  String get rdBriefOverdueSummary =>
      'A few things slipped past while you were busy. Nothing\'s lost — I held onto them. Let\'s clear them together, no rush.';

  @override
  String get rdBriefSnooze => 'Snooze';

  @override
  String get rdBriefDoItNow => 'Do it now';

  @override
  String get rdBriefEmptyTitle => 'Nothing needs you today';

  @override
  String get rdBriefEmptyBody =>
      'Your day is open and no memory is waiting on you. I\'ll keep everything safe and speak up the moment something matters.';

  @override
  String get rdBriefMemoriesHeldSafe => 'memories held safe';

  @override
  String get rdBriefRemindersDue => 'reminders due';

  @override
  String get rdBriefCaptureThought => 'Capture a thought';

  @override
  String get rdBriefCaptureSub =>
      'Drop anything on your mind — I\'ll hold it for you.';

  @override
  String get rdOnboardingTagline =>
      'A second mind. For when you don\'t want to forget anything.';

  @override
  String get rdOnboardingSeeHow => 'See how it works';

  @override
  String get rdOnboardingAuthInvalidEmail => 'Enter a valid email address.';

  @override
  String get rdOnboardingAuthCodeFailed => 'Could not send a code. Try again.';

  @override
  String get rdOnboardingGoogleFailed => 'Google sign-in failed.';

  @override
  String get rdOnboardingAuthTitle => 'Login or sign up';

  @override
  String get rdOnboardingEmailHint => 'Enter your email';

  @override
  String get rdOnboardingContinue => 'Continue';

  @override
  String get rdOnboardingApple => 'Continue with Apple';

  @override
  String get rdOnboardingAppleSoon => 'Apple sign-in is coming soon.';

  @override
  String get rdOnboardingLegal =>
      'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.';

  @override
  String get rdOnboardingInviteRequired =>
      'You need an invite code to join Mira.';

  @override
  String get rdOnboardingInviteHint => 'Enter your invite code';

  @override
  String get rdOnboardingInviteEmpty => 'Enter your invite code.';

  @override
  String get rdOnboardingInviteInvalid => 'That invite code was not accepted.';

  @override
  String get rdOnboardingInviteVerifyFailed =>
      'Could not verify the code. Try again.';

  @override
  String get rdOnboardingOtpRequired => 'Enter the code we emailed you.';

  @override
  String get rdOnboardingOtpMismatch => 'That code did not match. Try again.';

  @override
  String get rdOnboardingOtpResent => 'We sent a new code.';

  @override
  String get rdOnboardingOtpResendFailed => 'Could not resend the code.';

  @override
  String get rdOnboardingCheckEmail => 'Check your email';

  @override
  String get rdOnboardingOtpSent => 'We sent you a 6-digit code';

  @override
  String get rdOnboardingOtpResendPrompt => 'Didn\'t get the code? ';

  @override
  String get rdOnboardingResend => 'Resend';

  @override
  String get rdOnboardingEnter => 'Enter';

  @override
  String get rdOnboardingDetailsTitle => 'Your details';

  @override
  String get rdOnboardingDetailsDesc =>
      'This is how Mira will greet you. You can change it later in Settings.';

  @override
  String get rdOnboardingNameHint => 'Your name';

  @override
  String get rdOnboardingRememberTitle => 'What do you want Mira to remember?';

  @override
  String get rdOnboardingRememberSub =>
      'Anything you don\'t want to forget. An idea. A task. A link. Even a feeling.';

  @override
  String get rdOnboardingRememberHint => 'Press the button and speak or type';

  @override
  String get rdOnboardingNext => 'Next';

  @override
  String get rdOnboardingUnderstoodBrand => 'MIRA understands you';

  @override
  String get rdCommonUndo => 'Undo';

  @override
  String get rdCommonCancel => 'Cancel';

  @override
  String get rdCommonSave => 'Save';

  @override
  String get rdCommonDone => 'Done';

  @override
  String get rdCommonView => 'View';

  @override
  String get rdCommonClear => 'Clear';

  @override
  String get rdCommonAccount => 'Account';

  @override
  String get rdCommonComingSoon => 'Coming soon';

  @override
  String get rdCommonSettings => 'Settings';

  @override
  String get rdCommonConnect => 'Connect';

  @override
  String get rdCommonConnected => 'Connected';

  @override
  String get rdCommonManage => 'Manage';

  @override
  String get rdCommonUpgrade => 'Upgrade';

  @override
  String get rdCommonAm => 'AM';

  @override
  String get rdCommonPm => 'PM';

  @override
  String get rdRootTitleMemory => 'Memory';

  @override
  String get rdRootTitleCapture => 'Capture';

  @override
  String get rdRootTitleNotifications => 'Notifications';

  @override
  String get rdRootTitleConnectedApps => 'Connected apps';

  @override
  String get rdRootTitleListening => 'Listening';

  @override
  String get rdRootTitleChat => 'Chat';

  @override
  String get rdRootTitleSetup => 'Setup';

  @override
  String get rdAskTitle => 'Ask your memory';

  @override
  String get rdAskHint => 'Ask across everything…';

  @override
  String get rdAskSectionTry => 'Try asking';

  @override
  String get rdAskSectionRecent => 'Recent';

  @override
  String get rdAskSearching => 'Searching your memory…';

  @override
  String get rdAskSomethingElse => 'Ask something else';

  @override
  String get rdAskErrorConnection =>
      'I couldn\'t reach your memory just now. Check your connection and try again.';

  @override
  String get rdAskSuggestionRecent => 'What did I save recently?';

  @override
  String get rdAskSuggestionFollowUp => 'What should I follow up on?';

  @override
  String get rdAskSuggestionSummariseWeek => 'Summarise this week';

  @override
  String get rdAskSuggestionFindByTopic => 'Find a note by topic';

  @override
  String rdAskDrawnFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories',
      one: '1 memory',
    );
    return 'Drawn from $_temp0';
  }

  @override
  String get rdCollectionAddTitle => 'Add to collection';

  @override
  String get rdCollectionNew => 'New collection';

  @override
  String get rdCollectionNameHint => 'Collection name';

  @override
  String get rdLibraryYourMemory => 'YOUR MEMORY';

  @override
  String get rdLibraryTitle => 'Library';

  @override
  String rdLibraryKeptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories, all held safe',
      one: '1 memory, all held safe',
    );
    return '$_temp0';
  }

  @override
  String get rdLibrarySearchHint => 'Search your memory…';

  @override
  String get rdLibraryFilterAll => 'All';

  @override
  String get rdLibraryFilterNotes => 'Notes';

  @override
  String get rdLibraryFilterVoice => 'Voice';

  @override
  String get rdLibraryFilterPhotos => 'Photos';

  @override
  String get rdLibraryFilterLinks => 'Links';

  @override
  String get rdLibraryFilterEvents => 'Events';

  @override
  String get rdLibraryNoMatches => 'No matches';

  @override
  String rdLibrarySearchFor(String query) {
    return ' for \"$query\"';
  }

  @override
  String rdLibrarySearchIn(String name) {
    return ' in $name';
  }

  @override
  String rdLibraryMemoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories',
      one: '1 memory',
    );
    return '$_temp0';
  }

  @override
  String get rdLibraryGroupedForYou => 'MIRA GROUPED FOR YOU';

  @override
  String get rdLibraryNoCollectionsYet => 'No collections yet.';

  @override
  String get rdLibraryCollections => 'Collections';

  @override
  String get rdLibraryArchivedTitle => 'Archived';

  @override
  String get rdLibraryOutOfTheWay => 'Out of the way';

  @override
  String get rdLibraryArchivedEmpty =>
      'Nothing archived.\nArchived memories rest here, out of the way.';

  @override
  String get rdLibraryRestore => 'Restore';

  @override
  String get rdLibraryDayToday => 'Today';

  @override
  String get rdLibraryDayThisWeek => 'This week';

  @override
  String get rdLibraryDayEarlier => 'Earlier';

  @override
  String get rdLibraryEmptyFilter =>
      'Nothing here under this filter.\nEverything you capture will settle in quietly.';

  @override
  String rdLibraryEndMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You\'ve kept $count memories.\nMira holds them so you don\'t have to.',
      one: 'You\'ve kept 1 memory.\nMira holds them so you don\'t have to.',
    );
    return '$_temp0';
  }

  @override
  String get rdLibrarySelectMemories => 'Select memories';

  @override
  String rdLibrarySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get rdLibrarySelectAll => 'Select all';

  @override
  String get rdLibraryDeselectAll => 'Deselect all';

  @override
  String get rdLibraryActionCollection => 'Collection';

  @override
  String get rdLibraryActionBoard => 'Board';

  @override
  String get rdLibraryActionPin => 'Pin';

  @override
  String get rdLibraryActionArchive => 'Archive';

  @override
  String get rdLibraryActionDelete => 'Delete';

  @override
  String get rdLibraryUntitled => 'Untitled';

  @override
  String get rdLibraryTypeVoice => 'Voice';

  @override
  String get rdLibraryTypeLink => 'Link';

  @override
  String get rdLibraryTypePhoto => 'Photo';

  @override
  String get rdLibraryTypeEvent => 'Event';

  @override
  String get rdLibraryTypeNote => 'Note';

  @override
  String get rdLibraryTimeJustNow => 'Just now';

  @override
  String rdLibraryTimeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String rdLibraryTimeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get rdLibraryTimeYesterday => 'Yesterday';

  @override
  String rdLibraryTimeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String rdLibraryTimeDate(int month, int day) {
    return '$month/$day';
  }

  @override
  String rdLibraryAddedToCollection(int count, String name) {
    return 'Added $count to \"$name\"';
  }

  @override
  String get rdLibraryAddToCollectionFailed =>
      'Couldn\'t add to collection. Check your connection.';

  @override
  String rdLibraryAddedToBoard(int count, String board) {
    return 'Added $count to \"$board\"';
  }

  @override
  String get rdLibraryAddToBoardFailed =>
      'Couldn\'t add to board. Check your connection.';

  @override
  String rdLibraryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count memories',
      one: 'Deleted 1 memory',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryArchivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Archived $count memories',
      one: 'Archived 1 memory',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryPinnedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pinned $count memories',
      one: 'Pinned 1 memory',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryRestored(String title) {
    return 'Restored \"$title\"';
  }

  @override
  String rdLibraryCouldntOpenCollection(String name) {
    return 'Couldn\'t open \"$name\".';
  }

  @override
  String get rdLibraryAddToBoard => 'Add to board';

  @override
  String get rdLibraryUntitledBoard => 'Untitled board';

  @override
  String rdLibraryCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get rdLibraryNewBoard => 'New board';

  @override
  String get rdLibraryBoardNameHint => 'Board name';

  @override
  String get rdLibraryFallbackBoard => 'board';

  @override
  String get rdMemoryConnectedMemory => 'Connected memory';

  @override
  String get rdMemoryLinked => 'Linked';

  @override
  String rdMemoryInsightLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'linked it to $count related memories',
      one: 'linked it to 1 related memory',
    );
    return '$_temp0';
  }

  @override
  String rdMemoryInsightConnected(String names) {
    return 'connected $names';
  }

  @override
  String rdMemoryInsightTagged(String tags) {
    return 'tagged it $tags';
  }

  @override
  String rdMemoryInsightSummary(String details) {
    return 'I read through this and $details so it stays easy to find.';
  }

  @override
  String get rdMemoryPinned => 'Pinned';

  @override
  String get rdMemoryUnpinned => 'Unpinned';

  @override
  String rdMemoryVoiceNoteBadge(String duration) {
    return 'Voice note · $duration';
  }

  @override
  String get rdMemoryEditedJustNow => 'Edited just now · today, 4:12 PM';

  @override
  String get rdMemoryRecordedAgo => 'Recorded 2h ago · today, 4:12 PM';

  @override
  String get rdMemoryCapturedAgo => 'Captured 2h ago · today, 4:12 PM';

  @override
  String get rdMemoryEditTranscriptHint =>
      'Editing the transcript — Mira will re-read it and refresh connections when you save.';

  @override
  String get rdMemoryEditNoteHint =>
      'Editing note — Mira will re-read it and refresh connections when you save.';

  @override
  String get rdMemoryTitleHint => 'Title';

  @override
  String get rdMemoryTranscriptHint => 'Transcript…';

  @override
  String get rdMemoryWriteNoteHint => 'Write your note…';

  @override
  String get rdMemoryTranscribedByMira => 'TRANSCRIBED BY MIRA';

  @override
  String get rdMemoryMiraNoticed => 'Mira noticed';

  @override
  String get rdMemoryReminder => 'Reminder';

  @override
  String get rdMemoryReminderOnBrief => 'On — tracked in your Brief';

  @override
  String get rdMemoryReminderOnBringUp => 'On — Mira will bring this up';

  @override
  String get rdMemoryReminderOff => 'Off — tap to remind me';

  @override
  String get rdMemoryConnectedMemories => 'Connected memories';

  @override
  String get rdMemorySeeInCanvas => 'See in Canvas';

  @override
  String get rdMemoryPeopleAndTags => 'People & entities';

  @override
  String get rdMemorySourceVoice => 'Recorded on Home · iPhone · not shared';

  @override
  String get rdMemorySourceNote => 'Typed on Home · iPhone · not shared';

  @override
  String get rdMemorySaveChanges => 'Save changes';

  @override
  String get rdMemoryAskMiraAboutThis => 'Ask Mira about this';

  @override
  String get rdMemoryPinToTop => 'Pin to top';

  @override
  String get rdMemoryUnpin => 'Unpin';

  @override
  String get rdMemoryEditNote => 'Edit note';

  @override
  String get rdMemoryShareMemory => 'Share memory';

  @override
  String get rdMemorySavedTranscript => 'Saved — Mira re-read your transcript';

  @override
  String get rdMemorySavedNote => 'Saved — Mira re-read this note';

  @override
  String rdMemoryAddedToCollection(String name) {
    return 'Added to “$name”';
  }

  @override
  String get rdMemoryLinkCopied => 'Link copied';

  @override
  String get rdMemoryCopyLink => 'Copy link';

  @override
  String get rdMemoryCopyAsText => 'Copy as text';

  @override
  String get rdMemoryEmail => 'Email';

  @override
  String get rdMemoryMessage => 'Message';

  @override
  String get rdMemoryCopiedToClipboard => 'Copied to clipboard';

  @override
  String get rdMemoryNoAppAvailable => 'No app available for that';

  @override
  String rdMemoryDeleteConfirmBody(String title, int connections) {
    String _temp0 = intl.Intl.pluralLogic(
      connections,
      locale: localeName,
      other: '$connections connections',
      one: '1 connection',
    );
    return '“$title” and its $_temp0 will be removed from your Library. This can\'t be undone.';
  }

  @override
  String get rdMemoryKeepIt => 'Keep it';

  @override
  String get rdChatOpening =>
      'Ask me anything about your memories — what you saved, what to follow up on, or I can draft something for you.';

  @override
  String rdChatOpeningAnchored(String title) {
    return 'This one\'s about “$title.” Ask me anything about it — what\'s open, how it connects, or I can draft something for you.';
  }

  @override
  String get rdChatStarterDraftReminder => 'Draft a reminder';

  @override
  String get rdChatStarterHowConnect => 'How does this connect?';

  @override
  String get rdChatStarterSummarise => 'Summarise this';

  @override
  String get rdChatFollowUpDefault => 'Follow up on this';

  @override
  String get rdChatEmptyAnswer =>
      'I looked, but I don\'t have anything on that yet — capture it and I\'ll connect it here.';

  @override
  String get rdChatOfflineFallback =>
      'I couldn\'t reach your memory just now. Try again in a moment.';

  @override
  String get rdChatTitle => 'Ask Mira';

  @override
  String rdChatAboutTitle(String title) {
    return 'About “$title”';
  }

  @override
  String get rdChatGroundedInMemories => 'Grounded in your memories';

  @override
  String get rdChatFromYourMemories => 'FROM YOUR MEMORIES';

  @override
  String get rdChatReminderAdded => 'Reminder added';

  @override
  String get rdChatSetReminder => 'Set this reminder';

  @override
  String get rdChatComposeHint => 'Ask about your memories…';

  @override
  String get rdChatCiteVoiceSub => 'Voice · read by Mira';

  @override
  String get rdChatCitePhotoSub => 'Photo · read by Mira';

  @override
  String get rdAccountTitle => 'Account';

  @override
  String get rdAccountPlaceholderName => 'Your account';

  @override
  String get rdAccountSignedOut => 'Signed out';

  @override
  String get rdAccountSectionProfile => 'Profile';

  @override
  String get rdAccountName => 'Name';

  @override
  String get rdAccountEmail => 'Email';

  @override
  String get rdAccountPhone => 'Phone';

  @override
  String get rdAccountSectionSecurity => 'Security';

  @override
  String get rdAccountFaceIdTitle => 'Face ID unlock';

  @override
  String get rdAccountFaceIdSub => 'Require Face ID to open Mira';

  @override
  String get rdAccountAutoLockTitle => 'Auto-lock';

  @override
  String get rdAccountAutoLockSub => 'Lock after 5 minutes idle';

  @override
  String get rdAccountChangePassword => 'Change password';

  @override
  String get rdAccountSectionPlan => 'Plan';

  @override
  String get rdAccountMiraPlus => 'Mira Plus';

  @override
  String get rdAccountMiraFree => 'Mira Free';

  @override
  String get rdAccountPlusActiveSub => 'Active · \$8 / month';

  @override
  String rdAccountFreeUsageSub(int used, int limit) {
    return '$used of $limit memories used';
  }

  @override
  String get rdAccountSectionPreferences => 'Preferences';

  @override
  String get rdAccountNotificationsTitle => 'Notifications';

  @override
  String get rdAccountNotificationsSub => 'Brief, reminders & quiet hours';

  @override
  String get rdAccountRemindersTitle => 'Reminders';

  @override
  String get rdAccountRemindersSub => 'Everything Mira is holding for you';

  @override
  String get rdAccountAppearanceTitle => 'Appearance';

  @override
  String get rdAccountAppearanceSub => 'Theme, accent, text size & motion';

  @override
  String get rdAccountConnectedAppsTitle => 'Connected apps';

  @override
  String get rdAccountConnectedAppsSub => 'Calendar, Notes, Photos & more';

  @override
  String get rdAccountSectionMemoryData => 'Memory & data';

  @override
  String get rdAccountExportData => 'Export my data';

  @override
  String get rdAccountExportDataSub => 'Download everything Mira holds';

  @override
  String get rdAccountMemoryHistory => 'Memory history';

  @override
  String get rdAccountMemoryHistorySub => 'See what was captured & when';

  @override
  String get rdAccountSignOut => 'Sign out';

  @override
  String get rdAccountDeleteAccount => 'Delete account';

  @override
  String get rdAccountFootVersion => 'Mira · Version 1.0';

  @override
  String get rdAccountAllMemoriesSynced => 'All memories synced';

  @override
  String rdAccountStorageHeadline(int count) {
    return '$count memories';
  }

  @override
  String rdAccountStorageSubline(int limit) {
    return 'of $limit · plenty of room';
  }

  @override
  String get rdNotificationsTitle => 'Notifications';

  @override
  String get rdNotificationsIntro =>
      'Mira stays quiet by default — and only speaks up when it truly helps.';

  @override
  String get rdNotificationsSectionDailyBrief => 'Daily Brief';

  @override
  String get rdNotificationsMorningBrief => 'Morning brief';

  @override
  String get rdNotificationsMorningBriefSub =>
      'A calm summary to start the day';

  @override
  String get rdNotificationsBriefTime => 'Brief time';

  @override
  String get rdNotificationsResurfaceMemory => 'Resurface a memory';

  @override
  String get rdNotificationsResurfaceMemorySub =>
      'Occasionally revisit something worth holding';

  @override
  String get rdNotificationsSectionReminders => 'Reminders';

  @override
  String get rdNotificationsTimeSensitive => 'Time-sensitive reminders';

  @override
  String get rdNotificationsTimeSensitiveSub =>
      'Dates, tickets, and things that expire';

  @override
  String get rdNotificationsGentleNudges => 'Gentle nudges';

  @override
  String get rdNotificationsGentleNudgesSub =>
      'Soft prompts for unfinished threads';

  @override
  String get rdNotificationsSectionCaptures => 'Captures';

  @override
  String get rdNotificationsConfirmBeforeSaving => 'Confirm before saving';

  @override
  String get rdNotificationsConfirmBeforeSavingSub =>
      'Ask before adding a capture to your graph';

  @override
  String get rdNotificationsWeeklyRecap => 'Weekly recap';

  @override
  String get rdNotificationsWeeklyRecapSub => 'A Sunday look back at the week';

  @override
  String get rdNotificationsSectionQuietHours => 'Quiet hours';

  @override
  String get rdNotificationsQuietHours => 'Quiet hours';

  @override
  String get rdNotificationsQuietHoursSub =>
      'Hold all notifications while you rest';

  @override
  String get rdNotificationsSchedule => 'Schedule';

  @override
  String get rdNotificationsQuietStartHelp => 'Quiet hours start';

  @override
  String get rdNotificationsQuietEndHelp => 'Quiet hours end';

  @override
  String get rdNotificationsSectionDelivery => 'Delivery';

  @override
  String get rdNotificationsSound => 'Sound';

  @override
  String get rdNotificationsHaptics => 'Haptics';

  @override
  String get rdNotificationsFoot => 'Mira notifies you gently, or not at all.';

  @override
  String get rdConnectedAppsTitle => 'Connected apps';

  @override
  String get rdConnectedAppsIntro =>
      'Mira quietly weaves these sources into your memory — nothing leaves without your say.';

  @override
  String get rdConnectedAppsSectionConnected => 'Connected';

  @override
  String get rdConnectedAppsCalendar => 'Calendar';

  @override
  String get rdConnectedAppsCalendarSub => 'Synced 2m ago · feeds your Brief';

  @override
  String get rdConnectedAppsNotes => 'Notes';

  @override
  String get rdConnectedAppsNotesSub => 'Synced 1h ago · 128 notes';

  @override
  String get rdConnectedAppsPhotos => 'Photos';

  @override
  String get rdConnectedAppsPhotosSub => 'Synced today · screenshots & scans';

  @override
  String get rdConnectedAppsSectionAvailable => 'Available';

  @override
  String get rdConnectedAppsGmail => 'Gmail';

  @override
  String get rdConnectedAppsGmailSub => 'Turn important mail into memories';

  @override
  String get rdConnectedAppsSafari => 'Safari';

  @override
  String get rdConnectedAppsSafariSub =>
      'Save pages & highlights as you browse';

  @override
  String get rdConnectedAppsReadwise => 'Readwise';

  @override
  String get rdConnectedAppsReadwiseSub => 'Import book & article highlights';

  @override
  String get rdConnectedAppsVoiceMemos => 'Voice Memos';

  @override
  String get rdConnectedAppsVoiceMemosSub =>
      'Transcribe recordings into your graph';

  @override
  String get rdConnectedAppsPrivacy =>
      'Mira only reads what you connect, and processes it privately. Disconnect anytime.';

  @override
  String rdConnectedAppsFoot(int count) {
    return '$count sources available to connect';
  }

  @override
  String get rdAppearanceTitle => 'Appearance';

  @override
  String get rdAppearanceIntro =>
      'Make Mira feel like yours — colour, contrast and calm.';

  @override
  String get rdAppearanceSectionTheme => 'Theme';

  @override
  String get rdAppearanceThemeSystem => 'System';

  @override
  String get rdAppearanceThemeLight => 'Light';

  @override
  String get rdAppearanceThemeDark => 'Dark';

  @override
  String get rdAppearanceDarkModeHint =>
      'Dark mode is on — tuned for calm, low-light reading.';

  @override
  String get rdAppearanceSectionAccent => 'Accent color';

  @override
  String get rdAppearanceAccentPeriwinkle => 'Periwinkle';

  @override
  String get rdAppearanceAccentSage => 'Sage';

  @override
  String get rdAppearanceAccentClay => 'Clay';

  @override
  String get rdAppearanceAccentPlum => 'Plum';

  @override
  String get rdAppearanceAccentCustom => 'Custom';

  @override
  String get rdAppearanceSectionTextSize => 'Text size';

  @override
  String get rdAppearanceTextSmall => 'Small';

  @override
  String get rdAppearanceTextDefault => 'Default';

  @override
  String get rdAppearanceTextLarge => 'Large';

  @override
  String get rdAppearancePreviewText =>
      'Mira keeps your memories clear and readable.';

  @override
  String get rdAppearanceReduceMotion => 'Reduce motion';

  @override
  String get rdAppearanceReduceMotionSub =>
      'Calmer transitions and less movement';

  @override
  String get rdAppearanceSectionAppIcon => 'App icon';

  @override
  String get rdAppearanceIconDefault => 'Default';

  @override
  String get rdAppearanceIconSage => 'Sage';

  @override
  String get rdAppearanceIconDusk => 'Dusk';

  @override
  String get rdAppearanceFoot => 'Appearance changes apply instantly.';

  @override
  String get rdStorageTitle => 'Storage';

  @override
  String get rdStorageIntro =>
      'What Mira is holding, and how much room is left.';

  @override
  String get rdStorageUpdating => 'Updating usage…';

  @override
  String get rdStorageSectionBreakdown => 'Breakdown';

  @override
  String get rdStorageSectionManage => 'Manage';

  @override
  String get rdStorageClearArchived => 'Clear archived';

  @override
  String get rdStorageClearArchivedSub => 'Remove captures you have archived';

  @override
  String get rdStorageOffloadCloud => 'Offload originals to cloud';

  @override
  String get rdStorageOffloadCloudSub =>
      'Keep full-quality copies in a connected service';

  @override
  String get rdStorageFoot => 'Mira keeps only what you approve.';

  @override
  String get rdStorageCategoryPhotos => 'Photos';

  @override
  String get rdStorageCategoryVoice => 'Voice';

  @override
  String get rdStorageCategoryScreenshots => 'Screenshots';

  @override
  String get rdStorageCategoryNotes => 'Notes';

  @override
  String get rdStorageCategoryLinks => 'Links';

  @override
  String get rdStorageCategoryOther => 'Other';

  @override
  String get rdStorageEmpty => 'Empty';

  @override
  String rdStorageItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String rdStorageOfQuota(String quota) {
    return 'of $quota';
  }

  @override
  String get rdStorageNoArchived => 'No archived items to clear';

  @override
  String rdStorageCleared(int count, String freed) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archived items',
      one: '1 archived item',
    );
    return 'Cleared $_temp0$freed';
  }

  @override
  String rdStorageFreedSuffix(String amount) {
    return ' · $amount freed';
  }

  @override
  String get rdStorageClearFailed => 'Couldn\'t clear archived items';

  @override
  String get rdRemindersTitle => 'Reminders';

  @override
  String get rdRemindersSubtitleEmpty => 'Nothing waiting on you';

  @override
  String get rdRemindersSubtitleOne => '1 thing Mira is holding for you';

  @override
  String rdRemindersSubtitleMany(int count) {
    return '$count things Mira is holding for you';
  }

  @override
  String get rdRemindersSectionOverdue => 'Overdue';

  @override
  String get rdRemindersSectionToday => 'Today';

  @override
  String get rdRemindersSectionUpcoming => 'Upcoming';

  @override
  String get rdRemindersSectionWaiting => 'When the moment\'s right';

  @override
  String get rdRemindersSectionDone => 'Done';

  @override
  String get rdRemindersEmptyTitle => 'No reminders yet';

  @override
  String get rdRemindersEmptyBody =>
      'Ask Mira to remind you about something,\nand it will settle in here.';

  @override
  String get rdRemindersMarkedDone => 'Marked done';

  @override
  String get rdRemindersBackOnList => 'Back on your list';

  @override
  String get rdRemindersSnoozedTomorrow => 'Snoozed until tomorrow';

  @override
  String get rdRemindersDeleted => 'Reminder deleted';

  @override
  String get rdRemindersSet => 'Reminder set';

  @override
  String get rdRemindersUntitled => 'Untitled reminder';

  @override
  String get rdRemindersFromMemory => 'From a memory';

  @override
  String get rdRemindersDone => 'Done';

  @override
  String get rdRemindersSnooze => 'Snooze';

  @override
  String get rdRemindersOverdue => 'Overdue';

  @override
  String rdRemindersOverdueByHours(int hours) {
    return 'Overdue by ${hours}h';
  }

  @override
  String get rdRemindersOverdueSinceYesterday => 'Overdue since yesterday';

  @override
  String rdRemindersOverdueByDays(int days) {
    return 'Overdue by ${days}d';
  }

  @override
  String get rdRemindersNow => 'Now';

  @override
  String rdRemindersInMinutes(int minutes) {
    return 'In ${minutes}m';
  }

  @override
  String rdRemindersInHours(int hours) {
    return 'In ${hours}h';
  }

  @override
  String get rdRemindersTomorrow => 'Tomorrow';

  @override
  String rdRemindersInDays(int days) {
    return 'In ${days}d';
  }

  @override
  String get rdRemindersComposeTitle => 'New reminder';

  @override
  String get rdRemindersComposeHint => 'Remind me to…';

  @override
  String get rdRemindersWhenLabel => 'WHEN';

  @override
  String get rdRemindersLaterToday => 'Later today';

  @override
  String get rdRemindersThisEvening => 'This evening';

  @override
  String get rdRemindersNextWeek => 'Next week';

  @override
  String get rdRemindersPickDateTime => 'Pick date & time';

  @override
  String get rdRemindersSetReminder => 'Set reminder';

  @override
  String get rdRemindersTranscribing => 'Transcribing…';

  @override
  String get rdHomeRecentsEmpty => 'Your recent memories will appear here.';

  @override
  String get rdHomeRemindAgain => 'Remind again…';

  @override
  String rdHomeSnoozed(String label) {
    return 'Snoozed · $label';
  }

  @override
  String get rdHomeLaterToday => 'Later today';

  @override
  String rdHomeInDays(int days) {
    return 'In $days days';
  }

  @override
  String get rdHomeKindNote => 'Note';

  @override
  String get rdHomeKindVoice => 'Voice';

  @override
  String rdHomeLinksCount(int count) {
    return '$count links';
  }

  @override
  String rdCanvasMapContext(int memories, int connections) {
    return 'Your memory · $memories memories · $connections connections';
  }

  @override
  String rdCanvasClusterContext(int clusters, int memories) {
    return '$clusters clusters · $memories memories';
  }

  @override
  String get rdCanvasMergeSuccess => 'Memories merged';

  @override
  String get rdCanvasMergeFail => 'Couldn\'t merge those';

  @override
  String get rdCanvasUnlinkSuccess => 'Connection removed';

  @override
  String get rdCanvasUnlinkFail => 'Couldn\'t remove that connection';

  @override
  String get rdCanvasMyBoard => 'My board';

  @override
  String get rdCanvasNewBoard => 'New board';

  @override
  String get rdCanvasBoardDefault => 'Board';

  @override
  String rdCanvasBoardLabel(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$name · $_temp0';
  }

  @override
  String get rdCanvasRenameTitle => 'Rename board';

  @override
  String get rdCanvasBoardNameHint => 'Board name';

  @override
  String get rdCanvasLoading => 'Loading…';

  @override
  String get rdCanvasBoardsHeader => 'BOARDS';

  @override
  String get rdCanvasUntitledBoard => 'Untitled board';

  @override
  String rdCanvasCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String rdCanvasLinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'memories',
      one: 'memory',
    );
    return '$count linked $_temp0.';
  }

  @override
  String get rdCanvasNodePerson => 'Person';

  @override
  String get rdCanvasNodeTask => 'Task';

  @override
  String get rdCanvasNodeEvent => 'Event';

  @override
  String get rdCanvasNodeNote => 'Note';

  @override
  String get rdCanvasNodeBook => 'Book';

  @override
  String get rdCanvasNodeIdea => 'Idea';

  @override
  String get rdCanvasNodeTopic => 'Topic';

  @override
  String get rdCanvasNodeOrganization => 'Company';

  @override
  String get rdCanvasNodeProject => 'Project';

  @override
  String get rdCanvasNodePlace => 'Place';

  @override
  String get rdCanvasClusterTasks => 'Tasks';

  @override
  String get rdCanvasClusterBooks => 'Books & ideas';

  @override
  String get rdCanvasClusterEvents => 'Events';

  @override
  String get rdCanvasClusterNotes => 'Notes & memories';

  @override
  String get rdCanvasNoClusters => 'No clusters yet';

  @override
  String get rdCanvasGraphEmpty => 'Your memory graph is empty';

  @override
  String rdCanvasFocusedOn(String label) {
    return 'Focused on $label';
  }

  @override
  String get rdCanvasTapExplore => 'Tap a memory · drag to explore';

  @override
  String rdCanvasMergeInto(String label) {
    return 'Merge into \"$label\"';
  }

  @override
  String get rdCanvasMergePickDuplicate =>
      'Pick the duplicate to fold in — it keeps every connection.';

  @override
  String get rdCanvasFocusConstellation => 'Focus this constellation';

  @override
  String get rdCanvasMergeDuplicate => 'Merge a duplicate';

  @override
  String rdCanvasConnectedTo(int count) {
    return 'CONNECTED TO $count';
  }

  @override
  String get rdCanvasCardRemoved => 'Card removed';

  @override
  String get rdCanvasNewNoteTitle => 'New note';

  @override
  String get rdCanvasNewNoteSub => 'Tap to edit later.';

  @override
  String get rdCanvasEditCard => 'Edit card';

  @override
  String get rdCanvasEditTitle => 'Title';

  @override
  String get rdCanvasEditNoteOptional => 'Note (optional)';

  @override
  String get rdCanvasBoardEmpty => 'This board is empty';

  @override
  String get rdCanvasConnectTapSecond => 'Now tap another card to connect them';

  @override
  String get rdCanvasConnectMode => 'Connect mode · tap two cards to link them';

  @override
  String get rdCanvasAddMode => 'Add mode · tap anywhere to drop a card';

  @override
  String rdCanvasEdgeWithPerson(String person) {
    return 'with $person';
  }

  @override
  String get rdCanvasEdgeReminder => 'reminder';

  @override
  String get rdCanvasEdgeToRead => 'to read';

  @override
  String get rdCanvasEdgeRelated => 'related';

  @override
  String get rdPaywallPlanSaveBadge => '2 months free';

  @override
  String get rdPaywallPlanPerMonth => '/mo';

  @override
  String get rdPaywallPlanAnnualNote => '\$72 billed yearly';

  @override
  String rdPaywallFinePrint(String then) {
    return '$then · cancel anytime.\nNo charge today — we\'ll remind you before it ends.';
  }

  @override
  String get rdPaywallMemPlan => 'Plan';

  @override
  String get rdPaywallMemPlanValue => 'Annual · \$6/mo';

  @override
  String get rdPaywallMemRenews => 'Renews';

  @override
  String get rdPaywallMemRenewsValue => 'Aug 12, 2025';

  @override
  String get rdPaywallMemPayment => 'Payment';

  @override
  String get rdPaywallMemPaymentValue => 'Apple ID';

  @override
  String get rdPaywallMemoriesHeld => 'Memories held';

  @override
  String rdPaywallMemoriesCount(String count) {
    return '$count · unlimited';
  }

  @override
  String get rdPaywallMemoriesGrowth =>
      'Growing calmly. On Free this would have stopped at 2,000.';

  @override
  String get rdPaywallPerksLabel => 'YOUR PLUS PERKS';

  @override
  String get rdPaywallPerkUnlimited => 'Unlimited memories';

  @override
  String get rdPaywallPerkGraph => 'Full memory graph';

  @override
  String get rdPaywallPerkVoice => 'Longer history & 10-min voice';

  @override
  String get rdPaywallPerkConnect => 'Unlimited connected apps';

  @override
  String get rdSetupSkip => 'Skip';

  @override
  String get rdSetupContinue => 'Continue';

  @override
  String get rdSetupPickFew => 'Pick a few';

  @override
  String get rdSetupWelcomeTitle => 'Let\'s set up\nyour second mind.';

  @override
  String get rdSetupWelcomeDesc =>
      'A few quick questions so Mira remembers the way you do. About two minutes — and you can change any of it later.';

  @override
  String get rdSetupBeginSetup => 'Begin setup';

  @override
  String get rdSetupSkipForNow => 'Skip for now';

  @override
  String get rdSetupAddressTitle => 'What should Mira\ncall you?';

  @override
  String get rdSetupAddressDesc =>
      'This is how your Brief and reminders will greet you.';

  @override
  String get rdSetupNameHint => 'Your name';

  @override
  String get rdSetupToneLabel => 'And how should it speak?';

  @override
  String get rdSetupToneCalm => 'Calm';

  @override
  String get rdSetupToneCalmSub => 'Gentle, unhurried';

  @override
  String get rdSetupToneConcise => 'Concise';

  @override
  String get rdSetupToneConciseSub => 'Short and clear';

  @override
  String get rdSetupToneWarm => 'Warm';

  @override
  String get rdSetupToneWarmSub => 'Friendly, personal';

  @override
  String get rdSetupFocusTitle => 'What matters\nto you?';

  @override
  String get rdSetupFocusDesc =>
      'Mira will cluster your memories around these. Choose any that fit.';

  @override
  String get rdSetupFocusWork => 'Work & projects';

  @override
  String get rdSetupFocusIdeas => 'Ideas & sparks';

  @override
  String get rdSetupFocusPeople => 'People';

  @override
  String get rdSetupFocusReading => 'Reading & links';

  @override
  String get rdSetupFocusHealth => 'Health';

  @override
  String get rdSetupFocusMoney => 'Money';

  @override
  String get rdSetupFocusTravel => 'Travel & places';

  @override
  String get rdSetupFocusLearning => 'Learning';

  @override
  String get rdSetupPeopleTitle => 'Who\'s important\nto you?';

  @override
  String get rdSetupPeopleDesc =>
      'Mira links what you capture to the people in your life. Add a few — first names are enough.';

  @override
  String get rdSetupPeopleHint => 'Add a name';

  @override
  String get rdSetupPeopleEmpty =>
      'No one yet — Mira will still learn as you capture.';

  @override
  String get rdSetupRhythmTitle => 'When should your\nBrief arrive?';

  @override
  String get rdSetupRhythmDesc =>
      'A calm once-a-day summary of what needs you — nothing more.';

  @override
  String get rdSetupRhythmMorning => 'Morning';

  @override
  String get rdSetupRhythmMidday => 'Midday';

  @override
  String get rdSetupRhythmEvening => 'Evening';

  @override
  String get rdSetupQuietHours => 'Quiet hours';

  @override
  String get rdSetupQuietHoursSub => 'No nudges 22:00 – 07:00';

  @override
  String get rdSetupPrivacyTitle => 'Your memory\nstays yours.';

  @override
  String get rdSetupPrivacyDesc =>
      'Before you connect anything, here\'s the promise Mira is built on.';

  @override
  String get rdSetupPrivacyProcessed => 'Processed privately';

  @override
  String get rdSetupPrivacyProcessedSub =>
      'Your captures are analysed on-device whenever possible.';

  @override
  String get rdSetupPrivacyEncrypted => 'Encrypted end-to-end';

  @override
  String get rdSetupPrivacyEncryptedSub =>
      'Only you can read your memories — not even Mira can.';

  @override
  String get rdSetupPrivacyNeverSold => 'Never sold, ever';

  @override
  String get rdSetupPrivacyNeverSoldSub =>
      'We don\'t sell or share your data. No ads, no exceptions.';

  @override
  String get rdSetupChoicesLabel => 'Your choices';

  @override
  String get rdSetupSyncDevices => 'Sync across my devices';

  @override
  String get rdSetupSyncDevicesSub =>
      'Encrypted backup so your memory follows you.';

  @override
  String get rdSetupHelpImprove => 'Help improve Mira';

  @override
  String get rdSetupHelpImproveSub =>
      'Share anonymous, aggregated usage — never your content.';

  @override
  String get rdSetupSourcesTitle => 'Connect\nyour world.';

  @override
  String get rdSetupSourcesDesc =>
      'Give Mira a head start. It only reads what you connect, and processes it privately.';

  @override
  String get rdSetupSourceCalendar => 'Calendar';

  @override
  String get rdSetupSourceCalendarSub => 'Meetings feed your Brief';

  @override
  String get rdSetupSourceNotes => 'Notes';

  @override
  String get rdSetupSourceNotesSub => 'Your written thoughts';

  @override
  String get rdSetupSourcePhotos => 'Photos';

  @override
  String get rdSetupSourcePhotosSub => 'Screenshots & scans';

  @override
  String get rdSetupSourceGmail => 'Gmail';

  @override
  String get rdSetupSourceGmailSub => 'Important mail';

  @override
  String get rdSetupImportTitle => 'Bring your\nnotes with you.';

  @override
  String get rdSetupImportDesc =>
      'Already keep notes elsewhere? Import them once and Mira will weave them into your graph. Nothing is deleted from the original app.';

  @override
  String rdSetupImportNotesFound(String count) {
    return '~$count notes found';
  }

  @override
  String get rdSetupImportLater => 'You can also import later from Settings.';

  @override
  String get rdSetupImportBackground =>
      'Mira will import in the background — you can start using it right away.';

  @override
  String rdSetupImportCta(String count) {
    return 'Import $count notes';
  }

  @override
  String get rdSetupPermissionsTitle => 'Let Mira\nhelp quietly.';

  @override
  String get rdSetupPermissionsDesc =>
      'Two permissions, both optional. Turn off anything, anytime.';

  @override
  String get rdSetupMicTitle => 'Microphone';

  @override
  String get rdSetupMicSub => 'So you can speak a memory anytime';

  @override
  String get rdSetupNotifTitle => 'Notifications';

  @override
  String get rdSetupNotifSub => 'Only your Brief and reminders you set';

  @override
  String get rdSetupWeavingTitle => 'Weaving your\nmemory…';

  @override
  String rdSetupWeavingDesc(String line) {
    return 'Mira is arranging $line into the shape of your mind.';
  }

  @override
  String get rdSetupWeavingPreferences => 'your preferences';

  @override
  String rdSetupWeavingFocusAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focus areas',
      one: '1 focus area',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingImported(String count) {
    return '$count imported notes';
  }

  @override
  String get rdSetupReadyTitle => 'Your second\nmind is ready.';

  @override
  String rdSetupReadyDesc(String name) {
    return 'Everything you capture from here, $name, has a place to live — and a way back to you.';
  }

  @override
  String get rdSetupReadyYou => 'you';

  @override
  String get rdSetupTakeTour => 'Take a quick tour';

  @override
  String get rdSetupSkipTour => 'Skip the tour';

  @override
  String get rdSetupTour1Title => 'One place to capture';

  @override
  String get rdSetupTour1Body =>
      'Type, speak, or snap a photo — everything you save starts right here.';

  @override
  String get rdSetupTour2Title => 'Everything lands here';

  @override
  String get rdSetupTour2Body =>
      'Each capture joins your timeline, already linked to what it relates to.';

  @override
  String get rdSetupTour3Title => 'Capture from anywhere';

  @override
  String get rdSetupTour3Body =>
      'Tap the mic any time — even mid-conversation — to save a thought in a breath.';

  @override
  String get rdSetupTour4Title => 'Move around calmly';

  @override
  String get rdSetupTour4Body =>
      'Home, Library, Canvas and your Daily Brief all live down here.';

  @override
  String get rdSetupTourSkip => 'Skip tour';

  @override
  String get rdSetupTourNext => 'Next';

  @override
  String get rdSetupTourFinish => 'Finish';

  @override
  String get rdSetupInviteTitle => 'Give someone a\ncalmer mind.';

  @override
  String get rdSetupInviteDesc =>
      'Mira is better with the people you think alongside. Invite a few — they skip the waitlist, and you both get a month of Plus.';

  @override
  String get rdSetupInviteCodeLabel => 'YOUR INVITE CODE';

  @override
  String get rdSetupCopy => 'Copy';

  @override
  String get rdSetupCopied => 'Copied';

  @override
  String get rdSetupChannelMessages => 'Messages';

  @override
  String get rdSetupChannelMail => 'Mail';

  @override
  String get rdSetupChannelCopyLink => 'Copy link';

  @override
  String get rdSetupShareInvite => 'Share your invite';

  @override
  String get rdSetupMaybeLater => 'Maybe later';
}
