import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists onboarding completion locally; syncs with API when available.
class OnboardingRepository {
  OnboardingRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;
  static const _completedPrefix = 'mira_onboarding_done_';

  Future<bool> isCompletedLocally(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_completedPrefix$userId') ?? false;
  }

  Future<void> markCompletedLocally(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_completedPrefix$userId', true);
  }

  Future<AuthUser> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
  }

  Future<AuthUser> submitOnboarding(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/onboarding',
      data: payload,
    );
    final user = AuthUser.fromJson(response.data!);
    await markCompletedLocally(user.id);
    return user;
  }

  /// Persists the full setup-wizard payload (name, tone, focus areas, people,
  /// rhythm, privacy flags, sources, imports, permissions) collected by the
  /// redesigned onboarding flow. Body keys are camelCase per the API's
  /// [CamelModel] convention.
  Future<void> submitSetup(Map<String, dynamic> prefs) async {
    await _dio.post<Map<String, dynamic>>('/auth/onboarding/setup', data: prefs);
  }
}
