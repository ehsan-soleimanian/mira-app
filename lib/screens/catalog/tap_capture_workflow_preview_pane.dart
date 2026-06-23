import 'package:flutter/material.dart';
import 'package:mira_app/features/capture/widgets/capture_bubble_menu.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview for the single-tap mic capture workflow.
class TapCaptureWorkflowPreviewPane extends StatelessWidget {
  const TapCaptureWorkflowPreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    void snack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MiraSpacing.sm,
          vertical: MiraSpacing.lg,
        ),
        child: CaptureBubbleMenu(
          onTextTap: () => snack('Open text capture'),
          onLinkTap: () => snack('Open link capture'),
          onImageTap: () => snack('Open image capture'),
        ),
      ),
    );
  }
}
