import 'package:flutter/material.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Empty Daily Brief — preview cards instead of orb / "no memories".
class DailyBriefEmptyPreview extends StatelessWidget {
  const DailyBriefEmptyPreview({
    super.key,
    required this.items,
    required this.onDismiss,
    required this.onCardTap,
    required this.onCheckboxChanged,
    required this.onNoteExpand,
  });

  final List<BriefItem> items;
  final ValueChanged<BriefItem> onDismiss;
  final ValueChanged<BriefItem> onCardTap;
  final void Function(String id, bool value) onCheckboxChanged;
  final ValueChanged<String> onNoteExpand;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          'Your Daily Brief is getting ready',
          style: DailyBriefTypography.headerTitle(1.02),
        ),
        const SizedBox(height: 6),
        Text(
          'Tasks, daily updates, and context from Mira will appear here. '
          'Swipe a preview card left to dismiss it.',
          style: DailyBriefTypography.cardBody(1),
        ),
        const SizedBox(height: 20),
        if (items.isNotEmpty) ...[
          const BriefSectionDivider(label: 'Preview'),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _DismissibleBriefCard(
              item: items[i],
              onDismissed: () => onDismiss(items[i]),
              child: _PreviewCard(
                item: items[i],
                onTap: () => onCardTap(items[i]),
                onCheckboxChanged: onCheckboxChanged,
                onNoteExpand: onNoteExpand,
              ),
            ),
            if (i < items.length - 1) const SizedBox(height: 10),
          ],
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Preview cards dismissed. Pull down to refresh when your brief is ready.',
            style: DailyBriefTypography.cardBody(1),
          ),
        ],
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.item,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.onNoteExpand,
  });

  final BriefItem item;
  final VoidCallback onTap;
  final void Function(String id, bool value) onCheckboxChanged;
  final ValueChanged<String> onNoteExpand;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.94,
      child: switch (item) {
        BriefTask task => TaskBriefCard(
          task: task,
          onCheckboxChanged: (v) => onCheckboxChanged(task.id, v),
          onTap: onTap,
        ),
        BriefNote note => NoteBriefCard(
          note: note,
          onMoreTap: () => onNoteExpand(note.id),
          onTap: onTap,
        ),
        BriefImageItem image => ImageBriefCard(
          item: image,
          onTap: onTap,
        ),
      },
    );
  }
}

class _DismissibleBriefCard extends StatelessWidget {
  const _DismissibleBriefCard({
    required this.item,
    required this.child,
    required this.onDismissed,
  });

  final BriefItem item;
  final Widget child;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFC62828),
          size: 22,
        ),
      ),
      child: child,
    );
  }
}

/// Floating undo bar after swiping away a preview card.
class DailyBriefUndoBar extends StatelessWidget {
  const DailyBriefUndoBar({
    super.key,
    required this.onUndo,
  });

  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      color: AppColors.textPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Card removed',
              style: DailyBriefTypography.cardBody(1).copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onUndo,
              child: Text(
                'Undo',
                style: DailyBriefTypography.cardTitle(0.95).copyWith(
                  color: const Color(0xFF8EB4FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
