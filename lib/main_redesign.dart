import 'package:flutter/material.dart';

import 'package:mira_app/core/app_theme_controller.dart';

import 'redesign/redesign_app.dart';
import 'redesign/redesign_boot.dart';

/// Preview entry point for the redesign app (boots into Home / the tabs),
/// running on the real backend service container.
Future<void> main() async {
  final services = await bootstrapMiraServices();
  runApp(RedesignApp(services: services, themeController: AppThemeController()));
}
