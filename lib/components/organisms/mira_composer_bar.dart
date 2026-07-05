import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_add_button.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// "+" inset button + raised pill input — Figma `742-11005` / `742-11091`.
class MiraComposerBar extends StatelessWidget {
  const MiraComposerBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onAdd,
    this.onMicTap,
    this.onSend,
    this.onSubmitted,
    this.hintText = 'Type Here',
    this.scale = 1.0,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onAdd;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final addSize = ComposerTokens.addButtonSize * s;
    final inputH = ComposerTokens.inputHeight * s;
    final inputR = ComposerTokens.inputRadius * s;
    final sendSize = ComposerTokens.sendButtonSize * s;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MiraAddButton(size: addSize, onTap: onAdd),
        SizedBox(width: MiraSpacing.sm * s),
        Expanded(
          child: MiraInputField(
            controller: controller,
            focusNode: focusNode,
            hintText: hintText,
            onMicTap: onMicTap,
            onSend: onSend,
            onSubmitted: onSubmitted,
            height: inputH,
            radius: inputR,
            sendButtonSize: sendSize,
            minLines: 1,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
          ),
        ),
      ],
    );
  }
}
