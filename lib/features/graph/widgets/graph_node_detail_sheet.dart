import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/graph_tokens.dart';

/// Blurred overlay + bottom sheet with node memories (Figma).
class GraphNodeDetailSheet extends StatelessWidget {
  const GraphNodeDetailSheet({
    super.key,
    required this.node,
    required this.related,
    required this.scale,
  });

  final GraphNode node;
  final List<GraphNode> related;
  final double scale;

  static Future<void> show(
    BuildContext context, {
    required GraphNode node,
    required List<GraphNode> related,
    required double scale,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _GraphNodeDetailOverlay(
          animation: animation,
          node: node,
          related: related,
          scale: scale,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cards = [node, ...related.where((item) => item.id != node.id)];

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.72),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 12 * s, 8 * s),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.dosis(
                            size: 22 * s,
                            weight: FontWeight.w700,
                            color: AppColors.headline,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, size: 22 * s),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 24 * s),
                    shrinkWrap: true,
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12 * s),
                    itemBuilder: (context, index) {
                      final item = cards[index];
                      return _MemoryDetailCard(node: item, scale: s);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphNodeDetailOverlay extends StatelessWidget {
  const _GraphNodeDetailOverlay({
    required this.animation,
    required this.node,
    required this.related,
    required this.scale,
  });

  final Animation<double> animation;
  final GraphNode node;
  final List<GraphNode> related;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            FadeTransition(
              opacity: curved,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: GraphTokens.sheetBarrier),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {},
                  child: GraphNodeDetailSheet(
                    node: node,
                    related: related,
                    scale: scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryDetailCard extends StatefulWidget {
  const _MemoryDetailCard({required this.node, required this.scale});

  final GraphNode node;
  final double scale;

  @override
  State<_MemoryDetailCard> createState() => _MemoryDetailCardState();
}

class _MemoryDetailCardState extends State<_MemoryDetailCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final summary = widget.node.summary.trim();
    final canExpand = summary.length > 120;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: GraphTokens.sheetCard,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _expanded || !canExpand ? summary : '${summary.substring(0, 120)}…',
            style: AppTypography.vazirmatn(
              size: 15 * s,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Text(
                widget.node.createdAt != null
                    ? _formatDate(widget.node.createdAt!)
                    : '',
                style: AppTypography.vazirmatn(
                  size: 13 * s,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (canExpand)
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'more',
                        style: AppTypography.dosis(
                          size: 14 * s,
                          weight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20 * s,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}
