import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/widgets/capture_approval_panel.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/features/graph/widgets/memory_graph_icon_button.dart';
import 'package:mira_app/features/capture/widgets/voice_capture_failure_panel.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/page_header_tokens.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

/// Full-screen voice capture — listening → processing → approval (Figma).
class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen> {
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
    super.dispose();
  }

  void _onFlowChanged() {
    if (!mounted) return;
    final flow = _flow!;

    if (flow.lastCaptureError != null) {
      final message = flow.lastCaptureError!;
      flow.clearLastCaptureError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }

    if (flow.lastAnswer != null &&
        flow.lastAnswer!.contains('Saved to memory') &&
        flow.phase == CaptureUiPhase.idle) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(flow.lastAnswer!),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).maybePop();
      return;
    }

    if (flow.requestTextPrompt) {
      Navigator.of(context).maybePop();
      return;
    }

    if (flow.phase == CaptureUiPhase.idle && flow.voiceSessionActive == false) {
      Navigator.of(context).maybePop();
      return;
    }

    if (flow.pendingTimeClarification != null) {
      unawaited(flow.resolvePendingTimeClarification(context));
    }

    setState(() {});
  }

  Future<void> _handleBack() async {
    final flow = _flow;
    if (flow == null) return;
    switch (flow.phase) {
      case CaptureUiPhase.recording:
        await flow.cancelRecording();
      case CaptureUiPhase.approving:
        await flow.dismissPendingCapture();
        if (mounted) Navigator.of(context).maybePop();
      case CaptureUiPhase.voiceFailed:
        flow.dismissVoiceFailure();
        if (mounted) Navigator.of(context).maybePop();
      case CaptureUiPhase.uploading:
      case CaptureUiPhase.processing:
        break;
      default:
        if (mounted) Navigator.of(context).maybePop();
    }
  }

  Future<void> _stopAndSubmit() async {
    await _flow?.stopRecordingAndSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final flow = _flow!;
    final width = MediaQuery.sizeOf(context).width;
    final s = width / HomeScreenTokens.designWidth;

    return PopScope(
      canPop: flow.phase != CaptureUiPhase.uploading &&
          flow.phase != CaptureUiPhase.processing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && flow.phase == CaptureUiPhase.recording) {
          unawaited(flow.cancelRecording());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MiraPageHeader(
                onBack: _handleBack,
                trailing: MemoryGraphIconButton(
                  size: PageHeaderTokens.actionSize,
                  active:
                      flow.pendingProposal != null ||
                      flow.phase == CaptureUiPhase.approving,
                  onTap: () {
                    Navigator.of(context).pushMira(
                      (_) => const MemoryGraphScreen(),
                    );
                  },
                ),
              ),
              Expanded(child: _buildBody(flow, s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(CaptureFlowController flow, double s) {
    if (flow.phase == CaptureUiPhase.approving &&
        flow.pendingProposal != null) {
      return CaptureApprovalPanel(
        scale: s,
        proposal: flow.pendingProposal!,
        prompt: flow.voiceSessionPrompt,
        busy: flow.approvalBusy,
        onSave: () => unawaited(flow.approvePendingCapture()),
        onCancel: () => unawaited(flow.dismissPendingCapture()),
      );
    }

    if (flow.phase == CaptureUiPhase.voiceFailed &&
        flow.voiceFailureMessage != null) {
      return VoiceCaptureFailurePanel(
        scale: s,
        message: flow.voiceFailureMessage!,
        onRetry: () => unawaited(flow.retryVoiceAfterFailure()),
        onWriteText: flow.openTextFallbackFromVoice,
        belowPageHeader: true,
      );
    }

    if (flow.isProcessing) {
      return _ProcessingBody(
        scale: s,
        uploading: flow.phase == CaptureUiPhase.uploading,
        belowPageHeader: true,
      );
    }

    return _ListeningBody(
      scale: s,
      duration: flow.recordingDuration,
      onStop: _stopAndSubmit,
      belowPageHeader: true,
    );
  }
}

class _ListeningBody extends StatelessWidget {
  const _ListeningBody({
    required this.scale,
    required this.duration,
    required this.onStop,
    this.belowPageHeader = false,
  });

  final double scale;
  final Duration duration;
  final VoidCallback onStop;
  final bool belowPageHeader;

  double _headlineTop(double s) => belowPageHeader
      ? HomeScreenTokens.headlineYBelowHeader(s)
      : HomeScreenTokens.headlineY(s);

  double _subtitleTop(double s) => belowPageHeader
      ? HomeScreenTokens.subtitleYBelowHeader(s)
      : HomeScreenTokens.subtitleY(s);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        MiraHeroOrb(scale: s, belowPageHeader: belowPageHeader, ambient: true),
        Positioned(
          top: _headlineTop(s),
          left: 24 * s,
          right: 24 * s,
          child: Text(
            "I'm listening...",
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 34 * s,
              weight: FontWeight.w700,
              color: AppColors.headline,
            ),
          ),
        ),
        Positioned(
          top: _subtitleTop(s),
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'Speak naturally — Mira is taking notes',
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 16 * s,
              color: AppColors.subtitle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 130 * s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiraStopButton(
                size: StopButtonTokens.defaultSize * s,
                onTap: onStop,
              ),
              SizedBox(height: 14 * s),
              Text(
                formatRecordingDuration(duration),
                style: TextStyle(
                  fontSize: 24 * s,
                  color: AppColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: 18 * s),
              Text(
                'Tap to stop recording',
                style: TextStyle(
                  fontSize: 12 * s,
                  letterSpacing: 0.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProcessingBody extends StatelessWidget {
  const _ProcessingBody({
    required this.scale,
    required this.uploading,
    this.belowPageHeader = false,
  });

  final double scale;
  final bool uploading;
  final bool belowPageHeader;

  double _headlineTop(double s) => belowPageHeader
      ? HomeScreenTokens.headlineYBelowHeader(s)
      : HomeScreenTokens.headlineY(s);

  double _subtitleTop(double s) => belowPageHeader
      ? HomeScreenTokens.subtitleYBelowHeader(s)
      : HomeScreenTokens.subtitleY(s);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        MiraHeroOrb(
          scale: s,
          processing: true,
          belowPageHeader: belowPageHeader,
        ),
        Positioned(
          top: _headlineTop(s),
          left: 24 * s,
          right: 24 * s,
          child: uploading
              ? Text(
                  'Uploading voice…',
                  textAlign: TextAlign.center,
                  style: AppTypography.dosis(
                    size: 34 * s,
                    weight: FontWeight.w700,
                    color: AppColors.headline,
                  ),
                )
              : ShimmerText(
                  text: 'Mira is thinking...',
                  style: AppTypography.dosis(
                    size: 34 * s,
                    weight: FontWeight.w700,
                  ),
                  baseColor: const Color(0xFF9A9AA1),
                  highlightColor: const Color(0xFFF8F8FA),
                ),
        ),
        Positioned(
          top: _subtitleTop(s),
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'Just a moment',
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 16 * s,
              color: AppColors.subtitle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 160 * s,
          child: Center(
            child: SizedBox(
              width: 28 * s,
              height: 28 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2.5 * s,
                color: AppColors.micBlueNav,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
