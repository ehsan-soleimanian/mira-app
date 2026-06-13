import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/screens/home_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MiraApp(themeController: AppThemeController()));
}

class MiraApp extends StatelessWidget {
  const MiraApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      themeController: themeController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Mira',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
