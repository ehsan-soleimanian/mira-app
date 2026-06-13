import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

class BriefSectionDivider extends StatelessWidget {
  const BriefSectionDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: DailyBriefTypography.sectionLabel(1)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: DailyBriefColors.cardBorder,
          ),
        ),
      ],
    );
  }
}
