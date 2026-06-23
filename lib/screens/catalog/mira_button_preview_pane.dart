import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview — full [MiraButton] board (Figma 742:13615).
class MiraButtonPreviewPane extends StatelessWidget {
  const MiraButtonPreviewPane({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0F0F0),
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PreviewLabel('Filled'),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                MiraButton(label: 'Continue', onPressed: () {}),
                MiraButton(
                  label: 'Secondary',
                  color: MiraButtonColor.secondary,
                  onPressed: () {},
                ),
                MiraButton(
                  label: 'Logout',
                  color: MiraButtonColor.danger,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _PreviewLabel('Outlined'),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                MiraButton(
                  label: 'Continue',
                  variant: MiraButtonVariant.outlined,
                  onPressed: () {},
                ),
                MiraButton(
                  label: 'Secondary',
                  variant: MiraButtonVariant.outlined,
                  color: MiraButtonColor.secondary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _PreviewLabel('Disabled'),
            const Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                MiraButton(label: 'Continue'),
                MiraButton(
                  label: 'Continue',
                  variant: MiraButtonVariant.outlined,
                ),
              ],
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _PreviewLabel('Large CTA'),
            SizedBox(
              width: 345,
              child: Column(
                children: [
                  MiraButton(
                    label: 'Set new note',
                    size: MiraButtonSize.large,
                    expand: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 14),
                  MiraButton(
                    label: 'Set new note',
                    size: MiraButtonSize.large,
                    color: MiraButtonColor.secondary,
                    expand: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
