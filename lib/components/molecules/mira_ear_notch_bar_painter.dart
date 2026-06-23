import 'package:flutter/material.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';

/// Bar with raised corner ears blending into flat middle via concave notches.
class MiraEarNotchBarPainter extends CustomPainter {
  const MiraEarNotchBarPainter({this.scale = 1});

  final double scale;

  double s(double v) => v * scale;

  Path _buildPath(Size size) {
    final w = size.width;
    final bottom = size.height;
    final peakY = s(MiraEarNavTokens.peakY);
    final flatY = s(MiraEarNavTokens.flatY);
    final radius = s(MiraEarNavTokens.radius);
    final dipWidth = s(MiraEarNavTokens.dipWidth);

    final xDipL = radius + dipWidth;
    final xDipR = w - radius - dipWidth;

    return Path()
      ..moveTo(0, peakY + radius)
      ..quadraticBezierTo(0, peakY, radius, peakY)
      ..cubicTo(
        (radius + xDipL) / 2,
        peakY,
        (radius + xDipL) / 2,
        flatY,
        xDipL,
        flatY,
      )
      ..lineTo(xDipR, flatY)
      ..cubicTo(
        (xDipR + (w - radius)) / 2,
        flatY,
        (xDipR + (w - radius)) / 2,
        peakY,
        w - radius,
        peakY,
      )
      ..quadraticBezierTo(w, peakY, w, peakY + radius)
      ..lineTo(w, bottom - radius)
      ..quadraticBezierTo(w, bottom, w - radius, bottom)
      ..lineTo(radius, bottom)
      ..quadraticBezierTo(0, bottom, 0, bottom - radius)
      ..close();
  }

  Path _topEdgePath(Size size) {
    final w = size.width;
    final peakY = s(MiraEarNavTokens.peakY);
    final flatY = s(MiraEarNavTokens.flatY);
    final radius = s(MiraEarNavTokens.radius);
    final dipWidth = s(MiraEarNavTokens.dipWidth);
    final xDipL = radius + dipWidth;
    final xDipR = w - radius - dipWidth;

    return Path()
      ..moveTo(0, peakY + radius)
      ..quadraticBezierTo(0, peakY, radius, peakY)
      ..cubicTo(
        (radius + xDipL) / 2,
        peakY,
        (radius + xDipL) / 2,
        flatY,
        xDipL,
        flatY,
      )
      ..lineTo(xDipR, flatY)
      ..cubicTo(
        (xDipR + (w - radius)) / 2,
        flatY,
        (xDipR + (w - radius)) / 2,
        peakY,
        w - radius,
        peakY,
      )
      ..quadraticBezierTo(w, peakY, w, peakY + radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    canvas.drawPath(
      path.shift(Offset(0, s(9))),
      Paint()
        ..color = MiraEarNavTokens.shadowDark.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s(11)),
    );

    canvas.drawPath(
      path.shift(Offset(s(-4), s(-5))),
      Paint()
        ..color = MiraEarNavTokens.shadowLight
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s(7)),
    );

    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F4F8)],
        ).createShader(rect),
    );

    canvas.drawPath(
      _topEdgePath(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s(1.5)
        ..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant MiraEarNotchBarPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
