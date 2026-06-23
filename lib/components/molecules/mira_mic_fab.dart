import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';
import 'package:mira_app/theme/neo_theme.dart';

/// Cast shadow layer — rendered above navbar, below FAB disc.
class MicFabCastShadowPainter extends CustomPainter {
  const MicFabCastShadowPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4 * scale) / 2;

    NeoShadows.paintFabCastShadow(
      canvas,
      center,
      radius,
      scale: scale,
      offsetY: NavBarTokens.fabShadowCastY,
      blur: NavBarTokens.fabNeoBlur,
    );
  }

  @override
  bool shouldRepaint(covariant MicFabCastShadowPainter oldDelegate) =>
      oldDelegate.scale != scale;
}

/// Neumorphic mic FAB disc (shadow is a separate stack layer).
class MiraMicFab extends StatelessWidget {
  const MiraMicFab({
    super.key,
    required this.diameter,
    required this.scale,
    required this.progress,
    required this.iconTop,
    required this.child,
  });

  final double diameter;
  final double scale;
  final double progress;
  /// Icon top offset inside the FAB bounds (Figma micIconTop).
  final double iconTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _MicFabDiscPainter(
              scale: scale,
              progress: progress,
            ),
          ),
          Positioned(
            top: iconTop + NavBarTokens.micIconOpticalOffsetY * scale,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MicFabDiscPainter extends CustomPainter {
  const _MicFabDiscPainter({
    required this.scale,
    required this.progress,
  });

  final double scale;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4 * scale) / 2;

    NeoShadows.paintDiscSurface(
      canvas,
      center,
      radius,
      fill: NeoColors.base,
    );

    if (progress > 0) {
      const progressStroke = 2.0;
      final progressRadius = (size.width - progressStroke) / 2;
      final rect = Rect.fromCircle(center: center, radius: progressRadius);
      final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = AppColors.micBlueNav
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressStroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MicFabDiscPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.progress != progress;
}
