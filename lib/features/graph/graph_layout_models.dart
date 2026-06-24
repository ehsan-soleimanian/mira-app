/// Normalized graph layout persisted via `PUT /v2/graph/layout`.
class GraphLayout {
  const GraphLayout({
    required this.positions,
    this.panX = 0,
    this.panY = 0,
    this.scale = 1,
  });

  factory GraphLayout.fromResponse(GraphLayoutResponse? response) {
    if (response == null) return const GraphLayout(positions: []);
    return GraphLayout(
      positions: response.positions,
      panX: response.panX,
      panY: response.panY,
      scale: response.scale,
    );
  }

  final List<GraphLayoutPosition> positions;
  final double panX;
  final double panY;
  final double scale;

  Map<String, GraphLayoutPosition> get byNodeId => {
        for (final item in positions) item.nodeId: item,
      };

  Map<String, dynamic> toJson() => {
        'positions': positions.map((item) => item.toJson()).toList(),
        'pan_x': panX,
        'pan_y': panY,
        'scale': scale,
      };
}

class GraphLayoutPosition {
  const GraphLayoutPosition({
    required this.nodeId,
    required this.x,
    required this.y,
  });

  factory GraphLayoutPosition.fromJson(Map<String, dynamic> json) =>
      GraphLayoutPosition(
        nodeId: json['node_id'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );

  final String nodeId;
  final double x;
  final double y;

  Map<String, dynamic> toJson() => {
        'node_id': nodeId,
        'x': x,
        'y': y,
      };
}

class GraphLayoutResponse {
  const GraphLayoutResponse({
    required this.positions,
    this.panX = 0,
    this.panY = 0,
    this.scale = 1,
  });

  factory GraphLayoutResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['positions'] as List<dynamic>? ?? const [];
    return GraphLayoutResponse(
      positions: raw
          .whereType<Map<String, dynamic>>()
          .map(GraphLayoutPosition.fromJson)
          .toList(),
      panX: (json['pan_x'] as num?)?.toDouble() ?? 0,
      panY: (json['pan_y'] as num?)?.toDouble() ?? 0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
    );
  }

  final List<GraphLayoutPosition> positions;
  final double panX;
  final double panY;
  final double scale;
}
