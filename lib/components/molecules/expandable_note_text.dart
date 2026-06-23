import 'package:flutter/material.dart';
import 'package:mira_app/theme/note_card_tokens.dart';

/// Truncated note body with " more ⌄" / full text with " ⌃" — tap to toggle.
class ExpandableNoteText extends StatelessWidget {
  const ExpandableNoteText({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.collapsedLines = 2,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int collapsedLines;

  TextSpan _chevron(IconData icon, {String lead = ' '}) => TextSpan(
        text: '$lead${String.fromCharCode(icon.codePoint)}',
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 22,
          color: NoteCardTokens.ink,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          if (expanded) {
            return Text.rich(
              TextSpan(
                style: NoteCardTokens.bodyStyle,
                children: [
                  TextSpan(text: text),
                  _chevron(Icons.keyboard_arrow_up_rounded),
                ],
              ),
            );
          }

          final probe = TextPainter(
            text: TextSpan(text: text, style: NoteCardTokens.bodyStyle),
            maxLines: collapsedLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          if (!probe.didExceedMaxLines) {
            return Text.rich(
              TextSpan(
                style: NoteCardTokens.bodyStyle,
                children: [
                  TextSpan(text: text),
                  _chevron(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            );
          }

          final tail = _chevron(
            Icons.keyboard_arrow_down_rounded,
            lead: ' more ',
          );
          var lo = 0;
          var hi = text.length;
          var best = 0;
          while (lo <= hi) {
            final mid = (lo + hi) >> 1;
            final tp = TextPainter(
              text: TextSpan(
                style: NoteCardTokens.bodyStyle,
                children: [
                  TextSpan(text: text.substring(0, mid).trimRight()),
                  tail,
                ],
              ),
              maxLines: collapsedLines,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: maxWidth);
            if (tp.didExceedMaxLines) {
              hi = mid - 1;
            } else {
              best = mid;
              lo = mid + 1;
            }
          }

          return Text.rich(
            TextSpan(
              style: NoteCardTokens.bodyStyle,
              children: [
                TextSpan(text: text.substring(0, best).trimRight()),
                tail,
              ],
            ),
          );
        },
      ),
    );
  }
}
