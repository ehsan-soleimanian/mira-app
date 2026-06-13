import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/app_bottom_shell.dart';
import 'package:mira_app/widgets/daily_brief/brief_section_divider.dart';
import 'package:mira_app/widgets/daily_brief/daily_brief_header.dart';
import 'package:mira_app/widgets/daily_brief/image_brief_card.dart';
import 'package:mira_app/widgets/daily_brief/note_brief_card.dart';
import 'package:mira_app/widgets/daily_brief/task_brief_card.dart';

class DailyBriefScreen extends StatelessWidget {
  const DailyBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DailyBriefHeader(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: const [
                  BriefSectionDivider(label: 'Today'),
                  SizedBox(height: 14),
                  TaskBriefCard(),
                  SizedBox(height: 10),
                  NoteBriefCard(),
                  SizedBox(height: 10),
                  ImageBriefCard(),
                  SizedBox(height: 24),
                  BriefSectionDivider(label: 'Yesterday'),
                  SizedBox(height: 14),
                  TaskBriefCard(),
                  SizedBox(height: 10),
                  NoteBriefCard(),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.dailyBrief,
        onHomeTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}
