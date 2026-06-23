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
  });

  final double scale;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onWriteText;
  final bool busy;

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
            'شنیدم نشد',
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
            message,
            textAlign: TextAlign.center,
            style: AppTypography.vazirmatn(
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
                label: 'دوباره بگو',
                size: MiraButtonSize.large,
                expand: true,
                onPressed: busy ? null : onRetry,
              ),
              SizedBox(height: 12 * s),
              MiraButton(
                label: 'با متن بنویس',
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
