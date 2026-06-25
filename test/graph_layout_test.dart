import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/graph/graph_layout.dart';
import 'package:mira_app/models/api/graph_models.dart';

void main() {
  test('MemoryGraphLayout places neighbors on inner ring', () {
    final graph = GraphResponse(
      nodes: [
        GraphNode(
          id: 'person',
          kind: 'ENTITY',
          nodeType: 'Person',
          title: 'Sajad',
          summary: 'User',
          captureId: null,
          createdAt: DateTime(2024, 1, 1),
        ),
        GraphNode(
          id: 'task',
          kind: 'TASK',
          nodeType: 'Task',
          title: 'Product Design',
          summary: 'Design work',
          captureId: 'cap-1',
          createdAt: DateTime(2024, 2, 1),
        ),
      ],
      edges: [
        GraphEdge(
          id: 'e1',
          sourceId: 'task',
          targetId: 'person',
          relationship: 'INVOLVES',
        ),
      ],
    );

    final layout = MemoryGraphLayout.compute(
      graph: graph,
      viewport: const Size(390, 700),
      highlightNodeId: 'task',
    );

    expect(layout.centerLabel, 'Sajad');
    expect(layout.nodes, hasLength(1));
    expect(layout.nodes.first.node.id, 'task');
    expect(layout.nodes.first.isHighlighted, isTrue);
    expect(layout.edges, isNotEmpty);
  });
}
