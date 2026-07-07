import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mira_app/models/api/settings_models.dart';

/// System / Light / Dark theme selection, persisted across launches with
/// `shared_preferences` so the user's choice is restored on the next start.
///
/// The stored value is the [MiraThemePreference.apiValue] string (`system` /
/// `light` / `dark`) so it lines up with what the settings API round-trips.
class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemeMode initialMode = ThemeMode.system})
    : _mode = initialMode;

  static const String _storageKey = 'app_theme_mode';

  ThemeMode _mode;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// The current mode expressed as a [MiraThemePreference] (System / Light /
  /// Dark), for driving settings UI and the API.
  MiraThemePreference get preference => switch (_mode) {
    ThemeMode.system => MiraThemePreference.system,
    ThemeMode.light => MiraThemePreference.light,
    ThemeMode.dark => MiraThemePreference.dark,
  };

  /// Loads the persisted choice and applies it. Call once at startup before
  /// building the app; silently keeps [initialMode] if nothing is stored.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) return;
    _mode = _modeFromPreference(MiraThemePreference.fromApi(stored));
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    _persist(mode);
  }

  void setPreference(MiraThemePreference preference) {
    setMode(_modeFromPreference(preference));
  }

  void toggle() {
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode _modeFromPreference(MiraThemePreference preference) {
    return switch (preference) {
      MiraThemePreference.system => ThemeMode.system,
      MiraThemePreference.light => ThemeMode.light,
      MiraThemePreference.dark => ThemeMode.dark,
    };
  }

  static MiraThemePreference _preferenceFromMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => MiraThemePreference.system,
      ThemeMode.light => MiraThemePreference.light,
      ThemeMode.dark => MiraThemePreference.dark,
    };
  }

  /// Fire-and-forget write of the current mode. Persistence failures must not
  /// block the UI, so the future is intentionally not awaited.
  void _persist(ThemeMode mode) {
    SharedPreferences.getInstance()
        .then(
          (prefs) => prefs.setString(
            _storageKey,
            _preferenceFromMode(mode).apiValue,
          ),
        )
        .ignore();
  }
}
