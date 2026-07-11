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
}
