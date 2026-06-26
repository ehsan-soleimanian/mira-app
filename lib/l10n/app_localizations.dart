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

  /// No description provided for @captureEntityEquivalenceDefaultPrompt.
  String get captureEntityEquivalenceDefaultPrompt;

  /// No description provided for @captureEntityEquivalenceSamePerson.
  String get captureEntityEquivalenceSamePerson;

  /// No description provided for @captureEntityEquivalenceDifferentPeople.
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
