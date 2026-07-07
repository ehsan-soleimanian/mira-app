import 'package:flutter/material.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';

import 'rd_root.dart';
import 'theme/rd_colors.dart';

/// Hosts the redesign inside the real `MiraServices` container via `AppScope`,
/// so every redesign screen can reach the existing repositories with
/// `AppScope.servicesOf(context)` and talk to the backend. Run with
/// `flutter run -t lib/main_redesign.dart`. Once the wiring is complete this
/// becomes the shipping `main.dart`.
class RedesignApp extends StatelessWidget {
  const RedesignApp({
    super.key,
    required this.services,
    required this.themeController,
    this.initial = 'home',
  });

  final MiraServices services;
  final AppThemeController themeController;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      themeController: themeController,
      services: services,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mira',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: RdColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: RdColors.navy,
            surface: RdColors.bg,
          ),
        ),
        home: RdRoot(initial: initial),
      ),
    );
  }
}
