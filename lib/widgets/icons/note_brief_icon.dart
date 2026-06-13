import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Overlapping notes icon for note cards — 28×28 from Figma.
class NoteBriefIcon extends StatelessWidget {
  const NoteBriefIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _NoteBriefIconPainter(),
    );
  }
}

class _NoteBriefIconPainter extends CustomPainter {
  const _NoteBriefIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = DailyBriefColors.noteIcon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.12, w * 0.62, h * 0.72),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(back, stroke);

    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.2, w * 0.62, h * 0.72),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(front, stroke);

    canvas.drawLine(Offset(w * 0.18, h * 0.42), Offset(w * 0.58, h * 0.42), stroke);
    canvas.drawLine(Offset(w * 0.18, h * 0.54), Offset(w * 0.5, h * 0.54), stroke);
    canvas.drawLine(Offset(w * 0.18, h * 0.66), Offset(w * 0.42, h * 0.66), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
