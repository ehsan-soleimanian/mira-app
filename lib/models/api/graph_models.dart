import 'package:mira_app/features/graph/graph_layout_models.dart';

/// Graph v2 API models — evidence-first knowledge graph.

enum GraphNodeKind {
  user,
  entity,
  capture,
  mention,
  assertion,
  task,
  preference;

  static GraphNodeKind? fromApi(String? value) {
    if (value == null) return null;
    return GraphNodeKind.values.cast<GraphNodeKind?>().firstWhere(
      (k) => k?.name.toUpperCase() == value.toUpperCase(),
      orElse: () => null,
    );
  }
}

enum GraphViewMode {
  knowledge('knowledge'),
  evidence('evidence'),
  hybrid('hybrid'),
  tasks('tasks');

  const GraphViewMode(this.apiValue);
  final String apiValue;
}

class GraphResponse {
  const GraphResponse({
    required this.nodes,
    required this.edges,
    this.view,
    this.layout,
  });

  factory GraphResponse.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List<dynamic>? ?? const [];
    final rawEdges = json['edges'] as List<dynamic>? ?? const [];
    final rawLayout = json['layout'];
    return GraphResponse(
      view: json['view'] as String?,
      nodes: rawNodes
          .whereType<Map<String, dynamic>>()
          .map(GraphNode.fromJson)
          .toList(),
      edges: rawEdges
          .whereType<Map<String, dynamic>>()
          .map(GraphEdge.fromJson)
          .toList(),
      layout: rawLayout is Map<String, dynamic>
          ? GraphLayoutResponse.fromJson(rawLayout)
          : null,
    );
  }

  final String? view;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final GraphLayoutResponse? layout;
}

class GraphNode {
  const GraphNode({
    required this.id,
    required this.kind,
    required this.nodeType,
    required this.title,
    required this.summary,
    this.entityType,
    this.status,
    this.labels = const [],
    this.captureId,
    this.createdAt,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String? ?? 'ENTITY';
    final entityType =
        json['entityType'] as String? ?? json['entity_type'] as String?;
    return GraphNode(
      id: json['id'] as String,
      kind: kind,
      nodeType: entityType ?? kind,
      entityType: entityType,
      title: json['title'] as String? ?? '',
      summary: json['subtitle'] as String? ?? json['summary'] as String? ?? '',
      status: json['status'] as String?,
      labels: (json['labels'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      captureId: json['captureId'] as String? ?? json['capture_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
    );
  }

  final String id;
  final String kind;
  final String nodeType;
  final String? entityType;
  final String title;
  final String summary;
  final String? status;
  final List<String> labels;
  final String? captureId;
  final DateTime? createdAt;
}

class GraphEdge {
  const GraphEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.relationship,
    this.kind,
    this.confidence,
    this.evidenceCount,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
    id: json['id'] as String,
    sourceId: json['sourceId'] as String? ?? json['source_id'] as String,
    targetId: json['targetId'] as String? ?? json['target_id'] as String,
    relationship:
        json['type'] as String? ?? json['relationship'] as String? ?? 'RELATED',
    kind: json['kind'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble(),
    evidenceCount:
        json['evidenceCount'] as int? ?? json['evidence_count'] as int?,
  );

  final String id;
  final String sourceId;
  final String targetId;
  final String relationship;
  final String? kind;
  final double? confidence;
  final int? evidenceCount;
}

class GraphIngestResponse {
  const GraphIngestResponse({
    required this.captureId,
    this.createdEntities = const [],
    this.createdAssertions = const [],
    this.materializedEdges = const [],
    this.tasks = const [],
    this.preferences = const [],
  });

  factory GraphIngestResponse.fromJson(Map<String, dynamic> json) =>
      GraphIngestResponse(
        captureId: json['captureId'] as String? ?? json['capture_id'] as String,
        createdEntities:
            (json['createdEntities'] as List<dynamic>? ??
                    json['created_entities'] as List<dynamic>? ??
                    const [])
                .map((e) => e.toString())
                .toList(),
        createdAssertions:
            (json['createdAssertions'] as List<dynamic>? ??
                    json['created_assertions'] as List<dynamic>? ??
                    const [])
                .map((e) => e.toString())
                .toList(),
        materializedEdges:
            (json['materializedEdges'] as List<dynamic>? ??
                    json['materialized_edges'] as List<dynamic>? ??
                    const [])
                .map((e) => e.toString())
                .toList(),
        tasks: (json['tasks'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        preferences: (json['preferences'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  final String captureId;
  final List<String> createdEntities;
  final List<String> createdAssertions;
  final List<String> materializedEdges;
  final List<String> tasks;
  final List<String> preferences;

  String? get highlightEntityId =>
      createdEntities.isNotEmpty ? createdEntities.first : null;
}

class GraphTaskDto {
  const GraphTaskDto({
    required this.taskId,
    required this.title,
    required this.actionType,
    required this.status,
    required this.captureId,
    this.dueAt,
    this.duePrecision,
    this.dueText,
  });

  factory GraphTaskDto.fromJson(Map<String, dynamic> json) => GraphTaskDto(
    taskId: json['taskId'] as String? ?? json['task_id'] as String,
    title: json['title'] as String? ?? '',
    actionType:
        json['actionType'] as String? ?? json['action_type'] as String? ?? '',
    status: json['status'] as String? ?? 'OPEN',
    captureId:
        json['captureId'] as String? ?? json['capture_id'] as String? ?? '',
    dueAt: _parseOptionalDate(json['dueAt'] ?? json['due_at']),
    duePrecision:
        json['duePrecision'] as String? ?? json['due_precision'] as String?,
    dueText: json['dueText'] as String? ?? json['due_text'] as String?,
  );

  final String taskId;
  final String title;
  final String actionType;
  final String status;
  final String captureId;
  final DateTime? dueAt;
  final String? duePrecision;
  final String? dueText;

  static DateTime? _parseOptionalDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.parse(value).toLocal();
  }
}

class ArchiveCaptureResponse {
  const ArchiveCaptureResponse({
    required this.archived,
    required this.captureId,
    this.assertionsRejected = 0,
    this.tasksCancelled = 0,
    this.edgesDemoted = 0,
  });

  factory ArchiveCaptureResponse.fromJson(Map<String, dynamic> json) =>
      ArchiveCaptureResponse(
        archived: json['archived'] as bool? ?? true,
        captureId: json['captureId'] as String? ?? json['capture_id'] as String,
        assertionsRejected:
            json['assertionsRejected'] as int? ??
            json['assertions_rejected'] as int? ??
            0,
        tasksCancelled:
            json['tasksCancelled'] as int? ??
            json['tasks_cancelled'] as int? ??
            0,
        edgesDemoted:
            json['edgesDemoted'] as int? ?? json['edges_demoted'] as int? ?? 0,
      );

  final bool archived;
  final String captureId;
  final int assertionsRejected;
  final int tasksCancelled;
  final int edgesDemoted;
}
