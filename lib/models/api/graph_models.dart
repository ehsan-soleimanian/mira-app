class GraphResponse {
  const GraphResponse({required this.nodes, required this.edges});

  factory GraphResponse.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List<dynamic>? ?? const [];
    final rawEdges = json['edges'] as List<dynamic>? ?? const [];
    return GraphResponse(
      nodes: rawNodes
          .whereType<Map<String, dynamic>>()
          .map(GraphNode.fromJson)
          .toList(),
      edges: rawEdges
          .whereType<Map<String, dynamic>>()
          .map(GraphEdge.fromJson)
          .toList(),
    );
  }

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
}

class GraphNode {
  const GraphNode({
    required this.id,
    required this.nodeType,
    required this.title,
    required this.summary,
    required this.captureId,
    required this.createdAt,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) => GraphNode(
        id: json['id'] as String,
        nodeType: json['node_type'] as String? ?? 'Note',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        captureId: json['capture_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  final String id;
  final String nodeType;
  final String title;
  final String summary;
  final String? captureId;
  final DateTime createdAt;
}

class GraphEdge {
  const GraphEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.relationship,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
        id: json['id'] as String,
        sourceId: json['source_id'] as String,
        targetId: json['target_id'] as String,
        relationship: json['relationship'] as String? ?? 'RELATES_TO',
      );

  final String id;
  final String sourceId;
  final String targetId;
  final String relationship;
}
