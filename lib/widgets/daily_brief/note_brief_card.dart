import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_badge.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_shell.dart';
import 'package:mira_app/widgets/icons/note_brief_icon.dart';

class NoteBriefCard extends StatelessWidget {
  const NoteBriefCard({
    super.key,
    this.title = 'Lorem ipsum dolor sit amet,',
    this.preview = 'consectetur adipiscing elit, sed do',
    this.onTap,
    this.onMoreTap,
  });

  final String title;
  final String preview;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

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
            child: Text(title, style: DailyBriefTypography.cardTitle(1)),
          ),
          const SizedBox(height: 4),
          Text(preview, style: DailyBriefTypography.cardBody(1)),
          GestureDetector(
            onTap: onMoreTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('more', style: DailyBriefTypography.cardBody(1)),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
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
