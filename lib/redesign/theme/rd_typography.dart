import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rd_colors.dart';

/// Type ramp for the redesign. Three families, matching the design exactly:
/// Dosis (display / titles), Inter (Latin body), Vazirmatn (UI text + Persian
/// RTL). Loaded via `google_fonts` — the package is already a dependency.
abstract final class RdText {
  static TextStyle get eyebrow => GoogleFonts.vazirmatn(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: RdColors.muted,
        letterSpacing: 0.2,
      );

  static TextStyle get name => GoogleFonts.dosis(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: RdColors.ink,
        height: 1.1,
      );

  static TextStyle get title => GoogleFonts.dosis(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: RdColors.ink,
        height: 1.22,
        letterSpacing: 0.2,
      );

  static TextStyle get placeholder => GoogleFonts.vazirmatn(
        fontSize: 15,
        color: RdColors.faint,
      );

  static TextStyle get sectionLabel => GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: RdColors.faint,
        letterSpacing: 1,
      );

  static TextStyle get seeAll => GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: RdColors.peri,
      );

  static TextStyle get itemTitle => GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: RdColors.ink,
        height: 1.4,
      );

  static TextStyle get meta => GoogleFonts.vazirmatn(
        fontSize: 12,
        color: RdColors.faint,
      );

  static TextStyle get navLabel => GoogleFonts.vazirmatn(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );
}
