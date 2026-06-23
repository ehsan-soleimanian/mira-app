import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_composer_glyphs.dart';
import 'package:mira_app/components/molecules/mira_gradient_border_painter.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Circular "+" button — INSET (concave / تورفتگی) with gradient border.
///
/// Figma `Mira-App / 742-11005`.
class MiraAddButton extends StatelessWidget {
  const MiraAddButton({
    super.key,
    this.size = ComposerTokens.addButtonSize,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;

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
          boxShadow: ComposerTokens.addButtonOuterShadow,
        ),
        child: CustomPaint(
          painter: MiraInnerShadowPainter(
            shape: (s) => Path()..addOval(Offset.zero & s),
            baseColor: ComposerTokens.insetBase,
            darkShadow: ComposerTokens.softShadow.withValues(alpha: 0.7),
            lightShadow: Colors.white,
            blur: size * 0.17,
            offset: size * 0.10,
          ),
          child: CustomPaint(
            painter: MiraGradientBorderPainter(radius: size / 2),
            child: Center(
              child: SizedBox(
                width: size * 0.32,
                height: size * 0.32,
                child: const CustomPaint(
                  painter: MiraPlusPainter(ComposerTokens.glyphColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
