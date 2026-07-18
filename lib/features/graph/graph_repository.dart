import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/features/graph/graph_layout_models.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:uuid/uuid.dart';

/// Fetches graph v2 views from the API.
class GraphRepository {
  GraphRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;
  static const _uuid = Uuid();

  Future<GraphResponse> fetchGraph({
    GraphViewMode view = GraphViewMode.knowledge,
  }) async {
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
    return GraphLayout.fromResponse(
      GraphLayoutResponse.fromJson(response.data!),
    );
  }

  Future<Map<String, dynamic>> fetchEntityDetail(String entityId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v2/entities/$entityId',
    );
    return response.data!;
  }

  /// Fetches the redesigned memory-detail payload for a capture:
  /// `{ capture, uiState, connections: { nodes, edges } }`.
  /// The [captureId] must be a graph capture id — a library-item id will 404,
  /// which callers are expected to catch and fall back from.
  Future<Map<String, dynamic>> fetchCaptureDetail(String captureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v2/captures/$captureId',
    );
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

  Future<MemoryProjectionReceipt> updateTaskStatus(
    String taskId,
    String status,
  ) {
    return applyGraphPatch(
      idempotencyKey: 'task-update:${_uuid.v4()}',
      operations: [
        {'op': 'update_task', 'taskId': taskId, 'status': status},
      ],
    );
  }

  Future<MemoryProjectionReceipt> archiveCapture(String captureId) {
    return applyGraphPatch(
      idempotencyKey: 'capture-archive:${_uuid.v4()}',
      operations: [
        {'op': 'archive_capture', 'captureId': captureId},
      ],
    );
  }

  Future<MemoryProjectionReceipt> patchCaptureTitle(
    String captureId,
    String title,
  ) {
    return applyGraphPatch(
      idempotencyKey: 'capture-title:${_uuid.v4()}',
      operations: [
        {'op': 'update_capture_title', 'captureId': captureId, 'title': title},
      ],
    );
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

  Future<GraphIngestResponse> correctCapture(
    String captureId,
    String text,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v2/captures/$captureId/correct',
      data: {'text': text},
    );
    return GraphIngestResponse.fromJson(response.data!);
  }

  Future<MemoryProjectionReceipt> rejectAssertion(String assertionId) async {
    return applyGraphPatch(
      idempotencyKey: 'assertion-reject:${_uuid.v4()}',
      operations: [
        {
          'op': 'set_assertion_status',
          'assertionId': assertionId,
          'status': 'REJECTED',
        },
      ],
    );
  }

  Future<MemoryProjectionReceipt> rejectAssertions(
    List<String> assertionIds,
  ) async {
    final unique = assertionIds.toSet().toList()..sort();
    return applyGraphPatch(
      idempotencyKey: 'assertions-reject:${_uuid.v4()}',
      operations: [
        for (final id in unique)
          {
            'op': 'set_assertion_status',
            'assertionId': id,
            'status': 'REJECTED',
          },
      ],
    );
  }

  /// Merges the [sourceId] entity into [targetId] (source is absorbed). Used by
  /// the memory Map's "merge duplicate" action. Throws on 404 (unknown entity).
  Future<MemoryProjectionReceipt> mergeEntities({
    required String sourceId,
    required String targetId,
  }) async {
    return applyGraphPatch(
      idempotencyKey: 'merge:${_uuid.v4()}',
      operations: [
        {'op': 'merge_entities', 'sourceId': sourceId, 'targetId': targetId},
      ],
    );
  }

  Future<MemoryProjectionReceipt> splitEntity({
    required String sourceId,
    required String canonicalName,
    required String entityType,
    required String identityHint,
    required List<String> assertionIds,
    List<String> captureIds = const [],
    List<String> aliases = const [],
    List<String> facets = const [],
    String? summary,
  }) {
    final selected = assertionIds.toSet().toList()..sort();
    return applyGraphPatch(
      idempotencyKey: 'split:${_uuid.v4()}',
      operations: [
        {
          'op': 'split_entity',
          'sourceId': sourceId,
          'newEntity': {
            'canonicalName': canonicalName,
            'entityType': entityType,
            'identityHint': identityHint,
            'aliases': aliases,
            'facets': facets,
            if (summary != null && summary.trim().isNotEmpty)
              'summary': summary.trim(),
          },
          'assertionIds': selected,
          'captureIds': captureIds.toSet().toList(),
        },
      ],
    );
  }

  Future<MemoryProjectionReceipt> applyGraphPatch({
    required String idempotencyKey,
    required List<Map<String, dynamic>> operations,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v2/memory/patches',
      data: {'idempotencyKey': idempotencyKey, 'operations': operations},
    );
    return MemoryProjectionReceipt.fromJson(response.data!);
  }

  Future<MemoryProjectionReceipt> retryMemoryEvent(String eventId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v2/memory/events/$eventId/retry',
    );
    return MemoryProjectionReceipt.fromJson(response.data!);
  }

  /// Reads the durable outbox receipt without retrying or duplicating the
  /// mutation. The event endpoint wraps the receipt in `projection` because it
  /// also exposes ledger audit metadata.
  Future<MemoryProjectionReceipt> fetchMemoryEventProjection(
    String eventId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v2/memory/events/$eventId',
    );
    final projection = response.data?['projection'];
    if (projection is! Map<String, dynamic>) {
      throw const FormatException('Memory event projection is missing');
    }
    return MemoryProjectionReceipt.fromJson(projection);
  }

  /// Waits briefly for the projection worker to make a durable graph mutation
  /// visible. A timeout returns the latest pending receipt; it does not turn a
  /// safely committed ledger event into an apparent failure.
  Future<MemoryProjectionReceipt> waitForProjection(
    MemoryProjectionReceipt receipt, {
    Duration timeout = const Duration(seconds: 12),
    Duration pollInterval = const Duration(milliseconds: 450),
  }) async {
    var latest = receipt;
    if (!latest.isPending) return latest;

    final clock = Stopwatch()..start();
    while (latest.isPending && clock.elapsed < timeout) {
      await Future<void>.delayed(pollInterval);
      try {
        latest = await fetchMemoryEventProjection(latest.eventId);
      } on DioException {
        // A short network interruption must not cause a second mutation. Keep
        // polling the same durable event until the UI's bounded wait expires.
      }
    }
    return latest;
  }
}
