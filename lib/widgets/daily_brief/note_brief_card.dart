import 'package:flutter/material.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_badge.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_shell.dart';
import 'package:mira_app/widgets/icons/note_brief_icon.dart';

class NoteBriefCard extends StatelessWidget {
  const NoteBriefCard({
    super.key,
    required this.note,
    this.onMoreTap,
    this.onTap,
  });

  final BriefNote note;
  final VoidCallback? onMoreTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BriefCardShell(
      onTap: onTap,
      leading: const NoteBriefIcon(size: 28),
      badge: const BriefCardBadge(
        label: 'Note',
        background: DailyBriefColors.noteBadgeBg,
        textColor: DailyBriefColors.noteBadgeText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: Text(note.title, style: DailyBriefTypography.cardTitle(1)),
          ),
          const SizedBox(height: 4),
          Text(
            note.isExpanded ? note.fullText : note.preview,
            style: DailyBriefTypography.cardBody(1),
          ),
          GestureDetector(
            onTap: onMoreTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note.isExpanded ? 'less' : 'more',
                    style: DailyBriefTypography.cardBody(1),
                  ),
                  Icon(
                    note.isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: DailyBriefColors.metaGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
