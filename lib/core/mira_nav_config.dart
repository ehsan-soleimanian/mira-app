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
}
