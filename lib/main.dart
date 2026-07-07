import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/core/auth/google_sign_in_config.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/config/api_endpoint_resolver.dart';
import 'package:mira_app/app/mira_services.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/redesign/rd_root.dart';
import 'package:mira_app/redesign/theme/rd_colors.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: RdColors.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await ApiConfig.init();
  await GoogleSignInConfig.ensureLoaded();
  final services = MiraServices.create();
  await services.notificationService.initialize();

  if (kDebugMode) {
    if (ApiConfig.hasExplicitBaseUrl) {
      services.apiClient.setBaseUrl(ApiConfig.baseUrl);
    } else {
      final resolved = await ApiEndpointResolver.probeFirstReachable();
      if (resolved != null) {
        await ApiConfig.setDevBaseUrl(resolved);
        services.apiClient.setBaseUrl(resolved);
      }
    }
  }

  final themeController = AppThemeController();
  await themeController.load();

  runApp(MiraApp(themeController: themeController, services: services));
}

class MiraApp extends StatelessWidget {
  const MiraApp({
    super.key,
    required this.themeController,
    required this.services,
  });

  final AppThemeController themeController;
  final MiraServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      themeController: themeController,
      services: services,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: _lightTheme(),
            darkTheme: _darkTheme(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RdRoot(),
          );
        },
      ),
    );
  }
}

/// Light theme — matches the current app. Carries [RdTheme.light] so migrated
/// screens can read tokens via `context.rd`.
ThemeData _lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: RdTheme.light.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RdTheme.light.navy,
      surface: RdTheme.light.bg,
    ),
    extensions: const [RdTheme.light],
  );
}

/// Dark theme — the redesign dark palette. Carries [RdTheme.dark]; only takes
/// effect once screens migrate off the const `RdColors` tokens.
ThemeData _darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RdTheme.dark.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RdTheme.dark.navy,
      brightness: Brightness.dark,
      surface: RdTheme.dark.card,
    ),
    extensions: const [RdTheme.dark],
  );
}
