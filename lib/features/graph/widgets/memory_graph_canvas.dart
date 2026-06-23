import 'package:flutter/material.dart';
import 'package:mira_app/features/graph/graph_layout.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/graph_tokens.dart';

/// Paints nodes + edges and handles tap hit-testing on the radial layout.
class MemoryGraphCanvas extends StatelessWidget {
  const MemoryGraphCanvas({
    super.key,
    required this.layout,
    required this.scale,
    required this.onNodeTap,
  });

  final MemoryGraphLayout layout;
  final double scale;
  final ValueChanged<GraphNode> onNodeTap;

  @override
  Widget build(BuildContext context) {
    final nodeRadius = GraphTokens.nodeRadius * scale;
    final computed = layout;

    return InteractiveViewer(
      minScale: 0.85,
      maxScale: 1.8,
      boundaryMargin: const EdgeInsets.all(80),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final hit = computed.hitTest(details.localPosition, nodeRadius);
          if (hit != null) onNodeTap(hit.node);
        },
        child: SizedBox(
          width: computed.canvasSize.width,
          height: computed.canvasSize.height,
          child: CustomPaint(
            painter: _MemoryGraphPainter(layout: computed, scale: scale),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: computed.centerPosition.dx - 60 * scale,
                  top: computed.centerPosition.dy - 14 * scale,
                  width: 120 * scale,
                  child: Text(
                    computed.centerLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.dosis(
                      size: 18 * scale,
                      weight: FontWeight.w600,
                      color: AppColors.headline,
                    ),
                  ),
                ),
                for (final item in computed.nodes) ...[
                  if (item.isHighlighted)
                    Positioned(
                      left: item.position.dx - 72 * scale,
                      top: item.position.dy - nodeRadius - 54 * scale,
                      width: 144 * scale,
                      child: _NewMemoryBadge(scale: scale, title: item.node.title),
                    ),
                  Positioned(
                    left: item.position.dx - nodeRadius,
                    top: item.position.dy - nodeRadius,
                    child: _GraphNodeDot(
                      radius: nodeRadius,
                      highlighted: item.isHighlighted,
                    ),
                  ),
                  Positioned(
                    left: item.position.dx - 56 * scale,
                    top: item.position.dy + nodeRadius + 6 * scale,
                    width: 112 * scale,
                    child: Text(
                      item.node.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 13 * scale,
                        weight: FontWeight.w500,
                        color: AppColors.accent,
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
  const _GraphNodeDot({required this.radius, required this.highlighted});

  final double radius;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? AppColors.headline : GraphTokens.nodeFill,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: radius * 0.4,
            offset: Offset(0, radius * 0.15),
          ),
        ],
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
