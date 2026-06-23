import 'package:flutter/material.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.themeController,
    required this.services,
    required super.child,
  });

  final AppThemeController themeController;
  final MiraServices services;

  static AppThemeController themeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.themeController;
  }

  static MiraServices servicesOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      themeController != oldWidget.themeController ||
      services != oldWidget.services;
}
