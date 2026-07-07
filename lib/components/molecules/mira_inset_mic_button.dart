import 'package:flutter/material.dart';
import 'package:mira_app/core/mira_haptics.dart';

/// Inset-style workspace mic button for the bottom navigation center action.
class MiraInsetMicButton extends StatefulWidget {
  const MiraInsetMicButton({
    super.key,
    this.size = 76,
    this.iconSize = 30,
    this.onTap,
    this.onShortTap,
    this.onRecordingStart,
    this.recordingActive = false,
    this.recordingProgress = 0,
    this.semanticLabel,
  });

  static const componentId = 'workspace-inset-mic';

  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final VoidCallback? onShortTap;
  final VoidCallback? onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;
  final String? semanticLabel;

  @override
  State<MiraInsetMicButton> createState() => _MiraInsetMicButtonState();
}

class _MiraInsetMicButtonState extends State<MiraInsetMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  bool _pressing = false;
  bool _recordingTriggered = false;
  int _downAt = 0;

  static const _holdThresholdMs = 280;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _holdThresholdMs),
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(MiraInsetMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.recordingActive && !_pressing) {
      _holdController
        ..stop()
        ..reset();
      _recordingTriggered = false;
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    if (widget.recordingActive) return;
    MiraHaptics.micPressDown();
    _downAt = DateTime.now().millisecondsSinceEpoch;
    _recordingTriggered = false;
    setState(() => _pressing = true);
    _holdController.forward(from: 0);

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
      _holdController
        ..stop()
        ..reset();
      if (widget.onShortTap != null) {
        widget.onShortTap!();
      } else {
        widget.onTap?.call();
      }
    } else if (!widget.recordingActive) {
      _holdController
        ..stop()
        ..reset();
    }
  }

  double get _ringProgress {
    if (widget.recordingActive) {
      return widget.recordingProgress.clamp(0.0, 1.0);
    }
    if (_recordingTriggered) return 1;
    return _holdController.value;
  }

  @override
  Widget build(BuildContext context) {
    final ring = _ringProgress;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _onPressStart(),
        onPointerUp: (_) => _onPressEnd(),
        onPointerCancel: (_) => _onPressEnd(),
        child: AnimatedScale(
          scale: _pressing || widget.recordingActive ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: SizedBox.square(
            dimension: widget.size,
            child: CustomPaint(
              painter: _InsetMicButtonPainter(progress: ring),
              child: Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsetMicButtonPainter extends CustomPainter {
  const _InsetMicButtonPainter({required this.progress});

  final double progress;

  static const _blue = Color(0xFF4A6EFF);
  static const _teal = Color(0xFF18A58A);
  static const _rim = Color(0xFFE9ECF4);
  static const _shadow = Color(0xFF9EA8BA);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final circle = Path()..addOval(rect);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _rim
        ..style = PaintingStyle.fill,
    );

    canvas.save();
    canvas.clipPath(circle);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue, _teal],
        ).createShader(rect),
    );

    final inverseBounds = rect.inflate(radius);
    final inverse = Path.combine(
      PathOperation.difference,
      Path()..addRect(inverseBounds),
      circle,
    );

    canvas.drawPath(
      inverse.shift(Offset(-radius * 0.08, -radius * 0.08)),
      Paint()
        ..color = _shadow.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.18),
    );
    canvas.drawPath(
      inverse.shift(Offset(radius * 0.07, radius * 0.07)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.34)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.15),
    );

    canvas.drawCircle(
      center.translate(-radius * 0.22, -radius * 0.28),
      radius * 0.58,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.26),
    );

    canvas.restore();

    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress <= 0) return;

    canvas.drawArc(
      rect.deflate(2),
      -1.5707963267948966,
      6.283185307179586 * clampedProgress,
      false,
      Paint()
        ..color = const Color(0xFFFF7A59)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _InsetMicButtonPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
