import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/graph/graph_physics_engine.dart';

void main() {
  test('physics engine moves connected nodes toward spring rest', () {
    final engine = GraphPhysicsEngine(
      initialPositions: {
        'a': const Offset(100, 100),
        'b': const Offset(400, 100),
      },
      edges: [(from: 'a', to: 'b')],
      center: const Offset(250, 200),
      bounds: const Size(500, 400),
    );

    for (var i = 0; i < 120; i++) {
      engine.tick(1 / 60);
    }

    final distance = (engine.positions['a']! - engine.positions['b']!).distance;
    expect(distance, greaterThan(80));
    expect(distance, lessThan(260));
  });

  test('drag pins node until released', () {
    final engine = GraphPhysicsEngine(
      initialPositions: {'a': const Offset(50, 50)},
      edges: const [],
      center: const Offset(100, 100),
      bounds: const Size(200, 200),
    );

    engine.setDragPosition('a', const Offset(120, 140));
    expect(engine.positions['a'], const Offset(120, 140));
    engine.endDrag('a');
    engine.tick(1 / 60);
    expect(engine.draggingId, isNull);
  });
}
