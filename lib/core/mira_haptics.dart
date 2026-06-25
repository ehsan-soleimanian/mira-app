import 'package:flutter/services.dart';

/// Tactile feedback tuned for Mira capture gestures.
abstract final class MiraHaptics {
  /// Finger down on mic — faint tick.
  static void micPressDown() {
    HapticFeedback.selectionClick();
  }

  /// Hold threshold reached — recording engaged.
  static Future<void> micRecordingEngaged() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 48));
    await HapticFeedback.lightImpact();
  }
}
