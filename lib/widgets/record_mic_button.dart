import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';

/// ناحیه لمسی میکروفون — short tap / hold border
class RecordMicButton extends StatefulWidget {
  const RecordMicButton({
    super.key,
    required this.size,
    this.drawBackground = true,
    this.onShortTap,
    this.onRecordComplete,
  });

  final double size;
  final bool drawBackground;
  final VoidCallback? onShortTap;
  final VoidCallback? onRecordComplete;

  @override
  State<RecordMicButton> createState() => _RecordMicButtonState();
}

class _RecordMicButtonState extends State<RecordMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressing = false;
  int _downAt = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() => setState(() {}));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRecordComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressStart() {
    _downAt = DateTime.now().millisecondsSinceEpoch;
    setState(() => _pressing = true);
    _controller.forward(from: 0);
  }

  void _onPressEnd() {
    if (!_pressing) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - _downAt;
    final isShortTap = elapsed < 280 && _controller.value < 0.1;

    setState(() => _pressing = false);
    _controller
      ..stop()
      ..reset();

    if (isShortTap) {
      widget.onShortTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPressStart(),
      onPointerUp: (_) => _onPressEnd(),
      onPointerCancel: (_) => _onPressEnd(),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MicButtonPainter(
            progress: _controller.value,
            drawBackground: widget.drawBackground,
          ),
        ),
      ),
    );
  }
}

class _MicButtonPainter extends CustomPainter {
  _MicButtonPainter({
    required this.progress,
    required this.drawBackground,
  });

  final double progress;
  final bool drawBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const idleStroke = 0.8;
    final radius = (size.width - idleStroke) / 2;

    if (drawBackground) {
      canvas.drawCircle(
        center.translate(0, 3),
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(center, radius, Paint()..color = Colors.white);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFEDEDF0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = idleStroke,
      );
    }

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
  bool shouldRepaint(covariant _MicButtonPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.drawBackground != drawBackground;
}
