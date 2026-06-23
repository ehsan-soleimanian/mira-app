import 'package:flutter/material.dart';

/// Neumorphic INSET shadow inside [shape] — dark top-left, light bottom-right.
class MiraInnerShadowPainter extends CustomPainter {
  const MiraInnerShadowPainter({
    required this.shape,
    required this.baseColor,
    required this.darkShadow,
    required this.lightShadow,
    this.blur = 8,
    this.offset = 5,
  });

  final Path Function(Size size) shape;
  final Color baseColor;
  final Color darkShadow;
  final Color lightShadow;
  final double blur;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shape(size);
    canvas.drawPath(path, Paint()..color = baseColor);

    canvas.save();
    canvas.clipPath(path);

    final bounds = (Offset.zero & size).inflate(blur * 3 + offset + 2);
    final inverse = Path.combine(
      PathOperation.difference,
      Path()..addRect(bounds),
      path,
    );
    final mask = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawPath(
      inverse.shift(Offset(offset, offset)),
      Paint()
        ..color = darkShadow
        ..maskFilter = mask,
    );
    canvas.drawPath(
      inverse.shift(Offset(-offset, -offset)),
      Paint()
        ..color = lightShadow
        ..maskFilter = mask,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiraInnerShadowPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.darkShadow != darkShadow ||
      oldDelegate.lightShadow != lightShadow ||
      oldDelegate.blur != blur ||
      oldDelegate.offset != offset;
}
