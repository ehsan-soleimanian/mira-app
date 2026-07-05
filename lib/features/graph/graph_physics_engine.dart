import 'dart:math' as math;
import 'dart:ui';

/// Force-directed layout with draggable nodes (session physics).
class GraphPhysicsEngine {
  GraphPhysicsEngine({
    required Map<String, Offset> initialPositions,
    required List<({String from, String to})> edges,
    required this.center,
    required this.bounds,
  }) : _edges = List.of(edges) {
    for (final entry in initialPositions.entries) {
      _nodes[entry.key] = _PhysicsNode(id: entry.key, position: entry.value);
    }
    _restLengths = _computeRestLengths();
  }

  static const double _damping = 0.86;
  static const double _springK = 0.022;
  static const double _repulsion = 14000;
  static const double _centerPull = 0.0008;
  static const double _maxVelocity = 14;
  static const double _settleThreshold = 0.08;

  final Offset center;
  final Size bounds;
  final List<({String from, String to})> _edges;
  final Map<String, _PhysicsNode> _nodes = {};
  late final Map<String, double> _restLengths;

  String? draggingId;

  Map<String, Offset> get positions => {
    for (final entry in _nodes.entries) entry.key: entry.value.position,
  };

  bool get isSettled {
    if (draggingId != null) return false;
    for (final node in _nodes.values) {
      if (node.velocity.distance > _settleThreshold) return false;
    }
    return true;
  }

  void setDragPosition(String id, Offset position) {
    final node = _nodes[id];
    if (node == null) return;
    draggingId = id;
    node
      ..pinned = true
      ..position = _clampToBounds(position)
      ..velocity = Offset.zero;
  }

  void endDrag(String id) {
    final node = _nodes[id];
    if (node == null) return;
    node.pinned = false;
    if (draggingId == id) draggingId = null;
  }

  void tick(double dt) {
    if (_nodes.isEmpty) return;
    final scaledDt = dt.clamp(0.0, 0.032) * 60;

    for (final node in _nodes.values) {
      if (node.pinned) continue;
      var force = Offset.zero;

      final toCenter = center - node.position;
      force += toCenter * _centerPull;

      for (final other in _nodes.values) {
        if (other.id == node.id) continue;
        final delta = node.position - other.position;
        final dist = math.max(delta.distance, 28.0);
        final strength = _repulsion / (dist * dist);
        force += Offset(delta.dx / dist, delta.dy / dist) * strength;
      }

      for (final edge in _edges) {
        final peerId = edge.from == node.id
            ? edge.to
            : edge.to == node.id
            ? edge.from
            : null;
        if (peerId == null) continue;
        final peer = _nodes[peerId];
        if (peer == null) continue;
        final key = _edgeKey(edge.from, edge.to);
        final rest = _restLengths[key] ?? 120.0;
        final delta = peer.position - node.position;
        final dist = math.max(delta.distance, 1.0);
        final displacement = dist - rest;
        force +=
            Offset(delta.dx / dist, delta.dy / dist) *
            (displacement * _springK);
      }

      node.velocity = (node.velocity + force * scaledDt) * _damping;
      if (node.velocity.distance > _maxVelocity) {
        node.velocity = Offset.fromDirection(
          node.velocity.direction,
          _maxVelocity,
        );
      }
      node.position = _clampToBounds(node.position + node.velocity * scaledDt);
    }
  }

  Map<String, double> _computeRestLengths() {
    final lengths = <String, double>{};
    for (final edge in _edges) {
      final from = _nodes[edge.from]?.position;
      final to = _nodes[edge.to]?.position;
      if (from == null || to == null) continue;
      lengths[_edgeKey(edge.from, edge.to)] = (from - to).distance.clamp(
        80.0,
        220.0,
      );
    }
    return lengths;
  }

  String _edgeKey(String a, String b) => a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';

  Offset _clampToBounds(Offset position) {
    const margin = 36.0;
    return Offset(
      position.dx.clamp(margin, bounds.width - margin),
      position.dy.clamp(margin, bounds.height - margin),
    );
  }
}

class _PhysicsNode {
  _PhysicsNode({required this.id, required this.position});

  final String id;
  Offset position;
  Offset velocity = Offset.zero;
  bool pinned = false;
}
