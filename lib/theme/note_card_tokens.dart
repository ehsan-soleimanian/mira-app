import 'package:flutter/material.dart';

/// Design tokens for [NoteCard] — Mira expandable note card.
abstract final class NoteCardTokens {
  static const radius = 20.0;
  static const borderWidth = 1.4;
  static const softShadow = Color(0xFFB8C2D0);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1F2430);
  static const tagBg = Color(0xFFFBECE7);
  static const tagText = Color(0xFF8B7B76);
  static const glyphBlue = Color(0xFF293D8C);
  static const date = Color(0xFFB4B8BF);
  static const previewBackground = Color(0xFFF4F5F7);

  static const titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: Color(0xFF111827),
  );

  static const bodyStyle = TextStyle(
    fontSize: 16,
    height: 1.45,
    color: ink,
  );

  static const dateStyle = TextStyle(
    fontSize: 15,
    color: date,
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: softShadow.withValues(alpha: 0.22),
          offset: const Offset(0, 6),
          blurRadius: 18,
        ),
        const BoxShadow(
          color: Colors.white,
          offset: Offset(0, -1),
          blurRadius: 4,
        ),
      ];
}
