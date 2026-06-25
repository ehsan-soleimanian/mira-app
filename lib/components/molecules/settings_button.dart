import 'package:flutter/material.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/screens/settings/settings_screen.dart';

/// Settings — Figma circular gear asset.
class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    this.onTap,
    this.size = 48,
  });

  final VoidCallback? onTap;
  final double size;

  void _openSettings(BuildContext context) {
    Navigator.of(context).pushMira((_) => const SettingsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => _openSettings(context),
      child: Image.asset(
        FigmaAssets.settingsIconPng,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
