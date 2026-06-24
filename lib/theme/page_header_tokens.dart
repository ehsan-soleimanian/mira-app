/// Shared layout tokens for page headers (back + title + trailing actions).
abstract final class PageHeaderTokens {
  static const horizontalPadding = 16.0;
  static const topPadding = 8.0;
  static const bottomPadding = 12.0;
  static const actionSize = 48.0;

  static const titleFontSize = 18.0;

  static double get contentHeight => topPadding + actionSize + bottomPadding;
}
