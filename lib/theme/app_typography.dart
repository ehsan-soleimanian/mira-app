import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Typography from Figma — Dosis (headline/nav) + Vazirmatn (body).
abstract final class AppTypography {
  static TextStyle homeHeadline(double scale) => GoogleFonts.dosis(
        fontSize: 40 * scale,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.headline,
      );

  static TextStyle homeSubtitle(double scale) => GoogleFonts.vazirmatn(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.subtitle,
      );

  static TextStyle tip(double scale) => GoogleFonts.vazirmatn(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.hintText,
      );

  static TextStyle navActive(double scale) => GoogleFonts.dosis(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.textPrimary,
      );

  static TextStyle navInactive(double scale) => GoogleFonts.dosis(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.textPrimary,
      );

  // Legacy helpers for other screens.
  static TextStyle headline(BuildContext context) => homeHeadline(1);

  static TextStyle subtitle(BuildContext context) => homeSubtitle(1);

  static TextStyle hint(BuildContext context) => tip(1);
}
