import 'package:flutter/material.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// In-place recovery when voice capture or STT fails — retry or type instead.
class VoiceCaptureFailurePanel extends StatelessWidget {
  const VoiceCaptureFailurePanel({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
    required this.onWriteText,
    this.busy = false,
    this.belowPageHeader = false,
  });

  final double scale;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onWriteText;
  final bool busy;
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
            "Couldn't hear that",
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
            message,
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 16 * s,
              color: AppColors.subtitle,
              height: 1.45,
            ),
          ),
        ),
        Positioned(
          left: 24 * s,
          right: 24 * s,
          bottom: 120 * s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                Padding(
                  padding: EdgeInsets.only(bottom: 16 * s),
                  child: SizedBox(
                    width: 28 * s,
                    height: 28 * s,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5 * s,
                      color: AppColors.micBlueNav,
                    ),
                  ),
                ),
              MiraButton(
                label: 'Try again',
                size: MiraButtonSize.large,
                expand: true,
                onPressed: busy ? null : onRetry,
              ),
              SizedBox(height: 12 * s),
              MiraButton(
                label: 'Write with text',
                variant: MiraButtonVariant.outlined,
                size: MiraButtonSize.large,
                expand: true,
                onPressed: busy ? null : onWriteText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
