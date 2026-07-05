import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class CanvasRepository {
  CanvasRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<CanvasDto> create({String title = 'Mira canvas'}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/canvas',
      data: {'title': title},
    );
    return CanvasDto.fromJson(response.data!);
  }

  Future<CanvasDto> fetch(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/canvas/$id');
    return CanvasDto.fromJson(response.data!);
  }
}
