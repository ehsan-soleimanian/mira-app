import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/theme/neumorphic_tokens.dart';

/// Circular neumorphic icon button — [NeumorphicStyle.raised] (convex) or
/// [NeumorphicStyle.inset] (concave / تورفتگی), with optional badge.
///
/// ```dart
/// NeumorphicIconButton(icon: Icons.settings_outlined),
/// NeumorphicIconButton(
///   icon: Icons.arrow_back_rounded,
///   style: NeumorphicStyle.inset,
/// ),
/// NeumorphicIconButton(
///   icon: Icons.psychology_outlined,
///   showBadge: true,
/// ),
/// ```
class NeumorphicIconButton extends StatelessWidget {
  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.style = NeumorphicStyle.raised,
    this.size = 72,
    this.iconSize = 30,
    this.iconColor = NeumorphicTokens.iconColor,
    this.showBadge = false,
    this.badgeColor = NeumorphicTokens.badgeBlue,
    this.onTap,
  });

  final IconData icon;
  final NeumorphicStyle style;
  final double size;
  final double iconSize;
  final Color iconColor;
  final bool showBadge;
  final Color badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final distance = size * 0.095;
    final blur = size * 0.20;

    final face = Center(
      child: Icon(icon, size: iconSize, color: iconColor),
    );

    final circle = style == NeumorphicStyle.raised
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NeumorphicTokens.raisedSurface,
              boxShadow: [
                BoxShadow(
                  color: NeumorphicTokens.shadowDark.withValues(alpha: 0.6),
                  offset: Offset(distance, distance),
                  blurRadius: blur,
                ),
                BoxShadow(
                  color: NeumorphicTokens.shadowLight,
                  offset: Offset(-distance, -distance),
                  blurRadius: blur,
                ),
              ],
            ),
            child: face,
          )
        : SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: MiraInnerShadowPainter(
                shape: (s) => Path()..addOval(Offset.zero & s),
                baseColor: NeumorphicTokens.insetSurface,
                darkShadow: NeumorphicTokens.shadowDark.withValues(alpha: 0.75),
                lightShadow: NeumorphicTokens.shadowLight,
                blur: blur * 0.8,
                offset: distance * 0.9,
              ),
              child: face,
            ),
          );

    Widget result = circle;
    if (showBadge) {
      final badgeSize = size * 0.20;
      result = SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: circle),
            Positioned(
              top: size * 0.07,
              right: size * 0.07,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(
                    color: NeumorphicTokens.background,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: result,
    );
  }
}
