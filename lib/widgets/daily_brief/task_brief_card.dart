import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_badge.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_shell.dart';
import 'package:mira_app/widgets/icons/task_clock_icon.dart';

class TaskBriefCard extends StatelessWidget {
  const TaskBriefCard({
    super.key,
    this.title = 'Product review with the team',
    this.timeLabel = 'Today, 10 A.M',
    this.onTap,
  });

  final String title;
  final String timeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BriefCardShell(
      onTap: onTap,
      leading: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: DailyBriefColors.checkboxBorder,
            width: 1.8,
          ),
        ),
      ),
      badge: const BriefCardBadge(
        label: 'Task',
        background: DailyBriefColors.taskBadgeBg,
        textColor: DailyBriefColors.taskBadgeText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: Text(title, style: DailyBriefTypography.cardTitle(1)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const TaskClockIcon(),
              const SizedBox(width: 4),
              Text(timeLabel, style: DailyBriefTypography.cardBody(1)),
            ],
          ),
        ],
      ),
    );
  }
}
