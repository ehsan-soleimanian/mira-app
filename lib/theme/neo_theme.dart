import 'package:flutter/material.dart';

/// Neomorphism shadow tokens — base matches [AppColors.background].
abstract final class NeoColors {
  static const base = Color(0xFFF5F5F5);
  static const highlight = Color(0xFFFFFFFF);
  static const shade = Color(0xFFC8CCD4);
  static const innerShade = Color(0x59000000);
  static const innerHighlight = Color(0x80FFFFFF);
}

/// Dual-shadow helpers for soft neumorphic surfaces.
abstract final class NeoShadows {
  /// Extruded element — light top-left + dark bottom-right.
  static void paintExtruded(
    Canvas canvas,
    Path path, {
    required Color fill,
    required double scale,
    double distance = 5,
    double blur = 14,
  }) {
    final d = distance * scale;
    final b = blur * scale;

    canvas.save();
    canvas.translate(d, d);
    canvas.drawShadow(path, NeoColors.shade.withValues(alpha: 0.55), b, false);
    canvas.restore();

    canvas.save();
    canvas.translate(-d, -d);
    canvas.drawShadow(path, NeoColors.highlight.withValues(alpha: 0.9), b, false);
    canvas.restore();

    canvas.drawPath(path, Paint()..color = fill);
  }

  /// Recessed cavity — inner shadows clipped to [clipPath].
  static void paintRecessed(
    Canvas canvas,
    Path clipPath,
    Rect bounds, {
    required double scale,
  }) {
    canvas.save();
    canvas.clipPath(clipPath);

    final innerDark = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.55, -0.75),
        radius: 1.15,
        colors: [
          NeoColors.innerShade,
          NeoColors.innerShade.withValues(alpha: 0.0),
        ],
      ).createShader(bounds);

    final innerLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.65, 0.85),
        radius: 1.05,
        colors: [
          NeoColors.innerHighlight,
          NeoColors.innerHighlight.withValues(alpha: 0.0),
        ],
      ).createShader(bounds);

    canvas.drawRect(bounds.inflate(4 * scale), innerDark);
    canvas.drawRect(bounds.inflate(4 * scale), innerLight);
    canvas.restore();
  }

  /// Circular extruded disc (FAB).
  static void paintExtrudedCircle(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color fill,
    required double scale,
    double distance = 4,
    double blur = 12,
  }) {
    paintExtruded(
      canvas,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      fill: fill,
      scale: scale,
      distance: distance,
      blur: blur,
    );
  }

  /// FAB cast shadow only — sits above navbar, below disc (lands in notch).
  static void paintFabCastShadow(
    Canvas canvas,
    Offset center,
    double radius, {
    required double scale,
    double offsetY = 5,
    double blur = 13,
  }) {
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final b = blur * scale;
    final oy = offsetY * scale;

    canvas.save();
    canvas.translate(1.5 * scale, oy);
    canvas.drawShadow(
      path,
      NeoColors.shade.withValues(alpha: 0.42),
      b,
      false,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(-2 * scale, -1.5 * scale);
    canvas.drawShadow(
      path,
      NeoColors.highlight.withValues(alpha: 0.55),
      7 * scale,
      false,
    );
    canvas.restore();
  }

  /// FAB disc fill + convex highlight (no outer extrusion shadows).
  static void paintDiscSurface(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color fill,
  }) {
    canvas.drawCircle(center, radius, Paint()..color = fill);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [
            NeoColors.highlight.withValues(alpha: 0.55),
            NeoColors.highlight.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFEDEDF0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }
}
