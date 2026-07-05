import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/features/auth/models/onboarding_data.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/features/auth/widgets/onboarding_capture_mic_button.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Figma step 8 — blurred first-capture chrome + «MIRA understands you».
///
/// Submits minimal onboarding profile, then enters the app.
class OnboardingProcessingScreen extends StatefulWidget {
  const OnboardingProcessingScreen({
    super.key,
    required this.data,
    required this.onCompleted,
  });

  final OnboardingData data;
  final VoidCallback onCompleted;

  @override
  State<OnboardingProcessingScreen> createState() =>
      _OnboardingProcessingScreenState();
}

class _OnboardingProcessingScreenState
    extends State<OnboardingProcessingScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_finishOnboarding());
  }

  Future<void> _finishOnboarding() async {
    setState(() => _failed = false);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    try {
      final services = AppScope.servicesOf(context);
      await services.onboardingRepository.submitOnboarding(
        widget.data.toJson(),
      );
      await _syncPreferences(services);
    } catch (error) {
      if (!mounted) return;
      setState(() => _failed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatAuthError(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mounted) widget.onCompleted();
  }

  Future<void> _syncPreferences(MiraServices services) async {
    try {
      final current = await services.settingsRepository.fetchSettings();
      await services.settingsRepository.updateSettings(
        current.copyWith(
          dailyBriefEnabled: widget.data.dailyBriefEnabled,
          memoryInsightsEnabled: widget.data.memoryInsightsEnabled,
        ),
      );
    } catch (_) {
      // Settings sync should not block finishing onboarding.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _BlurredCaptureBackdrop(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'MIRA understands you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: OnboardingTokens.headlineColor.withValues(alpha: 0.92),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          if (_failed)
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: MiraButton(
                label: 'Try again',
                size: MiraButtonSize.large,
                expand: true,
                onPressed: _finishOnboarding,
              ),
            ),
        ],
      ),
    );
  }
}

/// Static replica of [OnboardingFirstCaptureScreen] for the blur layer.
class _BlurredCaptureBackdrop extends StatelessWidget {
  const _BlurredCaptureBackdrop();

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
      child: ColoredBox(
        color: OnboardingTokens.background,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MiraPageHeader(),
                const Center(
                  child: MiraSphere(size: OnboardingTokens.sphereSize),
                ),
                const SizedBox(height: 32),
                const Text(
                  'What do you want Mira to remember?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.headlineColor,
                  ),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 28),
                Container(
                  height: OnboardingFirstCaptureTokens.captureFieldHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      OnboardingFirstCaptureTokens.captureFieldRadius,
                    ),
                    border: Border.all(color: ComposerTokens.flatFieldBorder),
                    boxShadow: OnboardingCaptureMicTokens.captureFieldShadow,
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'HELLO',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: OnboardingTokens.headlineColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: OnboardingCaptureMicButton(onTap: () {})),
                const Spacer(),
                const AuthCtaButton(
                  label: 'Next',
                  enabled: false,
                  onPressed: null,
                ),
                const SizedBox(height: 12),
                MiraButton(
                  label: "I'll do it later",
                  variant: MiraButtonVariant.outlined,
                  size: MiraButtonSize.large,
                  expand: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
