import 'package:flutter/material.dart';
import 'package:mira_app/components/organisms/mira_composer_bar.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Bottom prompt row — Figma `742-11005` via [MiraComposerBar].
class PromptInputBar extends StatelessWidget {
  const PromptInputBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onAddTap,
    this.onMicTap,
    this.onSend,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onAddTap;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final scale = screenW / HomeScreenTokens.designWidth;
    final bottomPadding = keyboardInset > 0
        ? keyboardInset + 12 * scale
        : bottomInset + 12 * scale;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, bottomPadding),
      child: MiraComposerBar(
        controller: controller,
        focusNode: focusNode,
        scale: scale,
        onAdd:
            onAddTap ??
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
