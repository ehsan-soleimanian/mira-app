import 'package:flutter/material.dart';

/// vuesax/linear/coffee — 32×32
class DailyBriefNavIcon extends StatelessWidget {
  const DailyBriefNavIcon({
    super.key,
    this.size = 32,
    this.color = const Color(0xFF8E8E93),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoffeeNavIconPainter(color: color),
    );
  }
}

class _CoffeeNavIconPainter extends CustomPainter {
  const _CoffeeNavIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.28, h * 0.1), Offset(w * 0.28, h * 0.18), stroke);
    canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.16), stroke);
    canvas.drawLine(Offset(w * 0.72, h * 0.1), Offset(w * 0.72, h * 0.18), stroke);

    final cup = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.52, h * 0.42),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(cup, stroke);

    canvas.drawLine(Offset(w * 0.18, h * 0.5), Offset(w * 0.7, h * 0.5), stroke);

    final handle = Path()
      ..moveTo(w * 0.7, h * 0.36)
      ..quadraticBezierTo(w * 0.92, h * 0.36, w * 0.92, h * 0.52)
      ..quadraticBezierTo(w * 0.92, h * 0.68, w * 0.7, h * 0.66);
    canvas.drawPath(handle, stroke);
  }

  @override
  bool shouldRepaint(covariant _CoffeeNavIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
