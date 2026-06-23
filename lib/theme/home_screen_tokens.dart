/// Layout tokens from Figma frame iPhone 16 - 150 (692:4127).
abstract final class HomeScreenTokens {
  static const designWidth = 393.0;
  static const designHeight = 852.0;

  static const sphereSize = 145.0;
  static const sphereTop = 129.0;

  static const headlineTop = 290.0;
  static const headlineSize = 40.0;

  static const subtitleTop = 350.0;
  static const subtitleSize = 18.0;

  static const settingsSize = 48.0;
  static const settingsTop = 24.0;
  static const settingsRight = 24.0;
  static const catalogLeft = 24.0;

  static const tipWidth = 320.0;
  static const tipHeight = 43.0;
  static const tipGapAboveNav = 10.0;
}

/// Scales Figma design units (393pt baseline) to current screen width.
class FigmaScaler {
  const FigmaScaler(this.screenWidth);

  final double screenWidth;

  double get scale => screenWidth / HomeScreenTokens.designWidth;

  double s(double designPx) => designPx * scale;
}
