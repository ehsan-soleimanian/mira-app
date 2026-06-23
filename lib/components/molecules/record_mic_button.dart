import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_mic_fab.dart';

/// Mic touch target — short tap opens bubble menu; hold starts voice recording.
class RecordMicButton extends StatefulWidget {
  const RecordMicButton({
    super.key,
    required this.diameter,
    required this.scale,
    required this.iconTop,
    this.micIcon,
    this.onShortTap,
    this.onRecordingStart,
    this.recordingActive = false,
    this.recordingProgress = 0,
  });

  final double diameter;
  final double scale;
  final double iconTop;
  final Widget? micIcon;
  final VoidCallback? onShortTap;
  final VoidCallback? onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;

  @override
  State<RecordMicButton> createState() => _RecordMicButtonState();
}

class _RecordMicButtonState extends State<RecordMicButton>
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
  void didUpdateWidget(RecordMicButton oldWidget) {
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
    _downAt = DateTime.now().millisecondsSinceEpoch;
    _recordingTriggered = false;
    setState(() => _pressing = true);
    _controller.forward(from: 0);
    Future<void>.delayed(
      const Duration(milliseconds: _holdThresholdMs),
      () {
        if (!_pressing || _recordingTriggered || !mounted) return;
        _recordingTriggered = true;
        widget.onRecordingStart?.call();
      },
    );
  }

  void _onPressEnd() {
    if (!_pressing) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - _downAt;
    final isShortTap =
        elapsed < _holdThresholdMs && !_recordingTriggered;

    setState(() => _pressing = false);

    if (isShortTap) {
      _controller
        ..stop()
        ..reset();
      widget.onShortTap?.call();
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
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPressStart(),
      onPointerUp: (_) => _onPressEnd(),
      onPointerCancel: (_) => _onPressEnd(),
      child: MiraMicFab(
        diameter: widget.diameter,
        scale: widget.scale,
        progress: _ringProgress,
        iconTop: widget.iconTop,
        child: widget.micIcon ?? const SizedBox.shrink(),
      ),
    );
  }
}
