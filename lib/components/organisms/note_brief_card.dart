import 'package:flutter/material.dart';
import 'package:mira_app/components/organisms/note_card.dart';
import 'package:mira_app/models/daily_brief_models.dart';

/// Daily Brief note row — wraps [NoteCard] for API/mock data.
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
    return NoteCard(
      title: note.title,
      body: note.fullText,
      tagLabel: note.nodeType,
      date: DailyBriefData.dateLabelFor(note.createdAt).isEmpty
          ? null
          : DailyBriefData.dateLabelFor(note.createdAt),
      expanded: note.isExpanded,
      onTap: onTap,
      onExpandedChange: (_) => onMoreTap?.call(),
    );
  }
}
