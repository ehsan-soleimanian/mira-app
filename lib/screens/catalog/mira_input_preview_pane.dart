import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview — [MiraInputField] empty, active, and form modes.
class MiraInputPreviewPane extends StatefulWidget {
  const MiraInputPreviewPane({super.key});

  @override
  State<MiraInputPreviewPane> createState() => _MiraInputPreviewPaneState();
}

class _MiraInputPreviewPaneState extends State<MiraInputPreviewPane> {
  final _emptyController = TextEditingController();
  final _activeController =
      TextEditingController(text: 'Hello, How can I help?');
  final _formController = TextEditingController();

  @override
  void dispose() {
    _emptyController.dispose();
    _activeController.dispose();
    _formController.dispose();
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
            const _Label('Empty — grey border + mic (742:11005)'),
            const SizedBox(height: MiraSpacing.sm),
            MiraInputField(
              controller: _emptyController,
              onMicTap: () => _snack('Mic tapped'),
              onSend: (v) => _snack('Send: $v'),
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _Label('Active — blue border + send (742:11091)'),
            const SizedBox(height: MiraSpacing.sm),
            MiraInputField(
              controller: _activeController,
              onSend: (v) => _snack('Send: $v'),
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _Label('Flat form — solid border (onboarding / auth)'),
            const SizedBox(height: MiraSpacing.sm),
            MiraInputField(
              controller: _formController,
              hintText: 'your name',
              showMic: false,
              variant: MiraInputVariant.flat,
              radius: ComposerTokens.flatFieldRadius,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: MiraSpacing.lg),
            const _Label('Form mode — raised grey border (legacy)'),
            const SizedBox(height: MiraSpacing.sm),
            MiraInputField(
              hintText: 'Email',
              showMic: false,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: ComposerTokens.composerTextColor,
      ),
    );
  }
}
