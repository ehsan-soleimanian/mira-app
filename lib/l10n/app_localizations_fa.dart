// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'میرا';

  @override
  String get captureIntentClarificationPrompt =>
      'لطفا مشخص کنید: این یک سوال است یا باید به حافظه ذخیره شود؟';

  @override
  String get captureIntentThisIsQuestion => 'این یک سوال است';

  @override
  String get captureIntentSaveToMemory => 'به حافظه ذخیره کن';

  @override
  String get captureEntityEquivalenceDefaultPrompt =>
      'آیا این‌ها در حافظه‌ات یک نفر هستند؟';

  @override
  String get captureEntityEquivalenceSamePerson => 'بله، یک نفرند';

  @override
  String get captureEntityEquivalenceDifferentPeople => 'نه، متفاوت‌اند';

  @override
  String get graphMarkDone => 'انجام شد';

  @override
  String get graphCancelTask => 'لغو کار';

  @override
  String get graphEditMemory => 'ویرایش خاطره';

  @override
  String get graphDeleteMemory => 'حذف خاطره';

  @override
  String get graphDeleteConfirmTitle => 'این خاطره حذف شود؟';

  @override
  String get graphDeleteConfirmBody =>
      'این capture از گراف حذف می‌شود. افراد مرتبط اگر جای دیگر استفاده شده باشند می‌مانند.';

  @override
  String get graphSave => 'ذخیره';

  @override
  String get graphCorrectMemoryHint =>
      'متن جدیدی که می‌خواهید میرا به خاطر بسپارد';

  @override
  String get graphMutationSuccess => 'به‌روزرسانی شد';

  @override
  String get graphMutationFailed => 'به‌روزرسانی نشد. دوباره تلاش کنید.';

  @override
  String get graphRejectAssertion => 'رد این ادعا';
}
