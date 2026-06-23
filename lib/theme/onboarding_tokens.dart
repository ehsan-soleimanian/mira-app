import 'package:flutter/material.dart';

/// Layout tokens — Figma onboarding flow (659:3546).
abstract final class OnboardingTokens {
  static const background = Color(0xFFF5F5F5);
  static const sphereSize = 120.0;
  static const smallSphereSize = 92.0;
  static const headlineColor = Color(0xFF1A1C29);
  static const subtitleColor = Color(0xFF595959);
  static const mutedText = Color(0xFF8A8D98);
  static const progressActive = Color(0xFF4A6EFF);
  static const progressInactive = Color(0xFFD9DEE7);
  static const chipSelectedFill = Color(0xFF4A6EFF);
  static const chipSelectedText = Color(0xFFFFFFFF);
  static const chipBorder = Color(0xFFD3D8E1);
  static const surfaceTop = Color(0xFFFFFFFF);
  static const surfaceBottom = Color(0xFFECEEF2);
  static const divider = Color(0xFFE2E5EA);
  static const danger = Color(0xFF971B28);
  static const success = Color(0xFF11845B);

  static const designWidth = 393.0;
  static const maxContentWidth = 430.0;
}

/// Onboarding step index (0-based).
abstract final class OnboardingSteps {
  static const name = 0;
  static const role = 1;
  static const gender = 2;
  static const bio = 3;
  static const voice = 4;
  static const count = 5;
}

/// Preset choices aligned with PRD onboarding fields.
abstract final class OnboardingChoices {
  static const roles = [
    'Founder / CEO',
    'Product',
    'Engineer',
    'Designer',
    'Operations',
    'Student',
  ];

  static const genders = ['Female', 'Male', 'Non-binary', 'Prefer not to say'];
}
