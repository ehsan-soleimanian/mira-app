import 'package:flutter/material.dart';
import 'package:mira_app/screens/settings_screen.dart';
import 'package:mira_app/theme/app_colors.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, this.onTap});

  final VoidCallback? onTap;

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _openSettings(context),
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_outlined,
            size: 22,
            color: AppColors.settingsIcon,
          ),
        ),
      ),
    );
  }
}
