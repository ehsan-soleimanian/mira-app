import 'package:mira_app/theme/page_header_tokens.dart';

/// Layout tokens from Figma frame iPhone 16 - 150 (692:4127).
abstract final class HomeScreenTokens {
  static const designWidth = 393.0;
  static const designHeight = 852.0;

  static const sphereSize = 228.0;
  static const sphereTop = 82.0;

  static const headlineTop = 328.0;
  static const headlineSize = 40.0;

  static const subtitleTop = 388.0;
  static const subtitleSize = 18.0;

  static const settingsSize = 48.0;
  static const settingsTop = 24.0;
  static const settingsRight = 24.0;
  static const catalogLeft = 24.0;

  static const tipWidth = 320.0;
  static const tipHeight = 43.0;
  /// Gap between hint arrow tip and the top of the mic FAB.
  static const tipGapAboveMic = 8.0;

  static double sphereDiameter(double scale) => sphereSize * scale;

  static double sphereLeft(double screenWidth, double scale) =>
      (screenWidth - sphereDiameter(scale)) / 2;

  /// Same Y as home — orb aligns across Home, chat, and voice screens.
  static double sphereY(double scale) => sphereTop * scale;

  /// Orb Y inside body below [MiraPageHeader] — same absolute position as home.
  static double sphereYBelowHeader(double scale) {
    final offset = sphereY(scale) - PageHeaderTokens.contentHeight;
    return offset < 0 ? 0 : offset;
  }

  static double headlineY(double scale) => headlineTop * scale;

  static double headlineYBelowHeader(double scale) {
    final offset = headlineY(scale) - PageHeaderTokens.contentHeight;
    return offset < 0 ? 0 : offset;
  }

  static double subtitleY(double scale) => subtitleTop * scale;

  static double subtitleYBelowHeader(double scale) {
    final offset = subtitleY(scale) - PageHeaderTokens.contentHeight;
    return offset < 0 ? 0 : offset;
  }
}

/// Scales Figma design units (393pt baseline) to current screen width.
class FigmaScaler {
  const FigmaScaler(this.screenWidth);

  final double screenWidth;

  double get scale => screenWidth / HomeScreenTokens.designWidth;

  double s(double designPx) => designPx * scale;
}
