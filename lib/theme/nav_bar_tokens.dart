/// Design tokens from Figma bottom nav frame 741:4963 (neumorphic).
abstract final class NavBarTokens {
  static const designWidth = 393.0;
  static const designHeight = 98.0;

  static const panelTopFactor = 0.3469;
  static const panelHorizontalInset = 14.0;
  static const topCornerRadius = 24.0;
  static const panelBorderWidth = 1.5;

  static const micLeftFactor = 0.402;
  static const micRightFactor = 0.4198;
  static const micBottomFactor = 0.2857;
  static const micBorderWidth = 1.0;

  static const homeIconLeft = 70.0;
  static const coffeeIconLeft = 291.0;
  static const homeLabelLeft = 67.0;
  static const dailyBriefLabelCenterOffset = 78.5;
  static const iconTopInPanel = 4.0;
  static const labelTopInPanel = 38.0;
  static const micIconTop = 21.0;
  /// Optical nudge — SVG mic body is heavier toward the bottom.
  static const micIconOpticalOffsetY = -1.5;

  static const iconSize = 32.0;
  static const micIconSize = 24.0;
  static const labelFontSize = 16.0;
  static const inactiveOpacity = 0.5;

  static const micFabCenterY = 33.0;

  /// Neumorphic extrusion for navbar body.
  static const neoDistance = 5.0;
  static const neoBlur = 14.0;

  /// Neumorphic extrusion for FAB disc.
  static const fabNeoDistance = 4.0;
  static const fabNeoBlur = 11.0;

  /// Inset for recessed notch inner bowl.
  static const notchRecessInset = 6.0;

  static const fabShadowOffsetY = 3.0;
  /// Downward cast shadow into the notch bowl.
  static const fabShadowCastY = 5.0;
}
