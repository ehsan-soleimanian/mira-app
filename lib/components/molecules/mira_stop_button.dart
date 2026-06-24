import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

/// Glass sky-blue stop disc with a saturated blue square icon.
class MiraStopButton extends StatelessWidget {
  const MiraStopButton({
    super.key,
    this.size = StopButtonTokens.defaultSize,
    this.onTap,
    this.fillColor = StopButtonTokens.fillColor,
    this.borderColor = StopButtonTokens.borderColor,
    this.iconColor = StopButtonTokens.iconColor,
  });

  final double size;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final square = size * (20 / StopButtonTokens.defaultSize);
    final s = size / StopButtonTokens.defaultSize;
    final borderWidth = 1.5 * s;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B8FE8).withValues(alpha: 0.18),
              offset: Offset(0, 8 * s),
              blurRadius: 18 * s,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14 * s, sigmaY: 14 * s),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fillColor,
                border: Border.all(color: borderColor, width: borderWidth),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    fillColor,
                    const Color(0xFF8EC5FF).withValues(alpha: 0.35),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: square,
                  height: square,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(square * 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.45),
                        blurRadius: 6 * s,
                        offset: Offset(0, 2 * s),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
