import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads a Figma-exported SVG asset with optional size and color filter.
class FigmaSvgIcon extends StatelessWidget {
  const FigmaSvgIcon({
    super.key,
    required this.asset,
    required this.size,
    this.opacity = 1,
  });

  final String asset;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (opacity >= 1) return icon;
    return Opacity(opacity: opacity, child: icon);
  }
}
