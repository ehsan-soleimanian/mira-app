import 'package:flutter/material.dart';
import 'package:mira_app/theme/note_card_tokens.dart';

/// Pink "Note" tag pill on [NoteCard].
class NoteCardTag extends StatelessWidget {
  const NoteCardTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: NoteCardTokens.tagBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: NoteCardTokens.tagText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
