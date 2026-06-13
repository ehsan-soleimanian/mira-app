import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

abstract final class AppTypography {
  static TextStyle get _base => GoogleFonts.inter();

  static TextStyle headline(BuildContext context) => _base.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle subtitle(BuildContext context) => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      );

  static TextStyle hint(BuildContext context) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textHint,
      );

  static TextStyle navActive(BuildContext context) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle navInactive(BuildContext context) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textInactive,
      );
}
