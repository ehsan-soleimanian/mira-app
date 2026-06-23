import 'package:flutter/material.dart';

/// Whether a neumorphic surface pops OUT or is pressed INTO the background.
enum NeumorphicStyle {
  raised,
  inset,
}

/// Shared neumorphic palette — aligned with Mira ear-notch nav (741:4986).
abstract final class NeumorphicTokens {
  static const background = Color(0xFFECEFF3);
  static const raisedSurface = Color(0xFFFDFEFF);
  static const insetSurface = Color(0xFFEFF2F7);
  static const shadowDark = Color(0xFFC3CCDB);
  static const shadowLight = Color(0xFFFFFFFF);
  static const iconColor = Color(0xFF404044);
  static const badgeBlue = Color(0xFF4B6EF5);
}
