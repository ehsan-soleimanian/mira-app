import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/widgets/settings/settings_header.dart';
import 'package:mira_app/widgets/settings/settings_list_tile.dart';

/// Settings — structure from [ehsan-soleimanian/mira-app](https://github.com/ehsan-soleimanian/mira-app).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = AppScope.themeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final footerColor = isDark ? const Color(0xFF71717A) : AppColors.textHint;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SettingsHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListenableBuilder(
                listenable: themeController,
                builder: (context, _) {
                  return ListView(
                    children: [
                      const SettingsListTile(
                        title: 'Account',
                        icon: Icons.person_outline,
                        showChevron: true,
                      ),
                      const SettingsListTile(
                        title: 'Privacy',
                        icon: Icons.info_outline,
                        showChevron: true,
                      ),
                      SettingsListTile(
                        title: 'Appearance',
                        subtitle: themeController.isDark ? 'Dark mode' : 'Light mode',
                        icon: Icons.color_lens_outlined,
                        trailing: Switch.adaptive(
                          value: themeController.isDark,
                          activeTrackColor: AppColors.micBlueNav,
                          onChanged: (_) => themeController.toggle(),
                        ),
                      ),
                      const SettingsListTile(
                        title: 'Language',
                        icon: Icons.chat_bubble_outline,
                        showChevron: true,
                      ),
                      const SettingsListTile(
                        title: 'Help & support',
                        icon: Icons.warning_amber_outlined,
                        showChevron: true,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Mira Design System v1.0',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: footerColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
