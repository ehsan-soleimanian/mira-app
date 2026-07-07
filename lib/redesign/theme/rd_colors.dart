import 'package:flutter/painting.dart';

/// Redesign palette — lifted directly from the Figma design (`Mira App.html`).
/// Shared across every redesigned screen; per-screen accents live with their
/// screens. Names mirror the CSS custom properties in the design so the mapping
/// stays obvious (`--navy`, `--peri`, `--line`, …).
abstract final class RdColors {
  static const bg = Color(0xFFF4F4F1);
  static const card = Color(0xFFFBFBF9);
  static const ink = Color(0xFF1B1C24);
  static const muted = Color(0xFF8A8B92);
  static const faint = Color(0xFFB7B8BE);

  static const navy = Color(0xFF14328C);
  static const peri = Color(0xFF7E8BC9);
  static const periSoft = Color(0xFFEDEFF8);
  static const line = Color(0xFFE9E9E4);

  static const success = Color(0xFF1F8A5B);
  static const gearIcon = Color(0xFF6B6C73);
}
