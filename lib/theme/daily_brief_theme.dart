import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

enum NavTab { home, library, canvas, dailyBrief }

class DailyBriefColors {
  static const cardBorder = Color(0xFFEBEBED);
  static const cardShadow = Color(0x08000000);
  static const sectionLabel = Color(0xFF9A9AA1);
  static const metaGrey = Color(0xFF8E8E93);
  static const taskBadgeBg = Color(0xFFEEF2FF);
  static const taskBadgeText = Color(0xFF4A6EFF);
  static const noteBadgeBg = Color(0xFFFFF5F0);
  static const noteBadgeText = Color(0xFF8B7355);
  static const imageBadgeBg = Color(0xFFE8FAFC);
  static const imageBadgeText = Color(0xFF2BB8C9);
  static const checkboxBorder = Color(0xFF4A6EFF);
  static const noteIcon = Color(0xFF1A1C29);
  static const navInactive = Color(0xFF8E8E93);
}

abstract final class DailyBriefTypography {
  static TextStyle headerTitle(double s) => GoogleFonts.inter(
    fontSize: 18 * s,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle headerSubtitle(double s) => GoogleFonts.inter(
    fontSize: 13 * s,
    fontWeight: FontWeight.w400,
    color: DailyBriefColors.metaGrey,
    height: 1.3,
  );

  static TextStyle cardTitle(double s) => GoogleFonts.inter(
    fontSize: 15 * s,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static TextStyle cardBody(double s) => GoogleFonts.inter(
    fontSize: 13 * s,
    fontWeight: FontWeight.w400,
    color: DailyBriefColors.metaGrey,
    height: 1.4,
  );

  static TextStyle sectionLabel(double s) => GoogleFonts.inter(
    fontSize: 13 * s,
    fontWeight: FontWeight.w500,
    color: DailyBriefColors.sectionLabel,
  );

  static TextStyle badge(double s, Color color) => GoogleFonts.inter(
    fontSize: 11 * s,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
