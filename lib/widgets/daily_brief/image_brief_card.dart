import 'package:flutter/material.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_badge.dart';
import 'package:mira_app/widgets/daily_brief/brief_card_shell.dart';

class ImageBriefCard extends StatelessWidget {
  const ImageBriefCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final BriefImageItem item;
  final VoidCallback? onTap;

  static const _thumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    return BriefCardShell(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          item.imageAsset,
          width: _thumbSize,
          height: _thumbSize,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
      badge: const BriefCardBadge(
        label: 'Image',
        background: DailyBriefColors.imageBadgeBg,
        textColor: DailyBriefColors.imageBadgeText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: Text(item.title, style: DailyBriefTypography.cardTitle(1)),
          ),
          const SizedBox(height: 4),
          Text(item.preview, style: DailyBriefTypography.cardBody(1)),
        ],
      ),
    );
  }
}
