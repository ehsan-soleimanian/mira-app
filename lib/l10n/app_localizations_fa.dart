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

  @override
  String get appUpdateTitle => 'نسخه جدید آماده است';

  @override
  String appUpdateBody(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  ) {
    return 'نسخه فعلی شما $currentVersion است. میرا $latestVersion (بیلد $latestBuild) برای نصب آماده است.';
  }

  @override
  String appUpdateVersionLabel(
    String currentVersion,
    String latestVersion,
    int latestBuild,
  ) {
    return 'نسخه $currentVersion → $latestVersion (بیلد $latestBuild)';
  }

  @override
  String appUpdateProgress(int percent) {
    return '$percent٪ دانلود شد';
  }

  @override
  String appUpdateProgressIndeterminate(String downloaded) {
    return '$downloaded دانلود شد';
  }

  @override
  String get appUpdateInstalling => 'در حال باز کردن نصب‌کننده…';

  @override
  String get appUpdateInstallStarted => 'مراحل نصب را روی گوشی تأیید کنید.';

  @override
  String get appUpdateSignatureMismatch =>
      'امضای این نسخه با اپ قبلی روی گوشی یکی نیست. اول میرا را حذف کنید، بعد دوباره دانلود و نصب کنید.';

  @override
  String get appUpdateInstallFailed =>
      'نصب شروع نشد. دوباره تلاش کنید یا اپ قبلی را حذف کنید.';

  @override
  String get appUpdateRetry => 'دوباره تلاش کن';

  @override
  String get appUpdateOpenSettings => 'رفتن به تنظیمات برای حذف اپ';

  @override
  String get appUpdateClose => 'بستن';

  @override
  String get appUpdateDownload => 'دانلود نسخه جدید';

  @override
  String get appUpdateLater => 'بعداً';

  @override
  String get appUpdateDownloadFailed =>
      'دانلود ناموفق بود. اتصال اینترنت را بررسی کنید.';
}
