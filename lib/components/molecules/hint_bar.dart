import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// Tip tooltip — Figma component Tip (742:10883).
class HintBar extends StatelessWidget {
  const HintBar({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 318 * s,
          height: 37 * s,
          child: CustomPaint(
            painter: MiraInnerShadowPainter(
              shape: (size) => Path()
                ..addRRect(
                  RRect.fromRectAndRadius(
                    Offset.zero & size,
                    Radius.circular(2 * s),
                  ),
                ),
              baseColor: AppColors.hintBarFill,
              darkShadow: const Color(0xFFC8C8CC).withValues(alpha: 0.52),
              lightShadow: Colors.white.withValues(alpha: 0.92),
              blur: 5 * s,
              offset: 2.5 * s,
            ),
            foregroundPainter: _HintBorderPainter(scale: s),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * s),
                child: Text(
                  'Hold take a voic / Click send photo , link and text',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: AppTypography.tip(s),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -1 * s),
          child: SizedBox(
            width: 9 * s,
            height: 7 * s,
            child: CustomPaint(painter: _HintArrowPainter(scale: s)),
          ),
        ),
      ],
    );
  }
}

class _HintBorderPainter extends CustomPainter {
  const _HintBorderPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5 * scale),
      Radius.circular(2 * scale),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale
        ..color = Colors.white.withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(covariant _HintBorderPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

class _HintArrowPainter extends CustomPainter {
  const _HintArrowPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawShadow(path, const Color(0xFFC8C8CC), 1.5 * scale, false);
    canvas.drawPath(path, Paint()..color = AppColors.hintBarFill);

    canvas.drawLine(
      Offset(0.5 * scale, 0),
      Offset(size.width - 0.5 * scale, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.68)
        ..strokeWidth = 1 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant _HintArrowPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
