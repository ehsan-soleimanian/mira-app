import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_add_button.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/components/organisms/mira_composer_bar.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview — empty (mic) and active (send + blue border) states.
class ComposerPreviewPane extends StatefulWidget {
  const ComposerPreviewPane({super.key});

  @override
  State<ComposerPreviewPane> createState() => _ComposerPreviewPaneState();
}

class _ComposerPreviewPaneState extends State<ComposerPreviewPane> {
  final _emptyController = TextEditingController();
  final _activeController =
      TextEditingController(text: 'Hello, How can I help?');

  @override
  void dispose() {
    _emptyController.dispose();
    _activeController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ComposerTokens.previewBackground,
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Empty — grey border + mic (742:11005)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ComposerTokens.composerTextColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.sm),
            MiraComposerBar(
              controller: _emptyController,
              onAdd: () => _snack('Add tapped'),
              onMicTap: () => _snack('Mic tapped'),
              onSend: (v) => _snack('Send: $v'),
            ),
            const SizedBox(height: MiraSpacing.lg),
            const Text(
              'Active — blue border + send (742:11091)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ComposerTokens.composerTextColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.sm),
            MiraComposerBar(
              controller: _activeController,
              onSend: (v) => _snack('Send: $v'),
            ),
            const SizedBox(height: MiraSpacing.lg),
            const Text(
              'Parts',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ComposerTokens.composerTextColor,
              ),
            ),
            const SizedBox(height: MiraSpacing.sm),
            Row(
              children: [
                MiraAddButton(onTap: () => _snack('Add')),
                const SizedBox(width: MiraSpacing.md),
                const Expanded(
                  child: MiraInputField(hintText: 'Type here...'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
