import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/features/graph/graph_layout_models.dart';
import 'package:mira_app/models/api/graph_models.dart';

/// Fetches the authenticated user's memory graph from Neo4j via the API.
class GraphRepository {
  GraphRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<GraphResponse> fetchGraph() async {
    final response = await _dio.get<Map<String, dynamic>>('/graph');
    return GraphResponse.fromJson(response.data!);
  }

  Future<GraphLayout> saveLayout(GraphLayout layout) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/graph/layout',
      data: layout.toJson(),
    );
    return GraphLayout.fromResponse(GraphLayoutResponse.fromJson(response.data!));
  }
}
