import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_composer_glyphs.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Round send button — light ring + up arrow (Figma `742-11091` active state).
class MiraSendButton extends StatelessWidget {
  const MiraSendButton({
    super.key,
    this.onTap,
    this.size = ComposerTokens.sendButtonSize,
  });

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFBFD), Color(0xFFEFF2F6)],
          ),
          border: Border.all(color: ComposerTokens.sendRing, width: 1),
          boxShadow: [
            BoxShadow(
              color: ComposerTokens.softShadow.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: const CustomPaint(
          painter: MiraArrowUpPainter(ComposerTokens.glyphColor),
        ),
      ),
    );
  }
}
