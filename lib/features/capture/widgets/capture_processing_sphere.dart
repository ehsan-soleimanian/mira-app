import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Pulsing Mira orb during capture processing (PRD: subtle glow while thinking).
class CaptureProcessingSphere extends StatefulWidget {
  const CaptureProcessingSphere({
    super.key,
    required this.size,
    this.processing = false,
  });

  final double size;
  final bool processing;

  @override
  State<CaptureProcessingSphere> createState() =>
      _CaptureProcessingSphereState();
}

class _CaptureProcessingSphereState extends State<CaptureProcessingSphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(CaptureProcessingSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.processing) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = widget.processing ? _controller.value : 0.0;
        final scale = 1 + t * 0.06;
        final glow = 0.15 + t * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.processing
                  ? [
                      BoxShadow(
                        color: AppColors.micBlueNav.withValues(alpha: glow),
                        blurRadius: 36 + t * 24,
                        spreadRadius: 4 + t * 8,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: MiraSphere(size: widget.size),
    );
  }
}
