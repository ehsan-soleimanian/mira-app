import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/neumorphic_icon_button.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/screens/settings/settings_screen.dart';
import 'package:mira_app/theme/neumorphic_tokens.dart';

/// Settings gear — neumorphic inset icon (design system).
///
/// Figma reference: 742:10837 · uses [NeumorphicIconButton].
class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    this.onTap,
    this.size = 48,
    this.style = NeumorphicStyle.inset,
  });

  final VoidCallback? onTap;
  final double size;
  final NeumorphicStyle style;

  void _openSettings(BuildContext context) {
    Navigator.of(context).pushMira((_) => const SettingsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicIconButton(
      icon: Icons.settings_outlined,
      style: style,
      size: size,
      iconSize: size * (30 / 72),
      onTap: onTap ?? () => _openSettings(context),
    );
  }
}
