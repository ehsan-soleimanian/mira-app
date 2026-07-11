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
import 'package:mira_app/core/update/app_update_listener.dart';
import 'package:mira_app/redesign/rd_root.dart';
import 'package:mira_app/redesign/theme/rd_colors.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  // Auth gate: boot straight into the app only if a session already exists;
  // otherwise start the first-run onboarding/login flow. An expired access
  // token is refreshed lazily by the API client's 401 interceptor, so a mere
  // token-present check is enough here.
  final loggedIn = await services.authRepository.isLoggedIn();

  runApp(
    MiraApp(
      themeController: themeController,
      services: services,
      initial: loggedIn ? 'home' : 'splash',
    ),
  );
}

class MiraApp extends StatelessWidget {
  const MiraApp({
    super.key,
    required this.themeController,
    required this.services,
    this.initial = 'home',
  });

  final AppThemeController themeController;
  final MiraServices services;

  /// Screen the root boots into — 'home' when a session exists, else 'splash'
  /// (set by the auth gate in [main]).
  final String initial;

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
            theme: _lightTheme(themeController.accent),
            darkTheme: _darkTheme(themeController.accent),
            // Live text size: scale the whole tree by the user's preference.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeController.textScale),
              ),
              child: child!,
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppUpdateListener(child: RdRoot(initial: initial)),
          );
        },
      ),
    );
  }
}

/// Light theme — matches the current app. Carries [RdTheme.light] so migrated
/// screens can read tokens via `context.rd`. [accent] recolors `peri` app-wide.
ThemeData _lightTheme(Color accent) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: RdTheme.light.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RdTheme.light.navy,
      surface: RdTheme.light.bg,
    ),
    extensions: [RdTheme.light.copyWith(peri: accent)],
  );
}

/// Dark theme — the redesign dark palette. Carries [RdTheme.dark]; only takes
/// effect once screens migrate off the const `RdColors` tokens. [accent]
/// recolors `peri` app-wide.
ThemeData _darkTheme(Color accent) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RdTheme.dark.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RdTheme.dark.navy,
      brightness: Brightness.dark,
      surface: RdTheme.dark.card,
    ),
    extensions: [RdTheme.dark.copyWith(peri: accent)],
  );
}
