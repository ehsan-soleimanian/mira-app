import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/figma_svg_icon.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/core/mira_haptics.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';

/// Inset neumorphic mic well from Figma component 741:4986.
class MiraEarNavMicButton extends StatefulWidget {
  const MiraEarNavMicButton({
    super.key,
    required this.size,
    required this.scale,
    required this.micIconSize,
    this.onTap,
    this.onShortTap,
    this.onRecordingStart,
    this.recordingActive = false,
    this.recordingProgress = 0,
  });

  static const componentId = '741:4986-mic';

  final double size;
  final double scale;
  final double micIconSize;
  final VoidCallback? onTap;
  final VoidCallback? onShortTap;
  final VoidCallback? onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;

  @override
  State<MiraEarNavMicButton> createState() => _MiraEarNavMicButtonState();
}

class _MiraEarNavMicButtonState extends State<MiraEarNavMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressing = false;
  bool _recordingTriggered = false;
  int _downAt = 0;

  static const _holdThresholdMs = 280;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _holdThresholdMs),
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(MiraEarNavMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.recordingActive && !_pressing) {
      _controller
        ..stop()
        ..reset();
      _recordingTriggered = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressStart() {
    if (widget.recordingActive) return;
    MiraHaptics.micPressDown();
    _downAt = DateTime.now().millisecondsSinceEpoch;
    _recordingTriggered = false;
    setState(() => _pressing = true);
    _controller.forward(from: 0);
    Future<void>.delayed(const Duration(milliseconds: _holdThresholdMs), () {
      if (!_pressing || _recordingTriggered || !mounted) return;
      _recordingTriggered = true;
      MiraHaptics.micRecordingEngaged();
      widget.onRecordingStart?.call();
    });
  }

  void _onPressEnd() {
    if (!_pressing) return;
    final elapsed = DateTime.now().millisecondsSinceEpoch - _downAt;
    final isShortTap = elapsed < _holdThresholdMs && !_recordingTriggered;
    setState(() => _pressing = false);

    if (isShortTap) {
      _controller
        ..stop()
        ..reset();
      if (widget.onShortTap != null) {
        widget.onShortTap!();
      } else {
        widget.onTap?.call();
      }
    } else if (!widget.recordingActive) {
      _controller
        ..stop()
        ..reset();
    }
  }

  double get _ringProgress {
    if (widget.recordingActive) {
      return widget.recordingProgress.clamp(0.0, 1.0);
    }
    if (_recordingTriggered) return 1;
    return _controller.value;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final ring = _ringProgress;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPressStart(),
      onPointerUp: (_) => _onPressEnd(),
      onPointerCancel: (_) => _onPressEnd(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: MiraEarNavTokens.shadowDark.withValues(alpha: 0.6),
              offset: Offset(0, 7 * s),
              blurRadius: 15 * s,
            ),
            BoxShadow(
              color: MiraEarNavTokens.shadowLight,
              offset: Offset(-4 * s, -4 * s),
              blurRadius: 10 * s,
            ),
          ],
        ),
        child: CustomPaint(
          painter: MiraInnerShadowPainter(
            shape: (size) => Path()..addOval(Offset.zero & size),
            baseColor: MiraEarNavTokens.micWellBase,
            darkShadow: MiraEarNavTokens.shadowDark.withValues(alpha: 0.75),
            lightShadow: Colors.white,
            blur: 9 * s,
            offset: 6 * s,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (ring > 0)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _MicProgressRingPainter(
                    progress: ring,
                    strokeWidth: 2 * s,
                  ),
                ),
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  MiraEarNavTokens.micBlue,
                  BlendMode.srcIn,
                ),
                child: FigmaSvgIcon(
                  asset: FigmaAssets.navMic,
                  size: widget.micIconSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicProgressRingPainter extends CustomPainter {
  const _MicProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      -3.141592653589793 / 2,
      sweep,
      false,
      Paint()
        ..color = MiraEarNavTokens.micBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MicProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
