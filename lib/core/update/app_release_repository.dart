import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/app_release_models.dart';

/// Fetches latest mobile build metadata from the public API.
class AppReleaseRepository {
  AppReleaseRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<AppReleaseInfo?> fetchLatest() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/app/version');
      final data = response.data;
      if (data == null) return null;
      return AppReleaseInfo.fromJson(data);
    } on DioException {
      return null;
    }
  }
}
