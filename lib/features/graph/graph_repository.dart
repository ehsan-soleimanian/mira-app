import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/features/graph/graph_layout_models.dart';
import 'package:mira_app/models/api/graph_models.dart';

/// Fetches graph v2 views from the API.
class GraphRepository {
  GraphRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<GraphResponse> fetchGraph({GraphViewMode view = GraphViewMode.knowledge}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v2/graph',
      queryParameters: {'view': view.apiValue},
    );
    return GraphResponse.fromJson(response.data!);
  }

  Future<GraphLayout> saveLayout(GraphLayout layout) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/v2/graph/layout',
      data: {
        'positions': layout.positions
            .map((p) => {'nodeId': p.nodeId, 'x': p.x, 'y': p.y})
            .toList(),
        'panX': layout.panX,
        'panY': layout.panY,
        'scale': layout.scale,
      },
    );
    return GraphLayout.fromResponse(GraphLayoutResponse.fromJson(response.data!));
  }

  Future<Map<String, dynamic>> fetchEntityDetail(String entityId) async {
    final response = await _dio.get<Map<String, dynamic>>('/v2/entities/$entityId');
    return response.data!;
  }
}
