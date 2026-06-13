import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/widgets/circle_icon_button.dart';

/// Settings page header — back + centered title (GitHub [MiraPageHeader] pattern).
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 18,
            onTap: onBack ?? () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
