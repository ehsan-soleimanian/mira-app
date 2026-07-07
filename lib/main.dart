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

  runApp(MiraApp(themeController: AppThemeController(), services: services));
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
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: RdColors.bg,
              colorScheme: ColorScheme.fromSeed(
                seedColor: RdColors.navy,
                surface: RdColors.bg,
              ),
            ),
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
