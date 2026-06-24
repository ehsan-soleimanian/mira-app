import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/components/molecules/settings_button.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

class DailyBriefHeader extends StatelessWidget {
  const DailyBriefHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return MiraPageHeader(
      onBack: onBack,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Daily Brief', style: DailyBriefTypography.headerTitle(1)),
          const SizedBox(height: 2),
          Text(
            'Everything that matters today',
            style: DailyBriefTypography.headerSubtitle(1),
          ),
        ],
      ),
      trailing: const SettingsButton(),
    );
  }
}
