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
  String get homeWorkspaceLibrary => 'کتابخانه';

  @override
  String get homeWorkspaceCanvas => 'بوم';

  @override
  String get homeAnswerTitle => 'میرا این را پیدا کرد';

  @override
  String get homeAnswerSourceLabel => 'حافظه تاییدشده';

  @override
  String get homeContinueTitle => 'گفتگو را ادامه بده';

  @override
  String get homeContinuePrompt => 'سؤال بعدی را بپرس یا چیزی را اصلاح کن';

  @override
  String get homeContinueResponseHint =>
      'پاسخ سؤال بعدی در کارت بالایی به‌روزرسانی می‌شود.';

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
  String get captureApprovalDraftLabel => 'قبل از ذخیره بررسی کن';

  @override
  String get captureApprovalReviewTitle => 'این در حافظه ذخیره شود؟';

  @override
  String get captureApprovalSourceLabel => 'ورودی';

  @override
  String get captureApprovalMemoryLabel => 'پیش‌نویس حافظه';

  @override
  String get captureApprovalSavedAsLabel => 'نوع ذخیره‌سازی';

  @override
  String get captureApprovalEmptySummary => 'هنوز توضیح استخراج‌شده‌ای ندارد.';

  @override
  String get captureApprovalMoreContext =>
      'فعلا فقط منبع واضح است. اگر می‌خواهی میرا معنای این ورودی را هم به یاد بسپارد، پایین صفحه یک توضیح اضافه کن.';

  @override
  String get captureApprovalSavePrompt =>
      'این دقیقا چیزی است که میرا ذخیره می‌کند. اگر چیزی کم است، قبل از ذخیره اصلاحش کن.';

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
  String get graphEntityPerson => 'شخص';

  @override
  String get graphEntityOrganization => 'شرکت';

  @override
  String get graphEntityProject => 'پروژه';

  @override
  String get graphEntityPlace => 'مکان';

  @override
  String get graphEntityActivity => 'فعالیت';

  @override
  String get graphEntityTopic => 'موضوع';

  @override
  String get graphEntityDocument => 'سند';

  @override
  String get graphEntityAsset => 'دارایی';

  @override
  String get graphEntityUnknown => 'موجودیت';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsRetry => 'دوباره تلاش کن';

  @override
  String get settingsLoginAgain => 'ورود دوباره';

  @override
  String get settingsSessionExpired =>
      'نشست شما منقضی شده است. لطفا دوباره وارد شوید.';

  @override
  String settingsLoadHttpError(int code) {
    return 'تنظیمات بارگذاری نشد (HTTP $code).';
  }

  @override
  String get settingsLoadConnectionError =>
      'اتصال به میرا برقرار نشد. اینترنت را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get settingsLoadGenericError =>
      'تنظیمات بارگذاری نشد. لطفا دوباره تلاش کنید.';

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

  @override
  String get meetingRecorderTitle => 'ضبط جلسه';

  @override
  String get meetingRecorderDefaultTitle => 'جلسه';

  @override
  String get meetingRecorderTitleHint => 'نام جلسه';

  @override
  String get meetingRecorderStarting => 'در حال آماده‌سازی ضبط...';

  @override
  String get meetingRecorderRecording => 'در حال ضبط';

  @override
  String get meetingRecorderReady => 'آماده ذخیره';

  @override
  String get meetingRecorderInterrupted => 'ضبط به خاطر وقفه متوقف شد.';

  @override
  String get meetingRecorderInterruptedBody =>
      'بخش ضبط‌شده هنوز اینجاست. می‌توانید آن را ذخیره کنید یا حذف کنید و دوباره شروع کنید.';

  @override
  String get meetingRecorderBody =>
      'میرا این را به عنوان یک آیتم کتابخانه ذخیره می‌کند و بعد برای جست‌وجو، خلاصه، تصمیم‌ها و پیگیری‌ها متن‌سازی می‌کند.';

  @override
  String get meetingRecorderStop => 'توقف';

  @override
  String get meetingRecorderCancel => 'لغو';

  @override
  String get meetingRecorderDiscard => 'حذف';

  @override
  String get meetingRecorderSave => 'ذخیره جلسه';

  @override
  String get meetingRecorderSaving => 'در حال ذخیره جلسه...';

  @override
  String get meetingRecorderSaved => 'جلسه در کتابخانه ذخیره شد.';

  @override
  String get meetingRecorderStartFailed =>
      'ضبط شروع نشد. دسترسی میکروفون را بررسی کنید.';

  @override
  String get meetingRecorderSaveFailed =>
      'این ضبط ذخیره نشد. دوباره تلاش کنید.';

  @override
  String get meetingRecorderNoAudio =>
      'فایل صوتی ساخته نشد. متن جلسه را وارد کنید یا روی گوشی دوباره ضبط کنید.';

  @override
  String get meetingRecorderPhoneCallNote =>
      'اگر تماس تلفنی یا جابه‌جایی اپ ضبط را قطع کند، میرا بخش ضبط‌شده تا قبل از وقفه را نگه می‌دارد.';

  @override
  String meetingRecorderDurationLabel(String duration) {
    return 'مدت $duration';
  }

  @override
  String get libraryMeetingImportTitle => 'جلسه‌ها';

  @override
  String get libraryMeetingImportBody =>
      'جلسه را زنده ضبط کنید یا متن، تصمیم‌ها و یادداشت‌های آن را وارد کتابخانه کنید.';

  @override
  String get libraryMeetingPasteAction => 'وارد کردن یادداشت جلسه';

  @override
  String get rdNavHome => 'خانه';

  @override
  String get rdNavLibrary => 'کتابخانه';

  @override
  String get rdNavCanvas => 'بوم';

  @override
  String get rdNavBrief => 'خلاصه';

  @override
  String get rdGreetingMorning => 'صبح بخیر';

  @override
  String get rdGreetingAfternoon => 'عصر بخیر';

  @override
  String get rdGreetingEvening => 'شب بخیر';

  @override
  String get rdHomeMemoryReady => 'حافظه‌ات\nآرام و آماده است';

  @override
  String get rdHomeComposerHint => 'هر چیزی بنویس یا بگو…';

  @override
  String get rdWaitingSectionTitle => 'منتظر لحظه مناسب';

  @override
  String get rdRecentlyCaptured => 'اخیراً ثبت‌شده';

  @override
  String get rdSeeAll => 'مشاهده همه';

  @override
  String get rdRemindersLink => 'یادآورها';

  @override
  String get rdSnoozeUndo => 'بازگردانی';

  @override
  String get rdSnoozeInHour => 'یک ساعت دیگر';

  @override
  String get rdSnoozeEvening => 'امشب';

  @override
  String get rdSnoozeTomorrow => 'فردا';

  @override
  String get rdSnoozeNextWeek => 'هفته آینده';

  @override
  String get rdWhenMomentRight => 'وقتی لحظه مناسب برسد';

  @override
  String rdWhenNextSee(String person) {
    return 'وقتی دوباره $person را ببینی';
  }

  @override
  String get rdListenTitle => 'دارم گوش می‌دهم…';

  @override
  String get rdListenSubtitle => 'طبیعی حرف بزن — میرا یادداشت می‌کند';

  @override
  String get rdListenTapToStop => 'برای توقف بزن';

  @override
  String get rdCanvasBoard => 'بورد';

  @override
  String get rdCanvasClusters => 'خوشه‌ها';

  @override
  String get rdCanvasMap => 'نقشه';

  @override
  String rdClusterMemories(int count) {
    return '$count خاطره';
  }

  @override
  String get rdOnboardingWelcome => 'میرا.\nذهن دوم تو.';

  @override
  String get rdOnboardingSignIn => 'ورود';

  @override
  String get rdOnboardingContinueGoogle => 'ادامه با گوگل';

  @override
  String get rdOnboardingSkip => 'رد کردن';

  @override
  String get rdOnboardingLater => 'بعداً انجام می‌دهم';

  @override
  String get rdCaptureEntryTitle => 'ثبت یک خاطره';

  @override
  String get rdCaptureEntrySubtitle =>
      'میرا می‌فهمد — قبل از ذخیره تأیید می‌کنی';

  @override
  String get rdCaptureModeVoice => 'صدا';

  @override
  String get rdCaptureModeVoiceHint => 'فقط حرف بزن';

  @override
  String get rdCaptureModeMeeting => 'جلسه';

  @override
  String get rdCaptureModeMeetingHint => 'ضبط طولانی و پردازش پس‌زمینه';

  @override
  String get rdCaptureModePhoto => 'عکس';

  @override
  String get rdCaptureModePhotoHint => 'از صحنه عکس بگیر';

  @override
  String get rdCaptureModeScreenshot => 'اسکرین‌شات';

  @override
  String get rdCaptureModeScreenshotHint => 'از گالری';

  @override
  String get rdCaptureModeLink => 'لینک';

  @override
  String get rdCaptureModeLinkHint => 'آدرس را بچسبان';

  @override
  String get rdCaptureModeType => 'با متن بنویس';

  @override
  String get rdCaptureModeFile => 'فایل یا ویدئو';

  @override
  String get rdCaptureModeFileHint => 'آپلود و پردازش در پس‌زمینه';

  @override
  String get rdCaptureFileUploadFailed => 'فایل آپلود نشد.';

  @override
  String get rdCaptureFileQueued =>
      'فایل در کتابخانه ذخیره شد و در پس‌زمینه پردازش می‌شود.';

  @override
  String get rdVoiceSearchListening => 'در حال گوش دادن';

  @override
  String get rdVoiceSearchSearching => 'در حال جستجو';

  @override
  String get rdVoiceSearchPrompt => 'جستجویت را بگو';

  @override
  String get rdVoiceSearchBusy => 'یک لحظه…';

  @override
  String get rdVoiceSearchCancel => 'لغو';

  @override
  String get rdVoiceSearchAction => 'جستجو';

  @override
  String get rdListenTranscribing => 'در حال تبدیل به متن…';

  @override
  String get rdMemoryFlagsAllChecked => 'همه بررسی شد — ممنون';

  @override
  String rdMemoryFlagsUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کلمه که میرا مطمئن نبود',
      one: '۱ کلمه که میرا مطمئن نبود',
    );
    return '$_temp0';
  }

  @override
  String get rdMemoryFlagsHint =>
      'روی کلمهٔ پرچم‌دار بزن تا به آن بروی، یا مستقیم متن را ویرایش کن.';

  @override
  String get rdCanvasSuggestConnect =>
      'این دو مرتبط به نظر می‌رسند — وصلشان کنیم؟';

  @override
  String get rdCanvasSuggestAction => 'وصل کن';

  @override
  String get rdPaywallComingSoon => 'پلاس به‌زودی — بهت خبر می‌دهیم.';

  @override
  String get rdPaywallWelcome => 'به میرا پلاس خوش آمدی ✨';

  @override
  String get rdPaywallCancelled => 'عضویت پلاس لغو شد.';

  @override
  String get rdPaywallBadge => 'میرا پلاس';

  @override
  String get rdPaywallTitle => 'به حافظه‌ات\nفضای بیشتری بده';

  @override
  String get rdPaywallSubtitle =>
      'هر چیزی که ثبت می‌کنی، هرچقدر لازم باشد نگه داشته می‌شود — در یک حافظهٔ آرام و به‌هم‌پیوسته.';

  @override
  String get rdPaywallPrivacyNote =>
      'پلاس آنچه میرا به خاطر می‌سپارد را تغییر می‌دهد — نه اینکه چه کسی ببیند. حافظه‌ات همیشه خصوصی می‌ماند.';

  @override
  String get rdPaywallFeatUnlimitedTitle => 'خاطرات نامحدود';

  @override
  String get rdPaywallFeatUnlimitedSub => 'بدون سقف — نسخهٔ رایگان ۲٬۰۰۰ مورد.';

  @override
  String get rdPaywallFeatGraphTitle => 'گراف کامل حافظه';

  @override
  String get rdPaywallFeatGraphSub => 'همهٔ ارتباط‌ها، نه فقط اخیرها.';

  @override
  String get rdPaywallFeatVoiceTitle => 'تاریخچه و صدای طولانی‌تر';

  @override
  String get rdPaywallFeatVoiceSub => 'سال‌ها خاطره و ضبط ۱۰ دقیقه‌ای.';

  @override
  String get rdPaywallFeatConnectTitle => 'اتصال همه‌چیز';

  @override
  String get rdPaywallFeatConnectSub => 'همهٔ اپ‌ها — رایگان فقط دو اتصال.';

  @override
  String get rdPaywallFeatBriefTitle => 'خلاصه روزانه و یادآورهای هوشمند';

  @override
  String get rdPaywallFeatBriefSub => 'میرا در زمان درست چیزها را برمی‌گرداند.';

  @override
  String get rdPaywallPlanAnnual => 'سالانه';

  @override
  String get rdPaywallPlanMonthly => 'ماهانه';

  @override
  String get rdPaywallPlanMonthlyNote => 'صورتحساب ماهانه';

  @override
  String get rdPaywallCtaTrial => '۱۴ روز پلاس رایگان';

  @override
  String get rdPaywallThenAnnual => 'بعد ۷۲ دلار در سال';

  @override
  String get rdPaywallThenMonthly => 'بعد ۸ دلار در ماه';

  @override
  String get rdPaywallRestore => 'بازیابی خرید';

  @override
  String get rdPaywallTerms => 'شرایط';

  @override
  String get rdPaywallPrivacy => 'حریم خصوصی';

  @override
  String get rdPaywallTermsToast => 'شرایط در مرورگر باز می‌شود.';

  @override
  String get rdPaywallPrivacyToast => 'حریم خصوصی در مرورگر باز می‌شود.';

  @override
  String get rdPaywallActiveBadge => 'میرا پلاس · فعال';

  @override
  String get rdPaywallActiveTitle => 'فضای کافی\nبرای به‌خاطر سپردن';

  @override
  String get rdPaywallActiveSubtitle =>
      'ممنون که پلاس هستی. هر چیزی که ثبت می‌کنی کامل نگه داشته می‌شود — بدون سقف و فراموشی.';

  @override
  String get rdPaywallManage => 'مدیریت اشتراک';

  @override
  String get rdPaywallCancelNote =>
      'اگر لغو کنی، چیزی حذف نمی‌شود — خاطرات می‌مانند و ثبت در سقف رایگان متوقف می‌شود.';

  @override
  String get rdPaywallCancelCta => 'لغو پلاس';

  @override
  String get rdPaywallDemoFree => 'رایگان';

  @override
  String get rdPaywallDemoPlus => 'عضو پلاس';

  @override
  String get rdCaptureListening => 'در حال گوش دادن…';

  @override
  String get rdCaptureEntryType => 'متن';

  @override
  String get rdCaptureEntryLink => 'لینک';

  @override
  String get rdCaptureEntryPhoto => 'عکس';

  @override
  String get rdCaptureTapWhenFinished => 'وقتی تمام شد ✓ بزن';

  @override
  String get rdCaptureUnderstanding => 'در حال فهمیدن';

  @override
  String get rdCaptureStepTranscribe => 'تبدیل گفتارت به متن';

  @override
  String get rdCaptureStepRecognise => 'شناسایی نوع و جزئیات';

  @override
  String get rdCaptureStepConnections => 'یافتن ارتباط‌ها در حافظه';

  @override
  String get rdCaptureSavedLink => 'لینک ذخیره‌شده';

  @override
  String get rdCaptureKeptPhoto =>
      'میرا عکست را نگه داشت و وقتی لازم باشد جزئیاتش را می‌خواند.';

  @override
  String get rdCaptureKeptScreenshot =>
      'میرا اسکرین‌شات را نگه داشت و وقتی لازم باشد جزئیاتش را می‌خواند.';

  @override
  String get rdCaptureYourNote => 'یادداشت تو';

  @override
  String get rdCaptureConnectMemory => 'وصل به خاطرهٔ موجود';

  @override
  String get rdCaptureRelatedMemory => 'خاطرهٔ مرتبط';

  @override
  String get rdCaptureSuggestedActions => 'اقدام‌های پیشنهادی';

  @override
  String get rdCaptureRemindWeekend => 'بعداً بخوان — آخر هفته یادآوری کن';

  @override
  String get rdCaptureRemindLater => 'بعداً یادآوری کن';

  @override
  String rdCaptureRemindBefore(String deadline) {
    return 'قبل از $deadline یادآوری کن';
  }

  @override
  String get rdCaptureActionAddTopic => 'افزودن به موضوع';

  @override
  String get rdCaptureActionAddTopicSub => 'گروه‌بندی با خاطرات مرتبط';

  @override
  String get rdCaptureActionShare => 'اشتراک‌گذاری';

  @override
  String get rdCaptureActionShareSub => 'برای کسی که اهمیت دارد بفرست';

  @override
  String get rdCaptureActionCalendar => 'افزودن به تقویم';

  @override
  String get rdCaptureActionCalendarSub => 'از جزئیاتی که میرا خواند';

  @override
  String get rdCaptureActionAddPeople => 'افزودن افراد داخلش';

  @override
  String get rdCaptureActionAddPeopleSub =>
      'وصل کردن چهره‌هایی که میرا می‌بیند';

  @override
  String get rdCaptureChangeType => 'تغییر نوع';

  @override
  String get rdCaptureFilePrompt => 'میرا این را چطور باید بایگانی کند؟';

  @override
  String get rdCaptureAddDetail => 'افزودن جزئیات';

  @override
  String get rdCaptureAddDetailHint => '# برچسب یا جزئیات';

  @override
  String get rdCaptureReadPhoto => 'میرا عکست را خواند';

  @override
  String get rdCaptureReadScreenshot => 'میرا اسکرین‌شات را خواند';

  @override
  String get rdCaptureReadPage => 'میرا صفحه را خواند';

  @override
  String rdCaptureLinkCrawlReady(String provider) {
    return 'محتوای صفحه با $provider خوانده شد.';
  }

  @override
  String get rdCaptureLinkMetadataOnly =>
      'آدرس لینک در دسترس است، اما این صفحه متن قابل‌خواندن نداد. میرا آن را صادقانه به‌عنوان لینک نگه می‌دارد.';

  @override
  String get rdCaptureLinkFailedTitle => 'میرا نتوانست این لینک را بخواند';

  @override
  String get rdCaptureLinkFailedBody =>
      'ممکن است صفحه خصوصی، موقتاً خارج از دسترس یا مانع ابزارهای خواندن باشد. هنوز چیزی وارد حافظه نشده است.';

  @override
  String get rdCaptureLinkRetry => 'دوباره بخوان';

  @override
  String get rdCaptureLinkReadAction => 'خواندن لینک';

  @override
  String get rdCaptureLinkSaveFailed =>
      'لینک هنوز در مرحلهٔ بازبینی است و ذخیره نشد. دوباره تلاش کن.';

  @override
  String get rdCaptureUnderstood => 'میرا فهمید';

  @override
  String get rdCaptureReview => 'بازبینی';

  @override
  String get rdCaptureCancel => 'لغو';

  @override
  String get rdCaptureDiscard => 'دور انداختن';

  @override
  String get rdCaptureDone => 'تمام';

  @override
  String get rdCaptureKeptTitle => 'در حافظه ماند';

  @override
  String get rdCaptureKeptSafe =>
      'ایمن نگه داشته شد. میرا در زمان مناسب برمی‌گرداند.';

  @override
  String rdCaptureKeptJoined(String details) {
    return '$details. میرا در زمان مناسب برمی‌گرداند.';
  }

  @override
  String get rdCaptureAddToMemory => 'افزودن به حافظه';

  @override
  String rdCaptureAddLinking(int count) {
    return 'افزودن · وصل $count';
  }

  @override
  String get rdCaptureDetailsExtracted => 'جزئیاتی که میرا استخراج کرد';

  @override
  String get rdCaptureTypeNote => 'یادداشت';

  @override
  String get rdCaptureTypeTask => 'کار';

  @override
  String get rdCaptureTypeEvent => 'رویداد';

  @override
  String get rdCaptureTypePerson => 'شخص';

  @override
  String get rdCaptureTypePlace => 'مکان';

  @override
  String get rdCaptureTypeLink => 'لینک';

  @override
  String get rdCaptureTypeArticle => 'مقاله';

  @override
  String get rdCaptureTypeIdea => 'ایده';

  @override
  String get rdCaptureTypeTravel => 'سفر';

  @override
  String get rdCaptureTypeSheetTitle => 'نوشتن یادداشت';

  @override
  String get rdCaptureTypeSheetHint => 'چه چیزی را می‌خواهی به خاطر بسپاری؟';

  @override
  String get rdCaptureLinkSheetTitle => 'افزودن لینک';

  @override
  String get rdCaptureLinkTitleOptional => 'عنوان (اختیاری)';

  @override
  String get rdCaptureUrlHint => 'https://…';

  @override
  String rdCaptureLinkBadge(String host) {
    return 'لینک · $host';
  }

  @override
  String rdCaptureLinkedMemories(int count) {
    return 'وصل به $count خاطره';
  }

  @override
  String get rdCaptureHasReminder => 'یادآور دارد';

  @override
  String get rdCapturePhotoFrameHint => 'پوستر، صفحه یا مکان را در کادر بگیر';

  @override
  String get rdCapturePhotoReading => 'در حال خواندن عکس…';

  @override
  String get rdCaptureScreenshotReading => 'در حال خواندن اسکرین‌شات…';

  @override
  String get rdCaptureScreenshotPickTitle => 'یک اسکرین‌شات انتخاب کن';

  @override
  String get rdCaptureScreenshotPickSub =>
      'میرا متن و جزئیات را از تصویر می‌خواند';

  @override
  String get rdCaptureScreenshotUse => 'استفاده از اسکرین‌شات';

  @override
  String get rdCaptureLinkSaveTitle => 'ذخیرهٔ لینک';

  @override
  String get rdCaptureLinkSaveSub => 'آدرس را بچسبان — میرا صفحه را می‌خواند';

  @override
  String get rdCaptureLinkReading => 'در حال خواندن صفحه…';

  @override
  String get rdCaptureLinkArticleDefault => 'مقاله از لینک';

  @override
  String get rdCaptureLinkArticleSub =>
      'میرا متن قابل‌خواندن را استخراج و قابل جستجو نگه می‌دارد.';

  @override
  String get rdCaptureContinue => 'ادامه';

  @override
  String get rdBriefTitle => 'خلاصه روز';

  @override
  String get rdBriefGreetingMorning => 'صبح بخیر';

  @override
  String get rdBriefGreetingAfternoon => 'ظهر بخیر';

  @override
  String get rdBriefGreetingEvening => 'عصر بخیر';

  @override
  String rdBriefGreeting(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String get rdBriefDayEnd => 'این هم از روزت.\nبقیه‌چیزها امن در حافظه‌اند.';

  @override
  String get rdBriefNothingNow => 'الان چیزی از تو می‌خواهد نیست.';

  @override
  String get rdBriefSnoozedTomorrow => 'تا فردا به تعویق افتاد';

  @override
  String get rdBriefDone => 'انجام شد';

  @override
  String get rdBriefClearedLater => 'پاک شد — میرا بعداً دوباره می‌پرسد';

  @override
  String get rdBriefUndo => 'برگردان';

  @override
  String get rdBriefClearAll => 'پاک کردن همه';

  @override
  String get rdBriefSeeAllReminders => 'همه یادآورها';

  @override
  String get rdBriefSectionWaitingMoment => 'منتظر لحظه مناسب';

  @override
  String get rdBriefSectionNeedsYou => 'نیاز به تو';

  @override
  String get rdBriefSectionToday => 'امروز';

  @override
  String get rdBriefSectionHandled => 'بی‌سر و صدا انجام شد';

  @override
  String get rdBriefSectionRecent => 'اخیر';

  @override
  String get rdBriefSectionResurfaced => 'میرا دوباره آورد';

  @override
  String get rdBriefSectionWaitingOnYou => 'منتظر تو';

  @override
  String rdBriefTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کار',
      one: '۱ کار',
    );
    return '$_temp0';
  }

  @override
  String rdBriefReminderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count یادآور',
      one: '۱ یادآور',
    );
    return '$_temp0';
  }

  @override
  String rdBriefEventsCount(int count) {
    return '$count رویداد';
  }

  @override
  String get rdBriefFallbackMemory => 'حافظه';

  @override
  String get rdBriefFallbackRecentMemory => 'حافظه اخیر';

  @override
  String get rdBriefFallbackReminder => 'یادآور';

  @override
  String get rdBriefFallbackAReminder => 'یک یادآور';

  @override
  String get rdBriefFallbackTask => 'کار';

  @override
  String get rdBriefFallbackEvent => 'رویداد';

  @override
  String get rdBriefFallbackUntitled => 'حافظه بدون عنوان';

  @override
  String get rdBriefFallbackAMemory => 'یک حافظه';

  @override
  String get rdBriefOverdue => 'عقب‌افتاده';

  @override
  String get rdBriefOpen => 'باز';

  @override
  String rdBriefDueOn(String when) {
    return 'موعد: $when';
  }

  @override
  String get rdBriefDueEarlierToday => 'موعد: امروز زودتر';

  @override
  String get rdBriefDueYesterday => 'موعد: دیروز';

  @override
  String rdBriefDueDaysAgo(int days) {
    return 'موعد: $days روز پیش';
  }

  @override
  String get rdBriefToday => 'امروز';

  @override
  String get rdBriefYesterday => 'دیروز';

  @override
  String get rdBriefTomorrow => 'فردا';

  @override
  String rdBriefHoursAgo(int hours) {
    return '$hours ساعت پیش';
  }

  @override
  String rdBriefDaysAgo(int days) {
    return '$days روز پیش';
  }

  @override
  String get rdBriefBroughtBack => 'برای تو برگردانده شد';

  @override
  String get rdBriefSavedToMemory => 'در حافظه‌ات ذخیره شد';

  @override
  String get rdBriefOpenAction => 'باز کردن';

  @override
  String get rdBriefRemindMe => 'یادآوری کن';

  @override
  String get rdBriefReminderSetThursday => 'یادآور برای پنج‌شنبه تنظیم شد';

  @override
  String get rdBriefMarkedDone => 'انجام‌شده علامت خورد';

  @override
  String get rdBriefDismissed => 'رد شد';

  @override
  String get rdBriefUpdated => 'به‌روز شد';

  @override
  String get rdBriefWelcomeBadge => 'به میرا خوش آمدی';

  @override
  String get rdBriefFirstTitle => 'خلاصه روزت\nبا هر ثبت پر می‌شود';

  @override
  String get rdBriefFirstSubtitle =>
      'فکر، کار یا لینک ذخیره کن — میرا هر صبح مهم‌ها را اینجا می‌آورد.';

  @override
  String get rdBriefFirstStep1Title => 'حرف بزن یا بنویس';

  @override
  String get rdBriefFirstStep1Sub => 'میرا قبل از ذخیره می‌فهمد';

  @override
  String get rdBriefFirstStep2Title => 'تأیید کن چه مهم است';

  @override
  String get rdBriefFirstStep2Sub => 'کنترل حافظه با توست';

  @override
  String get rdBriefFirstStep3Title => 'فردا اینجا ببین';

  @override
  String get rdBriefFirstStep3Sub => 'کارها، یادآورها و حافظه‌های برگشتی';

  @override
  String get rdBriefOverdueSummary =>
      'چند چیز موقع شلوغی از قلم افتاد. چیزی گم نشده — نگه داشتم. با هم آرام جمعشان می‌کنیم.';

  @override
  String get rdBriefSnooze => 'بعداً';

  @override
  String get rdBriefDoItNow => 'الان انجام بده';

  @override
  String get rdBriefEmptyTitle => 'امروز چیزی از تو نمی‌خواهد';

  @override
  String get rdBriefEmptyBody =>
      'روزت آزاد است و هیچ حافظه‌ای منتظر تو نیست. همه‌چیز امن است و وقتی مهم شود خبر می‌دهم.';

  @override
  String get rdBriefMemoriesHeldSafe => 'حافظه امن';

  @override
  String get rdBriefRemindersDue => 'یادآور موعددار';

  @override
  String get rdBriefCaptureThought => 'ثبت یک فکر';

  @override
  String get rdBriefCaptureSub => 'هر چیزی در ذهنت — نگه می‌دارم.';

  @override
  String get rdOnboardingTagline =>
      'ذهن دوم. برای وقتی نمی‌خواهی چیزی را فراموش کنی.';

  @override
  String get rdOnboardingSeeHow => 'ببین چطور کار می‌کند';

  @override
  String get rdOnboardingAuthInvalidEmail => 'یک ایمیل معتبر وارد کن.';

  @override
  String get rdOnboardingAuthCodeFailed => 'ارسال کد ممکن نشد. دوباره تلاش کن.';

  @override
  String get rdOnboardingGoogleFailed => 'ورود با گوگل ناموفق بود.';

  @override
  String get rdOnboardingAuthTitle => 'ورود یا ثبت‌نام';

  @override
  String get rdOnboardingEmailHint => 'ایمیلت را وارد کن';

  @override
  String get rdOnboardingContinue => 'ادامه';

  @override
  String get rdOnboardingApple => 'ادامه با اپل';

  @override
  String get rdOnboardingAppleSoon => 'ورود با اپل به‌زودی.';

  @override
  String get rdOnboardingLegal =>
      'اگر حساب جدید می‌سازی،\nشرایط و حریم خصوصی اعمال می‌شود.';

  @override
  String get rdOnboardingInviteRequired =>
      'برای پیوستن به میرا به کد دعوت نیاز داری.';

  @override
  String get rdOnboardingInviteHint => 'کد دعوت را وارد کن';

  @override
  String get rdOnboardingInviteEmpty => 'کد دعوت را وارد کن.';

  @override
  String get rdOnboardingInviteInvalid => 'این کد دعوت پذیرفته نشد.';

  @override
  String get rdOnboardingInviteVerifyFailed =>
      'تأیید کد ممکن نشد. دوباره تلاش کن.';

  @override
  String get rdOnboardingOtpRequired => 'کدی که ایمیل کردیم را وارد کن.';

  @override
  String get rdOnboardingOtpMismatch => 'کد مطابقت نداشت. دوباره تلاش کن.';

  @override
  String get rdOnboardingOtpResent => 'کد جدید فرستادیم.';

  @override
  String get rdOnboardingOtpResendFailed => 'ارسال مجدد کد ممکن نشد.';

  @override
  String get rdOnboardingCheckEmail => 'ایمیلت را چک کن';

  @override
  String get rdOnboardingOtpSent => 'یک کد ۶ رقمی فرستادیم';

  @override
  String get rdOnboardingOtpResendPrompt => 'کد نرسید؟ ';

  @override
  String get rdOnboardingResend => 'دوباره بفرست';

  @override
  String get rdOnboardingEnter => 'ورود';

  @override
  String get rdOnboardingDetailsTitle => 'مشخصات تو';

  @override
  String get rdOnboardingDetailsDesc =>
      'میرا با این نام سلام می‌کند. بعداً در تنظیمات می‌توانی عوضش کنی.';

  @override
  String get rdOnboardingNameHint => 'نام تو';

  @override
  String get rdOnboardingRememberTitle =>
      'چه چیزی را می‌خواهی میرا به خاطر بسپارد؟';

  @override
  String get rdOnboardingRememberSub =>
      'هر چیزی که نمی‌خواهی فراموش شود. ایده. کار. لینک. حتی یک حس.';

  @override
  String get rdOnboardingRememberHint => 'دکمه را بزن و حرف بزن یا بنویس';

  @override
  String get rdOnboardingNext => 'بعدی';

  @override
  String get rdOnboardingUnderstoodBrand => 'میرا تو را می‌فهمد';

  @override
  String get rdCommonUndo => 'واگرد';

  @override
  String get rdCommonCancel => 'لغو';

  @override
  String get rdCommonSave => 'ذخیره';

  @override
  String get rdCommonDone => 'انجام شد';

  @override
  String get rdCommonView => 'مشاهده';

  @override
  String get rdCommonClear => 'پاک کردن';

  @override
  String get rdCommonAccount => 'حساب';

  @override
  String get rdCommonComingSoon => 'به‌زودی';

  @override
  String get rdCommonSettings => 'تنظیمات';

  @override
  String get rdCommonConnect => 'اتصال';

  @override
  String get rdCommonConnected => 'متصل';

  @override
  String get rdCommonManage => 'مدیریت';

  @override
  String get rdCommonUpgrade => 'ارتقا';

  @override
  String get rdCommonAm => 'ق.ظ';

  @override
  String get rdCommonPm => 'ب.ظ';

  @override
  String get rdRootTitleMemory => 'حافظه';

  @override
  String get rdRootTitleCapture => 'ثبت';

  @override
  String get rdRootTitleNotifications => 'اعلان‌ها';

  @override
  String get rdRootTitleConnectedApps => 'اپ‌های متصل';

  @override
  String get rdRootTitleListening => 'در حال گوش دادن';

  @override
  String get rdRootTitleChat => 'گفتگو';

  @override
  String get rdRootTitleSetup => 'راه‌اندازی';

  @override
  String get rdAskTitle => 'از حافظه‌ات بپرس';

  @override
  String get rdAskHint => 'در همه‌چیز جستجو کن…';

  @override
  String get rdAskSectionTry => 'امتحان کن';

  @override
  String get rdAskSectionRecent => 'اخیر';

  @override
  String get rdAskSearching => 'در حال جستجو در حافظه…';

  @override
  String get rdAskSomethingElse => 'سؤال دیگری بپرس';

  @override
  String get rdAskErrorConnection =>
      'الان به حافظه‌ات دسترسی نداشتم. اتصال را چک کن و دوباره تلاش کن.';

  @override
  String get rdAskSuggestionRecent => 'چی اخیراً ذخیره کردم؟';

  @override
  String get rdAskSuggestionFollowUp => 'چه چیزهایی را باید پیگیری کنم؟';

  @override
  String get rdAskSuggestionSummariseWeek => 'این هفته را خلاصه کن';

  @override
  String get rdAskSuggestionFindByTopic => 'یادداشت را با موضوع پیدا کن';

  @override
  String rdAskDrawnFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حافظه',
      one: '۱ حافظه',
    );
    return 'بر اساس $_temp0';
  }

  @override
  String get rdCollectionAddTitle => 'افزودن به مجموعه';

  @override
  String get rdCollectionNew => 'مجموعه جدید';

  @override
  String get rdCollectionNameHint => 'نام مجموعه';

  @override
  String get rdLibraryYourMemory => 'حافظهٔ تو';

  @override
  String get rdLibraryTitle => 'کتابخانه';

  @override
  String rdLibraryKeptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاطره، همه امن',
      one: '۱ خاطره، همه امن',
    );
    return '$_temp0';
  }

  @override
  String get rdLibrarySearchHint => 'در حافظه‌ات جستجو کن…';

  @override
  String get rdLibraryFilterAll => 'همه';

  @override
  String get rdLibraryFilterNotes => 'یادداشت‌ها';

  @override
  String get rdLibraryFilterVoice => 'صدا';

  @override
  String get rdLibraryFilterPhotos => 'عکس‌ها';

  @override
  String get rdLibraryFilterLinks => 'لینک‌ها';

  @override
  String get rdLibraryFilterEvents => 'رویدادها';

  @override
  String get rdLibraryNoMatches => 'نتیجه‌ای نیست';

  @override
  String rdLibrarySearchFor(String query) {
    return ' برای «$query»';
  }

  @override
  String rdLibrarySearchIn(String name) {
    return ' در $name';
  }

  @override
  String rdLibraryMemoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاطره',
      one: '۱ خاطره',
    );
    return '$_temp0';
  }

  @override
  String get rdLibraryGroupedForYou => 'میرا برایت گروه‌بندی کرد';

  @override
  String get rdLibraryNoCollectionsYet => 'هنوز مجموعه‌ای نیست.';

  @override
  String get rdLibraryCollections => 'مجموعه‌ها';

  @override
  String get rdLibraryArchivedTitle => 'بایگانی';

  @override
  String get rdLibraryOutOfTheWay => 'کنار گذاشته';

  @override
  String get rdLibraryArchivedEmpty =>
      'چیزی بایگانی نشده.\nخاطرات بایگانی‌شده اینجا، دور از دید می‌مانند.';

  @override
  String get rdLibraryRestore => 'بازیابی';

  @override
  String get rdLibraryDayToday => 'امروز';

  @override
  String get rdLibraryDayThisWeek => 'این هفته';

  @override
  String get rdLibraryDayEarlier => 'قبل‌تر';

  @override
  String get rdLibraryEmptyFilter =>
      'چیزی با این فیلتر نیست.\nهر چیزی که ثبت کنی، آرام اینجا می‌نشیند.';

  @override
  String rdLibraryEndMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count خاطره نگه داشته‌ای.\nمیرا نگه می‌دارد تا تو لازم نداشته باشی.',
      one: '۱ خاطره نگه داشته‌ای.\nمیرا نگه می‌دارد تا تو لازم نداشته باشی.',
    );
    return '$_temp0';
  }

  @override
  String get rdLibrarySelectMemories => 'انتخاب خاطرات';

  @override
  String rdLibrarySelectedCount(int count) {
    return '$count انتخاب‌شده';
  }

  @override
  String get rdLibrarySelectAll => 'انتخاب همه';

  @override
  String get rdLibraryDeselectAll => 'لغو انتخاب همه';

  @override
  String get rdLibraryActionCollection => 'مجموعه';

  @override
  String get rdLibraryActionBoard => 'بورد';

  @override
  String get rdLibraryActionPin => 'سنجاق';

  @override
  String get rdLibraryActionArchive => 'بایگانی';

  @override
  String get rdLibraryActionDelete => 'حذف';

  @override
  String get rdLibraryUntitled => 'بدون عنوان';

  @override
  String get rdLibraryTypeVoice => 'صدا';

  @override
  String get rdLibraryTypeLink => 'لینک';

  @override
  String get rdLibraryTypePhoto => 'عکس';

  @override
  String get rdLibraryTypeEvent => 'رویداد';

  @override
  String get rdLibraryTypeNote => 'یادداشت';

  @override
  String get rdLibraryTimeJustNow => 'همین الان';

  @override
  String rdLibraryTimeMinutesAgo(int minutes) {
    return '$minutes دقیقه پیش';
  }

  @override
  String rdLibraryTimeHoursAgo(int hours) {
    return '$hours ساعت پیش';
  }

  @override
  String get rdLibraryTimeYesterday => 'دیروز';

  @override
  String rdLibraryTimeDaysAgo(int days) {
    return '$days روز پیش';
  }

  @override
  String rdLibraryTimeDate(int month, int day) {
    return '$month/$day';
  }

  @override
  String rdLibraryAddedToCollection(int count, String name) {
    return '$count مورد به «$name» اضافه شد';
  }

  @override
  String get rdLibraryAddToCollectionFailed =>
      'افزودن به مجموعه ممکن نشد. اتصال را بررسی کن.';

  @override
  String rdLibraryAddedToBoard(int count, String board) {
    return '$count مورد به «$board» اضافه شد';
  }

  @override
  String get rdLibraryAddToBoardFailed =>
      'افزودن به بورد ممکن نشد. اتصال را بررسی کن.';

  @override
  String rdLibraryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاطره حذف شد',
      one: '۱ خاطره حذف شد',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryArchivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاطره بایگانی شد',
      one: '۱ خاطره بایگانی شد',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryPinnedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاطره سنجاق شد',
      one: '۱ خاطره سنجاق شد',
    );
    return '$_temp0';
  }

  @override
  String rdLibraryRestored(String title) {
    return '«$title» بازیابی شد';
  }

  @override
  String rdLibraryCouldntOpenCollection(String name) {
    return 'باز کردن «$name» ممکن نشد.';
  }

  @override
  String get rdLibraryAddToBoard => 'افزودن به بورد';

  @override
  String get rdLibraryUntitledBoard => 'بورد بدون عنوان';

  @override
  String rdLibraryCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارت',
      one: '۱ کارت',
    );
    return '$_temp0';
  }

  @override
  String get rdLibraryNewBoard => 'بورد جدید';

  @override
  String get rdLibraryBoardNameHint => 'نام بورد';

  @override
  String get rdLibraryFallbackBoard => 'بورد';

  @override
  String get rdMemoryConnectedMemory => 'خاطره مرتبط';

  @override
  String get rdMemoryLinked => 'پیوندخورده';

  @override
  String rdMemoryInsightLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'به $count خاطره مرتبط وصلش کرد',
      one: 'به ۱ خاطره مرتبط وصلش کرد',
    );
    return '$_temp0';
  }

  @override
  String rdMemoryInsightConnected(String names) {
    return '$names را وصل کرد';
  }

  @override
  String rdMemoryInsightTagged(String tags) {
    return 'برچسب $tags زد';
  }

  @override
  String rdMemoryInsightSummary(String details) {
    return 'این را خواندم و $details تا پیدا کردنش آسان بماند.';
  }

  @override
  String get rdMemoryPinned => 'سنجاق شد';

  @override
  String get rdMemoryUnpinned => 'سنجاق برداشته شد';

  @override
  String rdMemoryVoiceNoteBadge(String duration) {
    return 'یادداشت صوتی · $duration';
  }

  @override
  String get rdMemoryEditedJustNow =>
      'همین الان ویرایش شد · امروز، ۴:۱۲ بعدازظهر';

  @override
  String get rdMemoryRecordedAgo => '۲ ساعت پیش ضبط شد · امروز، ۴:۱۲ بعدازظهر';

  @override
  String get rdMemoryCapturedAgo => '۲ ساعت پیش ثبت شد · امروز، ۴:۱۲ بعدازظهر';

  @override
  String get rdMemoryEditTranscriptHint =>
      'در حال ویرایش متن — با ذخیره، میرا دوباره می‌خواند و پیوندها را تازه می‌کند.';

  @override
  String get rdMemoryEditNoteHint =>
      'در حال ویرایش یادداشت — با ذخیره، میرا دوباره می‌خواند و پیوندها را تازه می‌کند.';

  @override
  String get rdMemoryTitleHint => 'عنوان';

  @override
  String get rdMemoryTranscriptHint => 'متن گفتار…';

  @override
  String get rdMemoryWriteNoteHint => 'یادداشتت را بنویس…';

  @override
  String get rdMemoryTranscribedByMira => 'رونویسی‌شده توسط میرا';

  @override
  String get rdMemoryMiraNoticed => 'میرا متوجه شد';

  @override
  String get rdMemoryReminder => 'یادآور';

  @override
  String get rdMemoryReminderOnBrief => 'روشن — در خلاصه روزانه پیگیری می‌شود';

  @override
  String get rdMemoryReminderOnBringUp => 'روشن — میرا دوباره یادآوری می‌کند';

  @override
  String get rdMemoryReminderOff => 'خاموش — برای یادآوری بزن';

  @override
  String get rdMemoryConnectedMemories => 'خاطرات مرتبط';

  @override
  String get rdMemorySeeInCanvas => 'ببین در بوم';

  @override
  String get rdMemoryPeopleAndTags => 'افراد و موجودیت‌ها';

  @override
  String get rdMemorySourceVoice =>
      'ضبط‌شده در خانه · آیفون · به‌اشتراک گذاشته نشده';

  @override
  String get rdMemorySourceNote =>
      'نوشته‌شده در خانه · آیفون · به‌اشتراک گذاشته نشده';

  @override
  String get rdMemorySaveChanges => 'ذخیره تغییرات';

  @override
  String get rdMemoryAskMiraAboutThis => 'از میرا درباره این بپرس';

  @override
  String get rdMemoryPinToTop => 'سنجاق به بالا';

  @override
  String get rdMemoryUnpin => 'برداشتن سنجاق';

  @override
  String get rdMemoryEditNote => 'ویرایش یادداشت';

  @override
  String get rdMemoryShareMemory => 'اشتراک‌گذاری خاطره';

  @override
  String get rdMemorySavedTranscript => 'ذخیره شد — میرا متن را دوباره خواند';

  @override
  String get rdMemorySavedNote => 'ذخیره شد — میرا این یادداشت را دوباره خواند';

  @override
  String rdMemoryAddedToCollection(String name) {
    return 'به «$name» اضافه شد';
  }

  @override
  String get rdMemoryLinkCopied => 'لینک کپی شد';

  @override
  String get rdMemoryCopyLink => 'کپی لینک';

  @override
  String get rdMemoryCopyAsText => 'کپی به‌صورت متن';

  @override
  String get rdMemoryEmail => 'ایمیل';

  @override
  String get rdMemoryMessage => 'پیام';

  @override
  String get rdMemoryCopiedToClipboard => 'در کلیپ‌بورد کپی شد';

  @override
  String get rdMemoryNoAppAvailable => 'برنامه‌ای برای این کار در دسترس نیست';

  @override
  String rdMemoryDeleteConfirmBody(String title, int connections) {
    String _temp0 = intl.Intl.pluralLogic(
      connections,
      locale: localeName,
      other: '$connections پیوندش',
      one: '۱ پیوندش',
    );
    return '«$title» و $_temp0 از کتابخانه حذف می‌شود. این کار قابل بازگشت نیست.';
  }

  @override
  String get rdMemoryKeepIt => 'نگهش دار';

  @override
  String get rdChatOpening =>
      'هر چیزی درباره خاطراتت بپرس — چه ذخیره کردی، چه پیگیری کنی، یا می‌توانم چیزی بنویسم.';

  @override
  String rdChatOpeningAnchored(String title) {
    return 'این درباره «$title» است. هر چیزی بپرس — چه باز مانده، چطور وصل است، یا می‌توانم چیزی بنویسم.';
  }

  @override
  String get rdChatStarterDraftReminder => 'پیش‌نویس یادآور';

  @override
  String get rdChatStarterHowConnect => 'چطور به بقیه وصل است؟';

  @override
  String get rdChatStarterSummarise => 'خلاصه‌اش کن';

  @override
  String get rdChatFollowUpDefault => 'پیگیری این موضوع';

  @override
  String get rdChatEmptyAnswer =>
      'نگاه کردم، اما چیزی درباره‌اش ندارم — ثبتش کن تا اینجا وصلش کنم.';

  @override
  String get rdChatOfflineFallback =>
      'الان به حافظه‌ات دسترسی ندارم. کمی بعد دوباره امتحان کن.';

  @override
  String get rdChatTitle => 'از میرا بپرس';

  @override
  String rdChatAboutTitle(String title) {
    return 'درباره «$title»';
  }

  @override
  String get rdChatGroundedInMemories => 'بر پایه خاطراتت';

  @override
  String get rdChatFromYourMemories => 'از خاطراتت';

  @override
  String get rdChatReminderAdded => 'یادآور اضافه شد';

  @override
  String get rdChatSetReminder => 'تنظیم این یادآور';

  @override
  String get rdChatComposeHint => 'درباره خاطراتت بپرس…';

  @override
  String get rdChatCiteVoiceSub => 'صدا · خوانده‌شده توسط میرا';

  @override
  String get rdChatCitePhotoSub => 'عکس · خوانده‌شده توسط میرا';

  @override
  String get rdAccountTitle => 'حساب';

  @override
  String get rdAccountPlaceholderName => 'حساب تو';

  @override
  String get rdAccountSignedOut => 'خارج شدی';

  @override
  String get rdAccountSectionProfile => 'پروفایل';

  @override
  String get rdAccountName => 'نام';

  @override
  String get rdAccountEmail => 'ایمیل';

  @override
  String get rdAccountPhone => 'تلفن';

  @override
  String get rdAccountSectionSecurity => 'امنیت';

  @override
  String get rdAccountFaceIdTitle => 'باز کردن با Face ID';

  @override
  String get rdAccountFaceIdSub => 'برای باز کردن میرا Face ID لازم باشد';

  @override
  String get rdAccountAutoLockTitle => 'قفل خودکار';

  @override
  String get rdAccountAutoLockSub => 'بعد از ۵ دقیقه بی‌حرکتی قفل شود';

  @override
  String get rdAccountChangePassword => 'تغییر رمز';

  @override
  String get rdAccountSectionPlan => 'طرح';

  @override
  String get rdAccountMiraPlus => 'میرا پلاس';

  @override
  String get rdAccountMiraFree => 'میرا رایگان';

  @override
  String get rdAccountPlusActiveSub => 'فعال · ۸ دلار در ماه';

  @override
  String rdAccountFreeUsageSub(int used, int limit) {
    return '$used از $limit خاطره استفاده شده';
  }

  @override
  String get rdAccountSectionPreferences => 'ترجیحات';

  @override
  String get rdAccountNotificationsTitle => 'اعلان‌ها';

  @override
  String get rdAccountNotificationsSub => 'خلاصه روز، یادآورها و ساعات سکوت';

  @override
  String get rdAccountRemindersTitle => 'یادآورها';

  @override
  String get rdAccountRemindersSub => 'همه چیزهایی که میرا برایت نگه داشته';

  @override
  String get rdAccountAppearanceTitle => 'ظاهر';

  @override
  String get rdAccountAppearanceSub => 'تم، رنگ، اندازه متن و حرکت';

  @override
  String get rdAccountConnectedAppsTitle => 'اپ‌های متصل';

  @override
  String get rdAccountConnectedAppsSub => 'تقویم، یادداشت، عکس و بیشتر';

  @override
  String get rdAccountSectionMemoryData => 'حافظه و داده';

  @override
  String get rdAccountExportData => 'خروجی داده‌هایم';

  @override
  String get rdAccountExportDataSub => 'دانلود همه چیزهایی که میرا نگه داشته';

  @override
  String get rdAccountMemoryHistory => 'تاریخچه حافظه';

  @override
  String get rdAccountMemoryHistorySub => 'ببین چه چیزی و کی ثبت شده';

  @override
  String get rdAccountSignOut => 'خروج';

  @override
  String get rdAccountDeleteAccount => 'حذف حساب';

  @override
  String get rdAccountFootVersion => 'میرا · نسخه ۱.۰';

  @override
  String get rdAccountAllMemoriesSynced => 'همه خاطرات همگام';

  @override
  String rdAccountStorageHeadline(int count) {
    return '$count خاطره';
  }

  @override
  String rdAccountStorageSubline(int limit) {
    return 'از $limit · جا زیاد است';
  }

  @override
  String get rdNotificationsTitle => 'اعلان‌ها';

  @override
  String get rdNotificationsIntro =>
      'میرا پیش‌فرض آرام است — فقط وقتی واقعاً کمک می‌کند صحبت می‌کند.';

  @override
  String get rdNotificationsSectionDailyBrief => 'خلاصه روز';

  @override
  String get rdNotificationsMorningBrief => 'خلاصه صبح';

  @override
  String get rdNotificationsMorningBriefSub => 'جمع‌بندی آرام برای شروع روز';

  @override
  String get rdNotificationsBriefTime => 'زمان خلاصه';

  @override
  String get rdNotificationsResurfaceMemory => 'برگرداندن یک خاطره';

  @override
  String get rdNotificationsResurfaceMemorySub =>
      'گاهی چیزی شایسته یادآوری را دوباره ببین';

  @override
  String get rdNotificationsSectionReminders => 'یادآورها';

  @override
  String get rdNotificationsTimeSensitive => 'یادآورهای زمان‌حساس';

  @override
  String get rdNotificationsTimeSensitiveSub =>
      'تاریخ‌ها، بلیت‌ها و چیزهایی که منقضی می‌شوند';

  @override
  String get rdNotificationsGentleNudges => 'یادآوری ملایم';

  @override
  String get rdNotificationsGentleNudgesSub => 'پیشنهاد نرم برای کارهای ناتمام';

  @override
  String get rdNotificationsSectionCaptures => 'ثبت‌ها';

  @override
  String get rdNotificationsConfirmBeforeSaving => 'تأیید قبل از ذخیره';

  @override
  String get rdNotificationsConfirmBeforeSavingSub =>
      'قبل از افزودن به گراف بپرس';

  @override
  String get rdNotificationsWeeklyRecap => 'مرور هفتگی';

  @override
  String get rdNotificationsWeeklyRecapSub => 'یک نگاه به عقب در یکشنبه';

  @override
  String get rdNotificationsSectionQuietHours => 'ساعات سکوت';

  @override
  String get rdNotificationsQuietHours => 'ساعات سکوت';

  @override
  String get rdNotificationsQuietHoursSub =>
      'همه اعلان‌ها را وقتی استراحت می‌کنی نگه دار';

  @override
  String get rdNotificationsSchedule => 'زمان‌بندی';

  @override
  String get rdNotificationsQuietStartHelp => 'شروع ساعات سکوت';

  @override
  String get rdNotificationsQuietEndHelp => 'پایان ساعات سکوت';

  @override
  String get rdNotificationsSectionDelivery => 'تحویل';

  @override
  String get rdNotificationsSound => 'صدا';

  @override
  String get rdNotificationsHaptics => 'لرزش';

  @override
  String get rdNotificationsFoot => 'میرا آرام اعلان می‌دهد، یا اصلاً نه.';

  @override
  String get rdConnectedAppsTitle => 'اپ‌های متصل';

  @override
  String get rdConnectedAppsIntro =>
      'میرا این منابع را آرام در حافظه‌ات می‌بافد — بدون اجازه‌ات چیزی خارج نمی‌شود.';

  @override
  String get rdConnectedAppsSectionConnected => 'متصل';

  @override
  String get rdConnectedAppsCalendar => 'تقویم';

  @override
  String get rdConnectedAppsCalendarSub =>
      '۲ دقیقه پیش همگام · به خلاصه روز می‌رسد';

  @override
  String get rdConnectedAppsNotes => 'یادداشت‌ها';

  @override
  String get rdConnectedAppsNotesSub => '۱ ساعت پیش همگام · ۱۲۸ یادداشت';

  @override
  String get rdConnectedAppsPhotos => 'عکس‌ها';

  @override
  String get rdConnectedAppsPhotosSub => 'امروز همگام · اسکرین‌شات و اسکن';

  @override
  String get rdConnectedAppsSectionAvailable => 'در دسترس';

  @override
  String get rdConnectedAppsGmail => 'جیمیل';

  @override
  String get rdConnectedAppsGmailSub => 'ایمیل مهم را به خاطره تبدیل کن';

  @override
  String get rdConnectedAppsSafari => 'سافاری';

  @override
  String get rdConnectedAppsSafariSub =>
      'صفحات و هایلایت‌ها را هنگام مرور ذخیره کن';

  @override
  String get rdConnectedAppsReadwise => 'ریدوایز';

  @override
  String get rdConnectedAppsReadwiseSub => 'هایلایت کتاب و مقاله را وارد کن';

  @override
  String get rdConnectedAppsVoiceMemos => 'یادداشت صوتی';

  @override
  String get rdConnectedAppsVoiceMemosSub => 'ضبط‌ها را به گراف تبدیل کن';

  @override
  String get rdConnectedAppsPrivacy =>
      'میرا فقط آنچه وصل می‌کنی می‌خواند و خصوصی پردازش می‌کند. هر وقت بخواه قطع کن.';

  @override
  String rdConnectedAppsFoot(int count) {
    return '$count منبع برای اتصال در دسترس است';
  }

  @override
  String get rdConnectedAppsUnavailable => 'اتصال‌ها هنوز در دسترس نیستند';

  @override
  String get rdConnectedAppsManagedByComposio =>
      'اتصال خصوصی OAuth با مدیریت Composio';

  @override
  String get rdConnectedAppsAuthorizing => 'تکمیل اتصال';

  @override
  String get rdConnectedAppsOpenFailed => 'صفحه امن اتصال باز نشد.';

  @override
  String get rdAppearanceTitle => 'ظاهر';

  @override
  String get rdAppearanceIntro => 'میرا را مال خودت کن — رنگ، کنتراست و آرامش.';

  @override
  String get rdAppearanceSectionTheme => 'تم';

  @override
  String get rdAppearanceThemeSystem => 'سیستم';

  @override
  String get rdAppearanceThemeLight => 'روشن';

  @override
  String get rdAppearanceThemeDark => 'تیره';

  @override
  String get rdAppearanceDarkModeHint =>
      'حالت تیره روشن است — برای خواندن آرام در نور کم.';

  @override
  String get rdAppearanceSectionAccent => 'رنگ تأکید';

  @override
  String get rdAppearanceAccentPeriwinkle => 'یاسی';

  @override
  String get rdAppearanceAccentSage => 'مریم‌گلی';

  @override
  String get rdAppearanceAccentClay => 'خاکی';

  @override
  String get rdAppearanceAccentPlum => 'آلویی';

  @override
  String get rdAppearanceAccentCustom => 'سفارشی';

  @override
  String get rdAppearanceSectionTextSize => 'اندازه متن';

  @override
  String get rdAppearanceTextSmall => 'کوچک';

  @override
  String get rdAppearanceTextDefault => 'پیش‌فرض';

  @override
  String get rdAppearanceTextLarge => 'بزرگ';

  @override
  String get rdAppearancePreviewText =>
      'میرا خاطراتت را واضح و خوانا نگه می‌دارد.';

  @override
  String get rdAppearanceReduceMotion => 'کاهش حرکت';

  @override
  String get rdAppearanceReduceMotionSub => 'انتقال‌های آرام‌تر و حرکت کمتر';

  @override
  String get rdAppearanceSectionAppIcon => 'آیکن اپ';

  @override
  String get rdAppearanceIconDefault => 'پیش‌فرض';

  @override
  String get rdAppearanceIconSage => 'مریم‌گلی';

  @override
  String get rdAppearanceIconDusk => 'غروب';

  @override
  String get rdAppearanceFoot => 'تغییرات ظاهر فوراً اعمال می‌شود.';

  @override
  String get rdStorageTitle => 'فضای ذخیره';

  @override
  String get rdStorageIntro => 'آنچه میرا نگه داشته و چقدر جا مانده.';

  @override
  String get rdStorageUpdating => 'در حال به‌روزرسانی مصرف…';

  @override
  String get rdStorageSectionBreakdown => 'جزئیات';

  @override
  String get rdStorageSectionManage => 'مدیریت';

  @override
  String get rdStorageClearArchived => 'پاک کردن بایگانی';

  @override
  String get rdStorageClearArchivedSub => 'ثبت‌های بایگانی‌شده را حذف کن';

  @override
  String get rdStorageOffloadCloud => 'انتقال اصل به ابر';

  @override
  String get rdStorageOffloadCloudSub =>
      'نسخه با کیفیت کامل در سرویس متصل نگه دار';

  @override
  String get rdStorageFoot => 'میرا فقط آنچه تأیید می‌کنی نگه می‌دارد.';

  @override
  String get rdStorageCategoryPhotos => 'عکس‌ها';

  @override
  String get rdStorageCategoryVoice => 'صدا';

  @override
  String get rdStorageCategoryScreenshots => 'اسکرین‌شات';

  @override
  String get rdStorageCategoryNotes => 'یادداشت‌ها';

  @override
  String get rdStorageCategoryLinks => 'لینک‌ها';

  @override
  String get rdStorageCategoryOther => 'سایر';

  @override
  String get rdStorageEmpty => 'خالی';

  @override
  String rdStorageItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد',
      one: '۱ مورد',
    );
    return '$_temp0';
  }

  @override
  String rdStorageOfQuota(String quota) {
    return 'از $quota';
  }

  @override
  String get rdStorageNoArchived => 'مورد بایگانی برای پاک کردن نیست';

  @override
  String rdStorageCleared(int count, String freed) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد بایگانی پاک شد',
      one: '۱ مورد بایگانی پاک شد',
    );
    return '$_temp0$freed';
  }

  @override
  String rdStorageFreedSuffix(String amount) {
    return ' · $amount آزاد شد';
  }

  @override
  String get rdStorageClearFailed => 'پاک کردن بایگانی ممکن نشد';

  @override
  String get rdRemindersTitle => 'یادآورها';

  @override
  String get rdRemindersSubtitleEmpty => 'چیزی منتظر تو نیست';

  @override
  String get rdRemindersSubtitleOne => '۱ چیز که میرا برایت نگه داشته';

  @override
  String rdRemindersSubtitleMany(int count) {
    return '$count چیز که میرا برایت نگه داشته';
  }

  @override
  String get rdRemindersSectionOverdue => 'عقب‌افتاده';

  @override
  String get rdRemindersSectionToday => 'امروز';

  @override
  String get rdRemindersSectionUpcoming => 'پیش‌رو';

  @override
  String get rdRemindersSectionWaiting => 'وقتی لحظه مناسب برسد';

  @override
  String get rdRemindersSectionDone => 'انجام‌شده';

  @override
  String get rdRemindersEmptyTitle => 'هنوز یادآوری نیست';

  @override
  String get rdRemindersEmptyBody =>
      'از میرا بخواه چیزی را یادآوری کند،\nاینجا جا می‌گیرد.';

  @override
  String get rdRemindersMarkedDone => 'انجام‌شده علامت خورد';

  @override
  String get rdRemindersBackOnList => 'برگشت به لیست';

  @override
  String get rdRemindersSnoozedTomorrow => 'تا فردا به تعویق افتاد';

  @override
  String get rdRemindersDeleted => 'یادآور حذف شد';

  @override
  String get rdRemindersSet => 'یادآور تنظیم شد';

  @override
  String get rdRemindersUntitled => 'یادآور بدون عنوان';

  @override
  String get rdRemindersFromMemory => 'از یک خاطره';

  @override
  String get rdRemindersDone => 'انجام شد';

  @override
  String get rdRemindersSnooze => 'بعداً';

  @override
  String get rdRemindersOverdue => 'عقب‌افتاده';

  @override
  String rdRemindersOverdueByHours(int hours) {
    return '$hours ساعت عقب';
  }

  @override
  String get rdRemindersOverdueSinceYesterday => 'از دیروز عقب افتاده';

  @override
  String rdRemindersOverdueByDays(int days) {
    return '$days روز عقب';
  }

  @override
  String get rdRemindersNow => 'الان';

  @override
  String rdRemindersInMinutes(int minutes) {
    return 'تا $minutes دقیقه';
  }

  @override
  String rdRemindersInHours(int hours) {
    return 'تا $hours ساعت';
  }

  @override
  String get rdRemindersTomorrow => 'فردا';

  @override
  String rdRemindersInDays(int days) {
    return 'تا $days روز';
  }

  @override
  String get rdRemindersComposeTitle => 'یادآور جدید';

  @override
  String get rdRemindersComposeHint => 'یادآوری کن که…';

  @override
  String get rdRemindersWhenLabel => 'کی';

  @override
  String get rdRemindersLaterToday => 'امروز بعداً';

  @override
  String get rdRemindersThisEvening => 'امشب';

  @override
  String get rdRemindersNextWeek => 'هفته آینده';

  @override
  String get rdRemindersPickDateTime => 'انتخاب تاریخ و ساعت';

  @override
  String get rdRemindersSetReminder => 'تنظیم یادآور';

  @override
  String get rdRemindersTranscribing => 'در حال تبدیل به متن…';

  @override
  String get rdHomeRecentsEmpty => 'خاطرات اخیرت اینجا ظاهر می‌شوند.';

  @override
  String get rdHomeRemindAgain => 'دوباره یادآوری کن…';

  @override
  String rdHomeSnoozed(String label) {
    return 'به تعویق افتاد · $label';
  }

  @override
  String get rdHomeLaterToday => 'بعداً امروز';

  @override
  String rdHomeInDays(int days) {
    return 'تا $days روز دیگر';
  }

  @override
  String get rdHomeKindNote => 'یادداشت';

  @override
  String get rdHomeKindVoice => 'صدا';

  @override
  String rdHomeLinksCount(int count) {
    return '$count لینک';
  }

  @override
  String rdCanvasMapContext(int memories, int connections) {
    return 'حافظه‌ات · $memories خاطره · $connections ارتباط';
  }

  @override
  String rdCanvasClusterContext(int clusters, int memories) {
    return '$clusters خوشه · $memories خاطره';
  }

  @override
  String get rdCanvasMergeSuccess => 'خاطرات ادغام شد';

  @override
  String get rdCanvasMergeFail => 'ادغام ممکن نشد';

  @override
  String get rdCanvasUnlinkSuccess => 'ارتباط حذف شد';

  @override
  String get rdCanvasUnlinkFail => 'حذف ارتباط ممکن نشد';

  @override
  String get rdCanvasSyncPending =>
      'با اطمینان ثبت شد — گراف حافظه در حال همگام‌سازی است';

  @override
  String get rdCaptureSyncPending =>
      'حافظه ذخیره شد؛ ارتباط‌ها در حال همگام‌سازی‌اند';

  @override
  String get rdCaptureSyncComplete => 'ارتباط‌های حافظه آماده شدند';

  @override
  String get rdCaptureSyncFailed =>
      'حافظه ذخیره شد، اما همگام‌سازی ارتباط‌ها نیاز به تلاش دوباره دارد';

  @override
  String get rdCaptureMemorySaveFailed =>
      'ذخیره این حافظه تأیید نشد؛ لطفاً دوباره تلاش کن.';

  @override
  String get rdCanvasSplitMixedIdentity => 'جدا کردن هویت‌های ترکیب‌شده';

  @override
  String rdCanvasSplitIdentity(String label) {
    return 'جدا کردن اطلاعات از «$label»';
  }

  @override
  String get rdCanvasSplitHint =>
      'هویت واقعی جدا را توصیف کن، سپس فقط اطلاعات متعلق به همان هویت را انتخاب کن.';

  @override
  String get rdCanvasSplitDescription => 'نشانهٔ هویت؛ مثلاً تعمیرکار شهرک غرب';

  @override
  String get rdCanvasSplitSelectFacts => 'اطلاعاتی که منتقل می‌شوند';

  @override
  String get rdCanvasSplitApply => 'ساخت هویت جدا';

  @override
  String get rdCanvasSplitSuccess => 'هویت جدا شد و ارتباط‌ها حفظ شدند';

  @override
  String get rdCanvasSplitFail => 'جدا کردن این هویت ممکن نشد';

  @override
  String get rdCanvasSplitNoFacts =>
      'اطلاعات قابل‌انتقالی برای این هویت پیدا نشد';

  @override
  String get rdCanvasIdentityAmbiguous =>
      'چند نفر با این نام در حافظه‌ات هست. از برچسب نقش/شهر برای تشخیص استفاده کن.';

  @override
  String get rdCanvasIdentityMergedSmell =>
      'فکت‌های این فرد قاطی به‌نظر می‌رسد (مثلاً نقش استارت‌آپ و تعمیرکار). بهتر است هویت‌ها را جدا کنی.';

  @override
  String get rdCanvasIdentityAmbiguousAction => 'جدا کردن هویت‌های قاطی‌شده';

  @override
  String get rdCanvasMyBoard => 'بورد من';

  @override
  String get rdCanvasNewBoard => 'بورد جدید';

  @override
  String get rdCanvasBoardDefault => 'بورد';

  @override
  String rdCanvasBoardLabel(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارت',
      one: '۱ کارت',
    );
    return '$name · $_temp0';
  }

  @override
  String get rdCanvasRenameTitle => 'تغییر نام بورد';

  @override
  String get rdCanvasBoardNameHint => 'نام بورد';

  @override
  String get rdCanvasLoading => 'در حال بارگذاری…';

  @override
  String get rdCanvasBoardsHeader => 'بوردها';

  @override
  String get rdCanvasUntitledBoard => 'بورد بدون عنوان';

  @override
  String rdCanvasCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارت',
      one: '۱ کارت',
    );
    return '$_temp0';
  }

  @override
  String rdCanvasLinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'خاطره',
      one: 'خاطره',
    );
    return '$count $_temp0 وصل.';
  }

  @override
  String get rdCanvasNodePerson => 'شخص';

  @override
  String get rdCanvasNodeTask => 'کار';

  @override
  String get rdCanvasNodeEvent => 'رویداد';

  @override
  String get rdCanvasNodeNote => 'یادداشت';

  @override
  String get rdCanvasNodeBook => 'کتاب';

  @override
  String get rdCanvasNodeIdea => 'ایده';

  @override
  String get rdCanvasNodeTopic => 'موضوع';

  @override
  String get rdCanvasNodeOrganization => 'شرکت';

  @override
  String get rdCanvasNodeProject => 'پروژه';

  @override
  String get rdCanvasNodePlace => 'مکان';

  @override
  String get rdCanvasClusterTasks => 'کارها';

  @override
  String get rdCanvasClusterBooks => 'کتاب‌ها و ایده‌ها';

  @override
  String get rdCanvasClusterEvents => 'رویدادها';

  @override
  String get rdCanvasClusterNotes => 'یادداشت‌ها و خاطرات';

  @override
  String get rdCanvasNoClusters => 'هنوز خوشه‌ای نیست';

  @override
  String get rdCanvasGraphEmpty => 'گراف حافظه‌ات خالی است';

  @override
  String rdCanvasFocusedOn(String label) {
    return 'تمرکز روی $label';
  }

  @override
  String get rdCanvasTapExplore => 'روی خاطره بزن · بکش و کاوش کن';

  @override
  String rdCanvasMergeInto(String label) {
    return 'ادغام در «$label»';
  }

  @override
  String get rdCanvasMergePickDuplicate =>
      'تکراری را انتخاب کن — همه ارتباط‌ها حفظ می‌شوند.';

  @override
  String get rdCanvasFocusConstellation => 'تمرکز روی این خوشه';

  @override
  String get rdCanvasMergeDuplicate => 'ادغام تکراری';

  @override
  String rdCanvasConnectedTo(int count) {
    return 'وصل به $count';
  }

  @override
  String get rdCanvasCardRemoved => 'کارت حذف شد';

  @override
  String get rdCanvasNewNoteTitle => 'یادداشت جدید';

  @override
  String get rdCanvasNewNoteSub => 'برای ویرایش بعداً بزن.';

  @override
  String get rdCanvasEditCard => 'ویرایش کارت';

  @override
  String get rdCanvasEditTitle => 'عنوان';

  @override
  String get rdCanvasEditNoteOptional => 'یادداشت (اختیاری)';

  @override
  String get rdCanvasBoardEmpty => 'این بورد خالی است';

  @override
  String get rdCanvasConnectTapSecond => 'حالا کارت دیگر را برای وصل کردن بزن';

  @override
  String get rdCanvasConnectMode => 'حالت وصل · دو کارت را بزن';

  @override
  String get rdCanvasAddMode => 'حالت افزودن · هر جا بزن تا کارت بیفتد';

  @override
  String rdCanvasEdgeWithPerson(String person) {
    return 'با $person';
  }

  @override
  String get rdCanvasEdgeReminder => 'یادآور';

  @override
  String get rdCanvasEdgeToRead => 'برای خواندن';

  @override
  String get rdCanvasEdgeRelated => 'مرتبط';

  @override
  String get rdPaywallPlanSaveBadge => '۲ ماه رایگان';

  @override
  String get rdPaywallPlanPerMonth => '/ماه';

  @override
  String get rdPaywallPlanAnnualNote => '۷۲ دلار سالانه';

  @override
  String rdPaywallFinePrint(String then) {
    return '$then · هر وقت لغو کن.\nامروز هزینه‌ای نیست — قبل از پایان یادآوری می‌کنیم.';
  }

  @override
  String get rdPaywallMemPlan => 'طرح';

  @override
  String get rdPaywallMemPlanValue => 'سالانه · ۶ دلار/ماه';

  @override
  String get rdPaywallMemRenews => 'تمدید';

  @override
  String get rdPaywallMemRenewsValue => '۱۲ اوت ۲۰۲۵';

  @override
  String get rdPaywallMemPayment => 'پرداخت';

  @override
  String get rdPaywallMemPaymentValue => 'Apple ID';

  @override
  String get rdPaywallMemoriesHeld => 'خاطرات نگه‌داشته‌شده';

  @override
  String rdPaywallMemoriesCount(String count) {
    return '$count · نامحدود';
  }

  @override
  String get rdPaywallMemoriesGrowth =>
      'آرام رشد می‌کند. در نسخه رایگان در ۲٬۰۰۰ متوقف می‌شد.';

  @override
  String get rdPaywallPerksLabel => 'مزایای پلاس تو';

  @override
  String get rdPaywallPerkUnlimited => 'خاطرات نامحدود';

  @override
  String get rdPaywallPerkGraph => 'گراف کامل حافظه';

  @override
  String get rdPaywallPerkVoice => 'تاریخچه طولانی‌تر و صدای ۱۰ دقیقه‌ای';

  @override
  String get rdPaywallPerkConnect => 'اپ‌های متصل نامحدود';

  @override
  String get rdSetupSkip => 'رد کردن';

  @override
  String get rdSetupContinue => 'ادامه';

  @override
  String get rdSetupPickFew => 'چند مورد انتخاب کن';

  @override
  String get rdSetupWelcomeTitle => 'بیایید\nذهن دومت را بسازیم.';

  @override
  String get rdSetupWelcomeDesc =>
      'چند سؤال کوتاه تا میرا مثل تو به خاطر بسپارد. حدود دو دقیقه — و بعداً هر وقت بخواهی عوض می‌کنی.';

  @override
  String get rdSetupBeginSetup => 'شروع راه‌اندازی';

  @override
  String get rdSetupSkipForNow => 'فعلاً رد کن';

  @override
  String get rdSetupAddressTitle => 'میرا باید\nتو را چه صدا کند؟';

  @override
  String get rdSetupAddressDesc =>
      'خلاصه روزانه و یادآورها با این نام سلام می‌کنند.';

  @override
  String get rdSetupNameHint => 'نام تو';

  @override
  String get rdSetupToneLabel => 'چطور حرف بزند؟';

  @override
  String get rdSetupToneCalm => 'آرام';

  @override
  String get rdSetupToneCalmSub => 'ملایم و بدون عجله';

  @override
  String get rdSetupToneConcise => 'مختصر';

  @override
  String get rdSetupToneConciseSub => 'کوتاه و روشن';

  @override
  String get rdSetupToneWarm => 'صمیمی';

  @override
  String get rdSetupToneWarmSub => 'دوستانه و شخصی';

  @override
  String get rdSetupFocusTitle => 'چه چیزهایی\nبرایت مهم است؟';

  @override
  String get rdSetupFocusDesc =>
      'میرا خاطرات را دور این‌ها خوشه می‌کند. هر کدام که مناسب است انتخاب کن.';

  @override
  String get rdSetupFocusWork => 'کار و پروژه‌ها';

  @override
  String get rdSetupFocusIdeas => 'ایده‌ها و جرقه‌ها';

  @override
  String get rdSetupFocusPeople => 'افراد';

  @override
  String get rdSetupFocusReading => 'خواندن و لینک‌ها';

  @override
  String get rdSetupFocusHealth => 'سلامت';

  @override
  String get rdSetupFocusMoney => 'پول';

  @override
  String get rdSetupFocusTravel => 'سفر و مکان‌ها';

  @override
  String get rdSetupFocusLearning => 'یادگیری';

  @override
  String get rdSetupPeopleTitle => 'چه کسانی\nبرایت مهم‌اند؟';

  @override
  String get rdSetupPeopleDesc =>
      'میرا ثبت‌ها را به افراد زندگی‌ات وصل می‌کند. چند نفر اضافه کن — اسم کوچک کافی است.';

  @override
  String get rdSetupPeopleHint => 'نام اضافه کن';

  @override
  String get rdSetupPeopleEmpty =>
      'هنوز کسی نیست — میرا با ثبت‌ها یاد می‌گیرد.';

  @override
  String get rdSetupRhythmTitle => 'خلاصه روزانه\nکی برسد؟';

  @override
  String get rdSetupRhythmDesc =>
      'یک خلاصه آرام روزانه از آنچه به تو نیاز دارد — نه بیشتر.';

  @override
  String get rdSetupRhythmMorning => 'صبح';

  @override
  String get rdSetupRhythmMidday => 'ظهر';

  @override
  String get rdSetupRhythmEvening => 'عصر';

  @override
  String get rdSetupQuietHours => 'ساعات سکوت';

  @override
  String get rdSetupQuietHoursSub => 'بدون نudge از ۲۲:۰۰ تا ۰۷:۰۰';

  @override
  String get rdSetupPrivacyTitle => 'حافظه‌ات\nمال خودت می‌ماند.';

  @override
  String get rdSetupPrivacyDesc =>
      'قبل از اتصال چیزی، این وعده‌ای است که میرا روی آن ساخته شده.';

  @override
  String get rdSetupPrivacyProcessed => 'پردازش خصوصی';

  @override
  String get rdSetupPrivacyProcessedSub =>
      'هر جا ممکن باشد روی دستگاه تحلیل می‌شود.';

  @override
  String get rdSetupPrivacyEncrypted => 'رمزگذاری سرتاسری';

  @override
  String get rdSetupPrivacyEncryptedSub =>
      'فقط تو خاطرات را می‌خوانی — حتی میرا نه.';

  @override
  String get rdSetupPrivacyNeverSold => 'هرگز فروخته نمی‌شود';

  @override
  String get rdSetupPrivacyNeverSoldSub =>
      'داده‌ات را نمی‌فروشیم و به اشتراک نمی‌گذاریم. بدون تبلیغ، بدون استثنا.';

  @override
  String get rdSetupChoicesLabel => 'انتخاب‌های تو';

  @override
  String get rdSetupSyncDevices => 'همگام‌سازی بین دستگاه‌ها';

  @override
  String get rdSetupSyncDevicesSub =>
      'پشتیبان رمزگذاری‌شده تا حافظه همراهت بماند.';

  @override
  String get rdSetupHelpImprove => 'کمک به بهتر شدن میرا';

  @override
  String get rdSetupHelpImproveSub =>
      'استفاده ناشناس و تجمیع‌شده — نه محتوای تو.';

  @override
  String get rdSetupSourcesTitle => 'دنیایت را\nوصل کن.';

  @override
  String get rdSetupSourcesDesc =>
      'به میرا یک شروع بده. فقط آنچه وصل می‌کنی را می‌خواند و خصوصی پردازش می‌کند.';

  @override
  String get rdSetupSourceCalendar => 'تقویم';

  @override
  String get rdSetupSourceCalendarSub => 'جلسات به خلاصه روزانه می‌روند';

  @override
  String get rdSetupSourceNotes => 'یادداشت‌ها';

  @override
  String get rdSetupSourceNotesSub => 'افکار نوشته‌شده‌ات';

  @override
  String get rdSetupSourcePhotos => 'عکس‌ها';

  @override
  String get rdSetupSourcePhotosSub => 'اسکرین‌شات و اسکن';

  @override
  String get rdSetupSourceGmail => 'Gmail';

  @override
  String get rdSetupSourceGmailSub => 'ایمیل‌های مهم';

  @override
  String get rdSetupImportTitle => 'یادداشت‌ها را\nبا خودت بیاور.';

  @override
  String get rdSetupImportDesc =>
      'جای دیگر یادداشت داری؟ یک‌بار وارد کن تا میرا در گراف ببافد. از اپ اصلی چیزی حذف نمی‌شود.';

  @override
  String rdSetupImportNotesFound(String count) {
    return 'حدود $count یادداشت یافت شد';
  }

  @override
  String get rdSetupImportLater => 'می‌توانی بعداً از تنظیمات وارد کنی.';

  @override
  String get rdSetupImportBackground =>
      'میرا در پس‌زمینه وارد می‌کند — همین الان شروع کن.';

  @override
  String rdSetupImportCta(String count) {
    return 'وارد کردن $count یادداشت';
  }

  @override
  String get rdSetupPermissionsTitle => 'بگذار میرا\nآرام کمک کند.';

  @override
  String get rdSetupPermissionsDesc =>
      'دو مجوز، هر دو اختیاری. هر وقت بخواهی خاموش کن.';

  @override
  String get rdSetupMicTitle => 'میکروفون';

  @override
  String get rdSetupMicSub => 'هر وقت بخواهی با صدا ثبت کنی';

  @override
  String get rdSetupNotifTitle => 'اعلان‌ها';

  @override
  String get rdSetupNotifSub => 'فقط خلاصه روزانه و یادآورهایی که تنظیم می‌کنی';

  @override
  String get rdSetupWeavingTitle => 'در حال بافت\nحافظه…';

  @override
  String rdSetupWeavingDesc(String line) {
    return 'میرا $line را به شکل ذهنت می‌چیند.';
  }

  @override
  String get rdSetupWeavingPreferences => 'ترجیحاتت';

  @override
  String rdSetupWeavingFocusAreas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حوزه تمرکز',
      one: '۱ حوزه تمرکز',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نفر',
      one: '۱ نفر',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منبع',
      one: '۱ منبع',
    );
    return '$_temp0';
  }

  @override
  String rdSetupWeavingImported(String count) {
    return '$count یادداشت واردشده';
  }

  @override
  String get rdSetupReadyTitle => 'ذهن دومت\nآماده است.';

  @override
  String rdSetupReadyDesc(String name) {
    return 'از اینجا به بعد هر چیزی ثبت کنی، $name، جایی برای ماندن دارد — و راهی برای برگشت به تو.';
  }

  @override
  String get rdSetupReadyYou => 'تو';

  @override
  String get rdSetupTakeTour => 'یک تور کوتاه';

  @override
  String get rdSetupSkipTour => 'رد کردن تور';

  @override
  String get rdSetupTour1Title => 'یک جا برای ثبت';

  @override
  String get rdSetupTour1Body =>
      'بنویس، بگو یا عکس بگیر — هر چیزی که ذخیره می‌کنی از اینجا شروع می‌شود.';

  @override
  String get rdSetupTour2Title => 'همه‌چیز اینجا می‌نشیند';

  @override
  String get rdSetupTour2Body =>
      'هر ثبت به خط زمانی می‌پیوندد، از قبل به آنچه مربوط است وصل.';

  @override
  String get rdSetupTour3Title => 'از هر جا ثبت کن';

  @override
  String get rdSetupTour3Body =>
      'هر وقت میک را بزن — حتی وسط گفتگو — یک فکر را در یک نفس ذخیره کن.';

  @override
  String get rdSetupTour4Title => 'آرام جابه‌جا شو';

  @override
  String get rdSetupTour4Body =>
      'خانه، کتابخانه، بوم و خلاصه روزانه این پایین‌اند.';

  @override
  String get rdSetupTourSkip => 'رد کردن تور';

  @override
  String get rdSetupTourNext => 'بعدی';

  @override
  String get rdSetupTourFinish => 'پایان';

  @override
  String get rdSetupInviteTitle => 'به کسی\nذهنی آرام‌تر بده.';

  @override
  String get rdSetupInviteDesc =>
      'میرا با کسانی که کنارشان فکر می‌کنی بهتر است. چند نفر دعوت کن — از صف رد می‌شوند و هر دو یک ماه پلاس می‌گیرید.';

  @override
  String get rdSetupInviteCodeLabel => 'کد دعوت تو';

  @override
  String get rdSetupCopy => 'کپی';

  @override
  String get rdSetupCopied => 'کپی شد';

  @override
  String get rdSetupChannelMessages => 'پیام';

  @override
  String get rdSetupChannelMail => 'ایمیل';

  @override
  String get rdSetupChannelCopyLink => 'کپی لینک';

  @override
  String get rdSetupShareInvite => 'اشتراک دعوت';

  @override
  String get rdSetupMaybeLater => 'شاید بعداً';
}
