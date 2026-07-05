import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class SpaceRepository {
  SpaceRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<SpaceDto>> list() async {
    final response = await _dio.get<List<dynamic>>('/spaces');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SpaceDto.fromJson)
        .toList();
  }

  Future<SpaceDto> create(String name) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/spaces',
      data: {'name': name},
    );
    return SpaceDto.fromJson(response.data!);
  }
}
