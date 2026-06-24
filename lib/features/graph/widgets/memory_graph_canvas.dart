import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mira_app/features/graph/graph_layout.dart';
import 'package:mira_app/features/graph/graph_layout_models.dart';
import 'package:mira_app/features/graph/graph_physics_engine.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/graph_tokens.dart';

/// Interactive graph: drag nodes, force physics, pinch/pan viewport.
class MemoryGraphCanvas extends StatefulWidget {
  const MemoryGraphCanvas({
    super.key,
    required this.graph,
    required this.baseLayout,
    required this.savedLayout,
    required this.scale,
    required this.onNodeTap,
    required this.onLayoutChanged,
  });

  final GraphResponse graph;
  final MemoryGraphLayout baseLayout;
  final GraphLayout savedLayout;
  final double scale;
  final ValueChanged<GraphNode> onNodeTap;
  final ValueChanged<GraphLayout> onLayoutChanged;

  @override
  State<MemoryGraphCanvas> createState() => _MemoryGraphCanvasState();
}

class _MemoryGraphCanvasState extends State<MemoryGraphCanvas>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late GraphPhysicsEngine _physics;
  late MemoryGraphLayout _renderLayout;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  var _physicsActive = true;
  var _initializedTransform = false;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _initPhysics();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant MemoryGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph ||
        oldWidget.baseLayout != widget.baseLayout ||
        oldWidget.savedLayout != widget.savedLayout) {
      _initPhysics();
      _initializedTransform = false;
      _applySavedViewport();
    }
  }

  void _initPhysics() {
    final savedById = widget.savedLayout.byNodeId;
    final initial = <String, Offset>{};
    for (final item in widget.baseLayout.nodes) {
      final saved = savedById[item.node.id];
      initial[item.node.id] = saved != null
          ? Offset(
              saved.x * widget.baseLayout.canvasSize.width,
              saved.y * widget.baseLayout.canvasSize.height,
            )
          : item.position;
    }

    final edges = widget.graph.edges
        .map((edge) => (from: edge.sourceId, to: edge.targetId))
        .toList();

    _physics = GraphPhysicsEngine(
      initialPositions: initial,
      edges: edges,
      center: widget.baseLayout.centerPosition,
      bounds: widget.baseLayout.canvasSize,
    );
    _renderLayout = _layoutFromPhysics();
    _physicsActive = true;
    _lastTick = Duration.zero;
  }

  void _applySavedViewport() {
    if (_initializedTransform) return;
    _initializedTransform = true;
    final layout = widget.savedLayout;
    if (layout.scale == 1 && layout.panX == 0 && layout.panY == 0) return;
    _transformController.value = Matrix4.identity()
      ..translateByDouble(layout.panX, layout.panY, 0, 1)
      ..scaleByDouble(layout.scale, layout.scale, 1, 1);
  }

  void _onTick(Duration elapsed) {
    if (!_physicsActive || _physics.draggingId != null) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    _physics.tick(dt);
    if (!mounted) return;
    setState(() => _renderLayout = _layoutFromPhysics());
    if (_physics.isSettled) {
      _physicsActive = false;
      _emitLayout();
    }
  }

  MemoryGraphLayout _layoutFromPhysics() {
    final positions = _physics.positions;
    final nodes = widget.baseLayout.nodes
        .map(
          (item) => GraphLayoutNode(
            node: item.node,
            position: positions[item.node.id] ?? item.position,
            ring: item.ring,
            isHighlighted: item.isHighlighted,
          ),
        )
        .toList();

    final edges = <GraphLayoutEdge>[];
    for (final edge in widget.graph.edges) {
      final from = positions[edge.sourceId];
      final to = positions[edge.targetId];
      if (from != null && to != null) {
        edges.add(
          GraphLayoutEdge(
            from: from,
            to: to,
            relationship: edge.relationship,
          ),
        );
        continue;
      }
      final center = widget.baseLayout.centerPosition;
      if (from != null) {
        edges.add(
          GraphLayoutEdge(
            from: center,
            to: from,
            relationship: edge.relationship,
          ),
        );
      } else if (to != null) {
        edges.add(
          GraphLayoutEdge(
            from: center,
            to: to,
            relationship: edge.relationship,
          ),
        );
      }
    }

    return MemoryGraphLayout(
      centerLabel: widget.baseLayout.centerLabel,
      centerPosition: widget.baseLayout.centerPosition,
      nodes: nodes,
      edges: edges,
      canvasSize: widget.baseLayout.canvasSize,
    );
  }

  void _emitLayout() {
    final size = widget.baseLayout.canvasSize;
    final translation = _transformController.value.getTranslation();
    final scale = _transformController.value.getMaxScaleOnAxis();
    widget.onLayoutChanged(
      GraphLayout(
        positions: _physics.positions.entries
            .map(
              (entry) => GraphLayoutPosition(
                nodeId: entry.key,
                x: (entry.value.dx / size.width).clamp(0.0, 1.0),
                y: (entry.value.dy / size.height).clamp(0.0, 1.0),
              ),
            )
            .toList(),
        panX: translation.x,
        panY: translation.y,
        scale: scale.clamp(0.5, 3.0),
      ),
    );
  }

  void _onNodePanStart(String nodeId) {
    _physicsActive = false;
    _physics.setDragPosition(
      nodeId,
      _physics.positions[nodeId] ?? Offset.zero,
    );
  }

  void _onNodePanUpdate(String nodeId, DragUpdateDetails details) {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final current = _physics.positions[nodeId] ?? Offset.zero;
    _physics.setDragPosition(nodeId, current + details.delta / scale);
    setState(() => _renderLayout = _layoutFromPhysics());
  }

  void _onNodePanEnd(String nodeId) {
    _physics.endDrag(nodeId);
    _physicsActive = true;
    _lastTick = Duration.zero;
    _emitLayout();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodeRadius = GraphTokens.nodeRadius * widget.scale;
    final computed = _renderLayout;

    WidgetsBinding.instance.addPostFrameCallback((_) => _applySavedViewport());

    return InteractiveViewer(
      transformationController: _transformController,
      minScale: 0.85,
      maxScale: 1.8,
      boundaryMargin: const EdgeInsets.all(80),
      onInteractionEnd: (_) => _emitLayout(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          if (_physics.draggingId != null) return;
          final hit = computed.hitTest(details.localPosition, nodeRadius);
          if (hit != null) widget.onNodeTap(hit.node);
        },
        child: SizedBox(
          width: computed.canvasSize.width,
          height: computed.canvasSize.height,
          child: CustomPaint(
            painter: _MemoryGraphPainter(layout: computed, scale: widget.scale),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: computed.centerPosition.dx - 60 * widget.scale,
                  top: computed.centerPosition.dy - 14 * widget.scale,
                  width: 120 * widget.scale,
                  child: Text(
                    computed.centerLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.dosis(
                      size: 18 * widget.scale,
                      weight: FontWeight.w600,
                      color: AppColors.headline,
                    ),
                  ),
                ),
                for (final item in computed.nodes) ...[
                  if (item.isHighlighted)
                    Positioned(
                      left: item.position.dx - 72 * widget.scale,
                      top: item.position.dy - nodeRadius - 54 * widget.scale,
                      width: 144 * widget.scale,
                      child: _NewMemoryBadge(
                        scale: widget.scale,
                        title: item.node.title,
                      ),
                    ),
                  Positioned(
                    left: item.position.dx - nodeRadius,
                    top: item.position.dy - nodeRadius,
                    child: GestureDetector(
                      onPanStart: (_) => _onNodePanStart(item.node.id),
                      onPanUpdate: (details) =>
                          _onNodePanUpdate(item.node.id, details),
                      onPanEnd: (_) => _onNodePanEnd(item.node.id),
                      onPanCancel: () => _onNodePanEnd(item.node.id),
                      child: _GraphNodeDot(
                        radius: nodeRadius,
                        highlighted: item.isHighlighted,
                        dragging: _physics.draggingId == item.node.id,
                      ),
                    ),
                  ),
                  Positioned(
                    left: item.position.dx - 56 * widget.scale,
                    top: item.position.dy + nodeRadius + 6 * widget.scale,
                    width: 112 * widget.scale,
                    child: IgnorePointer(
                      child: Text(
                        item.node.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(
                          size: 13 * widget.scale,
                          weight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewMemoryBadge extends StatelessWidget {
  const _NewMemoryBadge({required this.scale, required this.title});

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: GraphTokens.newMemoryBadge,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        children: [
          Text(
            'New Memory',
            style: AppTypography.vazirmatn(
              size: 11 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.dosis(
              size: 14 * scale,
              weight: FontWeight.w700,
              color: AppColors.headline,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphNodeDot extends StatelessWidget {
  const _GraphNodeDot({
    required this.radius,
    required this.highlighted,
    required this.dragging,
  });

  final double radius;
  final bool highlighted;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.12 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: highlighted ? AppColors.headline : GraphTokens.nodeFill,
          border: dragging
              ? Border.all(color: AppColors.accent, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dragging ? 0.22 : 0.12),
              blurRadius: radius * (dragging ? 0.55 : 0.4),
              offset: Offset(0, radius * 0.15),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryGraphPainter extends CustomPainter {
  _MemoryGraphPainter({required this.layout, required this.scale});

  final MemoryGraphLayout layout;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = GraphTokens.edge
      ..strokeWidth = 1.2 * scale
      ..style = PaintingStyle.stroke;

    for (final edge in layout.edges) {
      canvas.drawLine(edge.from, edge.to, edgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MemoryGraphPainter oldDelegate) =>
      oldDelegate.layout != layout || oldDelegate.scale != scale;
}
