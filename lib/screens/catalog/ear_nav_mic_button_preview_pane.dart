import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_ear_nav_mic_button.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview for the detached mic well from Figma 741:4986.
class EarNavMicButtonPreviewPane extends StatelessWidget {
  const EarNavMicButtonPreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    const scale = 1.0;

    return ColoredBox(
      color: MiraEarNavTokens.background,
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice mic well (${MiraEarNavMicButton.componentId})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: MiraEarNavTokens.activeColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MiraEarNavMicButton(
                  size: MiraEarNavTokens.fabSize,
                  scale: scale,
                  micIconSize: MiraEarNavTokens.micIconSize,
                  onShortTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mic tapped'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(milliseconds: 900),
                    ),
                  ),
                ),
                const MiraEarNavMicButton(
                  size: 56,
                  scale: 56 / MiraEarNavTokens.fabSize,
                  micIconSize: 24,
                  recordingActive: true,
                  recordingProgress: 0.68,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
