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
  String get appUpdateDownload => 'Download update';

  @override
  String get appUpdateLater => 'Later';

  @override
  String get appUpdateDownloadFailed =>
      'Download failed. Opening browser instead.';
}
