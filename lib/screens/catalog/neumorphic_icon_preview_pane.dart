import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/neumorphic_icon_button.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/neumorphic_tokens.dart';

/// Gallery preview — all icon variants × raised / inset styles.
class NeumorphicIconPreviewPane extends StatelessWidget {
  const NeumorphicIconPreviewPane({super.key});

  static const _rows = <({String label, IconData icon, bool badge})>[
    (label: 'Settings', icon: Icons.settings_outlined, badge: false),
    (label: 'Back', icon: Icons.arrow_back_rounded, badge: false),
    (label: 'Assistant', icon: Icons.psychology_outlined, badge: false),
    (label: 'Assistant • alert', icon: Icons.psychology_outlined, badge: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NeumorphicTokens.background,
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  child: Text(
                    'Raised',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Inset',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MiraSpacing.md),
            for (final row in _rows) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.label,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: NeumorphicIconButton(
                        icon: row.icon,
                        showBadge: row.badge,
                        size: 56,
                        iconSize: 24,
                        onTap: () {},
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: NeumorphicIconButton(
                        icon: row.icon,
                        showBadge: row.badge,
                        style: NeumorphicStyle.inset,
                        size: 56,
                        iconSize: 24,
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MiraSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
