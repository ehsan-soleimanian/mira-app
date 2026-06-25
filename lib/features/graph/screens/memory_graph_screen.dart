import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/features/auth/auth_gate.dart';
import 'package:mira_app/features/graph/graph_layout.dart';
import 'package:mira_app/features/graph/graph_layout_models.dart';
import 'package:mira_app/features/graph/graph_repository.dart';
import 'package:mira_app/features/graph/widgets/graph_node_detail_sheet.dart';
import 'package:mira_app/features/graph/widgets/memory_graph_canvas.dart';
import 'package:mira_app/features/graph_v2/widgets/graph_view_mode_switcher.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Full-screen radial knowledge graph — `GET /v2/graph`.
class MemoryGraphScreen extends StatefulWidget {
  const MemoryGraphScreen({
    super.key,
    this.highlightNodeId,
    this.title = 'Memory added',
    this.subtitle = 'Mira connected it to your mind.',
  });

  final String? highlightNodeId;
  final String title;
  final String subtitle;

  @override
  State<MemoryGraphScreen> createState() => _MemoryGraphScreenState();
}

class _MemoryGraphScreenState extends State<MemoryGraphScreen> {
  GraphRepository? _repository;
  GraphResponse? _graph;
  GraphViewMode _viewMode = GraphViewMode.knowledge;
  Object? _error;
  String? _errorMessage;
  var _loading = true;
  Timer? _layoutSaveTimer;
  var _layoutSaveInFlight = false;

  @override
  void dispose() {
    _layoutSaveTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository ??= AppScope.servicesOf(context).graphRepository;
    if (_graph == null && _loading && _error == null) {
      _loadGraph();
    }
  }

  Future<void> _loadGraph() async {
    setState(() {
      _loading = true;
      _error = null;
      _errorMessage = null;
    });
    try {
      final graph = await _repository!.fetchGraph(view: _viewMode);
      if (!mounted) return;
      setState(() {
        _graph = graph;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final message = _formatGraphLoadError(error);
      setState(() {
        _error = error;
        _errorMessage = message;
        _loading = false;
      });
    }
  }

  String _formatGraphLoadError(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 401) {
        return 'جلسه شما منقضی شده. لطفاً دوباره وارد شوید.';
      }
      final detail = error.response?.data;
      if (detail is Map && detail['detail'] != null) {
        return detail['detail'].toString();
      }
      if (code != null) {
        return 'خطا در دریافت گراف (HTTP $code).';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'اتصال به سرور برقرار نشد. اینترنت/آدرس API را بررسی کنید.';
      }
    }
    return 'Could not load memory graph';
  }

  Future<void> _logoutAndGoToAuth() async {
    final services = AppScope.servicesOf(context);
    await services.authRepository.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  void _scheduleLayoutSave(GraphLayout layout) {
    _layoutSaveTimer?.cancel();
    _layoutSaveTimer = Timer(const Duration(seconds: 2), () => _persistLayout(layout));
  }

  Future<void> _persistLayout(GraphLayout layout) async {
    if (_layoutSaveInFlight) return;
    _layoutSaveInFlight = true;
    try {
      await _repository!.saveLayout(layout);
    } catch (_) {
      // Best-effort — layout restores on next successful fetch.
    } finally {
      _layoutSaveInFlight = false;
    }
  }

  List<GraphNode> _relatedNodes(GraphNode node) {
    final graph = _graph;
    if (graph == null) return const [];
    final neighborIds = <String>{};
    for (final edge in graph.edges) {
      if (edge.sourceId == node.id) neighborIds.add(edge.targetId);
      if (edge.targetId == node.id) neighborIds.add(edge.sourceId);
    }
    return graph.nodes.where((item) => neighborIds.contains(item.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = width / HomeScreenTokens.designWidth;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MiraPageHeader(
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.dosis(
                        size: 28 * s,
                        weight: FontWeight.w700,
                        color: AppColors.headline,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.dosis(
                        size: 14 * s,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 8 * s),
                child: GraphViewModeSwitcher(
                  value: _viewMode,
                  scale: s,
                  onChanged: (mode) {
                    if (mode == _viewMode) return;
                    setState(() => _viewMode = mode);
                    _loadGraph();
                  },
                ),
              ),
              Expanded(child: _buildBody(s)),
              if (!_loading && _error == null && (_graph?.nodes.isNotEmpty ?? false))
                _AllSetBanner(scale: s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double s) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      final isUnauthorized = _error is DioException &&
          (_error as DioException).response?.statusCode == 401;
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'Could not load memory graph',
                style: AppTypography.dosis(
                  size: 16 * s,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12 * s),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: _loadGraph, child: const Text('Retry')),
                  if (isUnauthorized) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _logoutAndGoToAuth,
                      child: const Text('Login again'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    final graph = _graph!;
    if (graph.nodes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24 * s),
          child: Text(
            'No approved memories yet.\nSave a capture to grow your graph.',
            textAlign: TextAlign.center,
            style: AppTypography.dosis(
              size: 16 * s,
              height: 1.5,
              color: AppColors.subtitle,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = MemoryGraphLayout.compute(
          graph: graph,
          viewport: Size(constraints.maxWidth, constraints.maxHeight),
          highlightNodeId: widget.highlightNodeId,
        );
        final savedLayout = GraphLayout.fromResponse(graph.layout);
        return MemoryGraphCanvas(
          graph: graph,
          baseLayout: layout,
          savedLayout: savedLayout,
          scale: s,
          onNodeTap: (node) {
            GraphNodeDetailSheet.show(
              context,
              node: node,
              related: _relatedNodes(node),
              scale: s,
              repository: _repository!,
              onChanged: _loadGraph,
            );
          },
          onLayoutChanged: _scheduleLayoutSave,
        );
      },
    );
  }
}

class _AllSetBanner extends StatelessWidget {
  const _AllSetBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 16 * s),
      child: Container(
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: AppColors.hintBarFill,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8 * s),
              ),
              child: Icon(Icons.check_rounded, color: AppColors.accent, size: 18 * s),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All set',
                    style: AppTypography.dosis(
                      size: 16 * s,
                      weight: FontWeight.w700,
                      color: AppColors.headline,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    "It's part of your mind now. You can find it anytime with a simple question.",
                    style: AppTypography.dosis(
                      size: 13 * s,
                      height: 1.4,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
