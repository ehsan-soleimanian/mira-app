import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class CanvasWorkspaceScreen extends StatefulWidget {
  const CanvasWorkspaceScreen({super.key});

  @override
  State<CanvasWorkspaceScreen> createState() => _CanvasWorkspaceScreenState();
}

class _CanvasWorkspaceScreenState extends State<CanvasWorkspaceScreen> {
  CanvasDto? _canvas;
  var _creating = false;

  Future<void> _createCanvas() async {
    setState(() => _creating = true);
    final canvas = await AppScope.servicesOf(context).canvasRepository.create();
    if (!mounted) return;
    setState(() {
      _canvas = canvas;
      _creating = false;
    });
  }

  void _openGraph() {
    Navigator.of(context).pushMira((_) => const MemoryGraphScreen());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Canvas & Graph',
                style: AppTypography.dosis(size: 28, weight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Open graph',
              onPressed: _openGraph,
              icon: const Icon(Icons.account_tree_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 360,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E7EF)),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.dashboard_customize_outlined, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      _canvas?.title ?? 'Visual thinking board',
                      style: AppTypography.dosis(
                        size: 20,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag library objects here in the next iteration. v1 stores canvas nodes and keeps graph one tap away.',
                      textAlign: TextAlign.center,
                      style: AppTypography.dosis(
                        size: 14,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _creating
                          ? null
                          : () => unawaited(_createCanvas()),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(_canvas == null ? 'Create canvas' : 'Saved'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDEDF4)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
