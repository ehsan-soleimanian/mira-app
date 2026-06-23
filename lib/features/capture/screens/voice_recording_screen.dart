import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/widgets/capture_approval_panel.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
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
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(child: _buildBody(flow, s)),
                Positioned(
                  top: HomeScreenTokens.settingsTop * s,
                  left: HomeScreenTokens.settingsRight * s,
                  right: HomeScreenTokens.settingsRight * s,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MiraBackButton(
                        size: HomeScreenTokens.settingsSize * s,
                        onTap: _handleBack,
                      ),
                      SettingsButton(size: HomeScreenTokens.settingsSize * s),
                    ],
                  ),
                ),
              ],
            ),
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

    if (flow.isProcessing) {
      return _ProcessingBody(scale: s);
    }

    return _ListeningBody(
      scale: s,
      duration: flow.recordingDuration,
      onStop: _stopAndSubmit,
    );
  }
}

class _ListeningBody extends StatelessWidget {
  const _ListeningBody({
    required this.scale,
    required this.duration,
    required this.onStop,
  });

  final double scale;
  final Duration duration;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        Positioned(
          top: 88 * s,
          left: 0,
          right: 0,
          child: Center(child: MiraSphere(size: HomeScreenTokens.sphereSize * s)),
        ),
        Positioned(
          top: HomeScreenTokens.headlineTop * s,
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'دارم گوش می\u200cدهم…',
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 34 * s,
              weight: FontWeight.w700,
              color: AppColors.headline,
            ),
          ),
        ),
        Positioned(
          top: HomeScreenTokens.subtitleTop * s,
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'راحت صحبت کن؛ میرا یادداشت می\u200cگیرد',
            textAlign: TextAlign.center,
            style: AppTypography.vazirmatn(
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
                'برای توقف ضبط، لمس کنید',
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
  const _ProcessingBody({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      children: [
        Positioned(
          top: 88 * s,
          left: 0,
          right: 0,
          child: Center(child: MiraSphere(size: HomeScreenTokens.sphereSize * s)),
        ),
        Positioned(
          top: HomeScreenTokens.headlineTop * s,
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'دارم می\u200cفهمم…',
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 34 * s,
              weight: FontWeight.w700,
              color: AppColors.headline,
            ),
          ),
        ),
        Positioned(
          top: HomeScreenTokens.subtitleTop * s,
          left: 24 * s,
          right: 24 * s,
          child: Text(
            'چند لحظه صبر کن',
            textAlign: TextAlign.center,
            style: AppTypography.vazirmatn(
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
