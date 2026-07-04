import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/capture_workflow_initial_action.dart';
import 'package:mira_app/features/capture/screens/capture_workflow_screen.dart';
import 'package:mira_app/features/capture/screens/voice_recording_screen.dart';
import 'package:mira_app/features/daily_brief/daily_brief_repository.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_screen.dart';
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
  CaptureUiPhase? _lastCapturePhase;
  var _briefItems = const <BriefItem>[];
  var _briefLoading = true;
  Object? _briefError;

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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _briefLoading = false;
        _briefError = error;
      });
    }
  }

  void _openTextPrompt() {
    _flow?.openTextPrompt();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = _flow!;
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / HomeScreenTokens.designWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final processing = flow.isProcessing;
    final tasks = _briefItems.whereType<BriefTask>().take(3).toList();

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
              SizedBox(height: 18 * scale),
              _HomeHeroPanel(
                processing: processing,
                title: processing
                    ? l10n.homeProcessingTitle
                    : l10n.homeGreeting,
                subtitle: processing
                    ? l10n.homeProcessingSubtitle
                    : l10n.homeSubtitle,
                answer: flow.lastAnswer,
              ),
              const SizedBox(height: 18),
              _QuickCapturePanel(
                title: l10n.homeQuickCaptureTitle,
                prompt: l10n.homeQuickCapturePrompt,
                onPromptTap: _openTextPrompt,
                actions: [
                  _HomeAction(
                    icon: Icons.keyboard_alt_outlined,
                    title: l10n.homeTextActionTitle,
                    subtitle: l10n.homeTextActionSubtitle,
                    color: const Color(0xFF4A6EFF),
                    onTap: _openTextPrompt,
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
                    onTap: () =>
                        _openCaptureAction(CaptureWorkflowInitialAction.camera),
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
                    onTap: _openTextPrompt,
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
    this.answer,
  });

  final bool processing;
  final String title;
  final String subtitle;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = answer != null && answer!.trim().isNotEmpty;
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.dosis(size: 22, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  hasAnswer ? answer! : subtitle,
                  maxLines: hasAnswer ? 5 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.dosis(
                    size: 15,
                  ).copyWith(color: AppColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
        ],
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
  });

  final String title;
  final String prompt;
  final List<_HomeAction> actions;
  final VoidCallback onPromptTap;

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
  const _HomeSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
