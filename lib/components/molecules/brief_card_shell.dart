import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Shared card shell for Daily Brief list items.
class BriefCardShell extends StatelessWidget {
  const BriefCardShell({
    super.key,
    required this.leading,
    required this.body,
    required this.badge,
    this.onTap,
  });

  final Widget leading;
  final Widget body;
  final Widget badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DailyBriefColors.cardBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: DailyBriefColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: body,
                ),
              ),
            ],
          ),
          Positioned(top: 0, right: 0, child: badge),
        ],
      ),
    );
  }
}
