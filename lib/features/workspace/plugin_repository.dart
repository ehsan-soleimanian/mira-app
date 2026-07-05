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

  Future<void> connect(String id) async {
    await _dio.post<void>('/plugins/$id/connect', data: {});
  }

  Future<void> sync(String id) async {
    await _dio.post<void>('/plugins/$id/sync');
  }
}
