import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/neumorphic_icon_button.dart';
import 'package:mira_app/theme/neumorphic_tokens.dart';

/// Back chevron — neumorphic inset icon (design system).
class MiraBackButton extends StatelessWidget {
  const MiraBackButton({super.key, this.onTap, this.size = 48});

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return NeumorphicIconButton(
      icon: Icons.arrow_back_ios_new_rounded,
      style: NeumorphicStyle.inset,
      size: size,
      iconSize: size * (18 / 48),
      onTap: onTap ?? () => Navigator.maybePop(context),
    );
  }
}
