import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/components/molecules/mira_back_button.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';
import 'package:mira_app/features/capture/utils/capture_errors.dart';
import 'package:mira_app/features/capture/widgets/voice_capture_failure_panel.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/features/auth/widgets/onboarding_capture_mic_button.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Figma step 6–7 — first memory prompt + STT after voice stop.
class OnboardingFirstCaptureScreen extends StatefulWidget {
  const OnboardingFirstCaptureScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.onBack,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  @override
  State<OnboardingFirstCaptureScreen> createState() =>
      _OnboardingFirstCaptureScreenState();
}

class _OnboardingFirstCaptureScreenState
    extends State<OnboardingFirstCaptureScreen> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final VoiceRecorderPort _recorder;

  bool _submitting = false;
  bool _recording = false;
  bool _transcribing = false;
  String? _voiceFailureMessage;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _recorder = createVoiceRecorder();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    if (_recorder is DeviceVoiceRecorder) {
      _recorder.dispose();
    } else if (_recorder is SimulatedVoiceRecorder) {
      _recorder.dispose();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_recording || _submitting || _transcribing) return;
    FocusScope.of(context).unfocus();
    setState(() => _voiceFailureMessage = null);
    final ok = await _recorder.start();
    if (!ok || !mounted) return;
    setState(() {
      _recording = true;
      _recordingDuration = Duration.zero;
    });
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordingDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_recording || _transcribing) return;
    _recordingTimer?.cancel();
    setState(() {
      _recording = false;
      _transcribing = true;
    });

    try {
      final result = await _recorder.stop();
      if (!mounted) return;
      _recordingDuration = result.duration;

      final transcript = await AppScope.servicesOf(context)
          .captureRepository
          .transcribeVoice(
            durationMs: result.duration.inMilliseconds,
            audioPath: result.filePath,
          );
      if (!mounted) return;

      _applyTranscript(transcript.text);
    } catch (error) {
      if (mounted) {
        setState(() {
          _voiceFailureMessage = formatVoiceCaptureError(error);
        });
      }
    } finally {
      if (mounted) setState(() => _transcribing = false);
    }
  }

  /// Writes backend STT result into the capture field and notifies listeners.
  void _applyTranscript(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    _textController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  Future<void> _submitCapture() async {
    if (_submitting || _transcribing) return;
    if (_recording) await _stopRecording();
    if (!mounted) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await AppScope.servicesOf(
        context,
      ).captureRepository.createTextCapture(text);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatAuthError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (mounted) widget.onContinue();
  }

  void _focusTextFallback() {
    setState(() => _voiceFailureMessage = null);
    _focusNode.requestFocus();
  }

  bool get _busy => _submitting || _transcribing;

  @override
  Widget build(BuildContext context) {
    const hPad = OnboardingFirstCaptureTokens.horizontalPadding;

    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IgnorePointer(
                      ignoring: _recording || _busy,
                      child: MiraBackButton(onTap: widget.onBack),
                    ),
                  ),
                ),
                Expanded(
                  child: _voiceFailureMessage != null
                      ? VoiceCaptureFailurePanel(
                          scale: 1,
                          message: _voiceFailureMessage!,
                          onRetry: _startRecording,
                          onWriteText: _focusTextFallback,
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: MiraSphere(
                                  size: OnboardingTokens.sphereSize,
                                ),
                              ),
                              const SizedBox(
                                height: OnboardingFirstCaptureTokens.sphereToTitle,
                              ),
                              const Text(
                                'What do you want Mira to remember?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: OnboardingTokens.headlineColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(
                                height: OnboardingFirstCaptureTokens.titleToSubtitle,
                              ),
                              const Text(
                                "Anything you don't want to forget. An idea. "
                                'A decision. A task. A link. Even a feeling.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.45,
                                  color: OnboardingTokens.subtitleColor,
                                ),
                              ),
                              const SizedBox(
                                height:
                                    OnboardingFirstCaptureTokens.subtitleToField,
                              ),
                              SizedBox(
                                height:
                                    OnboardingFirstCaptureTokens.captureFieldHeight,
                                child: Stack(
                                  children: [
                                    MiraInputField(
                                      controller: _textController,
                                      focusNode: _focusNode,
                                      hintText: _recording
                                          ? 'Listening…'
                                          : 'Press the button and speak or type',
                                      showMic: false,
                                      variant: MiraInputVariant.flat,
                                      flatFillColor: Colors.white,
                                      flatBoxShadow: OnboardingCaptureMicTokens
                                          .captureFieldShadow,
                                      height: OnboardingFirstCaptureTokens
                                          .captureFieldHeight,
                                      maxLines: 6,
                                      radius: OnboardingFirstCaptureTokens
                                          .captureFieldRadius,
                                      enabled: !_recording && !_transcribing,
                                      textInputAction: TextInputAction.newline,
                                    ),
                                    if (_transcribing)
                                      Positioned.fill(
                                        child: _CaptureFieldTranscribingOverlay(
                                          radius: OnboardingFirstCaptureTokens
                                              .captureFieldRadius,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (_voiceFailureMessage == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: OnboardingFirstCaptureTokens.fieldToMic,
                        ),
                        if (_recording)
                          OnboardingCaptureRecordingControls(
                            duration: _recordingDuration,
                            onStop: _stopRecording,
                          )
                        else if (!_transcribing)
                          Center(
                            child: OnboardingCaptureMicButton(
                              onTap: _startRecording,
                              enabled: !_busy,
                            ),
                          )
                        else
                          const SizedBox(
                            height: OnboardingCaptureMicTokens.diameter,
                          ),
                        SizedBox(
                          height: OnboardingFirstCaptureTokens.micToCta,
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthFormCtaButton(
                        label: 'Next',
                        controller: _textController,
                        isReady: (text) => text.trim().isNotEmpty,
                        loading: _submitting,
                        enabled:
                            !_recording && !_transcribing && _voiceFailureMessage == null,
                        onPressed: _submitCapture,
                      ),
                      const SizedBox(height: 12),
                      MiraButton(
                        label: "I'll do it later",
                        variant: MiraButtonVariant.outlined,
                        size: MiraButtonSize.large,
                        expand: true,
                        onPressed: _recording || _busy || _voiceFailureMessage != null
                            ? null
                            : widget.onSkip,
                      ),
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
}

class _CaptureFieldTranscribingOverlay extends StatelessWidget {
  const _CaptureFieldTranscribingOverlay({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: ComposerTokens.flatFieldBorder),
          boxShadow: OnboardingCaptureMicTokens.captureFieldShadow,
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              SizedBox(width: 12),
              Text(
                'Transcribing…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OnboardingTokens.subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
