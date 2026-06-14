import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/screens/settings_screen.dart';

/// Settings gear — Figma Frame 121075695 (742:10837), 48×48.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, this.onTap, this.size = 48});

  final VoidCallback? onTap;
  final double size;

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = size * (32 / 48);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _openSettings(context),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              FigmaAssets.settingsIcon,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
