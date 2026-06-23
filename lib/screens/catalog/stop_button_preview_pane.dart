import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_stop_button.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

/// Catalog preview — [MiraStopButton] default size + scaled variant.
class StopButtonPreviewPane extends StatelessWidget {
  const StopButtonPreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StopButtonTokens.previewBackground,
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stop recording (618:3447)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: StopButtonTokens.iconColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.lg),
            Center(
              child: MiraStopButton(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stop tapped'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(milliseconds: 900),
                  ),
                ),
              ),
            ),
            const SizedBox(height: MiraSpacing.lg),
            const Text(
              'Scaled (56)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: StopButtonTokens.iconColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.sm),
            Center(
              child: MiraStopButton(
                size: 56,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
