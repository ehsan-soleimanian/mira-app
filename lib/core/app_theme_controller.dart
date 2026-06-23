import 'package:flutter/material.dart';

import 'package:mira_app/models/api/settings_models.dart';

/// Light / dark theme toggle.
class AppThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setPreference(MiraThemePreference preference) {
    setMode(switch (preference) {
      MiraThemePreference.system => ThemeMode.system,
      MiraThemePreference.light => ThemeMode.light,
      MiraThemePreference.dark => ThemeMode.dark,
    });
  }

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
