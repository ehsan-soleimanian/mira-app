import 'package:flutter/material.dart';

/// Thin "+" glyph with round caps.
class MiraPlusPainter extends CustomPainter {
  const MiraPlusPainter(this.color, {this.strokeWidth = 1.8});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant MiraPlusPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Figma microphone glyph — capsule, U-cradle, two sound lines (no stand).
class MiraComposerMicPainter extends CustomPainter {
  const MiraComposerMicPainter(this.color, {this.strokeWidth = 1.3});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const ox = 312.5, oy = 18.6665, ow = 15.0, oh = 16.6667;
    final scale = (size.width / ow) < (size.height / oh)
        ? size.width / ow
        : size.height / oh;

    canvas.save();
    canvas.translate(
      (size.width - ow * scale) / 2 - ox * scale,
      (size.height - oh * scale) / 2 - oy * scale,
    );
    canvas.scale(scale);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(315, 18.6665, 325, 32.8332),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(312.5, 26.1665)
        ..lineTo(312.5, 27.8332)
        ..cubicTo(312.5, 31.9748, 315.858, 35.3332, 320, 35.3332)
        ..cubicTo(324.142, 35.3332, 327.5, 31.9748, 327.5, 27.8332)
        ..lineTo(327.5, 26.1665),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(317.59, 23.2334)
        ..cubicTo(319.073, 22.6917, 320.69, 22.6917, 322.173, 23.2334),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(318.359, 25.7331)
        ..cubicTo(319.359, 25.4581, 320.418, 25.4581, 321.418, 25.7331),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiraComposerMicPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Figma up-arrow inside the send button (40px circle).
class MiraArrowUpPainter extends CustomPainter {
  const MiraArrowUpPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 40.0;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.5 / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(26.07, 16.57)
        ..lineTo(20, 10.5)
        ..lineTo(13.93, 16.57),
      paint,
    );
    canvas.drawLine(const Offset(20, 27.5), const Offset(20, 10.67), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiraArrowUpPainter oldDelegate) =>
      oldDelegate.color != color;
}
