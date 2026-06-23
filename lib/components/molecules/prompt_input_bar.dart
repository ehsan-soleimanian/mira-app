import 'package:flutter/material.dart';
import 'package:mira_app/components/organisms/mira_composer_bar.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Bottom prompt row — Figma `742-11005` via [MiraComposerBar].
class PromptInputBar extends StatelessWidget {
  const PromptInputBar({
    super.key,
    required this.controller,
    this.onAddTap,
    this.onMicTap,
    this.onSend,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback? onAddTap;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = screenW / HomeScreenTokens.designWidth;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        0,
        20 * scale,
        bottomInset + 12 * scale,
      ),
      child: MiraComposerBar(
        controller: controller,
        scale: scale,
        onAdd: onAddTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attach photo, link or file'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
        onMicTap: onMicTap,
        onSend: onSend ?? onSubmitted,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
