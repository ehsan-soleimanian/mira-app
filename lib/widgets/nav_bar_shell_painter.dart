import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';

/// Vector nav shell — Figma Group 48095737 (mic cradle + rounded panel).
class NavBarShellPainter extends CustomPainter {
  const NavBarShellPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final panelTop = h * NavBarTokens.panelTopFactor;
    final topRadius = NavBarTokens.topCornerRadius * scale;
    final panelStroke = NavBarTokens.panelBorderWidth * scale;
    final micStroke = NavBarTokens.micBorderWidth * scale;

    final micLeft = w * NavBarTokens.micLeftFactor;
    final micWidth = w * (1 - NavBarTokens.micLeftFactor - NavBarTokens.micRightFactor);
    final micHeight = h * (1 - NavBarTokens.micBottomFactor);
    final micRect = Rect.fromLTWH(micLeft, 0, micWidth, micHeight);

    final panelRect = Rect.fromLTWH(0, panelTop, w, h - panelTop);
    final panelRRect = RRect.fromRectAndCorners(
      panelRect,
      topLeft: Radius.circular(topRadius),
      topRight: Radius.circular(topRadius),
    );

    final fillPaint = Paint()..color = AppColors.navBarFill;
    final borderPaint = Paint()
      ..color = AppColors.navBarStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = panelStroke;

    canvas.drawRRect(panelRRect, fillPaint);
    canvas.drawRRect(panelRRect, borderPaint);

    canvas.drawOval(
      micRect,
      fillPaint,
    );
    canvas.drawOval(
      micRect,
      Paint()
        ..color = AppColors.navBarStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = micStroke,
    );
  }

  @override
  bool shouldRepaint(covariant NavBarShellPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
