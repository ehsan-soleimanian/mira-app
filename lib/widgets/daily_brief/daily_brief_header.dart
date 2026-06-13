import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/circle_icon_button.dart';
import 'package:mira_app/widgets/settings_button.dart';

class DailyBriefHeader extends StatelessWidget {
  const DailyBriefHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 18,
            onTap: onBack,
          ),
          Expanded(
            child: Column(
              children: [
                Text('Daily Brief', style: DailyBriefTypography.headerTitle(1)),
                const SizedBox(height: 2),
                Text(
                  'Everthing that matters today',
                  style: DailyBriefTypography.headerSubtitle(1),
                ),
              ],
            ),
          ),
          const SettingsButton(),
        ],
      ),
    );
  }
}
