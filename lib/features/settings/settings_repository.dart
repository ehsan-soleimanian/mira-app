import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  static const _languageKey = 'mira_settings_language';
  static const _themeKey = 'mira_settings_theme';
  static const _notificationsKey = 'mira_settings_notifications';
  static const _dailyBriefKey = 'mira_settings_daily_brief';
  static const _memoryInsightsKey = 'mira_settings_memory_insights';
  static const _analyticsKey = 'mira_settings_analytics';

  Future<AuthUser> fetchProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
  }

  Future<AuthUser> updateProfile({
    required String displayName,
    String? role,
    String? gender,
    String? bio,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/auth/me',
      data: {
        'display_name': displayName.trim(),
        'role': _blankToNull(role),
        'gender': _blankToNull(gender),
        'bio': _blankToNull(bio),
      },
    );
    return AuthUser.fromJson(response.data!);
  }

  Future<UserSettings> fetchSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/settings');
      final settings = UserSettings.fromJson(response.data!);
      await _cache(settings);
      return settings;
    } on DioException catch (error) {
      final cached = await _cachedSettings();
      if (_canUseLocalFallback(error)) return cached;
      rethrow;
    }
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    await _cache(settings);
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/auth/settings',
        data: settings.toJson(),
      );
      final saved = UserSettings.fromJson(response.data!);
      await _cache(saved);
      return saved;
    } on DioException catch (error) {
      if (_canUseLocalFallback(error)) return settings;
      rethrow;
    }
  }

  Future<bool> checkApiReady() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health/ready');
      return response.statusCode == 200 && response.data?['status'] == 'ready';
    } on DioException {
      return false;
    }
  }

  Future<void> _cache(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, settings.language.apiValue);
    await prefs.setString(_themeKey, settings.theme.apiValue);
    await prefs.setBool(_notificationsKey, settings.notificationsEnabled);
    await prefs.setBool(_dailyBriefKey, settings.dailyBriefEnabled);
    await prefs.setBool(_memoryInsightsKey, settings.memoryInsightsEnabled);
    await prefs.setBool(_analyticsKey, settings.analyticsEnabled);
  }

  Future<UserSettings> _cachedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      language: MiraLanguagePreference.fromApi(prefs.getString(_languageKey)),
      theme: MiraThemePreference.fromApi(prefs.getString(_themeKey)),
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      dailyBriefEnabled: prefs.getBool(_dailyBriefKey) ?? true,
      memoryInsightsEnabled: prefs.getBool(_memoryInsightsKey) ?? true,
      analyticsEnabled: prefs.getBool(_analyticsKey) ?? false,
    );
  }

  bool _canUseLocalFallback(DioException error) {
    final code = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        code == 404 ||
        code == 501;
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
