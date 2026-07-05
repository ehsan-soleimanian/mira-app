import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class CanvasWorkspaceScreen extends StatefulWidget {
  const CanvasWorkspaceScreen({super.key});

  @override
  State<CanvasWorkspaceScreen> createState() => _CanvasWorkspaceScreenState();
}

class _CanvasWorkspaceScreenState extends State<CanvasWorkspaceScreen> {
  static const _boardSize = Size(2600, 1800);

  final _transform = TransformationController();
  Timer? _saveDebounce;
  CanvasDto? _canvas;
  var _nodes = <_CanvasNode>[];
  var _edges = <Map<String, dynamic>>[];
  var _loading = true;
  var _saving = false;
  var _dirty = false;
  String? _error;
  int _localSeed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCanvas());
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _transform.dispose();
    super.dispose();
  }

  Future<void> _loadCanvas() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = AppScope.servicesOf(context).canvasRepository;
      final canvases = await repo.list();
      var canvas = canvases.isEmpty
          ? await repo.create(title: l10n.canvasDefaultTitle)
          : canvases.first;
      if (canvas.nodes.isEmpty) {
        final starterNodes = _starterNodes(l10n);
        canvas = await repo.update(
          canvas.id,
          nodes: starterNodes.map((node) => node.toJson()).toList(),
          edges: const [],
          viewport: _viewportJson(),
        );
      }
      if (!mounted) return;
      _applyCanvas(canvas);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.canvasLoadFailed;
      });
    }
  }

  void _applyCanvas(CanvasDto canvas) {
    final nodes = canvas.nodes.map(_CanvasNode.fromJson).toList();
    final maxSeed = nodes
        .map((node) => int.tryParse(node.id.replaceFirst('local-', '')) ?? 0)
        .fold<int>(0, math.max);
    _localSeed = math.max(_localSeed, maxSeed);
    _restoreViewport(canvas.viewport);
    setState(() {
      _canvas = canvas;
      _nodes = nodes;
      _edges = canvas.edges;
      _loading = false;
      _saving = false;
      _dirty = false;
    });
  }

  void _restoreViewport(Map<String, dynamic> viewport) {
    final x = (viewport['x'] as num?)?.toDouble() ?? -80.0;
    final y = (viewport['y'] as num?)?.toDouble() ?? -60.0;
    final scale = (viewport['scale'] as num?)?.toDouble() ?? 0.86;
    final matrix = Matrix4.identity();
    final nextScale = scale.clamp(0.4, 2.2).toDouble();
    matrix.storage[0] = nextScale;
    matrix.storage[5] = nextScale;
    matrix.storage[12] = x;
    matrix.storage[13] = y;
    _transform.value = matrix;
  }

  Map<String, dynamic> _viewportJson() {
    final matrix = _transform.value;
    return {
      'schemaVersion': 'canvas.v1',
      'x': matrix.storage[12],
      'y': matrix.storage[13],
      'scale': matrix.getMaxScaleOnAxis(),
    };
  }

  List<_CanvasNode> _starterNodes(AppLocalizations l10n) => [
    _CanvasNode(
      id: _nextId(),
      type: _CanvasNodeType.sticky,
      x: 260,
      y: 210,
      width: 210,
      height: 150,
      text: l10n.canvasStarterSticky,
      color: const Color(0xFFFFF1A8),
    ),
    _CanvasNode(
      id: _nextId(),
      type: _CanvasNodeType.text,
      x: 530,
      y: 230,
      width: 260,
      height: 130,
      text: l10n.canvasStarterText,
      color: Colors.white,
    ),
    _CanvasNode(
      id: _nextId(),
      type: _CanvasNodeType.shape,
      x: 410,
      y: 430,
      width: 220,
      height: 110,
      text: l10n.canvasStarterShape,
      color: const Color(0xFFEAF0FF),
    ),
  ];

  String _nextId() {
    _localSeed += 1;
    return 'local-$_localSeed';
  }

  void _openGraph() {
    Navigator.of(context).pushMira((_) => const MemoryGraphScreen());
  }

  void _addNode(_CanvasNode node) {
    setState(() => _nodes = [..._nodes, node]);
    _markDirty();
  }

  Offset _nextNodeOffset() {
    final step = (_nodes.length % 8) * 32.0;
    return Offset(300 + step, 250 + step);
  }

  void _addSticky() {
    final l10n = AppLocalizations.of(context)!;
    final offset = _nextNodeOffset();
    _addNode(
      _CanvasNode(
        id: _nextId(),
        type: _CanvasNodeType.sticky,
        x: offset.dx,
        y: offset.dy,
        width: 210,
        height: 150,
        text: l10n.canvasNewSticky,
        color: const Color(0xFFFFF1A8),
      ),
    );
  }

  void _addText() {
    final l10n = AppLocalizations.of(context)!;
    final offset = _nextNodeOffset();
    _addNode(
      _CanvasNode(
        id: _nextId(),
        type: _CanvasNodeType.text,
        x: offset.dx,
        y: offset.dy,
        width: 260,
        height: 128,
        text: l10n.canvasNewText,
        color: Colors.white,
      ),
    );
  }

  void _addShape() {
    final l10n = AppLocalizations.of(context)!;
    final offset = _nextNodeOffset();
    _addNode(
      _CanvasNode(
        id: _nextId(),
        type: _CanvasNodeType.shape,
        x: offset.dx,
        y: offset.dy,
        width: 220,
        height: 110,
        text: l10n.canvasNewShape,
        color: const Color(0xFFEAF0FF),
      ),
    );
  }

  void _addArrow() {
    final offset = _nextNodeOffset();
    _addNode(
      _CanvasNode(
        id: _nextId(),
        type: _CanvasNodeType.arrow,
        x: offset.dx,
        y: offset.dy,
        width: 230,
        height: 90,
        text: '',
        color: AppColors.accent,
      ),
    );
  }

  Future<void> _pickLibraryItem() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.servicesOf(context).libraryRepository;
    final items = await repo.list();
    if (!mounted) return;
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.canvasLibraryEmpty)));
      return;
    }
    final selected = await showModalBottomSheet<LibraryItem>(
      context: context,
      showDragHandle: true,
      builder: (context) => _LibraryPickerSheet(items: items),
    );
    if (selected == null) return;
    final offset = _nextNodeOffset();
    _addNode(
      _CanvasNode(
        id: _nextId(),
        type: _CanvasNodeType.library,
        x: offset.dx,
        y: offset.dy,
        width: 280,
        height: 148,
        text: selected.title,
        color: const Color(0xFFF7F8FC),
        metadata: {
          'itemId': selected.id,
          'itemType': selected.type,
          'summary': selected.summary,
          'source': selected.source,
          'extractionStatus': selected.extractionStatus,
          if (selected.thumbnailUrl != null)
            'thumbnailUrl': selected.thumbnailUrl,
          if (selected.mediaMetadata['duration_seconds'] != null)
            'durationSeconds': selected.mediaMetadata['duration_seconds'],
          if (selected.sourceUrl != null) 'sourceUrl': selected.sourceUrl,
        },
      ),
    );
  }

  void _moveNode(String id, Offset delta) {
    final scale = _transform.value.getMaxScaleOnAxis().clamp(0.4, 2.4);
    setState(() {
      _nodes = [
        for (final node in _nodes)
          if (node.id == id)
            node.copyWith(
              x: (node.x + delta.dx / scale)
                  .clamp(0, _boardSize.width - 80)
                  .toDouble(),
              y: (node.y + delta.dy / scale)
                  .clamp(0, _boardSize.height - 60)
                  .toDouble(),
            )
          else
            node,
      ];
    });
    _markDirty();
  }

  Future<void> _editNode(_CanvasNode node) async {
    final next = await showModalBottomSheet<_NodeEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _NodeEditSheet(node: node),
    );
    if (next == null) return;
    if (next.delete) {
      setState(
        () => _nodes = _nodes.where((item) => item.id != node.id).toList(),
      );
    } else if (next.node != null) {
      _replaceNode(next.node!);
    }
    _markDirty();
  }

  void _replaceNode(_CanvasNode next) {
    setState(() {
      _nodes = [
        for (final node in _nodes)
          if (node.id == next.id) next else node,
      ];
    });
  }

  void _markDirty() {
    if (_canvas == null) return;
    setState(() => _dirty = true);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_saveCanvas());
    });
  }

  Future<void> _saveCanvas() async {
    final canvas = _canvas;
    if (canvas == null) return;
    setState(() => _saving = true);
    try {
      final next = await AppScope.servicesOf(context).canvasRepository.update(
        canvas.id,
        nodes: _nodes.map((node) => node.toJson()).toList(),
        edges: _edges,
        viewport: _viewportJson(),
      );
      if (!mounted) return;
      setState(() {
        _canvas = next;
        _saving = false;
        _dirty = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.canvasSaveFailed)),
      );
    }
  }

  Future<void> _newCanvas() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    final repo = AppScope.servicesOf(context).canvasRepository;
    final canvas = await repo.create(title: l10n.canvasDefaultTitle);
    final starterNodes = _starterNodes(l10n);
    final saved = await repo.update(
      canvas.id,
      nodes: starterNodes.map((node) => node.toJson()).toList(),
      edges: const [],
      viewport: _viewportJson(),
    );
    if (mounted) _applyCanvas(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: _CanvasHeader(
            title: _canvas?.title ?? l10n.canvasTitle,
            saving: _saving,
            dirty: _dirty,
            onGraph: _openGraph,
            onNewCanvas: () => unawaited(_newCanvas()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: _CanvasToolbar(
            onSticky: _addSticky,
            onText: _addText,
            onLibrary: () => unawaited(_pickLibraryItem()),
            onShape: _addShape,
            onArrow: _addArrow,
            onSave: () => unawaited(_saveCanvas()),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 118),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: const Color(0xFFE7E7EF)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _buildBoard(l10n),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _CanvasMessage(
        icon: Icons.cloud_off_rounded,
        title: _error!,
        actionLabel: l10n.canvasRetry,
        onAction: () => unawaited(_loadCanvas()),
      );
    }
    return InteractiveViewer(
      transformationController: _transform,
      boundaryMargin: const EdgeInsets.all(900),
      minScale: 0.45,
      maxScale: 2.2,
      constrained: false,
      onInteractionEnd: (_) => _markDirty(),
      child: SizedBox(
        width: _boardSize.width,
        height: _boardSize.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            for (final node in _nodes)
              _CanvasNodeWidget(
                key: ValueKey(node.id),
                node: node,
                onDrag: (delta) => _moveNode(node.id, delta),
                onEdit: () => unawaited(_editNode(node)),
              ),
          ],
        ),
      ),
    );
  }
}

class _CanvasHeader extends StatelessWidget {
  const _CanvasHeader({
    required this.title,
    required this.saving,
    required this.dirty,
    required this.onGraph,
    required this.onNewCanvas,
  });

  final String title;
  final bool saving;
  final bool dirty;
  final VoidCallback onGraph;
  final VoidCallback onNewCanvas;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = saving
        ? l10n.canvasSaving
        : dirty
        ? l10n.canvasUnsaved
        : l10n.canvasSaved;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(size: 28, weight: FontWeight.w700),
              ),
              Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(
                  size: 13,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.canvasNewBoard,
          onPressed: onNewCanvas,
          icon: const Icon(Icons.add_box_outlined),
        ),
        IconButton(
          tooltip: l10n.canvasOpenGraph,
          onPressed: onGraph,
          icon: const Icon(Icons.account_tree_outlined),
        ),
      ],
    );
  }
}

class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({
    required this.onSticky,
    required this.onText,
    required this.onLibrary,
    required this.onShape,
    required this.onArrow,
    required this.onSave,
  });

  final VoidCallback onSticky;
  final VoidCallback onText;
  final VoidCallback onLibrary;
  final VoidCallback onShape;
  final VoidCallback onArrow;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ToolButton(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.canvasToolSticky,
            onTap: onSticky,
          ),
          _ToolButton(
            icon: Icons.text_fields_rounded,
            label: l10n.canvasToolText,
            onTap: onText,
          ),
          _ToolButton(
            icon: Icons.inventory_2_outlined,
            label: l10n.canvasToolLibrary,
            onTap: onLibrary,
          ),
          _ToolButton(
            icon: Icons.crop_square_rounded,
            label: l10n.canvasToolShape,
            onTap: onShape,
          ),
          _ToolButton(
            icon: Icons.arrow_right_alt_rounded,
            label: l10n.canvasToolArrow,
            onTap: onArrow,
          ),
          _ToolButton(
            icon: Icons.save_outlined,
            label: l10n.canvasToolSave,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.dosis(size: 13, weight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: Color(0xFFE1E4EE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _CanvasNodeWidget extends StatelessWidget {
  const _CanvasNodeWidget({
    super.key,
    required this.node,
    required this.onDrag,
    required this.onEdit,
  });

  final _CanvasNode node;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.x,
      top: node.y,
      width: node.width,
      height: node.height,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        onTap: onEdit,
        child: node.type == _CanvasNodeType.arrow
            ? CustomPaint(painter: _ArrowNodePainter(node.color))
            : _NodeCard(node: node),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node});

  final _CanvasNode node;

  @override
  Widget build(BuildContext context) {
    final isLibrary = node.type == _CanvasNodeType.library ||
        node.type == _CanvasNodeType.libraryItem ||
        node.type == _CanvasNodeType.chunkReference ||
        node.type == _CanvasNodeType.annotation ||
        node.type == _CanvasNodeType.embed;
    final isShape = node.type == _CanvasNodeType.shape;
    final summary = node.metadata['summary']?.toString() ?? '';
    final thumbnailUrl = node.metadata['thumbnailUrl']?.toString();
    final status = node.metadata['extractionStatus']?.toString();
    return Container(
      padding: EdgeInsets.all(isShape ? 14 : 12),
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(isShape ? 999 : 14),
        border: Border.all(
          color: isLibrary ? const Color(0xFFD7DEF5) : const Color(0x22000000),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLibrary
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnailUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.accent,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (status != null && status.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.dosis(size: 11).copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (node.metadata['locator'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          node.metadata['locator'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.dosis(size: 11).copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(size: 12).copyWith(
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                node.text,
                maxLines: isShape ? 2 : 6,
                overflow: TextOverflow.ellipsis,
                textAlign: isShape ? TextAlign.center : TextAlign.start,
                style: AppTypography.dosis(
                  size: node.type == _CanvasNodeType.text ? 18 : 16,
                  weight: isShape ? FontWeight.w700 : FontWeight.w600,
                ).copyWith(height: 1.15, color: _textColorFor(node.color)),
              ),
            ),
    );
  }

  Color _textColorFor(Color color) {
    return color.computeLuminance() < 0.35
        ? Colors.white
        : AppColors.textPrimary;
  }
}

class _NodeEditSheet extends StatefulWidget {
  const _NodeEditSheet({required this.node});

  final _CanvasNode node;

  @override
  State<_NodeEditSheet> createState() => _NodeEditSheetState();
}

class _NodeEditSheetState extends State<_NodeEditSheet> {
  late final TextEditingController _controller;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.text);
    _color = widget.node.color;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.canvasEditNode,
            style: AppTypography.dosis(size: 22, weight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (widget.node.type != _CanvasNodeType.arrow)
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.canvasNodeTextHint,
                filled: true,
                fillColor: const Color(0xFFF7F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final color in _nodeColors)
                GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color.toARGB32() == color.toARGB32()
                            ? AppColors.accent
                            : const Color(0xFFE1E4EE),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(_NodeEditResult.delete()),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.canvasDeleteNode),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    _NodeEditResult.update(
                      widget.node.copyWith(
                        text: _controller.text.trim().isEmpty
                            ? widget.node.text
                            : _controller.text.trim(),
                        color: _color,
                      ),
                    ),
                  );
                },
                child: Text(l10n.canvasApply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibraryPickerSheet extends StatelessWidget {
  const _LibraryPickerSheet({required this.items});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            l10n.canvasLibraryPickerTitle,
            style: AppTypography.dosis(size: 22, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final item in items.take(24))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.dosis(size: 16, weight: FontWeight.w700),
              ),
              subtitle: Text(
                item.summary.isEmpty ? item.source : item.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).pop(item),
            ),
        ],
      ),
    );
  }
}

class _CanvasMessage extends StatelessWidget {
  const _CanvasMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDEDF4)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowNodePainter extends CustomPainter {
  const _ArrowNodePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(12, size.height * 0.62);
    final end = Offset(size.width - 18, size.height * 0.35);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowSize = 16.0;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - math.pi / 7),
        end.dy - arrowSize * math.sin(angle - math.pi / 7),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + math.pi / 7),
        end.dy - arrowSize * math.sin(angle + math.pi / 7),
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowNodePainter oldDelegate) =>
      oldDelegate.color != color;
}

enum _CanvasNodeType {
  sticky,
  text,
  library,
  libraryItem,
  chunkReference,
  annotation,
  embed,
  shape,
  arrow,
}

class _CanvasNode {
  const _CanvasNode({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.text,
    required this.color,
    this.metadata = const {},
  });

  factory _CanvasNode.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString();
    return _CanvasNode(
      id: json['id']?.toString() ?? 'local-0',
      type: _nodeTypeFromWire(rawType),
      x: (json['x'] as num?)?.toDouble() ?? 120,
      y: (json['y'] as num?)?.toDouble() ?? 120,
      width: (json['width'] as num?)?.toDouble() ?? 210,
      height: (json['height'] as num?)?.toDouble() ?? 140,
      text: json['text']?.toString() ?? '',
      color: _colorFromInt((json['color'] as int?) ?? 0xFFFFFFFF),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  final String id;
  final _CanvasNodeType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final String text;
  final Color color;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': _nodeTypeToWire(type),
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'text': text,
    'color': color.toARGB32(),
    'metadata': metadata,
  };

  _CanvasNode copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    String? text,
    Color? color,
    Map<String, dynamic>? metadata,
  }) {
    return _CanvasNode(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
    );
  }
}

class _NodeEditResult {
  const _NodeEditResult({this.node, this.delete = false});

  factory _NodeEditResult.update(_CanvasNode node) =>
      _NodeEditResult(node: node);

  factory _NodeEditResult.delete() => const _NodeEditResult(delete: true);

  final _CanvasNode? node;
  final bool delete;
}

const _nodeColors = [
  Color(0xFFFFF1A8),
  Color(0xFFEAF0FF),
  Color(0xFFE9F8F2),
  Color(0xFFFFE8D9),
  Color(0xFFF7F8FC),
  Color(0xFF1A1C29),
];

Color _colorFromInt(int value) {
  return Color.fromARGB(
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  );
}

_CanvasNodeType _nodeTypeFromWire(String? value) {
  switch (value) {
    case 'library_item':
      return _CanvasNodeType.libraryItem;
    case 'chunk_reference':
      return _CanvasNodeType.chunkReference;
    case 'annotation':
      return _CanvasNodeType.annotation;
    case 'embed':
      return _CanvasNodeType.embed;
    default:
      return _CanvasNodeType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => _CanvasNodeType.sticky,
      );
  }
}

String _nodeTypeToWire(_CanvasNodeType type) {
  switch (type) {
    case _CanvasNodeType.library:
    case _CanvasNodeType.libraryItem:
      return 'library_item';
    case _CanvasNodeType.chunkReference:
      return 'chunk_reference';
    case _CanvasNodeType.annotation:
      return 'annotation';
    case _CanvasNodeType.embed:
      return 'embed';
    default:
      return type.name;
  }
}
