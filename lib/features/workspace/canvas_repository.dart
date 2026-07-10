import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class CanvasRepository {
  CanvasRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<CanvasDto>> list() async {
    final response = await _dio.get<List<dynamic>>('/canvas');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CanvasDto.fromJson)
        .toList();
  }

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

  Future<CanvasDto> update(
    String id, {
    String? title,
    List<Map<String, dynamic>>? nodes,
    List<Map<String, dynamic>>? edges,
    Map<String, dynamic>? viewport,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (nodes != null) data['nodes'] = nodes;
    if (edges != null) data['edges'] = edges;
    if (viewport != null) data['viewport'] = viewport;
    final response = await _dio.patch<Map<String, dynamic>>(
      '/canvas/$id',
      data: data,
    );
    return CanvasDto.fromJson(response.data!);
  }

  /// Deletes a board. Returns normally on 204; throws on 404 (unknown board).
  Future<void> delete(String id) async {
    await _dio.delete<void>('/canvas/$id');
  }
}
