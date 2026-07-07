import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mira_app/features/graph/graph_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/graph_tokens.dart';

/// Blurred overlay + bottom sheet with node memories and mutation actions.
class GraphNodeDetailSheet extends StatefulWidget {
  const GraphNodeDetailSheet({
    super.key,
    required this.node,
    required this.related,
    required this.scale,
    required this.repository,
    this.onChanged,
  });

  final GraphNode node;
  final List<GraphNode> related;
  final double scale;
  final GraphRepository repository;
  final VoidCallback? onChanged;

  static Future<void> show(
    BuildContext context, {
    required GraphNode node,
    required List<GraphNode> related,
    required double scale,
    required GraphRepository repository,
    VoidCallback? onChanged,
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
          repository: repository,
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  State<GraphNodeDetailSheet> createState() => _GraphNodeDetailSheetState();
}

class _GraphNodeDetailSheetState extends State<GraphNodeDetailSheet> {
  var _busy = false;
  Map<String, dynamic>? _entityDetail;

  @override
  void initState() {
    super.initState();
    if (_isEntity) {
      _loadEntityDetail();
    }
  }

  bool get _isTask => widget.node.kind.toUpperCase() == 'TASK';

  bool get _isCapture => widget.node.kind.toUpperCase() == 'CAPTURE';

  bool get _isEntity => widget.node.kind.toUpperCase() == 'ENTITY';

  String? get _captureId => _isCapture ? widget.node.id : widget.node.captureId;

  Future<void> _loadEntityDetail() async {
    try {
      final detail = await widget.repository.fetchEntityDetail(widget.node.id);
      if (!mounted) return;
      setState(() => _entityDetail = detail);
    } catch (_) {
      // Entity detail is optional enrichment.
    }
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
      if (!mounted) return;
      widget.onChanged?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.graphMutationSuccess)));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.graphMutationFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markTaskDone() => _runMutation(
    () => widget.repository.updateTaskStatus(widget.node.id, 'DONE'),
  );

  Future<void> _cancelTask() => _runMutation(
    () => widget.repository.updateTaskStatus(widget.node.id, 'CANCELLED'),
  );

  Future<void> _deleteCapture() async {
    final captureId = _captureId;
    if (captureId == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.graphDeleteConfirmTitle),
        content: Text(l10n.graphDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.graphDeleteMemory),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runMutation(() => widget.repository.archiveCapture(captureId));
  }

  Future<void> _editMemory() async {
    final captureId = _captureId;
    if (captureId == null) return;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.node.title);
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.graphEditMemory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.graphCorrectMemoryHint),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: Text(l10n.graphSave),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (saved == null || saved.isEmpty || !mounted) return;

    final trimmed = saved.trim();
    final original = widget.node.title.trim();
    if (trimmed == original) {
      await _runMutation(() async {
        await widget.repository.patchCaptureTitle(captureId, trimmed);
      });
      return;
    }
    await _runMutation(() async {
      await widget.repository.correctCapture(captureId, trimmed);
    });
  }

  Future<void> _rejectAssertion(String assertionId) =>
      _runMutation(() => widget.repository.rejectAssertion(assertionId));

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final l10n = AppLocalizations.of(context)!;
    final relatedCards = widget.related
        .where((item) => item.id != widget.node.id)
        .where(_hasUsefulCardContent)
        .toList();

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.78,
            ),
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
                          widget.node.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.dosis(
                            size: 22 * s,
                            weight: FontWeight.w700,
                            color: AppColors.headline,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, size: 22 * s),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (_isTask && widget.node.status != 'DONE')
                  _ActionRow(
                    scale: s,
                    busy: _busy,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _markTaskDone,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(l10n.graphMarkDone),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      OutlinedButton(
                        onPressed: _busy ? null : _cancelTask,
                        child: Text(l10n.graphCancelTask),
                      ),
                    ],
                  ),
                if (_isCapture)
                  _ActionRow(
                    scale: s,
                    busy: _busy,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _editMemory,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.graphEditMemory),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      IconButton.filledTonal(
                        onPressed: _busy ? null : _deleteCapture,
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: l10n.graphDeleteMemory,
                      ),
                    ],
                  ),
                if (_entityDetail != null)
                  _EntityAssertionsPanel(
                    scale: s,
                    detail: _entityDetail!,
                    busy: _busy,
                    onReject: _rejectAssertion,
                    rejectLabel: l10n.graphRejectAssertion,
                  ),
                if (relatedCards.isNotEmpty)
                  Flexible(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        20 * s,
                        8 * s,
                        20 * s,
                        24 * s,
                      ),
                      shrinkWrap: true,
                      itemCount: relatedCards.length + 1,
                      separatorBuilder: (_, _) => SizedBox(height: 10 * s),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text(
                            'Connected knowledge',
                            style: AppTypography.dosis(
                              size: 14 * s,
                              weight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          );
                        }
                        final item = relatedCards[index - 1];
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

  bool _hasUsefulCardContent(GraphNode node) =>
      node.title.trim().isNotEmpty || node.summary.trim().isNotEmpty;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.scale,
    required this.busy,
    required this.children,
  });

  final double scale;
  final bool busy;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 8 * scale),
      child: Row(children: children),
    );
  }
}

class _EntityAssertionsPanel extends StatelessWidget {
  const _EntityAssertionsPanel({
    required this.scale,
    required this.detail,
    required this.busy,
    required this.onReject,
    required this.rejectLabel,
  });

  final double scale;
  final Map<String, dynamic> detail;
  final bool busy;
  final Future<void> Function(String assertionId) onReject;
  final String rejectLabel;

  @override
  Widget build(BuildContext context) {
    final assertions = (detail['assertions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    if (assertions.isEmpty) return const SizedBox.shrink();
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 8 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Claims',
            style: AppTypography.dosis(size: 14 * s, weight: FontWeight.w600),
          ),
          SizedBox(height: 6 * s),
          ...assertions.map((a) {
            final id = a['assertionId'] as String? ?? '';
            final predicateKey = a['predicateKey'] as String? ?? '';
            final label = _claimTitle(predicateKey);
            final detail = _claimDetail(a['objectName'] as String?, a['value']);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: AppTypography.vazirmatn(size: 13 * s)),
              subtitle: Text(
                detail ?? predicateKey,
                style: AppTypography.vazirmatn(
                  size: 11 * s,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: TextButton(
                onPressed: busy || id.isEmpty ? null : () => onReject(id),
                child: Text(rejectLabel),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _claimTitle(String predicateKey) {
    switch (predicateKey) {
      case 'personal.role_relation':
        return 'Relationship';
      case 'sports.plays':
        return 'Activity';
      case 'personal.has_age':
        return 'Age';
      case 'personal.can_use':
        return 'Can use';
      case 'work.works_at':
        return 'Works at';
      case 'travel.wants_to_visit':
      case 'travel.plans_trip':
        return 'Travel plan';
      case 'location.located_at':
        return 'Location';
      default:
        return predicateKey
            .replaceAll('.', ' ')
            .replaceAll('_', ' ')
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }

  String? _claimDetail(String? objectName, Object? value) {
    final parts = <String>[];
    if (objectName != null && objectName.trim().isNotEmpty) {
      parts.add(objectName.trim());
    }
    if (value != null && value.toString().trim().isNotEmpty) {
      parts.add(value.toString().trim());
    }
    return parts.isEmpty ? null : parts.join(' - ');
  }
}

class _GraphNodeDetailOverlay extends StatelessWidget {
  const _GraphNodeDetailOverlay({
    required this.animation,
    required this.node,
    required this.related,
    required this.scale,
    required this.repository,
    this.onChanged,
  });

  final Animation<double> animation;
  final GraphNode node;
  final List<GraphNode> related;
  final double scale;
  final GraphRepository repository;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

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
                    repository: repository,
                    onChanged: onChanged,
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
          if (widget.node.title.trim().isNotEmpty) ...[
            Text(
              widget.node.title.trim(),
              style: AppTypography.dosis(
                size: 16 * s,
                weight: FontWeight.w700,
                color: AppColors.headline,
              ),
            ),
            SizedBox(height: 8 * s),
          ],
          if (summary.isNotEmpty)
            Text(
              _expanded || !canExpand
                  ? summary
                  : '${summary.substring(0, 120)}…',
              style: AppTypography.vazirmatn(
                size: 15 * s,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          if (summary.isNotEmpty) SizedBox(height: 14 * s),
          Row(
            children: [
              if (widget.node.nodeType.trim().isNotEmpty)
                _MetaChip(label: widget.node.nodeType, scale: s),
              if (widget.node.status != null && widget.node.status!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.node.nodeType.trim().isEmpty ? 0 : 6 * s,
                  ),
                  child: _MetaChip(label: widget.node.status!, scale: s),
                ),
              if (widget.node.createdAt != null) ...[
                if (widget.node.status != null ||
                    widget.node.nodeType.trim().isNotEmpty)
                  SizedBox(width: 8 * s),
                Text(
                  _formatDate(widget.node.createdAt!),
                  style: AppTypography.vazirmatn(
                    size: 13 * s,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.vazirmatn(size: 11 * s, color: AppColors.accent),
      ),
    );
  }
}
