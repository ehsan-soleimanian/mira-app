import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/atoms/figma_svg_icon.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/core/auth/google_sign_in_config.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/config/api_endpoint_resolver.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/features/auth/auth_gate.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await preloadFigmaSvgAssets(const [
    FigmaAssets.navHome,
    FigmaAssets.navCoffee,
    FigmaAssets.navMic,
    FigmaAssets.settingsIcon,
    FigmaAssets.tipArrow,
  ]);

  await ApiConfig.init();
  await GoogleSignInConfig.ensureLoaded();
  final services = MiraServices.create();

  if (kDebugMode) {
    if (ApiConfig.hasExplicitBaseUrl) {
      final url = ApiConfig.baseUrl;
      services.apiClient.setBaseUrl(url);
      debugPrint('MIRA API: $url');
    } else {
      final resolved = await ApiEndpointResolver.probeFirstReachable();
      if (resolved != null) {
        await ApiConfig.setDevBaseUrl(resolved);
        services.apiClient.setBaseUrl(resolved);
        debugPrint('MIRA API auto-selected: $resolved');
      } else {
        debugPrint(
          'MIRA API probe failed — set URL on login screen. '
          'Tried: ${ApiConfig.probeCandidates.join(', ')}',
        );
      }
    }
  }

  runApp(MiraApp(
    themeController: AppThemeController(),
    services: services,
  ));
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
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
