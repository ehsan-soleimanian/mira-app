import 'package:flutter/material.dart';

/// vuesax/linear/home — 32×32
class HomeNavIcon extends StatelessWidget {
  const HomeNavIcon({super.key, this.size = 32, this.color = const Color(0xFF171717)});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomeNavIconPainter(color: color),
    );
  }
}

class _HomeNavIconPainter extends CustomPainter {
  const _HomeNavIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final house = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.88, h * 0.4)
      ..lineTo(w * 0.88, h * 0.88)
      ..lineTo(w * 0.12, h * 0.88)
      ..lineTo(w * 0.12, h * 0.4)
      ..close();
    canvas.drawPath(house, stroke);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.58),
      Offset(w * 0.5, h * 0.88),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeNavIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
