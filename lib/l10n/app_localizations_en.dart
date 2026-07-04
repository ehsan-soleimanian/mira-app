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
  String get captureIntentClarificationPrompt =>
      'Could you clarify - is this a question or something to save?';

  @override
  String get captureIntentThisIsQuestion => 'This is a question';

  @override
  String get captureIntentSaveToMemory => 'Save to memory';

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
