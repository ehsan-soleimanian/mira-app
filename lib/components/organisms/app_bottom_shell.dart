import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/prompt_input_bar.dart';
import 'package:mira_app/core/mira_nav_config.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/screens/capture_workflow_screen.dart';
import 'package:mira_app/features/capture/screens/voice_recording_screen.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Shared bottom shell — tap opens capture workflow, hold starts voice recording.
class AppBottomShell extends StatefulWidget {
  const AppBottomShell({
    super.key,
    required this.activeTab,
    this.variant,
    this.onHomeTap,
    this.onLibraryTap,
    this.onCanvasTap,
    this.onDailyBriefTap,
  });

  final NavTab activeTab;
  final MiraNavVariant? variant;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLibraryTap;
  final VoidCallback? onCanvasTap;
  final VoidCallback? onDailyBriefTap;

  @override
  State<AppBottomShell> createState() => _AppBottomShellState();
}

class _AppBottomShellState extends State<AppBottomShell> {
  bool _showPromptInput = false;
  final _promptController = TextEditingController();
  final _promptFocusNode = FocusNode();
  CaptureFlowController? _flow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = AppScope.servicesOf(context).captureFlow;
    if (!identical(next, _flow)) {
      _flow?.removeListener(_onFlowChanged);
      _flow = next;
      _flow!.addListener(_onFlowChanged);
    }
  }

  @override
  void dispose() {
    _flow?.removeListener(_onFlowChanged);
    _promptFocusNode.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _onFlowChanged() {
    if (!mounted) return;
    if (_flow?.requestTextPrompt == true) {
      final draftText = _flow?.requestedPromptText;
      _flow?.clearTextPromptRequest();
      _openPromptInput(draftText: draftText);
      return;
    }
    setState(() {});
  }

  void _openCaptureWorkflow() {
    Navigator.of(context).pushMira((_) => const CaptureWorkflowScreen());
  }

  Future<void> _startVoiceRecording() async {
    final flow = _flow;
    if (flow == null) return;
    await flow.startRecording();
    if (!mounted || flow.phase != CaptureUiPhase.recording) return;
    await Navigator.of(context).pushMira((_) => const VoiceRecordingScreen());
  }

  void _openPromptInput({String? draftText}) {
    if (draftText != null) {
      _promptController.text = draftText;
      _promptController.selection = TextSelection.collapsed(
        offset: _promptController.text.length,
      );
    }
    setState(() => _showPromptInput = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _promptFocusNode.requestFocus();
    });
  }

  void _closePromptInput() {
    _promptFocusNode.unfocus();
    setState(() {
      _showPromptInput = false;
      _promptController.clear();
    });
  }

  Future<void> _submitPrompt(String value) async {
    final text = _preparePromptForCapture(value.trim());
    if (text.isEmpty) return;
    _closePromptInput();
    await _flow?.submitPrompt(context, text);
  }

  void _onTabTap(NavTab tab) {
    switch (tab) {
      case NavTab.home:
        widget.onHomeTap?.call();
        return;
      case NavTab.library:
        widget.onLibraryTap?.call();
        return;
      case NavTab.canvas:
        widget.onCanvasTap?.call();
        return;
      case NavTab.dailyBrief:
        widget.onDailyBriefTap?.call();
        return;
    }
  }

  double get _recordingProgress {
    final seconds = _flow?.recordingDuration.inSeconds ?? 0;
    return (seconds / 120).clamp(0.0, 1.0);
  }

  bool get _recordingActive => _flow?.phase == CaptureUiPhase.recording;

  @override
  Widget build(BuildContext context) {
    if (_showPromptInput) {
      return PromptInputBar(
        controller: _promptController,
        focusNode: _promptFocusNode,
        onMicTap: _closePromptInput,
        onSend: _submitPrompt,
        onSubmitted: _submitPrompt,
      );
    }

    return _WorkspaceBottomNav(
      activeTab: widget.activeTab,
      onTabTap: _onTabTap,
      onMicTap: _openCaptureWorkflow,
      onRecordingStart: _startVoiceRecording,
      recordingActive: _recordingActive,
      recordingProgress: _recordingProgress,
    );
  }
}

String _preparePromptForCapture(String text) {
  if (text.isEmpty || !_containsPersian(text)) return text;

  const askPrefix = 'what do i know about ';
  final lower = text.toLowerCase();
  if (lower.startsWith(askPrefix)) {
    final topic = text.substring(askPrefix.length).trim();
    if (topic.isNotEmpty) {
      return 'درباره‌ی $topic چه چیزهایی می‌دانی؟ لطفا کامل و فقط فارسی پاسخ بده.';
    }
  }

  if (_looksLikeQuestion(text) && !_asksForPersian(text)) {
    return '$text\nلطفا کامل و فقط فارسی پاسخ بده.';
  }
  return text;
}

bool _containsPersian(String value) =>
    RegExp(r'[\u0600-\u06FF]').hasMatch(value);

bool _asksForPersian(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('فارسی') || normalized.contains('persian');
}

bool _looksLikeQuestion(String value) {
  final lower = value.toLowerCase().trimLeft();
  if (value.contains('?') || value.contains('؟')) return true;
  return lower.startsWith('who ') ||
      lower.startsWith('what ') ||
      lower.startsWith('when ') ||
      lower.startsWith('where ') ||
      lower.startsWith('why ') ||
      lower.startsWith('how ') ||
      lower.startsWith('do ') ||
      lower.startsWith('does ') ||
      lower.startsWith('did ') ||
      lower.startsWith('آیا ') ||
      lower.startsWith('چی ') ||
      lower.startsWith('چه ') ||
      lower.startsWith('کی ') ||
      lower.startsWith('کجا ') ||
      lower.startsWith('چرا ') ||
      lower.startsWith('چطور ') ||
      lower.startsWith('درباره');
}

class _WorkspaceBottomNav extends StatelessWidget {
  const _WorkspaceBottomNav({
    required this.activeTab,
    required this.onTabTap,
    required this.onMicTap,
    required this.onRecordingStart,
    required this.recordingActive,
    required this.recordingProgress,
  });

  final NavTab activeTab;
  final ValueChanged<NavTab> onTabTap;
  final VoidCallback onMicTap;
  final VoidCallback onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: 92,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 14,
              right: 14,
              bottom: 8,
              height: 68,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE7E7EF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _WorkspaceNavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: 'Home',
                      selected: activeTab == NavTab.home,
                      onTap: () => onTabTap(NavTab.home),
                    ),
                    _WorkspaceNavItem(
                      icon: Icons.search_rounded,
                      selectedIcon: Icons.manage_search_rounded,
                      label: 'Library',
                      selected: activeTab == NavTab.library,
                      onTap: () => onTabTap(NavTab.library),
                    ),
                    const SizedBox(width: 70),
                    _WorkspaceNavItem(
                      icon: Icons.hub_outlined,
                      selectedIcon: Icons.hub_rounded,
                      label: 'Canvas',
                      selected: activeTab == NavTab.canvas,
                      onTap: () => onTabTap(NavTab.canvas),
                    ),
                    _WorkspaceNavItem(
                      icon: Icons.task_alt_rounded,
                      selectedIcon: Icons.fact_check_rounded,
                      label: 'Brief',
                      selected: activeTab == NavTab.dailyBrief,
                      onTap: () => onTabTap(NavTab.dailyBrief),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onMicTap,
                onLongPress: onRecordingStart,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A6EFF), Color(0xFF18A58A)],
                        ),
                      ),
                    ),
                    if (recordingActive)
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: recordingProgress,
                          strokeWidth: 3,
                          color: const Color(0xFFFF7A59),
                        ),
                      ),
                    const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceNavItem extends StatelessWidget {
  const _WorkspaceNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF4A6EFF) : Colors.black45;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
