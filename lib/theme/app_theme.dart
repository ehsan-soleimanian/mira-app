import 'package:flutter/material.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: MiraPageTransitionsBuilder(),
            TargetPlatform.iOS: MiraPageTransitionsBuilder(),
            TargetPlatform.macOS: MiraPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          surface: AppColors.surface,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: MiraPageTransitionsBuilder(),
            TargetPlatform.iOS: MiraPageTransitionsBuilder(),
            TargetPlatform.macOS: MiraPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
      );
}
