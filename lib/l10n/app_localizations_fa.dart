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
  String get homeGreeting => 'حافظه دوم تو آماده است';

  @override
  String get homeSubtitle =>
      'فکر، صدا، عکس، اسکرین‌شات یا یادآوری را بده. میرا آن را به گراف حافظه‌ات وصل می‌کند.';

  @override
  String get homeProcessingTitle => 'میرا دارد این را می‌فهمد';

  @override
  String get homeProcessingSubtitle =>
      'در حال استخراج معنا، کارها و ارتباط‌های گراف.';

  @override
  String get homeQuickCaptureTitle => 'هر چیزی را ثبت کن';

  @override
  String get homeQuickCapturePrompt => 'یک خاطره، سوال یا یادآوری بنویس';

  @override
  String get homeAskStarterLabel => 'بپرس';

  @override
  String get homeAskStarterPrompt => 'درباره‌ی ';

  @override
  String get homeSaveStarterLabel => 'به یاد بسپار';

  @override
  String get homeSaveStarterPrompt => 'به یاد بسپار که ';

  @override
  String get homeReminderStarterLabel => 'یادآور';

  @override
  String get homeReminderStarterPrompt => 'یادم بنداز که ';

  @override
  String get homeTextActionTitle => 'متن';

  @override
  String get homeTextActionSubtitle => 'بنویس یا بپرس';

  @override
  String get homeVoiceActionTitle => 'صدا';

  @override
  String get homeVoiceActionSubtitle => 'طبیعی حرف بزن';

  @override
  String get homePhotoActionTitle => 'عکس';

  @override
  String get homePhotoActionSubtitle => 'از دوربین تا گراف';

  @override
  String get homeScreenshotActionTitle => 'اسکرین‌شات';

  @override
  String get homeScreenshotActionSubtitle => 'سریع وارد کن';

  @override
  String get homeReminderActionTitle => 'یادآوری';

  @override
  String get homeReminderActionSubtitle => 'زمانش را بگو';

  @override
  String get homeGraphActionTitle => 'گراف';

  @override
  String get homeGraphActionSubtitle => 'ارتباط‌ها را ببین';

  @override
  String get homeRemindersTitle => 'یادآوری‌ها';

  @override
  String get homeRemindersEmptyTitle => 'هنوز یادآوری بازی نداری';

  @override
  String get homeRemindersEmptyBody =>
      'به میرا بگو چه کاری باید انجام بدهی؛ بعد از تایید اینجا دیده می‌شود.';

  @override
  String get homeOpenDailyBrief => 'Daily Brief';

  @override
  String get homeMemoryGraphTitle => 'گراف حافظه';

  @override
  String get homeMemoryGraphBody =>
      'ورودی‌های تاییدشده به entity، assertion و task تبدیل می‌شوند و در گراف وصل می‌شوند.';

  @override
  String get homeOpenGraph => 'باز کردن گراف';

  @override
  String get sharedImportAppBarTitle => 'ارسال به میرا';

  @override
  String get sharedImportImageTitle => 'وارد کردن اسکرین‌شات یا عکس';

  @override
  String get sharedImportTextTitle => 'وارد کردن متن ارسال‌شده';

  @override
  String get sharedImportImageBody =>
      'میرا این تصویر را می‌خواند، معنا را استخراج می‌کند و به گراف حافظه‌ات وصل می‌کند.';

  @override
  String get sharedImportTextBody =>
      'میرا این متن را به خاطره، سوال، کار یا یادآوری تبدیل می‌کند.';

  @override
  String get sharedImportImageHint => 'یادداشت اختیاری برای میرا';

  @override
  String get sharedImportTextHint => 'قبل از وارد کردن ویرایش کن';

  @override
  String get sharedImportSave => 'ذخیره در حافظه';

  @override
  String get sharedImportImporting => 'در حال وارد کردن...';

  @override
  String get sharedImportImportingStatus => 'در حال وارد کردن به میرا...';

  @override
  String get sharedImportReadingStatus =>
      'میرا دارد محتوای ارسال‌شده را می‌خواند...';

  @override
  String get sharedImportAnswerReceived => 'پاسخ دریافت شد';

  @override
  String get sharedImportFailed => 'وارد کردن ناموفق بود.';

  @override
  String get sharedImportOversize => 'این فایل بزرگ‌تر از ۱۰ مگابایت است.';

  @override
  String get sharedImportFallbackFileName => 'تصویر ارسال‌شده';

  @override
  String get sharedImportGraphTitle => 'خاطره ارسال‌شده اضافه شد';

  @override
  String get sharedImportGraphSubtitle =>
      'میرا این import را به گراف حافظه‌ات وصل کرد.';

  @override
  String get captureIntentClarificationPrompt =>
      'لطفا مشخص کنید: این یک سوال است یا باید به حافظه ذخیره شود؟';

  @override
  String get captureIntentThisIsQuestion => 'این یک سوال است';

  @override
  String get captureIntentSaveToMemory => 'به حافظه ذخیره کن';

  @override
  String get captureWorkflowComposeTitle =>
      'بپرس، به یاد بسپار، یا برنامه بساز';

  @override
  String get captureWorkflowComposeSubtitle =>
      'میرا می‌تواند از گراف حافظه جواب بدهد، یک خاطره را ذخیره کند، یا فکر تو را به کار تبدیل کند.';

  @override
  String get captureWorkflowComposeHint =>
      'طبیعی بنویس. اگر بین سوال و خاطره مردد باشد، از تو می‌پرسد.';

  @override
  String get captureApprovalDraftLabel => 'برداشت میرا';

  @override
  String get captureApprovalSavePrompt =>
      'این پیش‌نویس حافظه را ساختم. قبل از ذخیره، چیزی را تغییر بدهم؟';

  @override
  String get captureApprovalSavedPrompt =>
      'در حافظه ذخیره شد. اگر چیزی نیاز به تغییر دارد، ادامه بده.';

  @override
  String get captureApprovalCorrectionHint => 'اصلاح کن یا درباره همین بپرس';

  @override
  String get captureApprovalSaveAction => 'ذخیره در حافظه';

  @override
  String get captureApprovalDismissAction => 'رد کردن';

  @override
  String get captureApprovalUpdatingStatus => 'در حال به‌روزرسانی پیش‌نویس...';

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
  String get connectorsTitle => 'کانکتورها';

  @override
  String get connectorsSubtitle =>
      'کار، فایل‌ها، پیام‌ها، خواندنی‌ها و طراحی‌هایت را وارد حافظه میرا کن.';

  @override
  String get connectorsAvailableMetric => 'آماده';

  @override
  String get connectorsConnectedMetric => 'وصل';

  @override
  String get connectorsNativeMetric => 'بومی';

  @override
  String get connectorsNativeGroup => 'همگام‌سازی بومی';

  @override
  String get connectorsAdapterGroup => 'ورود دستی محتوا';

  @override
  String get connectorsLoadFailed => 'کانکتورها بارگذاری نشدند';

  @override
  String get connectorsPullToRetry => 'برای تلاش دوباره صفحه را به پایین بکش.';

  @override
  String get connectorsAllFilter => 'همه';

  @override
  String get connectorsConnectAction => 'وصل';

  @override
  String get connectorsSyncAction => 'همگام';

  @override
  String get connectorsHowToUseAction => 'روش استفاده';

  @override
  String get connectorsConnectedStatus => 'وصل';

  @override
  String get connectorsNativeStatus => 'بومی';

  @override
  String get connectorsAdapterReadyStatus => 'آماده';

  @override
  String get connectorsManualImportStatus => 'دستی';

  @override
  String get connectorsDefaultDescription =>
      'برای همگام‌سازی پلاگین میرا آماده است.';

  @override
  String get connectorsManualImportSubtitle =>
      'محتوا را وارد یا share کن؛ بعد در کتابخانه جست‌وجو و سوال کن.';

  @override
  String get connectorsWhatsappSubtitle =>
      'چت را export کن یا پیام‌ها را به میرا share کن؛ OAuth مستقیم چت شخصی وجود ندارد.';

  @override
  String get connectorsWhatsappUsageBody =>
      'واتساپ چت‌های شخصی را با OAuth معمولی در اختیار اپ‌ها نمی‌گذارد. در v1 مسیر درست میرا، ورود دستی است تا چت به حافظه قابل جست‌وجو تبدیل شود.';

  @override
  String get connectorsWhatsappStepExport =>
      'در واتساپ، چت را باز کن و Export chat را بزن؛ برای ورود سریع‌تر without media را انتخاب کن.';

  @override
  String get connectorsWhatsappStepShare =>
      'فایل .txt خروجی را به میرا share کن یا از Library آپلود کن.';

  @override
  String get connectorsWhatsappStepUse =>
      'میرا transcript را به عنوان آیتم Library ذخیره می‌کند؛ بعد می‌توانی جست‌وجو کنی یا از Assistant بپرسی.';

  @override
  String connectorsAdapterUsageBody(String name) {
    return '$name آماده‌ی adapter است. فعلا محتوا را دستی import/share کن؛ sync مستقیم provider بعدا از همین manifest فعال می‌شود.';
  }

  @override
  String get connectorsAdapterStepImport =>
      'فایل، export، لینک یا متن share‌شده را از provider وارد میرا کن.';

  @override
  String get connectorsAdapterStepLibrary =>
      'محتوا با source مشخص در Library دیده می‌شود.';

  @override
  String get connectorsAdapterStepAsk =>
      'بعد از Library search، Assistant، Canvas یا Graph از همان محتوا استفاده کن.';

  @override
  String get connectorsAdapterNote =>
      'Adapter-ready یعنی مسیر سمت میرا آماده است؛ نه اینکه میرا همین حالا خودکار داخل آن اپ را بخواند.';

  @override
  String connectorsSyncSuccess(String name) {
    return '$name وارد کتابخانه شد.';
  }

  @override
  String connectorsSyncFailed(String name) {
    return 'همگام‌سازی $name انجام نشد. دوباره تلاش کن.';
  }

  @override
  String connectorsLastSync(String time) {
    return 'آخرین همگام‌سازی $time';
  }

  @override
  String get canvasTitle => 'بوم';

  @override
  String get canvasDefaultTitle => 'بوم میرا';

  @override
  String get canvasStarterSticky => 'ایده اصلی را بچین';

  @override
  String get canvasStarterText =>
      'یادداشت، فایل و لینک‌های کتابخانه را کنار فکرهایت قرار بده.';

  @override
  String get canvasStarterShape => 'خوشه';

  @override
  String get canvasNewSticky => 'یادداشت جدید';

  @override
  String get canvasNewText => 'اینجا بنویس';

  @override
  String get canvasNewShape => 'گروه';

  @override
  String get canvasLoadFailed => 'بوم بارگذاری نشد';

  @override
  String get canvasSaveFailed => 'بوم ذخیره نشد. دوباره تلاش کن.';

  @override
  String get canvasLibraryEmpty => 'کتابخانه‌ات خالی است.';

  @override
  String get canvasRetry => 'تلاش دوباره';

  @override
  String get canvasNewBoard => 'بوم جدید';

  @override
  String get canvasOpenGraph => 'باز کردن گراف';

  @override
  String get canvasSaving => 'در حال ذخیره...';

  @override
  String get canvasUnsaved => 'تغییرات ذخیره‌نشده';

  @override
  String get canvasSaved => 'ذخیره شد';

  @override
  String get canvasToolSticky => 'استیکی';

  @override
  String get canvasToolText => 'متن';

  @override
  String get canvasToolLibrary => 'کتابخانه';

  @override
  String get canvasToolShape => 'شکل';

  @override
  String get canvasToolArrow => 'فلش';

  @override
  String get canvasToolSave => 'ذخیره';

  @override
  String get canvasEditNode => 'ویرایش آیتم';

  @override
  String get canvasNodeTextHint => 'روی بوم بنویس';

  @override
  String get canvasDeleteNode => 'حذف';

  @override
  String get canvasApply => 'اعمال';

  @override
  String get canvasLibraryPickerTitle => 'افزودن از کتابخانه';

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
