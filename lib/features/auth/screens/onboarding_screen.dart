import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/features/auth/models/onboarding_data.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/features/auth/widgets/onboarding_choice_chip.dart';
import 'package:mira_app/features/auth/widgets/onboarding_progress.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/features/capture/widgets/voice_recording_overlay.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Multi-step onboarding wizard - name, role, gender, bio, voice (659:3546).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onCompleted,
    this.initialName = '',
    this.profileEntryMode = false,
    this.skipNameStep = false,
    this.onExitFromFirstStep,
  });

  final VoidCallback onCompleted;
  final String initialName;

  /// When true, first step matches flow step 5 ("Your details").
  @Deprecated('Use OnboardingYourDetailsScreen in OnboardingFlow instead.')
  final bool profileEntryMode;

  /// Name already collected — start at role step (flow step 7).
  final bool skipNameStep;

  /// Back from the first wizard step (e.g. return to first capture).
  final VoidCallback? onExitFromFirstStep;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = OnboardingSteps.name;
  bool _submitting = false;
  bool _recording = false;
  bool _nameReady = false;
  bool _bioReady = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  late OnboardingData _data;
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final VoiceRecorderPort _recorder;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _data = OnboardingData(displayName: widget.initialName.trim());
    _nameController = TextEditingController(text: widget.initialName.trim());
    _bioController = TextEditingController();
    _nameReady = _nameController.text.trim().isNotEmpty;
    _bioReady = _bioController.text.trim().isNotEmpty;
    _nameController.addListener(_syncNameReady);
    _bioController.addListener(_syncBioReady);
    _step = widget.skipNameStep ? OnboardingSteps.role : OnboardingSteps.name;
    _recorder = createVoiceRecorder();
    _pageController = PageController();
  }

  int get _firstStep =>
      widget.skipNameStep ? OnboardingSteps.role : OnboardingSteps.name;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _nameController.removeListener(_syncNameReady);
    _bioController.removeListener(_syncBioReady);
    _nameController.dispose();
    _bioController.dispose();
    _pageController.dispose();
    if (_recorder is DeviceVoiceRecorder) {
      _recorder.dispose();
    } else if (_recorder is SimulatedVoiceRecorder) {
      _recorder.dispose();
    }
    super.dispose();
  }

  void _syncNameReady() {
    final ready = _nameController.text.trim().isNotEmpty;
    if (_nameReady != ready && mounted) {
      setState(() => _nameReady = ready);
    }
  }

  void _syncBioReady() {
    final ready = _bioController.text.trim().isNotEmpty;
    if (!mounted) return;
    setState(() => _bioReady = ready);
  }

  bool get _isNameComplete => _nameReady;

  bool get _canContinue {
    if (_submitting || _recording) return false;
    return switch (_step) {
      OnboardingSteps.name => _isNameComplete,
      OnboardingSteps.role => _data.role.isNotEmpty,
      OnboardingSteps.gender => _data.gender.isNotEmpty,
      OnboardingSteps.bio => _bioReady,
      OnboardingSteps.voice => true,
      _ => false,
    };
  }

  String get _primaryLabel {
    if (_step == OnboardingSteps.voice) {
      return _data.voiceIntroCompleted ? 'Finish setup' : 'Skip and finish';
    }
    return 'Continue';
  }

  Widget _buildBottomCta() {
    final label =
        widget.profileEntryMode && _step == OnboardingSteps.name
            ? 'Enter'
            : _primaryLabel;

    if (_step == OnboardingSteps.name) {
      return AuthFormCtaButton(
        label: label,
        controller: _nameController,
        isReady: (text) => text.trim().isNotEmpty,
        loading: _submitting,
        enabled: !_recording,
        onPressed: _next,
      );
    }
    if (_step == OnboardingSteps.bio) {
      return AuthFormCtaButton(
        label: label,
        controller: _bioController,
        isReady: (text) => text.trim().isNotEmpty,
        loading: _submitting,
        enabled: !_recording,
        onPressed: _next,
      );
    }

    final active = _canContinue;
    return AuthCtaButton(
      label: label,
      loading: _submitting,
      enabled: active,
      onPressed: active ? _next : null,
    );
  }

  Future<void> _next() async {
    if (!_canContinue) return;
    _captureCurrentStepData();

    if (_step < OnboardingSteps.voice) {
      setState(() => _step++);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finish(voiceCompleted: _data.voiceIntroCompleted);
  }

  void _captureCurrentStepData() {
    if (_step == OnboardingSteps.name) {
      _data = _data.copyWith(displayName: _nameController.text.trim());
    } else if (_step == OnboardingSteps.bio) {
      _data = _data.copyWith(bio: _bioController.text.trim());
    }
  }

  Future<void> _back() async {
    if (_submitting || _recording) return;
    if (_step == _firstStep) {
      widget.onExitFromFirstStep?.call();
      return;
    }
    setState(() => _step--);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _startVoiceIntro() async {
    if (_recording || _submitting) return;
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

  Future<void> _stopVoiceIntro() async {
    if (!_recording) return;
    _recordingTimer?.cancel();
    await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _data = _data.copyWith(voiceIntroCompleted: true);
    });
  }

  Future<void> _finish({required bool voiceCompleted}) async {
    if (_submitting) return;
    _captureCurrentStepData();
    final payload = _data
        .copyWith(
          voiceIntroCompleted: voiceCompleted || _data.voiceIntroCompleted,
        )
        .toJson();

    setState(() => _submitting = true);
    try {
      await AppScope.servicesOf(
        context,
      ).onboardingRepository.submitOnboarding(payload);
      if (mounted) widget.onCompleted();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatAuthError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileEntryName =
        widget.profileEntryMode && _step == OnboardingSteps.name;

    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Column(
              children: [
                if (!profileEntryName)
                  _OnboardingTopBar(
                    step: _step,
                    skipNameStep: widget.skipNameStep,
                    onBack: _step >= _firstStep ? _back : null,
                    disabled: _submitting || _recording,
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (!widget.skipNameStep) _buildNameStep(),
                      _buildRoleStep(),
                      _buildGenderStep(),
                      _buildBioStep(),
                      _buildVoiceStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    MiraSpacing.lg,
                    MiraSpacing.sm,
                    MiraSpacing.lg,
                    MiraSpacing.lg,
                  ),
                  child: _buildBottomCta(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepShell({
    required String eyebrow,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? footer,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: MiraSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: constraints.maxHeight < 680 ? 10 : 22),
                const Center(
                  child: MiraSphere(size: OnboardingTokens.smallSphereSize),
                ),
                const SizedBox(height: MiraSpacing.xl),
                Text(
                  eyebrow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: OnboardingTokens.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: MiraSpacing.sm),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.headlineColor,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: MiraSpacing.md),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.42,
                    color: OnboardingTokens.subtitleColor,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: MiraSpacing.xl),
                child,
                if (footer != null) ...[
                  const SizedBox(height: MiraSpacing.lg),
                  footer,
                ],
                const SizedBox(height: MiraSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameStep() {
    if (widget.profileEntryMode) {
      return _buildProfileEntryNameStep();
    }

    return _buildStepShell(
      eyebrow: 'STEP 1 OF 5',
      title: "What's your name?",
      subtitle:
          'Mira uses this to make your home, brief, and memory answers feel personal.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldCaption('Display name'),
          MiraInputField(
            controller: _nameController,
            hintText: 'Sara',
            showMic: false,
            variant: MiraInputVariant.flat,
            radius: ComposerTokens.flatFieldRadius,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canContinue) _next();
            },
          ),
        ],
      ),
    );
  }

  /// Figma step 5 — left-aligned icon, title, flat name field, Enter CTA.
  Widget _buildProfileEntryNameStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ProfileDetailsIcon(),
          const SizedBox(height: 28),
          const Text(
            'Your details',
            style: TextStyle(
              fontSize: 28,
              height: 1.12,
              fontWeight: FontWeight.w800,
              color: OnboardingTokens.headlineColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tell Mira what to call you so your home and memories feel personal.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: OnboardingTokens.subtitleColor,
            ),
          ),
          const SizedBox(height: 28),
          MiraInputField(
            controller: _nameController,
            hintText: 'your name',
            showMic: false,
            variant: MiraInputVariant.flat,
            height: 58,
            radius: ComposerTokens.flatFieldRadius,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _syncNameReady(),
            onSubmitted: (_) {
              if (_canContinue) _next();
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildRoleStep() {
    return _buildStepShell(
      eyebrow: 'STEP 2 OF 5',
      title: 'What are you building around?',
      subtitle:
          'Pick the closest role so Mira can tune examples and reminders to your day.',
      child: Wrap(
        spacing: 10,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          for (final role in OnboardingChoices.roles)
            OnboardingChoiceChip(
              label: role,
              selected: _data.role == role,
              onTap: () => setState(() => _data = _data.copyWith(role: role)),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return _buildStepShell(
      eyebrow: 'STEP 3 OF 5',
      title: 'How should Mira address you?',
      subtitle:
          'This stays in your profile and helps with more natural personalization.',
      child: Column(
        children: [
          for (final gender in OnboardingChoices.genders) ...[
            _SelectionRow(
              label: gender,
              selected: _data.gender == gender,
              onTap: () =>
                  setState(() => _data = _data.copyWith(gender: gender)),
            ),
            if (gender != OnboardingChoices.genders.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return _buildStepShell(
      eyebrow: 'STEP 4 OF 5',
      title: 'Give Mira a little context',
      subtitle:
          'A short intro makes the first answers less generic and the daily brief sharper.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldCaption('About you'),
          MiraInputField(
            controller: _bioController,
            hintText:
                'What are you working on, tracking, or trying to remember?',
            showMic: false,
            variant: MiraInputVariant.flat,
            radius: ComposerTokens.flatFieldRadius,
            height: 148,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => _syncBioReady(),
          ),
          const SizedBox(height: MiraSpacing.sm),
          Text(
            '${_bioController.text.trim().length}/255',
            style: const TextStyle(
              color: OnboardingTokens.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceStep() {
    return _buildStepShell(
      eyebrow: 'FINAL STEP',
      title: 'Say hello to Mira',
      subtitle:
          'Record a tiny voice intro if you want. Mira only saves that you completed it.',
      child: _recording
          ? VoiceRecordingOverlay(
              duration: _recordingDuration,
              amplitudeStream: _recorder.amplitudeStream,
              onStop: _stopVoiceIntro,
            )
          : _VoiceIntroPanel(
              recorded: _data.voiceIntroCompleted,
              onRecord: _startVoiceIntro,
            ),
      footer: TextButton(
        onPressed: _submitting || _recording
            ? null
            : () => _finish(voiceCompleted: false),
        child: const Text(
          'Skip voice intro',
          style: TextStyle(
            color: OnboardingTokens.subtitleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.step,
    required this.skipNameStep,
    required this.onBack,
    required this.disabled,
  });

  final int step;
  final bool skipNameStep;
  final VoidCallback? onBack;
  final bool disabled;

  int get _displayStep => skipNameStep
      ? step - OnboardingSteps.role + 1
      : step + 1;
  int get _displayTotal =>
      skipNameStep ? OnboardingSteps.count - 1 : OnboardingSteps.count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: onBack == null
                ? const SizedBox.shrink()
                : Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: disabled ? null : onBack,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: OnboardingTokens.headlineColor,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: OnboardingProgress(
              currentStep: skipNameStep ? step - 1 : step,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$_displayStep/$_displayTotal',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: OnboardingTokens.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsIcon extends StatelessWidget {
  const _ProfileDetailsIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(painter: _ProfileDetailsIconPainter()),
    );
  }
}

class _ProfileDetailsIconPainter extends CustomPainter {
  const _ProfileDetailsIconPainter();

  static const _stroke = Color(0xFF6B6560);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, paint);

    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx, size.height * 0.36), size.width * 0.13, paint);

    final shoulders = Path()
      ..moveTo(cx - size.width * 0.22, size.height * 0.76)
      ..quadraticBezierTo(
        cx,
        size.height * 0.56,
        cx + size.width * 0.22,
        size.height * 0.76,
      );
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: OnboardingTokens.mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 58,
          decoration: ComposerTokens.raisedSurfaceDecoration(
            borderRadius: BorderRadius.circular(18),
            active: selected,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? OnboardingTokens.progressActive
                          : OnboardingTokens.headlineColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? OnboardingTokens.progressActive
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? OnboardingTokens.progressActive
                          : OnboardingTokens.chipBorder,
                      width: 1.4,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceIntroPanel extends StatelessWidget {
  const _VoiceIntroPanel({required this.recorded, required this.onRecord});

  final bool recorded;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onRecord,
          onLongPress: onRecord,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 112,
            height: 112,
            decoration: ComposerTokens.raisedSurfaceDecoration(
              shape: BoxShape.circle,
              active: recorded,
            ),
            child: Icon(
              recorded ? Icons.check_rounded : Icons.mic_rounded,
              size: 44,
              color: recorded
                  ? OnboardingTokens.success
                  : OnboardingTokens.progressActive,
            ),
          ),
        ),
        const SizedBox(height: MiraSpacing.lg),
        Text(
          recorded ? 'Voice intro recorded' : 'Tap to record',
          style: TextStyle(
            color: recorded
                ? OnboardingTokens.success
                : OnboardingTokens.headlineColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: MiraSpacing.sm),
        const Text(
          'You can stop the recording from the overlay.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: OnboardingTokens.subtitleColor,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
