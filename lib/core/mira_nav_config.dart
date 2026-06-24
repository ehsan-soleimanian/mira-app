import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/nav_bar_shell_painter.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';

/// Bottom navigation visual variants in the Mira design system.
enum MiraNavVariant {
  /// Oval cradle + neumorphic shadows (Figma 741:4963 / 741:4987).
  cradle,

  /// Twin raised ears + concave notches + inset mic well (Figma 741:4986).
  earNotch,
}

/// Global switch for which nav organism screens render.
///
/// Change at app start or from settings/dev tools:
/// `MiraNavConfig.variant = MiraNavVariant.earNotch;`
abstract final class MiraNavConfig {
  static MiraNavVariant variant = MiraNavVariant.cradle;

  /// Scaled nav bar height for layout (tip bar, stacks, etc.).
  static double barHeightForWidth(double screenWidth) {
    final scale = screenWidth / NavBarTokens.designWidth;
    return switch (variant) {
      MiraNavVariant.cradle => NavBarTokens.designHeight * scale,
      MiraNavVariant.earNotch =>
        MiraEarNavTokens.totalHeight * scale,
    };
  }

  /// Distance from the home body bottom to the hint tooltip bottom edge.
  static double homeTipBottomInset(double screenWidth) {
    final scale = screenWidth / NavBarTokens.designWidth;
    return switch (variant) {
      MiraNavVariant.cradle => _cradleTipBottomInset(screenWidth, scale),
      MiraNavVariant.earNotch => _earNotchTipBottomInset(scale),
    };
  }

  static double _cradleTipBottomInset(double screenWidth, double scale) {
    final barH = NavBarTokens.designHeight * scale;
    final barSize = Size(screenWidth, barH);
    final micButtonSize = MiraEarNavTokens.fabSize * scale;
    final fabCenter = NavBarPathBuilder.fabCenter(barSize, scale);
    final fabTop = fabCenter.dy - micButtonSize / 2;
    final micProtrusion = fabTop < 0 ? -fabTop : 0.0;
    return micProtrusion + HomeScreenTokens.tipGapAboveMic * scale;
  }

  static double _earNotchTipBottomInset(double scale) {
    final fabTop = MiraEarNavTokens.fabTop * scale;
    final fabSize = MiraEarNavTokens.fabSize * scale;
    return fabTop + fabSize + HomeScreenTokens.tipGapAboveMic * scale;
  }
}
