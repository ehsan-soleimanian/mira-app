import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';

/// Inner blue swirl — color moves inside the orb only (no scale, no outer glow).
class MiraLivingSphere extends StatefulWidget {
  const MiraLivingSphere({
    super.key,
    required this.size,
    this.intensity = 1,
    this.processing = false,
  });

  final double size;
  final double intensity;
  final bool processing;

  @override
  State<MiraLivingSphere> createState() => _MiraLivingSphereState();
}

class _MiraLivingSphereState extends State<MiraLivingSphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: _durationFor(widget));
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant MiraLivingSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.processing != widget.processing) {
      _spin.duration = _durationFor(widget);
    }
    _syncMotion();
  }

  Duration _durationFor(MiraLivingSphere w) =>
      w.processing ? const Duration(seconds: 7) : const Duration(seconds: 9);

  void _syncMotion() {
    final active = widget.intensity > 0.02;
    if (active) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = widget.intensity.clamp(0.0, 1.0);

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MiraSphere(size: widget.size),
            if (intensity > 0.02)
              ClipOval(
                child: AnimatedBuilder(
                  animation: _spin,
                  builder: (context, _) => CustomPaint(
                    painter: _OrbInnerSwirlPainter(
                      phase: _spin.value,
                      intensity: intensity,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrbInnerSwirlPainter extends CustomPainter {
  _OrbInnerSwirlPainter({
    required this.phase,
    required this.intensity,
  });

  final double phase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = phase * math.pi * 2;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Sweeping blue band rotating inside the sphere.
    final sweep = Paint()
      ..blendMode = BlendMode.softLight
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF3D8EF5).withValues(alpha: 0.0),
          const Color(0xFF5EB0FF).withValues(alpha: 0.38 * intensity),
          const Color(0xFF2563EB).withValues(alpha: 0.52 * intensity),
          const Color(0xFF6EC8FF).withValues(alpha: 0.34 * intensity),
          const Color(0xFF3D8EF5).withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.12, 0.32, 0.5, 0.68, 0.88, 1.0],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.92, sweep);

    // Orbiting blue highlight — travels side to side through the orb.
    final orbit = Offset(
      center.dx + math.cos(angle) * radius * 0.28 * intensity,
      center.dy + math.sin(angle * 0.85) * radius * 0.22 * intensity,
    );
    final highlight = Paint()
      ..blendMode = BlendMode.overlay
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7EC4FF).withValues(alpha: 0.55 * intensity),
          const Color(0xFF2B6CE8).withValues(alpha: 0.28 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: orbit, radius: radius * 0.48));
    canvas.drawCircle(orbit, radius * 0.48, highlight);

    // Counter-rotating softer wash.
    final counter = Paint()
      ..blendMode = BlendMode.softLight
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4DA3FF).withValues(alpha: 0.32 * intensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            center.dx + math.cos(angle + math.pi) * radius * 0.2 * intensity,
            center.dy + math.sin(angle + math.pi) * radius * 0.16 * intensity,
          ),
          radius: radius * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(
        center.dx + math.cos(angle + math.pi) * radius * 0.2 * intensity,
        center.dy + math.sin(angle + math.pi) * radius * 0.16 * intensity,
      ),
      radius * 0.55,
      counter,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbInnerSwirlPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.intensity != intensity;
}
