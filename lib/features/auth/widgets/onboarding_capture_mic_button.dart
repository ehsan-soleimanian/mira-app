import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_composer_glyphs.dart';
import 'package:mira_app/components/molecules/mira_stop_button.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';
/// Figma onboarding step 6 — circular mic below the capture text area.
class OnboardingCaptureMicButton extends StatelessWidget {
  const OnboardingCaptureMicButton({
    super.key,
    required this.onTap,
    this.enabled = true,
    this.size = OnboardingCaptureMicTokens.diameter,
  });

  final VoidCallback onTap;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Record voice',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: enabled ? 1 : 0.45,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: OnboardingCaptureMicTokens.borderColor,
                width: 1,
              ),
              boxShadow: OnboardingCaptureMicTokens.shadow,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: OnboardingCaptureMicTokens.iconWidth,
              height: OnboardingCaptureMicTokens.iconHeight,
              child: CustomPaint(
                painter: MiraComposerMicPainter(
                  ComposerTokens.glyphColor,
                  strokeWidth: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma step 7 — [MiraStopButton] + timer + TAP TO STOP.
class OnboardingCaptureRecordingControls extends StatelessWidget {
  const OnboardingCaptureRecordingControls({
    super.key,
    required this.duration,
    required this.onStop,
    this.stopSize = StopButtonTokens.defaultSize,
  });

  final Duration duration;
  final VoidCallback onStop;
  final double stopSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiraStopButton(size: stopSize, onTap: onStop),
        const SizedBox(height: 14),
        Text(
          formatRecordingClock(duration),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: OnboardingTokens.headlineColor,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'TAP TO STOP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: OnboardingTokens.mutedText,
          ),
        ),
      ],
    );
  }
}

/// Layout tokens — Figma first-capture mic (step 6).
abstract final class OnboardingCaptureMicTokens {
  static const diameter = 64.0;
  static const iconWidth = 22.0;
  static const iconHeight = 24.0;
  static const borderColor = Color(0xFFE6E8ED);

  static const shadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
    BoxShadow(
      color: Color(0x0FFFFFFF),
      blurRadius: 4,
      offset: Offset(0, -1),
    ),
  ];

  static const captureFieldShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x14FFFFFF),
      blurRadius: 6,
      offset: Offset(0, -2),
    ),
  ];
}

/// Layout tokens — Figma onboarding first capture (step 6–7).
abstract final class OnboardingFirstCaptureTokens {
  static const horizontalPadding = 24.0;
  static const captureFieldHeight = 176.0;
  static const captureFieldRadius = 16.0;
  static const sphereToTitle = 32.0;
  static const titleToSubtitle = 14.0;
  static const subtitleToField = 28.0;
  static const fieldToMic = 24.0;
  static const micToCta = 28.0;
}
