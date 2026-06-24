import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Typography — Dosis across the English UI.
abstract final class AppTypography {
  static TextStyle dosis({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.dosis(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle vazirmatn({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.vazirmatn(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle homeHeadline(double scale) => GoogleFonts.dosis(
        fontSize: 40 * scale,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.headline,
      );

  static TextStyle homeSubtitle(double scale) => GoogleFonts.dosis(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.subtitle,
      );

  static TextStyle tip(double scale) => GoogleFonts.dosis(
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
}
