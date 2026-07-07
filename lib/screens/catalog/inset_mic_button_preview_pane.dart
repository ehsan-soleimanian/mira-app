import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_inset_mic_button.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview for the inset workspace mic center action.
class InsetMicButtonPreviewPane extends StatelessWidget {
  const InsetMicButtonPreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F2F6),
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inset workspace mic (${MiraInsetMicButton.componentId})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: MiraSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiraInsetMicButton(
                  onShortTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inset mic tapped'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(milliseconds: 900),
                    ),
                  ),
                ),
                const MiraInsetMicButton(
                  size: 62,
                  iconSize: 26,
                  recordingActive: true,
                  recordingProgress: 0.7,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
