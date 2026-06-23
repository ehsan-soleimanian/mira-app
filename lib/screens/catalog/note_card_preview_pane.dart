import 'package:flutter/material.dart';
import 'package:mira_app/components/organisms/note_card.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/note_card_tokens.dart';

/// Catalog preview — collapsed, expanded, and dated [NoteCard] variants.
class NoteCardPreviewPane extends StatelessWidget {
  const NoteCardPreviewPane({super.key});

  static const _lorem =
      'consectetur adipiscing elit, sed do Lorem ipsum dolor sit amet, '
      'consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore '
      'et dolore magna aliqua Egestas purus viverra accumsan in nisl nisi Arcu '
      'cursus vitae congue mauris rhoncus aenean vel elit scelerisque';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NoteCardTokens.previewBackground,
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          children: const [
            NoteCard(
              title: 'Lorem ipsum dolor sit amet,',
              body: _lorem,
            ),
            SizedBox(height: 22),
            NoteCard(
              title: 'Lorem ipsum dolor sit amet,',
              body: _lorem,
              initiallyExpanded: true,
            ),
            SizedBox(height: 22),
            NoteCard(
              title: 'Lorem ipsum dolor sit amet,',
              body: _lorem,
              date: '2024 /02/12',
            ),
          ],
        ),
      ),
    );
  }
}
