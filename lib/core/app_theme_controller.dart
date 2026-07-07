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
  static const String _accentKey = 'mira_accent';
  static const String _textScaleKey = 'mira_textscale';
  static const String _reduceMotionKey = 'mira_reducemotion';
  static const String _appIconKey = 'mira_appicon';

  /// Default accent — the periwinkle `--peri` brand tone.
  static const Color _defaultAccent = Color(0xFF7E8BC9);

  ThemeMode _mode;

  /// The app accent, painted into `RdTheme.peri` app-wide (see `main.dart`).
  Color _accent = _defaultAccent;

  /// Global text scale factor applied via `MediaQuery.textScaler`.
  double _textScale = 1.0;

  /// Whether the user opted to reduce motion / animations.
  bool _reduceMotion = false;

  /// The selected app-icon variant id (runtime swap is a native follow-up).
  String _appIcon = 'default';

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Color get accent => _accent;
  double get textScale => _textScale;
  bool get reduceMotion => _reduceMotion;
  String get appIcon => _appIcon;

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
    if (stored != null) {
      _mode = _modeFromPreference(MiraThemePreference.fromApi(stored));
    }

    final accent = prefs.getInt(_accentKey);
    if (accent != null) _accent = Color(accent);

    final textScale = prefs.getDouble(_textScaleKey);
    if (textScale != null) _textScale = textScale;

    _reduceMotion = prefs.getBool(_reduceMotionKey) ?? _reduceMotion;

    final appIcon = prefs.getString(_appIconKey);
    if (appIcon != null && appIcon.isNotEmpty) _appIcon = appIcon;

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

  /// Sets the app accent (recolors `RdTheme.peri` app-wide) and persists it.
  void setAccent(Color accent) {
    if (_accent.toARGB32() == accent.toARGB32()) return;
    _accent = accent;
    notifyListeners();
    _persistInt(_accentKey, accent.toARGB32());
  }

  /// Sets the global text scale (S / M / L → 0.9 / 1.0 / 1.15) and persists it.
  void setTextScale(double textScale) {
    if (_textScale == textScale) return;
    _textScale = textScale;
    notifyListeners();
    _persistDouble(_textScaleKey, textScale);
  }

  /// Toggles reduce-motion and persists it.
  void setReduceMotion(bool reduceMotion) {
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    notifyListeners();
    _persistBool(_reduceMotionKey, reduceMotion);
  }

  /// Selects the app-icon variant and persists it. The live launcher-icon swap
  /// needs a native plugin; here we only record the choice.
  // TODO: native launcher-icon swap
  void setAppIcon(String appIcon) {
    if (_appIcon == appIcon) return;
    _appIcon = appIcon;
    notifyListeners();
    _persistString(_appIconKey, appIcon);
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

  /// Fire-and-forget key writes for the appearance preferences — same
  /// non-blocking contract as [_persist].
  void _persistInt(String key, int value) {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(key, value))
        .ignore();
  }

  void _persistDouble(String key, double value) {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(key, value))
        .ignore();
  }

  void _persistBool(String key, bool value) {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(key, value))
        .ignore();
  }

  void _persistString(String key, String value) {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(key, value))
        .ignore();
  }
}
