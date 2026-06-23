import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

class BriefCardBadge extends StatelessWidget {
  const BriefCardBadge({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: DailyBriefTypography.badge(1, textColor),
      ),
    );
  }
}
