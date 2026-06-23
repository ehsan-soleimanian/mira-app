import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/prompt_input_bar.dart';
import 'package:mira_app/components/organisms/mira_bottom_nav.dart';
import 'package:mira_app/components/organisms/mira_bottom_nav_bar.dart';
import 'package:mira_app/core/mira_nav_config.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/screens/voice_recording_screen.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Shared bottom shell — tap opens capture flow, hold starts voice recording.
class AppBottomShell extends StatefulWidget {
  const AppBottomShell({
    super.key,
    required this.activeTab,
    this.variant,
    this.onHomeTap,
    this.onDailyBriefTap,
  });

  final NavTab activeTab;
  final MiraNavVariant? variant;
  final VoidCallback? onHomeTap;
  final VoidCallback? onDailyBriefTap;

  @override
  State<AppBottomShell> createState() => _AppBottomShellState();
}

class _AppBottomShellState extends State<AppBottomShell> {
  bool _showPromptInput = false;
  final _promptController = TextEditingController();
  CaptureFlowController? _flow;

  MiraNavVariant get _variant => widget.variant ?? MiraNavConfig.variant;

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
    _promptController.dispose();
    super.dispose();
  }

  void _onFlowChanged() {
    if (!mounted) return;
    if (_flow?.requestTextPrompt == true) {
      _flow?.clearTextPromptRequest();
      _openPromptInput();
      return;
    }
    if (_flow?.phase == CaptureUiPhase.bubbleMenu && _showPromptInput) {
      _showPromptInput = false;
    }
    setState(() {});
  }

  void _openBubbleMenu() {
    _flow?.showBubbleMenu();
  }

  Future<void> _startVoiceRecording() async {
    final flow = _flow;
    if (flow == null) return;
    await flow.startRecording();
    if (!mounted || flow.phase != CaptureUiPhase.recording) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const VoiceRecordingScreen()),
    );
  }

  void _openPromptInput() {
    _flow?.hideBubbleMenu();
    setState(() => _showPromptInput = true);
  }

  void _closePromptInput() {
    setState(() {
      _showPromptInput = false;
      _promptController.clear();
    });
  }

  Future<void> _submitPrompt(String value) async {
    final text = value.trim();
    if (text.isEmpty) return;
    _closePromptInput();
    await _flow?.submitPrompt(context, text);
  }

  void _onEarItemTap(NavTab tab) {
    if (tab == NavTab.home) {
      widget.onHomeTap?.call();
    } else {
      widget.onDailyBriefTap?.call();
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
        onMicTap: _closePromptInput,
        onSend: _submitPrompt,
        onSubmitted: _submitPrompt,
      );
    }

    return switch (_variant) {
      MiraNavVariant.cradle => MiraBottomNav(
        activeTab: widget.activeTab,
        onHomeTap: widget.onHomeTap,
        onVoiceShortTap: _openBubbleMenu,
        onRecordingStart: _startVoiceRecording,
        recordingActive: _recordingActive,
        recordingProgress: _recordingProgress,
        onDailyBriefTap: widget.onDailyBriefTap,
      ),
      MiraNavVariant.earNotch => MiraBottomNavBar(
        activeTab: widget.activeTab,
        onItemTap: _onEarItemTap,
        onMicShortTap: _openBubbleMenu,
        onRecordingStart: _startVoiceRecording,
        recordingActive: _recordingActive,
        recordingProgress: _recordingProgress,
      ),
    };
  }
}
