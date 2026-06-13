import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';

/// vuesax/linear/microphone — 28×28
class MicNavIcon extends StatelessWidget {
  const MicNavIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _MicNavIconPainter(),
    );
  }
}

class _MicNavIconPainter extends CustomPainter {
  const _MicNavIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.micBlueNav
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final capsule = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.083, w * 0.5, h * 0.625),
      Radius.circular(w * 0.25),
    );
    canvas.drawRRect(capsule, stroke);

    for (var i = 0; i < 3; i++) {
      final y = h * (0.22 + i * 0.1);
      final path = Path()
        ..moveTo(w * 0.36, y)
        ..quadraticBezierTo(w * 0.5, y - h * 0.02, w * 0.64, y);
      canvas.drawPath(path, stroke);
    }

    final stand = Path()
      ..moveTo(w * 0.125, h * 0.458)
      ..quadraticBezierTo(w * 0.125, h * 0.88, w * 0.5, h * 0.88)
      ..quadraticBezierTo(w * 0.875, h * 0.88, w * 0.875, h * 0.458);
    canvas.drawPath(stand, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
