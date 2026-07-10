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

  /// Fetches the redesigned memory-detail payload for a capture:
  /// `{ capture, uiState, connections: { nodes, edges } }`.
  /// The [captureId] must be a graph capture id — a library-item id will 404,
  /// which callers are expected to catch and fall back from.
  Future<Map<String, dynamic>> fetchCaptureDetail(String captureId) async {
    final response = await _dio.get<Map<String, dynamic>>('/v2/captures/$captureId');
    return response.data!;
  }

  Future<List<GraphTaskDto>> fetchTasks({String? status}) async {
    final response = await _dio.get<List<dynamic>>(
      '/v2/tasks',
      queryParameters: status != null ? {'status': status} : null,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GraphTaskDto.fromJson)
        .toList();
  }

  Future<GraphTaskDto> updateTaskStatus(String taskId, String status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/v2/tasks/$taskId',
      data: {'status': status},
    );
    return GraphTaskDto.fromJson(response.data!);
  }

  Future<ArchiveCaptureResponse> archiveCapture(String captureId) async {
    final response = await _dio.delete<Map<String, dynamic>>('/v2/captures/$captureId');
    return ArchiveCaptureResponse.fromJson(response.data!);
  }

  Future<String> patchCaptureTitle(String captureId, String title) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/v2/captures/$captureId',
      data: {'title': title},
    );
    return response.data!['title'] as String? ?? title;
  }

  /// Patches a capture's lifecycle flags. Sends only the provided keys as a
  /// camelCase body to `PATCH /v2/captures/{id}/state`.
  Future<void> updateCaptureState(
    String captureId, {
    bool? pinned,
    bool? reminderEnabled,
  }) async {
    final data = <String, dynamic>{
      'pinned': ?pinned,
      'reminderEnabled': ?reminderEnabled,
    };
    await _dio.patch<Map<String, dynamic>>(
      '/v2/captures/$captureId/state',
      data: data,
    );
  }

  Future<GraphIngestResponse> correctCapture(String captureId, String text) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v2/captures/$captureId/correct',
      data: {'text': text},
    );
    return GraphIngestResponse.fromJson(response.data!);
  }

  Future<void> rejectAssertion(String assertionId) async {
    await _dio.post<void>('/v2/assertions/$assertionId/reject');
  }

  /// Merges the [sourceId] entity into [targetId] (source is absorbed). Used by
  /// the memory Map's "merge duplicate" action. Throws on 404 (unknown entity).
  Future<void> mergeEntities({
    required String sourceId,
    required String targetId,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/v2/entities/$sourceId/merge/$targetId',
    );
  }
}
