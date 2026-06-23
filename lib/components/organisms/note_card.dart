import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/note_glyph.dart';
import 'package:mira_app/components/molecules/expandable_note_text.dart';
import 'package:mira_app/components/molecules/mira_gradient_border_painter.dart';
import 'package:mira_app/components/molecules/note_card_tag.dart';
import 'package:mira_app/theme/note_card_tokens.dart';

/// Expandable "Note" card — light surface, soft shadow, gradient border.
///
/// ```dart
/// NoteCard(title: 'Lorem ipsum…', body: longText),
/// NoteCard(title: '…', body: longText, initiallyExpanded: true),
/// NoteCard(title: '…', body: longText, date: '2024 /02/12'),
/// ```
class NoteCard extends StatefulWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.body,
    this.tagLabel = 'Note',
    this.date,
    this.leading,
    this.initiallyExpanded = false,
    this.expanded,
    this.collapsedLines = 2,
    this.onTap,
    this.onExpandedChange,
  });

  final String title;
  final String body;
  final String tagLabel;
  final String? date;
  final Widget? leading;
  final bool initiallyExpanded;

  /// When set, expansion is controlled by the parent ([onExpandedChange]).
  final bool? expanded;
  final int collapsedLines;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onExpandedChange;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late bool _expanded = widget.expanded ?? widget.initiallyExpanded;

  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != _expanded) {
      _expanded = widget.expanded!;
    }
  }

  bool get _isExpanded => widget.expanded ?? _expanded;

  void _toggle() {
    final next = !_isExpanded;
    if (widget.expanded != null) {
      widget.onExpandedChange?.call(next);
    } else {
      setState(() => _expanded = next);
      widget.onExpandedChange?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NoteCardTokens.surface,
          borderRadius: BorderRadius.circular(NoteCardTokens.radius),
          boxShadow: NoteCardTokens.cardShadow,
        ),
        child: CustomPaint(
          painter: MiraGradientBorderPainter(
            radius: NoteCardTokens.radius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.leading ?? const NoteGlyph(size: 34),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 60, top: 1),
                                child: Text(
                                  widget.title,
                                  style: NoteCardTokens.titleStyle,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ExpandableNoteText(
                                text: widget.body,
                                expanded: _isExpanded,
                                collapsedLines: widget.collapsedLines,
                                onToggle: _toggle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.date != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.date!,
                            style: NoteCardTokens.dateStyle,
                          ),
                        ),
                      ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: NoteCardTag(label: widget.tagLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
