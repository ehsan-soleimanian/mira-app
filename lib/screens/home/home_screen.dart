import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/notifications/notification_service.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/capture_workflow_initial_action.dart';
import 'package:mira_app/features/capture/screens/capture_workflow_screen.dart';
import 'package:mira_app/features/capture/screens/voice_recording_screen.dart';
import 'package:mira_app/features/capture/utils/answer_text_sanitizer.dart';
import 'package:mira_app/features/daily_brief/daily_brief_repository.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_screen.dart';
import 'package:mira_app/screens/workspace/canvas_workspace_screen.dart';
import 'package:mira_app/screens/workspace/library_screen.dart';
import 'package:mira_app/screens/workspace/tasks_brief_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

/// Home as a single capture workspace: text, voice, media, reminders, graph.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CaptureFlowController? _flow;
  DailyBriefRepository? _dailyBriefRepository;
  NotificationService? _notificationService;
  CaptureUiPhase? _lastCapturePhase;
  var _briefItems = const <BriefItem>[];
  var _briefLoading = true;
  Object? _briefError;
  var _activeTab = NavTab.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBrief());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppScope.servicesOf(context);
    _dailyBriefRepository = services.dailyBriefRepository;
    _notificationService = services.notificationService;

    final next = services.captureFlow;
    if (!identical(next, _flow)) {
      _flow?.removeListener(_onFlowChanged);
      _flow = next;
      _lastCapturePhase = next.phase;
      next.addListener(_onFlowChanged);
    }
  }

  @override
  void dispose() {
    _flow?.removeListener(_onFlowChanged);
    super.dispose();
  }

  void _onFlowChanged() {
    final phase = _flow?.phase;
    final finishedCapture =
        _lastCapturePhase != null &&
        _lastCapturePhase != CaptureUiPhase.idle &&
        phase == CaptureUiPhase.idle;
    _lastCapturePhase = phase;
    if (mounted) setState(() {});
    if (finishedCapture) {
      unawaited(_loadBrief(showLoader: false));
    }
  }

  Future<void> _loadBrief({bool showLoader = true}) async {
    final repository = _dailyBriefRepository;
    if (repository == null) return;
    if (showLoader && mounted) {
      setState(() {
        _briefLoading = true;
        _briefError = null;
      });
    }
    try {
      final response = await repository.fetchDailyUpdate();
      if (!mounted) return;
      setState(() {
        _briefItems = DailyBriefData.fromDailyUpdateItems(response.items);
        _briefLoading = false;
        _briefError = null;
      });
      unawaited(_syncTaskNotifications(_briefItems));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _briefLoading = false;
        _briefError = error;
      });
    }
  }

  Future<void> _syncTaskNotifications(List<BriefItem> items) async {
    final service = _notificationService;
    if (service == null) return;
    await service.syncTaskReminders(
      items
          .whereType<BriefTask>()
          .where((task) {
            final dueAt = task.dueAt;
            return dueAt != null && !task.isCompleted;
          })
          .map(
            (task) => TaskReminderRequest(
              taskId: task.id,
              title: task.title,
              dueAt: task.dueAt!,
              body: task.summary.isEmpty ? task.title : task.summary,
            ),
          ),
    );
  }

  void _openTextPrompt([String? draftText]) {
    _flow?.openTextPrompt(draftText);
  }

  Future<void> _startVoiceCapture() async {
    final flow = _flow;
    if (flow == null) return;
    await flow.startRecording();
    if (!mounted || flow.phase != CaptureUiPhase.recording) return;
    await Navigator.of(context).pushMira((_) => const VoiceRecordingScreen());
  }

  void _openCaptureAction(CaptureWorkflowInitialAction action) {
    Navigator.of(
      context,
    ).pushMira((_) => CaptureWorkflowScreen(initialAction: action));
  }

  void _openDailyBrief() {
    Navigator.of(context).pushMira((_) => const DailyBriefScreen());
  }

  void _openMemoryGraph() {
    Navigator.of(context).pushMira((_) => const MemoryGraphScreen());
  }

  void _selectTab(NavTab tab) {
    if (_activeTab == tab) return;
    setState(() => _activeTab = tab);
  }

  Widget _buildWorkspaceTab() {
    switch (_activeTab) {
      case NavTab.home:
        return const SizedBox.shrink();
      case NavTab.library:
        return const LibraryScreen();
      case NavTab.canvas:
        return const CanvasWorkspaceScreen();
      case NavTab.dailyBrief:
        return const TasksBriefScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_activeTab != NavTab.home) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(bottom: false, child: _buildWorkspaceTab()),
        bottomNavigationBar: AppBottomShell(
          activeTab: _activeTab,
          onHomeTap: () => _selectTab(NavTab.home),
          onLibraryTap: () => _selectTab(NavTab.library),
          onCanvasTap: () => _selectTab(NavTab.canvas),
          onDailyBriefTap: () => _selectTab(NavTab.dailyBrief),
        ),
      );
    }
    final flow = _flow!;
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / HomeScreenTokens.designWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final processing = flow.isProcessing;
    final tasks = _briefItems.whereType<BriefTask>().take(3).toList();
    final displayAnswer = sanitizeAssistantAnswer(flow.lastAnswer ?? '');
    final hasAnswer = displayAnswer.isNotEmpty;
    final answerDirection = hasAnswer
        ? _textDirectionFor(displayAnswer, Directionality.of(context))
        : Directionality.of(context);
    final answerIsPersian = answerDirection == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _loadBrief(showLoader: false),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 136 + bottomInset),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const _HomeTopBar(),
              const SizedBox(height: 12),
              _WorkspaceAccessPanel(
                libraryLabel: l10n.homeWorkspaceLibrary,
                canvasLabel: l10n.homeWorkspaceCanvas,
                onLibraryTap: () => _selectTab(NavTab.library),
                onCanvasTap: () => _selectTab(NavTab.canvas),
              ),
              SizedBox(height: 18 * scale),
              _HomeHeroPanel(
                processing: processing,
                title: processing
                    ? l10n.homeProcessingTitle
                    : l10n.homeGreeting,
                subtitle: processing
                    ? l10n.homeProcessingSubtitle
                    : l10n.homeSubtitle,
                answerTitle: answerIsPersian
                    ? 'برداشت میرا از حافظه‌ات'
                    : l10n.homeAnswerTitle,
                answerSourceLabel: answerIsPersian
                    ? 'بر اساس حافظه تاییدشده'
                    : l10n.homeAnswerSourceLabel,
                answer: displayAnswer,
              ),
              const SizedBox(height: 18),
              if (hasAnswer)
                _ContinueConversationPanel(
                  title: answerIsPersian
                      ? 'گفتگو را ادامه بده'
                      : l10n.homeContinueTitle,
                  prompt: answerIsPersian
                      ? 'سؤال بعدی را همین‌جا بپرس'
                      : l10n.homeContinuePrompt,
                  responseHint: answerIsPersian
                      ? 'پاسخ سؤال بعدی در همین کارت بالایی به‌روزرسانی می‌شود.'
                      : l10n.homeContinueResponseHint,
                  textDirection: answerDirection,
                  onPromptTap: () => _openTextPrompt(),
                  starters: [
                    _PromptStarter(
                      icon: Icons.search_rounded,
                      label: l10n.homeAskStarterLabel,
                      prompt: l10n.homeAskStarterPrompt,
                      color: const Color(0xFF2F80ED),
                    ),
                    _PromptStarter(
                      icon: Icons.bookmark_add_outlined,
                      label: l10n.homeSaveStarterLabel,
                      prompt: l10n.homeSaveStarterPrompt,
                      color: const Color(0xFF18A58A),
                    ),
                    _PromptStarter(
                      icon: Icons.alarm_add_rounded,
                      label: l10n.homeReminderStarterLabel,
                      prompt: l10n.homeReminderStarterPrompt,
                      color: const Color(0xFFDA8A00),
                    ),
                  ],
                  onStarterTap: (starter) => _openTextPrompt(starter.prompt),
                )
              else
                _QuickCapturePanel(
                  title: l10n.homeQuickCaptureTitle,
                  prompt: l10n.homeQuickCapturePrompt,
                  onPromptTap: () => _openTextPrompt(),
                  starters: [
                    _PromptStarter(
                      icon: Icons.search_rounded,
                      label: l10n.homeAskStarterLabel,
                      prompt: l10n.homeAskStarterPrompt,
                      color: const Color(0xFF2F80ED),
                    ),
                    _PromptStarter(
                      icon: Icons.bookmark_add_outlined,
                      label: l10n.homeSaveStarterLabel,
                      prompt: l10n.homeSaveStarterPrompt,
                      color: const Color(0xFF18A58A),
                    ),
                    _PromptStarter(
                      icon: Icons.alarm_add_rounded,
                      label: l10n.homeReminderStarterLabel,
                      prompt: l10n.homeReminderStarterPrompt,
                      color: const Color(0xFFDA8A00),
                    ),
                  ],
                  onStarterTap: (starter) => _openTextPrompt(starter.prompt),
                  actions: [
                    _HomeAction(
                      icon: Icons.keyboard_alt_outlined,
                      title: l10n.homeTextActionTitle,
                      subtitle: l10n.homeTextActionSubtitle,
                      color: const Color(0xFF4A6EFF),
                      onTap: () => _openTextPrompt(),
                    ),
                    _HomeAction(
                      icon: Icons.mic_none_rounded,
                      title: l10n.homeVoiceActionTitle,
                      subtitle: l10n.homeVoiceActionSubtitle,
                      color: const Color(0xFFFF7A59),
                      onTap: () => unawaited(_startVoiceCapture()),
                    ),
                    _HomeAction(
                      icon: Icons.photo_camera_outlined,
                      title: l10n.homePhotoActionTitle,
                      subtitle: l10n.homePhotoActionSubtitle,
                      color: const Color(0xFF18A58A),
                      onTap: () => _openCaptureAction(
                        CaptureWorkflowInitialAction.camera,
                      ),
                    ),
                    _HomeAction(
                      icon: Icons.screenshot_monitor_outlined,
                      title: l10n.homeScreenshotActionTitle,
                      subtitle: l10n.homeScreenshotActionSubtitle,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _openCaptureAction(
                        CaptureWorkflowInitialAction.gallery,
                      ),
                    ),
                    _HomeAction(
                      icon: Icons.notifications_none_rounded,
                      title: l10n.homeReminderActionTitle,
                      subtitle: l10n.homeReminderActionSubtitle,
                      color: const Color(0xFFDA8A00),
                      onTap: () =>
                          _openTextPrompt(l10n.homeReminderStarterPrompt),
                    ),
                    _HomeAction(
                      icon: Icons.account_tree_outlined,
                      title: l10n.homeGraphActionTitle,
                      subtitle: l10n.homeGraphActionSubtitle,
                      color: const Color(0xFF2F80ED),
                      onTap: _openMemoryGraph,
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              _ReminderPanel(
                title: l10n.homeRemindersTitle,
                emptyTitle: l10n.homeRemindersEmptyTitle,
                emptyBody: l10n.homeRemindersEmptyBody,
                openLabel: l10n.homeOpenDailyBrief,
                loading: _briefLoading,
                hasError: _briefError != null,
                tasks: tasks,
                onOpen: _openDailyBrief,
              ),
              const SizedBox(height: 14),
              _GraphPanel(
                title: l10n.homeMemoryGraphTitle,
                body: l10n.homeMemoryGraphBody,
                openLabel: l10n.homeOpenGraph,
                onOpen: _openMemoryGraph,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.home,
        onHomeTap: () => _selectTab(NavTab.home),
        onLibraryTap: () => _selectTab(NavTab.library),
        onCanvasTap: () => _selectTab(NavTab.canvas),
        onDailyBriefTap: _openDailyBrief,
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CatalogButton(size: PageHeaderTokens.actionSize),
        Spacer(),
        SettingsButton(size: PageHeaderTokens.actionSize),
      ],
    );
  }
}

class _HomeHeroPanel extends StatelessWidget {
  const _HomeHeroPanel({
    required this.processing,
    required this.title,
    required this.subtitle,
    required this.answerTitle,
    required this.answerSourceLabel,
    this.answer,
  });

  final bool processing;
  final String title;
  final String subtitle;
  final String answerTitle;
  final String answerSourceLabel;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final answerText = answer?.trim() ?? '';
    final hasAnswer = answerText.isNotEmpty;
    final textDirection = hasAnswer
        ? _textDirectionFor(answerText, Directionality.of(context))
        : Directionality.of(context);

    return Directionality(
      textDirection: textDirection,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7E7EF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: processing
                    ? const Color(0xFFEAF0FF)
                    : const Color(0xFFFFF3EA),
              ),
              child: Icon(
                processing ? Icons.auto_awesome_rounded : Icons.psychology_alt,
                color: processing ? AppColors.accent : const Color(0xFFE66A3C),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: hasAnswer
                  ? _AnswerSummary(
                      title: answerTitle,
                      sourceLabel: answerSourceLabel,
                      answer: answerText,
                      textDirection: textDirection,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: _homeTextStyle(
                            textDirection,
                            size: 22,
                            weight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _homeTextStyle(
                            textDirection,
                            size: 15,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerSummary extends StatelessWidget {
  const _AnswerSummary({
    required this.title,
    required this.sourceLabel,
    required this.answer,
    required this.textDirection,
  });

  final String title;
  final String sourceLabel;
  final String answer;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final parts = _AnswerParts.from(answer, textDirection);
    final isRtl = textDirection == TextDirection.rtl;
    final titleText = isRtl ? 'برداشت میرا از حافظه‌ات' : title;
    final sourceText = isRtl ? 'بر اساس حافظه تاییدشده' : sourceLabel;

    return Column(
      crossAxisAlignment: isRtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 16,
              color: const Color(0xFF18A58A),
            ),
            const SizedBox(width: 6),
            Text(
              sourceText,
              style: _homeTextStyle(
                textDirection,
                size: 12,
                weight: FontWeight.w700,
                color: const Color(0xFF18A58A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          titleText,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          style: _homeTextStyle(
            textDirection,
            size: 21,
            weight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        if (parts.summary != null) ...[
          const SizedBox(height: 8),
          Text(
            parts.summary!,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: _homeTextStyle(
              textDirection,
              size: 15,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
        if (parts.items.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final item in parts.items.take(3)) ...[
            _AnswerFactRow(text: item, textDirection: textDirection),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _AnswerFactRow extends StatelessWidget {
  const _AnswerFactRow({required this.text, required this.textDirection});

  final String text;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final isRtl = textDirection == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAF0FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAF0FF),
            ),
            child: Icon(
              isRtl
                  ? Icons.keyboard_arrow_left_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: _homeTextStyle(
                textDirection,
                size: 14,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerParts {
  const _AnswerParts({this.summary, required this.items});

  final String? summary;
  final List<String> items;

  static _AnswerParts from(String answer, TextDirection textDirection) {
    final displayAnswer = sanitizeAssistantAnswer(answer);
    final lines = displayAnswer
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return const _AnswerParts(summary: null, items: []);

    if (textDirection == TextDirection.rtl && _containsPersian(displayAnswer)) {
      return _fromPersianMixedAnswer(lines);
    }

    String? summary;
    final items = <String>[];
    for (final line in lines) {
      final cleaned = line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
      if (items.isEmpty &&
          summary == null &&
          !RegExp(r'^[-*•]').hasMatch(line) &&
          cleaned.endsWith(':')) {
        summary = _localizedAnswerIntro(cleaned, textDirection);
      } else {
        if (!_isBackendFollowUpQuestion(cleaned)) {
          items.add(_localizedAnswerLine(cleaned, textDirection));
        }
      }
    }

    if (items.isEmpty && summary == null) {
      summary = _localizedAnswerLine(displayAnswer, textDirection);
    }
    return _AnswerParts(summary: summary, items: items);
  }

  static _AnswerParts _fromPersianMixedAnswer(List<String> lines) {
    String? targetTitle;
    String? targetEnglish;
    String? placeName;
    var wantsToVisit = false;

    for (final rawLine in lines) {
      final line = rawLine.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
      if (_isBackendIntro(line) || _isBackendFollowUpQuestion(line)) continue;

      final thereAre = RegExp(
        r'^There are\s+"([^"]+)"\s+\(([^)]+)\)\.?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (thereAre != null) {
        targetTitle ??= thereAre.group(1)?.trim();
        targetEnglish ??= thereAre.group(2)?.trim();
        continue;
      }

      final visit = RegExp(
        r'^You want to visit\s+"([^"]+)"\s+\(([^)]+)\)\.?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (visit != null) {
        wantsToVisit = true;
        targetTitle ??= visit.group(1)?.trim();
        targetEnglish ??= visit.group(2)?.trim();
        continue;
      }

      final place = RegExp(
        r'^"?([^"\[]+)"?\s+\[([^\]]+)\]\s+is a place\.?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (place != null) {
        placeName = place.group(1)?.trim();
      }
    }

    final subject = targetTitle ?? placeName;
    if (subject == null || subject.isEmpty) {
      final cleaned = lines
          .map((line) => line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
          .where(
            (line) =>
                line.isNotEmpty &&
                !_isBackendIntro(line) &&
                !_isBackendFollowUpQuestion(line),
          )
          .join(' ');
      return _AnswerParts(summary: cleaned, items: const []);
    }

    final placePrefix = placeName == null
        ? ''
        : 'وقتی از «$placeName» می‌پرسی، ';
    final englishHint = targetEnglish == null || targetEnglish.isEmpty
        ? ''
        : ' ($targetEnglish)';
    final summary = wantsToVisit
        ? '$placePrefixبرداشت من این است که منظورت «$subject»$englishHint است؛ در حافظه‌ات این موضوع به علاقه یا برنامه‌ات برای بازدید از آن وصل شده.'
        : '$placePrefixبرداشت من این است که منظورت «$subject»$englishHint است؛ این همان مفهوم مرتبطی است که در حافظه‌ات پیدا کردم.';

    final items = <String>[
      if (placeName != null && placeName != subject)
        '«$placeName» را به عنوان مکان و سرنخ اصلی سؤال در نظر گرفتم.',
      if (wantsToVisit)
        'نیت ثبت‌شده در حافظه: دنبال‌کردن یا بازدید از این رویداد.',
    ];

    return _AnswerParts(summary: summary, items: items);
  }
}

TextDirection _textDirectionFor(String value, TextDirection fallback) {
  if (_containsPersian(value)) return TextDirection.rtl;
  final rtl = RegExp(r'[\u0600-\u06FF]').allMatches(value).length;
  final ltr = RegExp(r'[A-Za-z]').allMatches(value).length;
  if (rtl == 0 && ltr == 0) return fallback;
  return rtl >= ltr ? TextDirection.rtl : TextDirection.ltr;
}

TextStyle _homeTextStyle(
  TextDirection direction, {
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  if (direction == TextDirection.rtl) {
    return AppTypography.vazirmatn(
      size: size,
      weight: weight,
      color: color,
      height: height,
    );
  }
  return AppTypography.dosis(
    size: size,
    weight: weight,
    color: color,
    height: height,
  );
}

String _localizedAnswerIntro(String value, TextDirection direction) {
  if (direction != TextDirection.rtl) return value;
  final lower = value.toLowerCase();
  if (lower.startsWith('from the approved memory context')) {
    return 'از حافظه‌های تاییدشده‌ات:';
  }
  return value;
}

String _localizedAnswerLine(String value, TextDirection direction) {
  if (direction != TextDirection.rtl || !_containsPersian(value)) return value;

  final thereAre = RegExp(
    r'^There are\s+"([^"]+)"\s+\(([^)]+)\)\.?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (thereAre != null) {
    return 'در حافظه‌ات ثبت شده: ${thereAre.group(1)} (${thereAre.group(2)}).';
  }

  final visit = RegExp(
    r'^You want to visit\s+"([^"]+)"\s+\(([^)]+)\)\.?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (visit != null) {
    return 'می‌خواهی از ${visit.group(1)} (${visit.group(2)}) بازدید کنی.';
  }

  return value;
}

bool _containsPersian(String value) =>
    RegExp(r'[\u0600-\u06FF]').hasMatch(value);

bool _isBackendIntro(String value) =>
    value.toLowerCase().startsWith('from the approved memory context');

bool _isBackendFollowUpQuestion(String value) =>
    value.toLowerCase().startsWith('would you like to know more');

class _WorkspaceAccessPanel extends StatelessWidget {
  const _WorkspaceAccessPanel({
    required this.libraryLabel,
    required this.canvasLabel,
    required this.onLibraryTap,
    required this.onCanvasTap,
  });

  final String libraryLabel;
  final String canvasLabel;
  final VoidCallback onLibraryTap;
  final VoidCallback onCanvasTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WorkspaceAccessButton(
            icon: Icons.manage_search_rounded,
            label: libraryLabel,
            onTap: onLibraryTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WorkspaceAccessButton(
            icon: Icons.hub_rounded,
            label: canvasLabel,
            onTap: onCanvasTap,
          ),
        ),
      ],
    );
  }
}

class _WorkspaceAccessButton extends StatelessWidget {
  const _WorkspaceAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(size: 13, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCapturePanel extends StatelessWidget {
  const _QuickCapturePanel({
    required this.title,
    required this.prompt,
    required this.actions,
    required this.onPromptTap,
    required this.starters,
    required this.onStarterTap,
  });

  final String title;
  final String prompt;
  final List<_HomeAction> actions;
  final VoidCallback onPromptTap;
  final List<_PromptStarter> starters;
  final ValueChanged<_PromptStarter> onStarterTap;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPromptTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prompt,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(
                          size: 15,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final starter in starters)
                _PromptStarterChip(
                  starter: starter,
                  onTap: () => onStarterTap(starter),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final action in actions)
                    SizedBox(
                      width: tileWidth,
                      child: _HomeActionTile(action: action),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContinueConversationPanel extends StatelessWidget {
  const _ContinueConversationPanel({
    required this.title,
    required this.prompt,
    required this.responseHint,
    required this.textDirection,
    required this.onPromptTap,
    required this.starters,
    required this.onStarterTap,
  });

  final String title;
  final String prompt;
  final String responseHint;
  final TextDirection textDirection;
  final VoidCallback onPromptTap;
  final List<_PromptStarter> starters;
  final ValueChanged<_PromptStarter> onStarterTap;

  @override
  Widget build(BuildContext context) {
    final direction = textDirection;
    final isRtl = direction == TextDirection.rtl;
    return Directionality(
      textDirection: direction,
      child: _HomeSection(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: isRtl
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: _homeTextStyle(
                direction,
                size: 17,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onPromptTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          prompt,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          style: _homeTextStyle(
                            direction,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        isRtl
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.subdirectory_arrow_left_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    responseHint,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    style: _homeTextStyle(
                      direction,
                      size: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: isRtl ? WrapAlignment.end : WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final starter in starters)
                  _PromptStarterChip(
                    starter: starter,
                    onTap: () => onStarterTap(starter),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptStarter {
  const _PromptStarter({
    required this.icon,
    required this.label,
    required this.prompt,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String prompt;
  final Color color;
}

class _PromptStarterChip extends StatelessWidget {
  const _PromptStarterChip({required this.starter, required this.onTap});

  final _PromptStarter starter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: starter.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(starter.icon, size: 16, color: starter.color),
              const SizedBox(width: 6),
              Text(
                starter.label,
                style: AppTypography.dosis(
                  size: 13,
                  weight: FontWeight.w700,
                ).copyWith(color: starter.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderPanel extends StatelessWidget {
  const _ReminderPanel({
    required this.title,
    required this.emptyTitle,
    required this.emptyBody,
    required this.openLabel,
    required this.loading,
    required this.hasError,
    required this.tasks,
    required this.onOpen,
  });

  final String title;
  final String emptyTitle;
  final String emptyBody;
  final String openLabel;
  final bool loading;
  final bool hasError;
  final List<BriefTask> tasks;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(openLabel),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 2),
          ] else if (tasks.isEmpty) ...[
            const SizedBox(height: 6),
            Text(emptyTitle, style: AppTypography.dosis(size: 15)),
            const SizedBox(height: 4),
            Text(
              hasError ? emptyBody : emptyBody,
              style: AppTypography.dosis(
                size: 13,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ] else ...[
            const SizedBox(height: 4),
            for (final task in tasks) _ReminderRow(task: task),
          ],
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.task});

  final BriefTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: DailyBriefColors.taskBadgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 15,
              color: DailyBriefColors.taskBadgeText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.dosis(size: 15).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.timeLabel,
                  style: AppTypography.dosis(
                    size: 12,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPanel extends StatelessWidget {
  const _GraphPanel({
    required this.title,
    required this.body,
    required this.openLabel,
    required this.onOpen,
  });

  final String title;
  final String body;
  final String openLabel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              color: Color(0xFF2F80ED),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.dosis(size: 17, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.dosis(
                    size: 13,
                  ).copyWith(color: AppColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: openLabel,
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E7EF)),
      ),
      child: child,
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: action.color, size: 24),
              const SizedBox(height: 10),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(size: 15).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(
                  size: 12,
                ).copyWith(color: AppColors.textSecondary, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
