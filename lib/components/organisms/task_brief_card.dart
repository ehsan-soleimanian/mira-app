import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/brief_card_badge.dart';
import 'package:mira_app/components/atoms/task_brief_checkbox.dart';
import 'package:mira_app/components/atoms/task_clock_icon.dart';
import 'package:mira_app/components/molecules/brief_card_shell.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

class TaskBriefCard extends StatelessWidget {
  const TaskBriefCard({
    super.key,
    required this.task,
    this.onCheckboxChanged,
    this.onTap,
  });

  final BriefTask task;
  final ValueChanged<bool>? onCheckboxChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = DailyBriefTypography.cardTitle(1).copyWith(
      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
      color: task.isCompleted
          ? DailyBriefColors.metaGrey
          : DailyBriefTypography.cardTitle(1).color,
    );

    return BriefCardShell(
      onTap: onTap,
      leading: TaskBriefCheckbox(
        checked: task.isCompleted,
        onChanged: onCheckboxChanged ?? (_) {},
      ),
      badge: BriefCardBadge(
        label: task.nodeType,
        background: DailyBriefColors.taskBadgeBg,
        textColor: DailyBriefColors.taskBadgeText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: Text(task.title, style: titleStyle),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const TaskClockIcon(),
              const SizedBox(width: 4),
              Text(task.timeLabel, style: DailyBriefTypography.cardBody(1)),
            ],
          ),
        ],
      ),
    );
  }
}
