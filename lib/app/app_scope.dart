import 'package:flutter/material.dart';
import 'package:mira_app/core/app_theme_controller.dart';

class AppScope extends InheritedNotifier<AppThemeController> {
  const AppScope({
    super.key,
    required AppThemeController themeController,
    required super.child,
  }) : super(notifier: themeController);

  static AppThemeController themeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
