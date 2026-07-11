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
}
