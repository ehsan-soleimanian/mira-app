import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class PluginRepository {
  PluginRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<PluginManifestDto>> list() async {
    final response = await _dio.get<List<dynamic>>('/plugins');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PluginManifestDto.fromJson)
        .toList();
  }

  Future<PluginConnectResult> connect(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/plugins/$id/connect',
      data: <String, dynamic>{},
    );
    return PluginConnectResult.fromJson(response.data ?? const {});
  }

  Future<bool> refreshStatus(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/plugins/$id/status',
    );
    return response.data?['connected'] as bool? ?? false;
  }
}
