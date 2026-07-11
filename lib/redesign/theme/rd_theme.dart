import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Themeable redesign palette exposed as a [ThemeExtension] so screens can read
/// tokens that adapt to light / dark mode via `context.rd.<token>`.
///
/// The token names mirror the CSS custom properties in the Figma design
/// (`--navy`, `--peri`, `--line`, …) and the const values in [RdColors], which
/// stays as the light-mode source of truth while screens migrate. Light values
/// here are kept byte-for-byte identical to [RdColors] so [RdTheme.light]
/// renders exactly like the current app.
@immutable
class RdTheme extends ThemeExtension<RdTheme> {
  const RdTheme({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.navy,
    required this.peri,
    required this.periSoft,
    required this.line,
    required this.success,
    required this.gearIcon,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color muted;
  final Color faint;

  final Color navy;
  final Color peri;
  final Color periSoft;
  final Color line;

  final Color success;
  final Color gearIcon;

  /// Light palette — identical to the const tokens in `RdColors`.
  static const RdTheme light = RdTheme(
    bg: Color(0xFFF4F4F1),
    card: Color(0xFFFBFBF9),
    ink: Color(0xFF1B1C24),
    muted: Color(0xFF8A8B92),
    faint: Color(0xFFB7B8BE),
    navy: Color(0xFF14328C),
    peri: Color(0xFF7E8BC9),
    periSoft: Color(0xFFEDEFF8),
    line: Color(0xFFE9E9E4),
    success: Color(0xFF1F8A5B),
    gearIcon: Color(0xFF6B6C73),
  );

  /// Dark palette — surfaces and text invert; brand accents (`navy`, `peri`,
  /// `success`) stay put, `gearIcon` is lifted for contrast on dark cards.
  static const RdTheme dark = RdTheme(
    bg: Color(0xFF14151A),
    card: Color(0xFF1E1F26),
    ink: Color(0xFFF2F2F4),
    muted: Color(0xFF9A9BA3),
    faint: Color(0xFF6B6C75),
    navy: Color(0xFF14328C),
    peri: Color(0xFF7E8BC9),
    periSoft: Color(0xFF262A40),
    line: Color(0xFF2A2B33),
    success: Color(0xFF1F8A5B),
    gearIcon: Color(0xFF9A9BA3),
  );

  @override
  RdTheme copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? muted,
    Color? faint,
    Color? navy,
    Color? peri,
    Color? periSoft,
    Color? line,
    Color? success,
    Color? gearIcon,
  }) {
    return RdTheme(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      navy: navy ?? this.navy,
      peri: peri ?? this.peri,
      periSoft: periSoft ?? this.periSoft,
      line: line ?? this.line,
      success: success ?? this.success,
      gearIcon: gearIcon ?? this.gearIcon,
    );
  }

  @override
  RdTheme lerp(covariant ThemeExtension<RdTheme>? other, double t) {
    if (other is! RdTheme) return this;
    return RdTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      peri: Color.lerp(peri, other.peri, t)!,
      periSoft: Color.lerp(periSoft, other.periSoft, t)!,
      line: Color.lerp(line, other.line, t)!,
      success: Color.lerp(success, other.success, t)!,
      gearIcon: Color.lerp(gearIcon, other.gearIcon, t)!,
    );
  }
}

/// Ergonomic access to the active [RdTheme]: `context.rd.bg`, `context.rd.ink`,
/// … Falls back to [RdTheme.light] if the extension is somehow absent so screen
/// code never has to null-check.
extension RdThemeX on BuildContext {
  RdTheme get rd => Theme.of(this).extension<RdTheme>() ?? RdTheme.light;

  /// Bottom inset for the system navigation bar (Samsung 3-button, gesture bar,
  /// iOS home indicator). Prefer this over raw [MediaQuery.viewPadding] when
  /// screens opt out of [SafeArea] bottom padding.
  double get rdNavBarInset {
    final mq = MediaQuery.of(this);
    return math.max(mq.viewPadding.bottom, mq.padding.bottom);
  }
}
