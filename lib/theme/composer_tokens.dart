import 'package:flutter/material.dart';

/// One stroked layer of a (possibly multi-layer) gradient border.
class ComposerBorderLayer {
  const ComposerBorderLayer(this.gradient, {this.strokeWidth = 1.4});

  final Gradient gradient;
  final double strokeWidth;
}

/// Design tokens — Figma `742-11005` (rest) & `742-11091` (active input).
abstract final class ComposerTokens {
  static const hintColor = Color(0xFF9CA3AF);
  static const composerTextColor = Color(0xFF141414);
  static const formTextColor = Color(0xFF374151);
  static const glyphColor = Color(0xFF171717);
  static const surfaceTop = Color(0xFFFFFFFF);
  static const surfaceBottom = Color(0xFFECEEF2);
  static const insetBase = Color(0xFFEFF1F5);
  static const softShadow = Color(0xFFB8C2D0);
  static const sendRing = Color(0xFFEDF1FF);
  static const activeGlow = Color(0xFF0A88FF);
  static const previewBackground = Color(0xFFEBEBED);

  static const borderWidth = 1.4;

  static const greyBorderLayers = [
    ComposerBorderLayer(
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD2D6DE), Color(0xFFC6CBD4)],
      ),
      strokeWidth: 1.2,
    ),
  ];

  static const blueBorderLayers = [
    ComposerBorderLayer(
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A88FF), Color(0xFFEAF4FF)],
      ),
      strokeWidth: 1.6,
    ),
  ];

  static const addButtonSize = 54.0;
  static const inputHeight = 54.0;
  static const inputRadius = 15.5;
  static const sendButtonSize = 40.0;

  /// Flat form field — onboarding / auth (no gradient shine).
  static const flatFieldFill = Color(0xFFF3F3F3);
  static const flatFieldBorder = Color(0xFFE4E4E4);
  static const flatFieldRadius = 14.0;

  /// Raised pill fill — optional blue glow when [active].
  static BoxDecoration raisedSurfaceDecoration({
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    bool active = false,
  }) {
    return BoxDecoration(
      shape: shape,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [surfaceTop, Color(0xFFF8F9FB)],
      ),
      boxShadow: [
        BoxShadow(
          color: softShadow.withValues(alpha: 0.24),
          offset: const Offset(0, 4),
          blurRadius: 9,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.75),
          offset: const Offset(0, -1),
          blurRadius: 2,
        ),
        if (active)
          BoxShadow(color: activeGlow.withValues(alpha: 0.22), blurRadius: 18),
      ],
    );
  }

  static List<BoxShadow> addButtonOuterShadow = [
    BoxShadow(
      color: softShadow.withValues(alpha: 0.4),
      offset: const Offset(0, 6),
      blurRadius: 16,
    ),
    const BoxShadow(color: Colors.white, offset: Offset(0, -2), blurRadius: 6),
  ];
}
