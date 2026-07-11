import 'package:flutter/material.dart';

import 'rd_icon.dart';

/// Left-edge swipe-to-go-back — mirrors design2 `SwipeBack` in `app.jsx`.
class RdSwipeBack extends StatefulWidget {
  const RdSwipeBack({
    super.key,
    required this.enabled,
    required this.onBack,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onBack;
  final Widget child;

  @override
  State<RdSwipeBack> createState() => _RdSwipeBackState();
}

class _RdSwipeBackState extends State<RdSwipeBack> {
  double _dx = 0;
  bool _dragging = false;
  Offset? _start;

  void _reset() {
    _start = null;
    setState(() {
      _dx = 0;
      _dragging = false;
    });
  }

  void _onStart(DragStartDetails d, double width) {
    if (!widget.enabled) return;
    if (d.localPosition.dx > 26) return;
    _start = Offset(d.localPosition.dx, d.localPosition.dy);
    setState(() => _dragging = true);
  }

  void _onUpdate(DragUpdateDetails d, double width) {
    if (_start == null) return;
    final mx = d.localPosition.dx - _start!.dx;
    final my = (d.localPosition.dy - _start!.dy).abs();
    if (my > mx.abs() + 12) {
      _reset();
      return;
    }
    setState(() => _dx = mx.clamp(0, width));
  }

  void _onEnd(double width) {
    if (_start == null) return;
    final flick = _dx > 60;
    if (_dx > width * 0.34 || flick) {
      _reset();
      widget.onBack();
      return;
    }
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final width = MediaQuery.sizeOf(context).width;
    final hint = (_dx / 140).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (d) => _onStart(d, width),
      onHorizontalDragUpdate: (d) => _onUpdate(d, width),
      onHorizontalDragEnd: (_) => _onEnd(width),
      onHorizontalDragCancel: _reset,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(_dx, 0),
            child: widget.child,
          ),
          if (_dragging && _dx > 4)
            Positioned(
              left: 12,
              top: MediaQuery.sizeOf(context).height * 0.5 - 17,
              child: Opacity(
                opacity: hint,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFBFBF9).withValues(alpha: 0.92),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: RdIcon(
                      RdIcons.chevronLeft,
                      size: 20,
                      stroke: '#14328C',
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
