import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';
import 'package:mira_app/theme/neo_theme.dart';

/// Builds nav-bar geometry from Figma frame 741:4963 (mic oval + rounded panel).
class NavBarPathBuilder {
  const NavBarPathBuilder._();

  static double scaleOf(double width) => width / NavBarTokens.designWidth;

  /// Mic cradle oval — Figma ellipse in group 741:4963.
  static Rect micOvalRect(Size size) {
    final w = size.width;
    final h = size.height;
    final micLeft = w * NavBarTokens.micLeftFactor;
    final micWidth =
        w * (1 - NavBarTokens.micLeftFactor - NavBarTokens.micRightFactor);
    final micHeight = h * (1 - NavBarTokens.micBottomFactor);
    return Rect.fromLTWH(micLeft, 0, micWidth, micHeight);
  }

  static RRect panelRRect(Size size, double scale) {
    final w = size.width;
    final h = size.height;
    final inset = NavBarTokens.panelHorizontalInset * scale;
    final panelTop = h * NavBarTokens.panelTopFactor;
    final cornerR = NavBarTokens.topCornerRadius * scale;
    return RRect.fromRectAndCorners(
      Rect.fromLTWH(inset, panelTop, w - inset * 2, h - panelTop),
      topLeft: Radius.circular(cornerR),
      topRight: Radius.circular(cornerR),
    );
  }

  static Path panelPath(Size size, double scale) =>
      Path()..addRRect(panelRRect(size, scale));

  static Path micOvalPath(Size size) => Path()..addOval(micOvalRect(size));

  /// Silhouette used for neumorphic extrusion (oval ∪ panel).
  static Path silhouettePath(Size size, double scale) => Path.combine(
    PathOperation.union,
    panelPath(size, scale),
    micOvalPath(size),
  );

  /// Inset oval for recessed notch bowl.
  static Path notchRecessPath(Size size, double scale) {
    final oval = micOvalRect(size);
    final inset = NavBarTokens.notchRecessInset * scale;
    return Path()..addOval(oval.deflate(inset));
  }

  static double fabDiameter(Size size) => micOvalRect(size).width;

  static Offset fabCenter(Size size, double scale) => micOvalRect(size).center;
}

/// Neumorphic nav shell — extruded bar + recessed mic notch (741:4963).
class NavBarShellPainter extends CustomPainter {
  const NavBarShellPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = NavBarPathBuilder.panelPath(size, scale);
    final panelRRect = NavBarPathBuilder.panelRRect(size, scale);
    final oval = NavBarPathBuilder.micOvalPath(size);
    final silhouette = NavBarPathBuilder.silhouettePath(size, scale);
    final recess = NavBarPathBuilder.notchRecessPath(size, scale);
    final ovalBounds = NavBarPathBuilder.micOvalRect(size);

    // Extruded navbar body (dual shadow, no flat border).
    NeoShadows.paintExtruded(
      canvas,
      silhouette,
      fill: NeoColors.base,
      scale: scale,
      distance: NavBarTokens.neoDistance,
      blur: NavBarTokens.neoBlur,
    );

    // Recessed inner bowl in the mic cradle notch.
    NeoShadows.paintRecessed(canvas, recess, ovalBounds, scale: scale);

    // Subtle top-edge ambient on panel for depth along flat sections.
    canvas.save();
    canvas.clipPath(panel);
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          NeoColors.highlight.withValues(alpha: 0.35),
          NeoColors.highlight.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.18],
      ).createShader(Rect.fromLTWH(0, ovalBounds.top, size.width, 24 * scale));
    canvas.drawRect(
      Rect.fromLTWH(0, ovalBounds.top, size.width, 24 * scale),
      topGlow,
    );
    canvas.restore();

    // Fine rim lines mirror the Neo reference: soft grey edge, white lip.
    final rimWidth = NavBarTokens.panelBorderWidth * scale;
    canvas.drawRRect(
      panelRRect,
      Paint()
        ..color = AppColors.navBarStroke.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth,
    );
    canvas.drawRRect(
      panelRRect.deflate(0.7 * scale),
      Paint()
        ..color = NeoColors.highlight.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * scale,
    );

    final bottomLine = panelRRect.outerRect.bottom - 1.1 * scale;
    canvas.drawLine(
      Offset(panelRRect.outerRect.left + panelRRect.blRadiusX, bottomLine),
      Offset(panelRRect.outerRect.right - panelRRect.brRadiusX, bottomLine),
      Paint()
        ..color = NeoColors.highlight.withValues(alpha: 0.95)
        ..strokeWidth = 1.2 * scale
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      oval,
      Paint()
        ..color = AppColors.navBarStroke.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = NavBarTokens.micBorderWidth * scale,
    );
    canvas.drawPath(
      oval.shift(Offset(0, 0.8 * scale)),
      Paint()
        ..color = NeoColors.highlight.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant NavBarShellPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

/// Blue progress arc on FAB hold (replaces idle accent in neo style).
class MicFabAccentPainter extends CustomPainter {
  const MicFabAccentPainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi * 0.72,
      math.pi * 0.44,
      false,
      Paint()
        ..color = AppColors.micBlueNav
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant MicFabAccentPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth;
}
