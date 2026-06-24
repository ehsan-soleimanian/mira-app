import 'package:flutter/material.dart';

/// ChatGPT-style sweeping highlight over muted text.
class ShimmerText extends StatefulWidget {
  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    this.baseColor = const Color(0xFFA8A8AE),
    this.highlightColor = const Color(0xFFF4F4F6),
    this.duration = const Duration(milliseconds: 2400),
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final TextAlign textAlign;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
              transform: _ShimmerSlideTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(
        widget.text,
        textAlign: widget.textAlign,
        style: widget.style.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ShimmerSlideTransform extends GradientTransform {
  const _ShimmerSlideTransform(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final travel = bounds.width * 2.2;
    return Matrix4.translationValues(-travel + (percent * travel * 2), 0, 0);
  }
}

/// Shared label for capture / home processing states.
class MiraThinkingLabel extends StatelessWidget {
  const MiraThinkingLabel({
    super.key,
    required this.scale,
    this.uploading = false,
  });

  final double scale;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    final text = uploading ? 'Uploading voice…' : 'Mira is thinking...';
    final style = TextStyle(
      fontSize: 16 * scale,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -0.2,
    );

    if (uploading) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: style.copyWith(color: const Color(0xFF8E8E93)),
      );
    }

    return ShimmerText(
      text: text,
      style: style,
      baseColor: const Color(0xFF9A9AA1),
      highlightColor: const Color(0xFFF8F8FA),
    );
  }
}

bool isMiraThinkingStatus(String? text) {
  if (text == null) return false;
  final lower = text.toLowerCase();
  return lower.contains('thinking') || lower.contains('processing');
}
