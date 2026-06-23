import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Clock icon for task cards — 14×14 stroke style.
class TaskClockIcon extends StatelessWidget {
  const TaskClockIcon({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _TaskClockIconPainter(),
    );
  }
}

class _TaskClockIconPainter extends CustomPainter {
  const _TaskClockIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = DailyBriefColors.metaGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.42;

    canvas.drawCircle(center, radius, stroke);
    canvas.drawLine(center, Offset(w / 2, h * 0.32), stroke);
    canvas.drawLine(center, Offset(w * 0.62, h * 0.58), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
