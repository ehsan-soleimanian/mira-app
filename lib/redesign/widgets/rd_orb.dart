import 'package:flutter/material.dart';

/// The signature Mira orb — a periwinkle radial-gradient sphere that slowly
/// breathes. With [ring] it's wrapped by a pulsing ring (the Home hero orb);
/// without it, it's just the breathing sphere (e.g. the Daily Brief summary
/// orb). Matches `.rd-orb` / `.db-orb` and the `rdBreathe` / `rdPulse` keyframes.
class RdOrb extends StatefulWidget {
  const RdOrb({super.key, this.size = 74, this.ring = true});

  final double size;
  final bool ring;

  @override
  State<RdOrb> createState() => _RdOrbState();
}

class _RdOrbState extends State<RdOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final box = widget.ring ? s + 24 : s; // ring extends 12px on every side

    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          final breathe = 1.0 + 0.05 * t;
          final ringScale = 1.0 + 0.12 * t;
          final ringOpacity = (0.5 - 0.35 * t).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.ring)
                Transform.scale(
                  scale: ringScale,
                  child: Opacity(
                    opacity: ringOpacity,
                    child: Container(
                      width: box,
                      height: box,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7E8BC9).withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.scale(
                scale: breathe,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.28, -0.4),
                      radius: 0.95,
                      colors: [
                        Color(0xFFAEB9E8),
                        Color(0xFF8B98D6),
                        Color(0xFF6472B6),
                      ],
                      stops: [0.0, 0.42, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5A69B4).withValues(alpha: 0.55),
                        blurRadius: 40,
                        spreadRadius: -14,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(s * 0.14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(0.24, 0.32),
                          radius: 0.55,
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
