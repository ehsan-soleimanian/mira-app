import 'package:flutter/material.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Gradient border — single or multi-layer (grey rest / blue active).
class MiraGradientBorderPainter extends CustomPainter {
  const MiraGradientBorderPainter({
    required this.radius,
    this.layers = ComposerTokens.greyBorderLayers,
  });

  final double radius;
  final List<ComposerBorderLayer> layers;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    for (final layer in layers) {
      final rrect = RRect.fromRectAndRadius(
        rect.deflate(layer.strokeWidth / 2),
        Radius.circular(radius),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.strokeWidth
          ..shader = layer.gradient.createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MiraGradientBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.layers != layers;
}
