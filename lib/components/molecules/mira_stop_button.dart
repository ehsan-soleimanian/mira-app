import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

/// Circular stop button styled like the 741:4986 inset mic well.
///
/// Figma `618:3447` - e.g. stop voice recording.
///
/// ```dart
/// MiraStopButton(onTap: _stopRecording);
/// ```
class MiraStopButton extends StatelessWidget {
  const MiraStopButton({
    super.key,
    this.size = StopButtonTokens.defaultSize,
    this.onTap,
    this.fillColor = StopButtonTokens.fillColor,
    this.iconColor = StopButtonTokens.iconColor,
  });

  /// Diameter of the circle (excludes the soft shadow margin).
  final double size;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final square = size * (20 / StopButtonTokens.defaultSize);
    final s = size / StopButtonTokens.defaultSize;

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
              color: MiraEarNavTokens.shadowDark.withValues(alpha: 0.6),
              offset: Offset(0, 7 * s),
              blurRadius: 15 * s,
            ),
            BoxShadow(
              color: MiraEarNavTokens.shadowLight,
              offset: Offset(-4 * s, -4 * s),
              blurRadius: 10 * s,
            ),
          ],
        ),
        child: CustomPaint(
          painter: MiraInnerShadowPainter(
            shape: (size) => Path()..addOval(Offset.zero & size),
            baseColor: fillColor,
            darkShadow: MiraEarNavTokens.shadowDark.withValues(alpha: 0.75),
            lightShadow: Colors.white,
            blur: 9 * s,
            offset: 6 * s,
          ),
          child: Center(
            child: Container(
              width: square,
              height: square,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(square * 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
