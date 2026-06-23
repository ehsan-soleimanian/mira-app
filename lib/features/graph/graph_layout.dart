import 'dart:math' as math;
import 'dart:ui';

import 'package:mira_app/models/api/graph_models.dart';

/// Radial layout for the memory graph — hub in the center, satellites on rings.
class GraphLayoutNode {
  const GraphLayoutNode({
    required this.node,
    required this.position,
    required this.ring,
    this.isHighlighted = false,
  });

  final GraphNode node;
  final Offset position;
  final int ring;
  final bool isHighlighted;
}

class GraphLayoutEdge {
  const GraphLayoutEdge({
    required this.from,
    required this.to,
    required this.relationship,
  });

  final Offset from;
  final Offset to;
  final String relationship;
}

class MemoryGraphLayout {
  const MemoryGraphLayout({
    required this.centerLabel,
    required this.centerPosition,
    required this.nodes,
    required this.edges,
    required this.canvasSize,
  });

  final String centerLabel;
  final Offset centerPosition;
  final List<GraphLayoutNode> nodes;
  final List<GraphLayoutEdge> edges;
  final Size canvasSize;

  static MemoryGraphLayout compute({
    required GraphResponse graph,
    required Size viewport,
    String? highlightNodeId,
    String? centerLabelOverride,
  }) {
    final nodes = graph.nodes;
    if (nodes.isEmpty) {
      return MemoryGraphLayout(
        centerLabel: centerLabelOverride ?? 'Mira',
        centerPosition: Offset(viewport.width / 2, viewport.height / 2),
        nodes: const [],
        edges: const [],
        canvasSize: viewport,
      );
    }

    final byId = {for (final node in nodes) node.id: node};
    final adjacency = <String, Set<String>>{};
    for (final edge in graph.edges) {
      adjacency.putIfAbsent(edge.sourceId, () => {}).add(edge.targetId);
      adjacency.putIfAbsent(edge.targetId, () => {}).add(edge.sourceId);
    }

    final hub = _pickHub(nodes, adjacency);
    final center = Offset(viewport.width / 2, viewport.height * 0.46);
    final innerRadius = math.min(viewport.width, viewport.height) * 0.24;
    final outerRadius = math.min(viewport.width, viewport.height) * 0.38;

    final hubNeighbors = adjacency[hub.id] ?? <String>{};
    final innerIds = <String>[
      if (hubNeighbors.isNotEmpty) ...hubNeighbors,
      if (hubNeighbors.isEmpty)
        ...nodes.where((n) => n.id != hub.id).map((n) => n.id),
    ];
    final innerSet = innerIds.toSet();
    final outerIds = nodes
        .where((node) => node.id != hub.id && !innerSet.contains(node.id))
        .map((node) => node.id)
        .toList();

    final positioned = <GraphLayoutNode>[];

    void placeRing(List<String> ids, double radius, int ring) {
      if (ids.isEmpty) return;
      for (var index = 0; index < ids.length; index++) {
        final angle = (-math.pi / 2) + (2 * math.pi * index / ids.length);
        final node = byId[ids[index]];
        if (node == null) continue;
        positioned.add(
          GraphLayoutNode(
            node: node,
            position: Offset(
              center.dx + radius * math.cos(angle),
              center.dy + radius * math.sin(angle),
            ),
            ring: ring,
            isHighlighted: node.id == highlightNodeId,
          ),
        );
      }
    }

    placeRing(innerIds, innerRadius, 1);
    placeRing(outerIds, outerRadius, 2);

    final positions = {
      for (final item in positioned) item.node.id: item.position,
    };

    final layoutEdges = <GraphLayoutEdge>[];
    for (final edge in graph.edges) {
      final from = positions[edge.sourceId];
      final to = positions[edge.targetId];
      if (from != null && to != null) {
        layoutEdges.add(
          GraphLayoutEdge(from: from, to: to, relationship: edge.relationship),
        );
        continue;
      }
      if (edge.sourceId == hub.id || edge.targetId == hub.id) {
        final otherId =
            edge.sourceId == hub.id ? edge.targetId : edge.sourceId;
        final otherPos = positions[otherId];
        if (otherPos != null) {
          layoutEdges.add(
            GraphLayoutEdge(
              from: center,
              to: otherPos,
              relationship: edge.relationship,
            ),
          );
        }
      }
    }

    if (layoutEdges.isEmpty && positioned.isNotEmpty) {
      for (final item in positioned.where((n) => n.ring == 1)) {
        layoutEdges.add(
          GraphLayoutEdge(
            from: center,
            to: item.position,
            relationship: 'RELATES_TO',
          ),
        );
      }
    }

    return MemoryGraphLayout(
      centerLabel: centerLabelOverride ?? hub.title,
      centerPosition: center,
      nodes: positioned,
      edges: layoutEdges,
      canvasSize: viewport,
    );
  }

  static GraphNode _pickHub(
    List<GraphNode> nodes,
    Map<String, Set<String>> adjacency,
  ) {
    GraphNode? personHub;
    var bestPersonDegree = -1;
    GraphNode? degreeHub;
    var bestDegree = -1;

    for (final node in nodes) {
      final degree = adjacency[node.id]?.length ?? 0;
      if (node.nodeType == 'Person' && degree >= bestPersonDegree) {
        bestPersonDegree = degree;
        personHub = node;
      }
      if (degree >= bestDegree) {
        bestDegree = degree;
        degreeHub = node;
      }
    }

    return personHub ?? degreeHub ?? nodes.first;
  }

  GraphLayoutNode? hitTest(Offset localPosition, double nodeRadius) {
    for (final item in nodes.reversed) {
      if ((item.position - localPosition).distance <= nodeRadius + 8) {
        return item;
      }
    }
    return null;
  }
}
