import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/workspace/canvas_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Canvas — two ways to see your memory. **Board** is a freeform, pan/zoom
/// surface of loose cards you can drag around and connect; **Map** is Mira's
/// automatic memory graph, where tapping a node centres it, highlights its
/// neighbours, and opens a detail panel. Faithful to `.rd-canvas` /
/// `CanvasScreen` in the design.
class RdCanvasScreen extends StatefulWidget {
  const RdCanvasScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdCanvasScreen> createState() => _RdCanvasScreenState();
}

/// SharedPreferences key holding the id of the last-active board, so the
/// board a user was on is restored on the next launch.
const _kActiveBoardKey = 'mira-board-active';

class _RdCanvasScreenState extends State<RdCanvasScreen> {
  String _mode = 'board';

  /// Live memory graph for Map mode; null → use the designed sample. Loaded
  /// from `graphRepository.fetchGraph` (`/v2/graph`) and laid out client-side.
  List<_GNode>? _mapNodes;
  List<List<String>> _mapEdges = const [];
  List<_ClusterSpec> _clusters = const [];
  String? _mapFocusNodeId;
  String _mapContext = '';
  String _clusterContext = '';
  bool _loaded = false;

  // ── Board (persisted, multi-board) ──────────────────────────────────────
  /// All the user's boards from `canvasRepository.list()`. Empty until loaded.
  List<CanvasDto> _boards = const [];

  /// The active board id (persisted in `_kActiveBoardKey`); null before boards
  /// load or if the user has none yet.
  String? _activeBoardId;

  /// Bumped whenever the active board changes so the `_BoardView` key flips and
  /// its interaction state re-reads the freshly selected board.
  int _boardEpoch = 0;

  /// Bumped whenever the live graph reloads (e.g. after a merge) so the
  /// `_MapView` key flips and its derived adjacency/index rebuild from scratch.
  int _mapEpoch = 0;

  /// Assertions backing each live edge, keyed "a|b" (both directions) — used to
  /// "unlink" a connection by rejecting them.
  Map<String, List<String>> _mapEdgeAssertions = const {};

  /// Board-level context label (title · N cards), reported up from the live
  /// `_BoardView` so the top pill mirrors what's on screen.
  String _boardContext = '';

  bool _boardsLoading = true;

  CanvasDto? get _activeBoard {
    for (final b in _boards) {
      if (b.id == _activeBoardId) return b;
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadGraph();
      _loadBoards();
    }
  }

  Future<void> _loadGraph() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final services = AppScope.servicesOf(context);
      final graph = await services.graphRepository.fetchGraph();
      final (nodes, edges, edgeAssertions) = _mapGraphToNodes(graph, l10n);
      final clusters = _buildClustersFromNodes(nodes, edges, l10n);
      if (!mounted || nodes.isEmpty) return;
      setState(() {
        _mapNodes = nodes;
        _mapEdges = edges;
        _clusters = clusters;
        _mapContext = l10n.rdCanvasMapContext(nodes.length, edges.length);
        _clusterContext = l10n.rdCanvasClusterContext(
          _clusters.length,
          nodes.length,
        );
        _mapEdgeAssertions = edgeAssertions;
        _mapEpoch++; // force the map to rebuild from the fresh graph
      });
    } catch (_) {
      // Backend unreachable — leave the map empty (neutral empty state).
    }
  }

  void _mapToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.rd.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
          ),
        ),
      );
  }

  Future<void> _settleGraphMutation(
    MemoryProjectionReceipt receipt, {
    required String successMessage,
    required String failureMessage,
  }) async {
    var latest = receipt;
    if (latest.isPending) {
      _mapToast(AppLocalizations.of(context)!.rdCanvasSyncPending);
      latest = await AppScope.servicesOf(
        context,
      ).graphRepository.waitForProjection(latest);
    }
    if (!mounted) return;
    if (latest.isApplied) {
      _mapToast(successMessage);
      await _loadGraph();
    } else if (latest.isDead) {
      _mapToast(failureMessage);
    }
  }

  /// Merges [sourceId] into [targetId] on the real knowledge graph, then reloads
  /// so the absorbed node disappears. Best-effort with a toast either way.
  Future<void> _mergeEntities(String sourceId, String targetId) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = AppScope.servicesOf(context).graphRepository;
    try {
      final receipt = await repository.mergeEntities(
        sourceId: sourceId,
        targetId: targetId,
      );
      await _settleGraphMutation(
        receipt,
        successMessage: l10n.rdCanvasMergeSuccess,
        failureMessage: l10n.rdCanvasMergeFail,
      );
    } catch (_) {
      _mapToast(l10n.rdCanvasMergeFail);
    }
  }

  /// Unlinks a connection by rejecting the assertions backing it, then reloads.
  Future<void> _unlinkEdge(List<String> assertionIds) async {
    if (assertionIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.servicesOf(context).graphRepository;
    try {
      final receipt = await repo.rejectAssertions(assertionIds);
      await _settleGraphMutation(
        receipt,
        successMessage: l10n.rdCanvasUnlinkSuccess,
        failureMessage: l10n.rdCanvasUnlinkFail,
      );
    } catch (_) {
      _mapToast(l10n.rdCanvasUnlinkFail);
    }
  }

  Future<void> _splitEntity(_GNode node) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repository = AppScope.servicesOf(context).graphRepository;
      final detail = await repository.fetchEntityDetail(node.id);
      final assertions = (detail['assertions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_SplitEvidence.fromJson)
          .where((item) => item.assertionId.isNotEmpty)
          .toList();
      if (assertions.isEmpty) {
        _mapToast(l10n.rdCanvasSplitNoFacts);
        return;
      }
      if (!mounted) return;
      final selection = await _showSplitDialog(node, assertions);
      if (selection == null || !mounted) return;
      final receipt = await repository.splitEntity(
        sourceId: node.id,
        canonicalName: node.label,
        entityType: node.entityType ?? 'Person',
        identityHint: selection.identityHint,
        assertionIds: selection.assertionIds,
        facets: [selection.identityHint],
      );
      await _settleGraphMutation(
        receipt,
        successMessage: l10n.rdCanvasSplitSuccess,
        failureMessage: l10n.rdCanvasSplitFail,
      );
    } catch (_) {
      _mapToast(l10n.rdCanvasSplitFail);
    }
  }

  Future<_SplitSelection?> _showSplitDialog(
    _GNode node,
    List<_SplitEvidence> assertions,
  ) async {
    final controller = TextEditingController();
    final selected = <String>{};
    final result = await showDialog<_SplitSelection>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.rdCanvasSplitIdentity(node.label)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.rdCanvasSplitHint),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: l10n.rdCanvasSplitDescription,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.rdCanvasSplitSelectFacts),
                    const SizedBox(height: 6),
                    for (final assertion in assertions)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: selected.contains(assertion.assertionId),
                        title: Text(assertion.label),
                        onChanged: (checked) => setDialogState(() {
                          if (checked ?? false) {
                            selected.add(assertion.assertionId);
                          } else {
                            selected.remove(assertion.assertionId);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: controller.text.trim().isEmpty || selected.isEmpty
                    ? null
                    : () => Navigator.of(dialogContext).pop(
                        _SplitSelection(
                          identityHint: controller.text.trim(),
                          assertionIds: selected.toList(),
                        ),
                      ),
                child: Text(l10n.rdCanvasSplitApply),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    return result;
  }

  CanvasRepository get _canvasRepo =>
      AppScope.servicesOf(context).canvasRepository;

  /// Loads the board list, creating a first board if the user has none, then
  /// restores the last-active board (or defaults to the most recent). All
  /// best-effort: on any failure the Board view falls back to the designed
  /// sample cards so it still reads well offline.
  Future<void> _loadBoards() async {
    final myBoardTitle = AppLocalizations.of(context)!.rdCanvasMyBoard;
    try {
      final repo = _canvasRepo;
      var boards = await repo.list();
      if (boards.isEmpty) {
        final created = await repo.create(title: myBoardTitle);
        boards = [created];
      }

      String? stored;
      try {
        final prefs = await SharedPreferences.getInstance();
        stored = prefs.getString(_kActiveBoardKey);
      } catch (_) {
        stored = null;
      }
      final hasStored = stored != null && boards.any((b) => b.id == stored);
      final activeId = hasStored ? stored : boards.first.id;

      if (!mounted) return;
      setState(() {
        _boards = boards;
        _activeBoardId = activeId;
        _boardsLoading = false;
        _boardEpoch++;
      });
    } catch (_) {
      // Backend unreachable — leave `_boards` empty; `_BoardView` shows the
      // designed sample cards.
      if (!mounted) return;
      setState(() => _boardsLoading = false);
    }
  }

  Future<void> _persistActiveBoard(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActiveBoardKey, id);
    } catch (_) {
      // Non-blocking: losing the pointer only affects which board opens next.
    }
  }

  void _switchBoard(String id) {
    if (id == _activeBoardId) return;
    // The re-keyed `_BoardView` reports the authoritative label via onContext.
    setState(() {
      _activeBoardId = id;
      _boardEpoch++;
    });
    _persistActiveBoard(id);
  }

  /// Creates a new empty board, appends it, and switches to it.
  Future<void> _createBoard() async {
    try {
      final created = await _canvasRepo.create(
        title: AppLocalizations.of(context)!.rdCanvasNewBoard,
      );
      if (!mounted) return;
      setState(() {
        _boards = [..._boards, created];
        _activeBoardId = created.id;
        _boardEpoch++;
      });
      _persistActiveBoard(created.id);
    } catch (_) {
      // Best-effort; if creation fails we stay on the current board.
    }
  }

  /// Reports a board's title + live card count back up so the top context pill
  /// stays in sync with what `_BoardView` is showing.
  void _onBoardContext(String title, int cardCount) {
    final label = _boardLabel(title, cardCount);
    if (label == _boardContext) return;
    setState(() => _boardContext = label);
  }

  String _boardLabel(String title, int count) {
    final l10n = AppLocalizations.of(context)!;
    final name = title.trim().isEmpty
        ? l10n.rdCanvasBoardDefault
        : title.trim();
    return l10n.rdCanvasBoardLabel(name, count);
  }

  /// Opens the compact board switcher popover: the board list (check on the
  /// active one), plus a "New board" action. Selecting switches the active
  /// board; creating spins up a fresh one and switches to it.
  Future<void> _openBoardSwitcher() async {
    if (_boards.isEmpty) return;
    final result = await showDialog<_SwitcherResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) =>
          _BoardSwitcherSheet(boards: _boards, activeId: _activeBoardId),
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case _SwitcherAction.create:
        await _createBoard();
      case _SwitcherAction.rename:
        await _renameBoard(result.boardId!, result.title ?? '');
      case _SwitcherAction.archive:
        await _archiveBoard(result.boardId!);
      case _SwitcherAction.select:
        _switchBoard(result.boardId!);
    }
  }

  /// Rename a board via a small dialog, then persist + reload the board list.
  Future<void> _renameBoard(String id, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final rd = ctx.rd;
        return AlertDialog(
          backgroundColor: rd.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.rdCanvasRenameTitle,
            style: GoogleFonts.dosis(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
            style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.rdCanvasBoardNameHint,
              hintStyle: GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: rd.line, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: rd.navy, width: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(context)!.rdCommonCancel,
                style: GoogleFonts.vazirmatn(color: rd.muted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(
                AppLocalizations.of(context)!.rdCommonSave,
                style: GoogleFonts.vazirmatn(
                  color: rd.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final trimmed = newTitle?.trim() ?? '';
    if (trimmed.isEmpty || !mounted) return;
    try {
      await _canvasRepo.update(id, title: trimmed);
    } catch (_) {}
    await _loadBoards();
  }

  /// Archive (delete) a board, then reload — the active board is re-picked.
  Future<void> _archiveBoard(String id) async {
    try {
      await _canvasRepo.delete(id);
    } catch (_) {}
    if (mounted) await _loadBoards();
  }

  void _openCluster(_ClusterSpec cluster) {
    final focus = cluster.nodeIds.isNotEmpty ? cluster.nodeIds.first : null;
    setState(() {
      _mode = 'map';
      _mapFocusNodeId = focus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final live = _mapNodes != null;
    final context_ = switch (_mode) {
      'board' => _boardContext,
      'clusters' => _clusterContext,
      _ => _mapContext,
    };

    return Scaffold(
      backgroundColor: rd.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: switch (_mode) {
              'board' => _BoardView(
                key: ValueKey('board-$_boardEpoch-${_activeBoardId ?? ''}'),
                board: _activeBoard,
                repository: _boards.isEmpty ? null : _canvasRepo,
                onContext: _onBoardContext,
              ),
              'clusters' => _ClusterOverview(
                key: ValueKey('clusters-${_clusters.length}'),
                clusters: _clusters,
                onOpen: _openCluster,
              ),
              _ => _MapView(
                key: ValueKey(
                  live
                      ? 'map-live-$_mapEpoch-${_mapFocusNodeId ?? ''}'
                      : 'map-sample-${_mapFocusNodeId ?? ''}',
                ),
                nodes: _mapNodes ?? const <_GNode>[],
                edges: live ? _mapEdges : const <List<String>>[],
                initialSelectedId: _mapFocusNodeId,
                onMerge: live ? _mergeEntities : null,
                onSplit: live ? _splitEntity : null,
                edgeAssertions: live ? _mapEdgeAssertions : const {},
                onUnlink: live ? _unlinkEdge : null,
              ),
            },
          ),
          // mode toggle + context (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeToggle(
                          mode: _mode,
                          onChanged: (m) => setState(() => _mode = m),
                        ),
                        if (_mode == 'board') ...[
                          const SizedBox(width: 8),
                          _BoardSwitcherButton(
                            title: _activeBoard?.title,
                            loading: _boardsLoading,
                            onTap: _openBoardSwitcher,
                          ),
                        ],
                      ],
                    ),
                    if (context_.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rd.bg.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          context_,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: rd.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [rd.bg.withValues(alpha: 0), rd.bg],
                  stops: const [0.0, 0.55],
                ),
              ),
              child: RdBottomNav(active: 'canvas', go: widget.go),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final String mode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, 'board', RdIcons.grid4, l10n.rdCanvasBoard),
          const SizedBox(width: 3),
          _seg(context, 'clusters', RdIcons.people, l10n.rdCanvasClusters),
          const SizedBox(width: 3),
          _seg(context, 'map', RdIcons.navCanvas, l10n.rdCanvasMap),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String id, String icon, String label) {
    final rd = context.rd;
    final on = mode == id;
    return GestureDetector(
      onTap: () => onChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: on ? rd.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            RdIcon(
              icon,
              size: 14,
              color: on ? Colors.white : rd.muted,
              strokeWidth: 1.9,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : rd.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Board switcher (button + popover) ─────────────────────────────────────

/// Small board-name pill that sits beside the Board/Map toggle. Tapping it
/// opens the board switcher popover.
class _BoardSwitcherButton extends StatelessWidget {
  const _BoardSwitcherButton({
    required this.title,
    required this.loading,
    required this.onTap,
  });

  final String? title;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final label = (title == null || title!.trim().isEmpty)
        ? (loading
              ? AppLocalizations.of(context)!.rdCanvasLoading
              : AppLocalizations.of(context)!.rdCanvasBoardDefault)
        : title!.trim();
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: rd.card.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(RdIcons.grid4, size: 14, color: rd.peri, strokeWidth: 1.9),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
            ),
            const SizedBox(width: 5),
            // A small down-caret drawn from the chevron-left glyph, rotated.
            Transform.rotate(
              angle: -math.pi / 2,
              child: RdIcon(
                RdIcons.chevronLeft,
                size: 13,
                color: rd.faint,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the switcher popover returns: either a board to switch to, or the
/// intent to create a new board.
enum _SwitcherAction { select, create, rename, archive }

class _SwitcherResult {
  const _SwitcherResult.select(String this.boardId)
    : action = _SwitcherAction.select,
      title = null;
  const _SwitcherResult.create()
    : action = _SwitcherAction.create,
      boardId = null,
      title = null;

  /// Rename requested — [title] carries the current title to prefill the editor.
  const _SwitcherResult.rename(String this.boardId, String this.title)
    : action = _SwitcherAction.rename;
  const _SwitcherResult.archive(String this.boardId)
    : action = _SwitcherAction.archive,
      title = null;

  final _SwitcherAction action;
  final String? boardId;
  final String? title;

  // Back-compat for the existing `createNew` check.
  bool get createNew => action == _SwitcherAction.create;
}

/// Compact popover listing the user's boards (check on the active one) with a
/// "New board" action. Intentionally small — a switcher, not a gallery.
class _BoardSwitcherSheet extends StatelessWidget {
  const _BoardSwitcherSheet({required this.boards, required this.activeId});

  final List<CanvasDto> boards;
  final String? activeId;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final media = MediaQuery.of(context);
    // Anchor near the top, under the mode bar, matching where the button lives.
    return Padding(
      padding: EdgeInsets.only(
        top: media.padding.top + 52,
        left: 14,
        right: 14,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rd.line, width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF141628).withValues(alpha: 0.3),
                  blurRadius: 48,
                  spreadRadius: -18,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    AppLocalizations.of(context)!.rdCanvasBoardsHeader,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: rd.faint,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: boards.length,
                    itemBuilder: (context, i) {
                      final b = boards[i];
                      final active = b.id == activeId;
                      return _row(context, rd, b, active);
                    },
                  ),
                ),
                Divider(height: 1, thickness: 1, color: rd.line),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pop(const _SwitcherResult.create()),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        RdIcon(
                          RdIcons.plusCircle,
                          size: 18,
                          color: rd.peri,
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: 11),
                        Text(
                          AppLocalizations.of(context)!.rdCanvasNewBoard,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: rd.peri,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, RdTheme rd, CanvasDto b, bool active) {
    final title = b.title.trim().isEmpty
        ? AppLocalizations.of(context)!.rdCanvasUntitledBoard
        : b.title.trim();
    final count = b.nodes.length;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(_SwitcherResult.select(b.id)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: active ? rd.periSoft.withValues(alpha: 0.5) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    AppLocalizations.of(context)!.rdCanvasCardCount(count),
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11.5,
                      color: rd.muted,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).pop(_SwitcherResult.rename(b.id, b.title)),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: RdIcon(
                  '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>',
                  size: 15,
                  color: rd.muted,
                  strokeWidth: 1.9,
                ),
              ),
            ),
            if (boards.length > 1)
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(_SwitcherResult.archive(b.id)),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RdIcon(
                    '<path d="M6 6l12 12M18 6 6 18"/>',
                    size: 15,
                    color: rd.faint,
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (active) ...[
              const SizedBox(width: 2),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rd.peri,
                ),
                child: const Center(
                  child: RdIcon(
                    RdIcons.checkThick,
                    size: 11,
                    stroke: '#FFFFFF',
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Map view — Mira's memory graph
// ══════════════════════════════════════════════════════════════════════

class _SplitEvidence {
  const _SplitEvidence({required this.assertionId, required this.label});

  factory _SplitEvidence.fromJson(Map<String, dynamic> json) {
    final predicate =
        json['predicateKey'] as String? ??
        json['predicate_key'] as String? ??
        'fact';
    final object =
        json['objectName'] ?? json['object_name'] ?? json['value'] ?? '';
    return _SplitEvidence(
      assertionId:
          json['assertionId'] as String? ??
          json['assertion_id'] as String? ??
          '',
      label: object.toString().trim().isEmpty
          ? predicate
          : '$predicate · ${object.toString()}',
    );
  }

  final String assertionId;
  final String label;
}

class _SplitSelection {
  const _SplitSelection({
    required this.identityHint,
    required this.assertionIds,
  });

  final String identityHint;
  final List<String> assertionIds;
}

enum _GType {
  person,
  task,
  event,
  note,
  book,
  idea,
  topic,
  organization,
  project,
  place,
}

class _GNode {
  const _GNode({
    required this.id,
    required this.x,
    required this.y,
    required this.disc,
    required this.type,
    required this.label,
    required this.typ,
    required this.sub,
    this.entityType,
    this.initial,
    this.disambiguator,
    this.identityAmbiguous = false,
    this.identityReviewKind,
  });

  final String id;
  final double x;
  final double y;
  final double disc;
  final _GType type;
  final String label;
  final String typ;
  final String sub;
  final String? entityType;
  final String? initial;
  final String? disambiguator;
  final bool identityAmbiguous;
  final String? identityReviewKind;
}

String _gTypeIcon(_GType t) {
  switch (t) {
    case _GType.task:
      return RdIcons.checkCircle;
    case _GType.event:
      return RdIcons.calendar;
    case _GType.note:
      return RdIcons.pencil;
    case _GType.book:
      return RdIcons.book;
    case _GType.idea:
      return RdIcons.bulb;
    case _GType.topic:
      return RdIcons.hash;
    case _GType.organization:
      return RdIcons.work;
    case _GType.project:
      return RdIcons.folder;
    case _GType.place:
      return RdIcons.pin;
    case _GType.person:
      return RdIcons.people;
  }
}

/// Maps a live memory [GraphResponse] into the Map view's node/edge model,
/// laying nodes out in a deterministic sunflower spiral (higher-degree hubs
/// nearer the centre) since the backend layout is optional. Bounded to keep
/// the graph legible on a phone.
(List<_GNode>, List<List<String>>, Map<String, List<String>>) _mapGraphToNodes(
  GraphResponse g,
  AppLocalizations l10n,
) {
  final nodes = g.nodes.take(40).toList();
  final ids = {for (final n in nodes) n.id};
  final edges = <List<String>>[];
  // Undirected lookup of the assertions backing each edge, keyed "a|b" (both
  // directions), so the Map can "unlink" a connection by rejecting them.
  final edgeAssertions = <String, List<String>>{};
  for (final e in g.edges) {
    if (e.sourceId != e.targetId &&
        ids.contains(e.sourceId) &&
        ids.contains(e.targetId)) {
      edges.add([e.sourceId, e.targetId]);
      if (e.assertionIds.isNotEmpty) {
        edgeAssertions['${e.sourceId}|${e.targetId}'] = e.assertionIds;
        edgeAssertions['${e.targetId}|${e.sourceId}'] = e.assertionIds;
      }
    }
  }
  final degree = {for (final n in nodes) n.id: 0};
  for (final e in edges) {
    degree[e[0]] = (degree[e[0]] ?? 0) + 1;
    degree[e[1]] = (degree[e[1]] ?? 0) + 1;
  }
  final sorted = [...nodes]
    ..sort((a, b) => (degree[b.id] ?? 0).compareTo(degree[a.id] ?? 0));
  const cx = 240.0;
  const cy = 400.0;
  const goldenAngle = 2.399963229728653;
  final out = <_GNode>[];
  for (var i = 0; i < sorted.length; i++) {
    final n = sorted[i];
    final r = 36.0 * math.sqrt(i.toDouble());
    final angle = i * goldenAngle;
    final deg = degree[n.id] ?? 0;
    final type = _gTypeForNode(n);
    final label = _shortGLabel(n.title.isEmpty ? n.summary : n.title);
    final hint = n.disambiguator?.trim();
    out.add(
      _GNode(
        id: n.id,
        x: cx + r * math.cos(angle),
        y: cy + r * math.sin(angle),
        disc: deg >= 5 ? 68 : (deg >= 2 ? 52 : 44),
        type: type,
        label: label,
        typ: _gTypeLabelFor(type, l10n),
        sub: (hint != null && hint.isNotEmpty)
            ? hint
            : (n.summary.trim().isEmpty
                  ? l10n.rdCanvasLinkedCount(deg)
                  : n.summary),
        entityType: n.entityType,
        initial: type == _GType.person && label.isNotEmpty
            ? label.substring(0, 1).toUpperCase()
            : null,
        disambiguator: hint,
        identityAmbiguous: n.identityAmbiguous,
        identityReviewKind: n.identityReviewKind,
      ),
    );
  }
  return (out, edges, edgeAssertions);
}

_GType _gTypeForNode(GraphNode n) {
  final t = '${n.entityType ?? ''} ${n.nodeType}'.toLowerCase();
  if (t.contains('person') || t.contains('people')) return _GType.person;
  if (t.contains('organization') || t.contains('company')) {
    return _GType.organization;
  }
  if (t.contains('project')) return _GType.project;
  if (t.contains('place')) return _GType.place;
  if (t.contains('task') || t.contains('reminder') || t.contains('todo')) {
    return _GType.task;
  }
  if (t.contains('event') || t.contains('meeting')) return _GType.event;
  if (t.contains('book')) return _GType.book;
  if (t.contains('idea')) return _GType.idea;
  if (t.contains('topic') || t.contains('tag') || t.contains('theme')) {
    return _GType.topic;
  }
  return _GType.note;
}

String _gTypeLabelFor(_GType t, AppLocalizations l10n) {
  switch (t) {
    case _GType.person:
      return l10n.rdCanvasNodePerson;
    case _GType.task:
      return l10n.rdCanvasNodeTask;
    case _GType.event:
      return l10n.rdCanvasNodeEvent;
    case _GType.note:
      return l10n.rdCanvasNodeNote;
    case _GType.book:
      return l10n.rdCanvasNodeBook;
    case _GType.idea:
      return l10n.rdCanvasNodeIdea;
    case _GType.topic:
      return l10n.rdCanvasNodeTopic;
    case _GType.organization:
      return l10n.rdCanvasNodeOrganization;
    case _GType.project:
      return l10n.rdCanvasNodeProject;
    case _GType.place:
      return l10n.rdCanvasNodePlace;
  }
}

String _shortGLabel(String s) {
  final clean = s.trim().replaceAll('\n', ' ');
  if (clean.length <= 16) return clean;
  return '${clean.substring(0, 15).trimRight()}…';
}

// ── Cluster overview ──────────────────────────────────────────────────

class _ClusterPalette {
  const _ClusterPalette(this.bg, this.ring, this.fg);
  final Color bg;
  final Color ring;
  final Color fg;
}

const _clusterPalettes = <String, _ClusterPalette>{
  'navy': _ClusterPalette(
    Color(0xFFE4EAF6),
    Color(0xFF14328C),
    Color(0xFF14328C),
  ),
  'peri': _ClusterPalette(
    Color(0xFFE7E9F5),
    Color(0xFF7E8BC9),
    Color(0xFF46508C),
  ),
  'rose': _ClusterPalette(
    Color(0xFFF3E4E6),
    Color(0xFFC27E88),
    Color(0xFF8E4650),
  ),
  'teal': _ClusterPalette(
    Color(0xFFDEECEC),
    Color(0xFF5E9B9B),
    Color(0xFF2C5E5E),
  ),
  'amber': _ClusterPalette(
    Color(0xFFF4EBDA),
    Color(0xFFC79A54),
    Color(0xFF8A6420),
  ),
  'plum': _ClusterPalette(
    Color(0xFFECE4F0),
    Color(0xFF9A7BB0),
    Color(0xFF5E3E77),
  ),
};

class _ClusterSpec {
  const _ClusterSpec({
    required this.id,
    required this.name,
    required this.count,
    required this.colorKey,
    required this.type,
    required this.x,
    required this.y,
    required this.nodeIds,
  });

  final String id;
  final String name;
  final int count;
  final String colorKey;
  final _GType type;
  final double x;
  final double y;
  final List<String> nodeIds;
}

const _clusterColorKeys = ['navy', 'peri', 'rose', 'teal', 'amber', 'plum'];

const _clusterLayout = <Offset>[
  Offset(116, 148),
  Offset(300, 106),
  Offset(300, 288),
  Offset(132, 352),
  Offset(318, 476),
  Offset(88, 522),
  Offset(200, 220),
  Offset(360, 400),
];

List<_ClusterSpec> _buildClustersFromNodes(
  List<_GNode> nodes,
  List<List<String>> edges,
  AppLocalizations l10n,
) {
  if (nodes.isEmpty) return const [];

  final buckets = <String, List<_GNode>>{};
  for (final n in nodes) {
    final key = switch (n.type) {
      _GType.person => 'person:${n.label.toLowerCase()}',
      _GType.topic => 'topic:${n.label.toLowerCase()}',
      _GType.organization => 'organization:${n.label.toLowerCase()}',
      _GType.project => 'project:${n.label.toLowerCase()}',
      _GType.place => 'place:${n.label.toLowerCase()}',
      _GType.task => 'type:tasks',
      _GType.book => 'type:books',
      _GType.event => 'type:events',
      _ => 'type:notes',
    };
    buckets.putIfAbsent(key, () => []).add(n);
  }

  final sorted = buckets.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));

  final clusters = <_ClusterSpec>[];
  for (var i = 0; i < sorted.length && i < 8; i++) {
    final entry = sorted[i];
    final group = entry.value;
    final first = group.first;
    final name = switch (first.type) {
      _GType.person => first.label,
      _GType.topic => first.label,
      _GType.organization => first.label,
      _GType.project => first.label,
      _GType.place => first.label,
      _GType.task => l10n.rdCanvasClusterTasks,
      _GType.book => l10n.rdCanvasClusterBooks,
      _GType.event => l10n.rdCanvasClusterEvents,
      _ => l10n.rdCanvasClusterNotes,
    };
    final pos = _clusterLayout[i % _clusterLayout.length];
    clusters.add(
      _ClusterSpec(
        id: 'c$i',
        name: name,
        count: group.length,
        colorKey: _clusterColorKeys[i % _clusterColorKeys.length],
        type: first.type,
        x: pos.dx,
        y: pos.dy,
        nodeIds: group.map((n) => n.id).toList(),
      ),
    );
  }
  return clusters;
}

class _ClusterOverview extends StatefulWidget {
  const _ClusterOverview({
    super.key,
    required this.clusters,
    required this.onOpen,
  });

  final List<_ClusterSpec> clusters;
  final ValueChanged<_ClusterSpec> onOpen;

  @override
  State<_ClusterOverview> createState() => _ClusterOverviewState();
}

class _ClusterOverviewState extends State<_ClusterOverview> {
  Offset _pan = const Offset(8, 40);

  double _diameter(_ClusterSpec c) => 82 + c.count * 8;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    if (widget.clusters.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.rdCanvasNoClusters,
          style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.muted),
        ),
      );
    }
    return GestureDetector(
      onPanUpdate: (d) => setState(() => _pan += d.delta),
      child: ClipRect(
        child: Transform.translate(
          offset: _pan,
          child: SizedBox(
            width: 480,
            height: 820,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final c in widget.clusters) ...[
                  Positioned(
                    left: c.x - _diameter(c) / 2,
                    top: c.y - _diameter(c) / 2,
                    child: _ClusterBubble(
                      cluster: c,
                      diameter: _diameter(c),
                      onTap: () => widget.onOpen(c),
                    ),
                  ),
                  Positioned(
                    left: c.x - 72,
                    top: c.y + _diameter(c) / 2 + 12,
                    width: 144,
                    child: Column(
                      children: [
                        Text(
                          c.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: rd.ink,
                          ),
                        ),
                        Text(
                          l10n.rdClusterMemories(c.count),
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            color: rd.muted,
                          ),
                        ),
                      ],
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

class _ClusterBubble extends StatelessWidget {
  const _ClusterBubble({
    required this.cluster,
    required this.diameter,
    required this.onTap,
  });

  final _ClusterSpec cluster;
  final double diameter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette =
        _clusterPalettes[cluster.colorKey] ?? _clusterPalettes['navy']!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.bg,
          border: Border.all(color: palette.ring, width: 2),
          boxShadow: [
            BoxShadow(
              color: palette.ring.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${cluster.count}',
            style: GoogleFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: palette.fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView({
    super.key,
    this.nodes = const <_GNode>[],
    this.edges = const <List<String>>[],
    this.initialSelectedId,
    this.onMerge,
    this.onSplit,
    this.edgeAssertions = const {},
    this.onUnlink,
  });

  final List<_GNode> nodes;
  final List<List<String>> edges;
  final String? initialSelectedId;

  /// Merges the first entity id into the second on the real graph. Null for the
  /// offline sample (nothing to persist).
  final void Function(String source, String target)? onMerge;

  final ValueChanged<_GNode>? onSplit;

  /// Assertions backing each edge, keyed "a|b" (both directions).
  final Map<String, List<String>> edgeAssertions;

  /// Unlinks a connection by rejecting its backing assertions. Null offline.
  final void Function(List<String> assertionIds)? onUnlink;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView>
    with SingleTickerProviderStateMixin {
  static const _initialPan = Offset(30, 96);

  late final Map<String, _GNode> _byId = {
    for (final n in widget.nodes) n.id: n,
  };
  late final Map<String, List<String>> _adj = _buildAdjacency();

  String? _selected;
  // When set, the map isolates this node + its neighbours (Focus mode); a pill
  // shows to exit. A pure view state — everything else is hidden.
  String? _focus;
  Offset _pan = _initialPan;

  // Pinch / button zoom (the map was pan-only; the Board already zoomed).
  double _scale = 1.0;
  double _scaleStart = 1.0;
  Offset _panStart = Offset.zero;
  Offset _focalStart = Offset.zero;

  void _zoomBy(double delta) {
    setState(() => _scale = (_scale + delta).clamp(0.6, 2.4));
  }

  late final AnimationController _panCtl =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      )..addListener(() {
        final a = _panAnim;
        if (a != null) setState(() => _pan = a.value);
      });
  Animation<Offset>? _panAnim;

  Map<String, List<String>> _buildAdjacency() {
    final adj = {for (final n in widget.nodes) n.id: <String>[]};
    for (final e in widget.edges) {
      adj[e[0]]!.add(e[1]);
      adj[e[1]]!.add(e[0]);
    }
    return adj;
  }

  @override
  void initState() {
    super.initState();
    final id = widget.initialSelectedId;
    if (id != null && _byId.containsKey(id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _select(id, MediaQuery.sizeOf(context).width);
      });
    }
  }

  @override
  void dispose() {
    _panCtl.dispose();
    super.dispose();
  }

  void _animatePanTo(Offset target) {
    _panAnim = Tween(
      begin: _pan,
      end: target,
    ).animate(CurvedAnimation(parent: _panCtl, curve: Curves.easeOutCubic));
    _panCtl.forward(from: 0);
  }

  void _select(String id, double width) {
    final n = _byId[id]!;
    setState(() => _selected = id);
    _animatePanTo(Offset(width / 2 - n.x, 220 - n.y));
  }

  void _close() {
    setState(() => _selected = null);
    _animatePanTo(_initialPan);
  }

  /// Enter Focus mode on [id] — isolates it + its neighbours and centres it.
  void _focusOn(String id, double width) {
    final n = _byId[id]!;
    setState(() => _focus = id);
    _animatePanTo(Offset(width / 2 - n.x, 220 - n.y));
  }

  void _exitFocus() {
    setState(() => _focus = null);
    _animatePanTo(_initialPan);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final near = _selected == null
            ? const <String>{}
            : {_selected!, ..._adj[_selected]!};
        // Focus mode: only the focused node + its neighbours are shown.
        final focusSet = _focus == null
            ? const <String>{}
            : {_focus!, ..._adj[_focus]!};
        bool visible(String id) => _focus == null || focusSet.contains(id);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selected != null) _close();
          },
          onScaleStart: (d) {
            _panCtl.stop();
            _scaleStart = _scale;
            _panStart = _pan;
            _focalStart = d.focalPoint;
          },
          onScaleUpdate: (d) => setState(() {
            _scale = (_scaleStart * d.scale).clamp(0.6, 2.4);
            _pan = _panStart + (d.focalPoint - _focalStart);
          }),
          child: ClipRect(
            child: Stack(
              children: [
                Transform.translate(
                  offset: _pan,
                  child: Transform.scale(
                    scale: _scale,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 480,
                      height: 820,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _EdgePainter(
                                nodes: _byId,
                                edges: widget.edges,
                                selected: _selected,
                                color: rd.peri,
                              ),
                            ),
                          ),
                          for (final n in widget.nodes)
                            if (visible(n.id))
                              Positioned(
                                left: n.x,
                                top: n.y,
                                child: FractionalTranslation(
                                  translation: const Offset(-0.5, -0.5),
                                  child: _GNodeWidget(
                                    node: n,
                                    selected: _selected == n.id,
                                    dimmed:
                                        _selected != null &&
                                        !near.contains(n.id),
                                    onTap: () => _select(n.id, width),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Neutral empty state when there's no memory graph yet.
                if (widget.nodes.isEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.rdCanvasGraphEmpty,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            color: rd.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                // hint (fixed) — only meaningful when there are nodes to explore
                if (widget.nodes.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 108,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _selected == null ? 1 : 0,
                        child: const Center(child: _GraphHint()),
                      ),
                    ),
                  ),
                // zoom control (fixed) — hidden while a node's detail panel is up
                if (_selected == null)
                  Positioned(
                    left: 14,
                    bottom: 116,
                    child: _ZoomChip(
                      level: _scale,
                      onOut: () => _zoomBy(-0.2),
                      onIn: () => _zoomBy(0.2),
                    ),
                  ),
                // detail panel (fixed)
                Positioned(
                  left: 14,
                  right: 14,
                  // Keep the detail card fully above the shared navigation.
                  // On Android 3-button navigation the system inset is large;
                  // omitting it made the app nav visibly overlap the card.
                  bottom: 108 + context.rdNavBarInset,
                  child: _DetailPanel(
                    node: _selected == null ? null : _byId[_selected],
                    connected: _selected == null
                        ? const []
                        : _adj[_selected]!.map((id) => _byId[id]!).toList(),
                    onClose: _close,
                    onSelectConnected: (id) => _select(id, width),
                    onFocus: _selected == null
                        ? null
                        : () => _focusOn(_selected!, width),
                    onMerge: (widget.onMerge == null || _selected == null)
                        ? null
                        : (sourceId) => widget.onMerge!(sourceId, _selected!),
                    onSplit: (widget.onSplit == null || _selected == null)
                        ? null
                        : () => widget.onSplit!(_byId[_selected!]!),
                    mergeCandidates: widget.onMerge == null
                        ? const []
                        : [
                            for (final n in widget.nodes)
                              if (n.id != _selected &&
                                  n.entityType != null &&
                                  n.entityType == _byId[_selected]?.entityType)
                                n,
                          ],
                    onUnlink: widget.onUnlink,
                    connectionAssertions: _selected == null
                        ? const {}
                        : {
                            for (final id in _adj[_selected]!)
                              id:
                                  widget.edgeAssertions['${_selected!}|$id'] ??
                                  const <String>[],
                          },
                  ),
                ),
                // Focus pill (fixed) — tap to leave Focus mode.
                if (_focus != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 14,
                    child: Center(
                      child: GestureDetector(
                        onTap: _exitFocus,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: rd.navy,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: rd.navy.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.rdCanvasFocusedOn(_byId[_focus]!.label),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const RdIcon(
                                '<path d="M6 6l12 12M18 6 6 18"/>',
                                size: 14,
                                stroke: '#FFFFFF',
                                strokeWidth: 2.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GNodeWidget extends StatelessWidget {
  const _GNodeWidget({
    required this.node,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final _GNode node;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: dimmed ? 0.28 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: selected ? 1.06 : 1,
              child: _disc(rd),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 84,
              child: Text(
                node.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: node.disc >= 68 ? 12.5 : 11.5,
                  fontWeight: node.disc >= 68
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: rd.ink,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disc(RdTheme rd) {
    final size = node.disc;
    final iconSize = node.disc >= 68 ? 26.0 : (node.disc >= 52 ? 22.0 : 20.0);

    BoxDecoration decoration;
    Widget inner;

    switch (node.type) {
      case _GType.person:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.28, -0.4),
            colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A69B4).withValues(alpha: 0.5),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 12),
            ),
          ],
          border: selected ? Border.all(color: rd.peri, width: 2) : null,
        );
        inner = Text(
          node.initial ?? '',
          style: GoogleFonts.dosis(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      case _GType.topic:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: rd.periSoft,
          border: Border.all(
            color: selected ? rd.peri : const Color(0x807E8BC9),
            width: selected ? 2 : 1.5,
          ),
        );
        inner = RdIcon(
          _gTypeIcon(node.type),
          size: iconSize,
          stroke: '#14328C',
          strokeWidth: 2,
        );
      case _GType.organization:
      case _GType.project:
      case _GType.place:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE8ECF8),
          border: Border.all(
            color: selected ? rd.peri : const Color(0xFFB8C0DE),
            width: selected ? 2 : 1.5,
          ),
        );
        inner = RdIcon(
          _gTypeIcon(node.type),
          size: iconSize,
          stroke: '#14328C',
          strokeWidth: 2,
        );
      default:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: rd.card,
          border: Border.all(
            color: selected ? rd.peri : rd.line,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2246).withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: -8,
              offset: const Offset(0, 6),
            ),
          ],
        );
        inner = RdIcon(
          _gTypeIcon(node.type),
          size: iconSize,
          color: rd.peri,
          strokeWidth: 1.8,
        );
    }

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: Center(child: inner),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.nodes,
    required this.edges,
    required this.selected,
    required this.color,
  });

  final Map<String, _GNode> nodes;
  final List<List<String>> edges;
  final String? selected;

  /// Edge tint — the periwinkle accent, passed from the widget so it tracks the
  /// active [RdTheme] (painters cannot read `context`).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
      final a = nodes[e[0]]!;
      final b = nodes[e[1]]!;
      final hot = selected != null && (e[0] == selected || e[1] == selected);
      final dim = selected != null && !hot;

      final paint = Paint()
        ..color = color.withValues(alpha: hot ? 0.9 : (dim ? 0.08 : 0.28))
        ..strokeWidth = hot ? 2 : 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), paint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) =>
      old.selected != selected || old.color != color;
}

class _GraphHint extends StatelessWidget {
  const _GraphHint();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(RdIcons.plusCircle, size: 14, color: rd.muted, strokeWidth: 2),
          const SizedBox(width: 7),
          Text(
            AppLocalizations.of(context)!.rdCanvasTapExplore,
            style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.node,
    required this.connected,
    required this.onClose,
    required this.onSelectConnected,
    this.onFocus,
    this.onMerge,
    this.onSplit,
    this.mergeCandidates = const [],
    this.onUnlink,
    this.connectionAssertions = const {},
  });

  final _GNode? node;
  final List<_GNode> connected;
  final VoidCallback onClose;
  final ValueChanged<String> onSelectConnected;

  /// Enter Focus mode on this node (isolate it + its neighbours). Null hides
  /// the button.
  final VoidCallback? onFocus;

  /// Merge a duplicate entity (its id) into this node on the real graph. Null
  /// hides the button (offline sample).
  final ValueChanged<String>? onMerge;

  final VoidCallback? onSplit;

  /// Other nodes offered as merge targets.
  final List<_GNode> mergeCandidates;

  /// Unlinks a connection by rejecting the assertions backing it. Null hides
  /// the per-connection × affordance.
  final ValueChanged<List<String>>? onUnlink;

  /// Assertions backing each connection (connected node id → assertion ids).
  final Map<String, List<String>> connectionAssertions;

  @override
  Widget build(BuildContext context) {
    final showing = node != null;
    return IgnorePointer(
      ignoring: !showing,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        offset: showing ? Offset.zero : const Offset(0, 1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showing ? 1 : 0,
          child: node == null ? const SizedBox.shrink() : _card(context, node!),
        ),
      ),
    );
  }

  void _openMergePicker(BuildContext context, _GNode current) {
    final rd = context.rd;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          20 + MediaQuery.of(ctx).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: rd.line,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.rdCanvasMergeInto(current.label),
              style: GoogleFonts.dosis(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: rd.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context)!.rdCanvasMergePickDuplicate,
              style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in mergeCandidates)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onMerge?.call(c.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: rd.periSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: RdIcon(
                                  _gTypeIcon(c.type),
                                  size: 17,
                                  stroke: '#14328C',
                                  strokeWidth: 1.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: rd.ink,
                                    ),
                                  ),
                                  Text(
                                    c.typ,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 11.5,
                                      color: rd.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _card(BuildContext context, _GNode n) {
    final rd = context.rd;
    final isPerson = n.type == _GType.person;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rd.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628).withValues(alpha: 0.28),
            blurRadius: 50,
            spreadRadius: -20,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isPerson ? null : rd.periSoft,
                  gradient: isPerson
                      ? const RadialGradient(
                          center: Alignment(-0.28, -0.4),
                          colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
                        )
                      : null,
                ),
                child: Center(
                  child: isPerson
                      ? Text(
                          n.initial ?? '',
                          style: GoogleFonts.dosis(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : RdIcon(
                          _gTypeIcon(n.type),
                          size: 22,
                          stroke: '#14328C',
                          strokeWidth: 1.8,
                        ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.typ.toUpperCase(),
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: rd.peri,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      n.identityAmbiguous &&
                              (n.disambiguator?.trim().isNotEmpty ?? false)
                          ? '${n.label} (${n.disambiguator!.trim()})'
                          : n.label,
                      style: GoogleFonts.dosis(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: rd.ink,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: RdIcon(
                    RdIcons.close,
                    size: 18,
                    color: rd.faint,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text(
              n.sub,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                height: 1.5,
                color: rd.muted,
              ),
            ),
          ),
          if (n.identityAmbiguous)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: rd.periSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rd.line, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.identityReviewKind == 'possible_merged_homonym'
                          ? AppLocalizations.of(
                              context,
                            )!.rdCanvasIdentityMergedSmell
                          : AppLocalizations.of(
                              context,
                            )!.rdCanvasIdentityAmbiguous,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12.5,
                        height: 1.45,
                        color: rd.navy,
                      ),
                    ),
                    if (onSplit != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onSplit,
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.rdCanvasIdentityAmbiguousAction,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: rd.peri,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (onFocus != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: GestureDetector(
                onTap: onFocus,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rd.periSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RdIcon(
                        '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>',
                        size: 15,
                        color: rd.navy,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.rdCanvasFocusConstellation,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: rd.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (onMerge != null && mergeCandidates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => _openMergePicker(context, n),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rd.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rd.line, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RdIcon(
                        '<path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M8 21H5a2 2 0 0 1-2-2v-3M16 21h3a2 2 0 0 0 2-2v-3M9 12h6"/>',
                        size: 15,
                        color: rd.muted,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        AppLocalizations.of(context)!.rdCanvasMergeDuplicate,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: rd.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (onSplit != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: onSplit,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rd.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rd.line, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RdIcon(
                        '<path d="M12 3v18M5 7c3 0 4 2 7 5M19 17c-3 0-4-2-7-5"/>',
                        size: 15,
                        color: rd.muted,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.rdCanvasSplitMixedIdentity,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: rd.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              AppLocalizations.of(
                context,
              )!.rdCanvasConnectedTo(connected.length),
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: rd.faint,
              ),
            ),
          ),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final c in connected)
                GestureDetector(
                  onTap: () => onSelectConnected(c.id),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: rd.card,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: rd.line, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RdIcon(
                          c.type == _GType.person
                              ? RdIcons.people
                              : _gTypeIcon(c.type),
                          size: 14,
                          color: rd.peri,
                          strokeWidth: 1.8,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c.label,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12.5,
                            color: rd.ink,
                          ),
                        ),
                        if (onUnlink != null &&
                            (connectionAssertions[c.id]?.isNotEmpty ??
                                false)) ...[
                          const SizedBox(width: 7),
                          GestureDetector(
                            onTap: () => onUnlink!(connectionAssertions[c.id]!),
                            behavior: HitTestBehavior.opaque,
                            child: RdIcon(
                              '<path d="M6 6l12 12M18 6 6 18"/>',
                              size: 11,
                              color: rd.faint,
                              strokeWidth: 2.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Board view — freeform card surface (pan + zoom)
// ══════════════════════════════════════════════════════════════════════

/// A user-drawn connection between two board cards, rendered in connect-mode.
class _BoardEdge {
  const _BoardEdge({required this.from, required this.to, required this.label});

  final String from;
  final String to;
  final String label;
}

/// Add-card tool lives at toolbar index 1; Connect tool at index 3.
const _addTool = 1;
const _connectTool = 3;

class _BoardView extends StatefulWidget {
  const _BoardView({
    super.key,
    this.board,
    this.repository,
    required this.onContext,
  });

  /// The active board to load cards/edges from. Null (or an empty board, or a
  /// failed load) falls back to the designed sample cards.
  final CanvasDto? board;

  /// Repository used to persist edits. Null when the backend is unreachable —
  /// the board still works locally, it just won't save.
  final CanvasRepository? repository;

  /// Reports the board title + live card count up so the top context pill
  /// mirrors what's on screen.
  final void Function(String title, int cardCount) onContext;

  @override
  State<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<_BoardView> {
  double _scale = 0.72;
  Offset _offset = const Offset(-30, 40);

  double _startScale = 0.72;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  int _tool = 0;

  /// The board's cards. Seeded from the active board's persisted nodes, or from
  /// the designed sample when the board is empty / unavailable. Mutable so we
  /// can add cards.
  late List<_CardSpec> _cards;

  /// Whether these cards are the offline designed sample (true) or came from a
  /// real board (false). Sample cards are never persisted.
  late bool _isSample;

  /// Card positions (top-left, board coordinates), seeded from the specs.
  /// Dragging mutates these so cards keep their positions after drop.
  late Map<String, Offset> _positions;

  /// The card currently under the finger — lifted (bigger shadow, slight
  /// scale) and raised above its siblings.
  String? _draggingId;

  /// Connect-mode: the first-tapped card (source); the second tap creates an
  /// edge and clears this.
  String? _connectSource;

  /// In move-mode, the card tapped to select it — reveals a delete (×) affordance.
  String? _selectedCard;

  /// User-created connections. Seeded from the board's persisted edges.
  late List<_BoardEdge> _edges;

  /// Debounce for persistence — coalesces a burst of edits into one write.
  Timer? _saveDebounce;

  bool _suggestVisible = true;

  /// Monotonic counter for locally-created card ids so they don't collide.
  int _newCardSeq = 0;

  bool get _connectMode => _tool == _connectTool;
  bool get _addMode => _tool == _addTool;

  @override
  void initState() {
    super.initState();
    _hydrateFromBoard();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  /// Builds the initial card/edge state from `widget.board`.
  ///
  /// Fallback policy: when there is **no** active board DTO at all (the boards
  /// list failed to load, or the backend is unreachable) we show a clean, empty
  /// canvas with a neutral empty state rather than any fabricated content. A
  /// real board that simply has no nodes yet shows the same empty canvas.
  void _hydrateFromBoard() {
    final board = widget.board;

    if (board == null) {
      // Offline / no board — empty canvas, nothing persisted.
      _isSample = true;
      _cards = <_CardSpec>[];
      _edges = [];
    } else {
      _isSample = false;
      _cards = board.nodes.map(_cardFromNode).whereType<_CardSpec>().toList();
      _edges = board.edges
          .map(_edgeFromJson)
          .whereType<_BoardEdge>()
          // Drop edges whose endpoints no longer exist.
          .where(
            (e) =>
                _cards.any((c) => c.id == e.from) &&
                _cards.any((c) => c.id == e.to),
          )
          .toList();
    }

    _positions = {for (final c in _cards) c.id: Offset(c.left, c.top)};

    // Report context after the first frame so we don't setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onContext(_boardTitle, _cards.length);
    });
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startScale = _scale;
    _startOffset = _offset;
    _startFocal = d.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_startScale * d.scale).clamp(0.4, 1.4);
      _offset = _startOffset + (d.focalPoint - _startFocal);
    });
  }

  void _zoom(double delta, Size viewport) {
    final ns = (_scale + delta).clamp(0.4, 1.4);
    final center = Offset(viewport.width / 2, viewport.height / 2);
    final scene = (center - _offset) / _scale;
    setState(() {
      _offset = center - scene * ns;
      _scale = ns;
    });
  }

  void _onCardDragStart(String id) {
    setState(() => _draggingId = id);
  }

  void _onCardDragUpdate(String id, Offset delta) {
    // Scale-compensate: a finger movement of `delta` in screen space equals
    // `delta / scale` in board space.
    final current = _positions[id] ?? Offset.zero;
    setState(() => _positions[id] = current + delta / _scale);
  }

  void _onCardDragEnd() {
    setState(() => _draggingId = null);
    // Position changed → persist the new layout.
    _scheduleSave();
  }

  void _onCardTap(String id) {
    if (!_connectMode) {
      // Move-mode: tap selects (revealing delete); tap again deselects.
      setState(() => _selectedCard = _selectedCard == id ? null : id);
      return;
    }
    var created = false;
    setState(() {
      if (_connectSource == null) {
        _connectSource = id;
      } else if (_connectSource == id) {
        // Tapping the source again cancels the selection.
        _connectSource = null;
      } else {
        _edges.add(
          _BoardEdge(
            from: _connectSource!,
            to: id,
            label: _relationLabel(_connectSource!, id),
          ),
        );
        _connectSource = null;
        created = true;
      }
    });
    if (created) _scheduleSave();
  }

  /// Removes a card (and any edges touching it), persists, and offers Undo.
  void _deleteCard(String id) {
    final idx = _cards.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final removedCard = _cards[idx];
    final removedPos = _positions[id];
    final removedEdges = _edges
        .where((e) => e.from == id || e.to == id)
        .toList();
    setState(() {
      _cards = _cards.where((c) => c.id != id).toList();
      _edges = _edges.where((e) => e.from != id && e.to != id).toList();
      _positions.remove(id);
      _selectedCard = null;
    });
    widget.onContext(_boardTitle, _cards.length);
    _scheduleSave();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.rd.ink,
          content: Text(
            AppLocalizations.of(context)!.rdCanvasCardRemoved,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.rdCommonUndo,
            textColor: Colors.white,
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _cards = [..._cards, removedCard];
                if (removedPos != null) _positions[id] = removedPos;
                _edges = [..._edges, ...removedEdges];
              });
              widget.onContext(_boardTitle, _cards.length);
              _scheduleSave();
            },
          ),
        ),
      );
  }

  void _exitConnect() {
    setState(() {
      _tool = 0;
      _connectSource = null;
    });
  }

  /// The red × shown on a selected card to delete it.
  Widget _cardDelete(String id) {
    return GestureDetector(
      onTap: () => _deleteCard(id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFC0392B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: RdIcon(
            '<path d="M6 6l12 12M18 6 6 18"/>',
            size: 14,
            stroke: '#FFFFFF',
            strokeWidth: 2.6,
          ),
        ),
      ),
    );
  }

  /// Drops a fresh note card at [scenePoint] (board coordinates) while the
  /// add-card tool is active, then persists.
  void _addCardAt(Offset scenePoint) {
    final id = 'n${DateTime.now().millisecondsSinceEpoch}_${_newCardSeq++}';
    final spec = _CardSpec(
      id: id,
      kind: _CardKind.note,
      // Centre the ~158-wide card under the tap.
      left: scenePoint.dx - 79,
      top: scenePoint.dy - 40,
      rotation: 0,
      tag: AppLocalizations.of(context)!.rdCanvasNodeNote,
      title: AppLocalizations.of(context)!.rdCanvasNewNoteTitle,
      sub: AppLocalizations.of(context)!.rdCanvasNewNoteSub,
    );
    setState(() {
      _cards = [..._cards, spec];
      _positions[id] = Offset(spec.left, spec.top);
      // Leave add-mode after placing, matching a one-shot "drop" gesture, and
      // select the new card so its edit / delete affordances show at once.
      _tool = 0;
      _selectedCard = id;
    });
    widget.onContext(_boardTitle, _cards.length);
    _scheduleSave();
    // Auto-open the editor on the fresh card (design auto-focuses its title).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editCard(id);
    });
  }

  /// The navy pencil shown on a selected card to edit its title / note.
  Widget _cardEdit(String id) {
    return GestureDetector(
      onTap: () => _editCard(id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.rd.navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: RdIcon(
            '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>',
            size: 13,
            stroke: '#FFFFFF',
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// Edit a card's title + note inline via a small sheet, then persist.
  Future<void> _editCard(String id) async {
    final card = _cards.firstWhere((c) => c.id == id);
    final titleCtl = TextEditingController(text: card.title);
    final subCtl = TextEditingController(text: card.sub ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final rd = context.rd;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              22 +
                  (MediaQuery.of(ctx).viewPadding.bottom -
                          MediaQuery.of(ctx).viewInsets.bottom)
                      .clamp(0.0, 64.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: rd.line,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.rdCanvasEditCard,
                  style: GoogleFonts.dosis(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 12),
                _editField(
                  titleCtl,
                  AppLocalizations.of(context)!.rdCanvasEditTitle,
                  autofocus: true,
                ),
                const SizedBox(height: 10),
                _editField(
                  subCtl,
                  AppLocalizations.of(context)!.rdCanvasEditNoteOptional,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(true),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rd.navy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.rdCommonSave,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (saved == true && mounted) {
      final t = titleCtl.text.trim();
      final s = subCtl.text.trim();
      setState(() {
        _cards = _cards
            .map(
              (c) => c.id == id
                  ? c.copyWith(
                      title: t.isEmpty ? c.title : t,
                      sub: s.isEmpty ? null : s,
                    )
                  : c,
            )
            .toList();
      });
      _scheduleSave();
    }
    titleCtl.dispose();
    subCtl.dispose();
  }

  Widget _editField(
    TextEditingController ctl,
    String hint, {
    bool autofocus = false,
  }) {
    final rd = context.rd;
    return TextField(
      controller: ctl,
      autofocus: autofocus,
      style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
        filled: true,
        fillColor: rd.bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rd.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rd.navy, width: 1.4),
        ),
      ),
    );
  }

  String get _boardTitle => widget.board?.title ?? '';

  // ── Persistence ──────────────────────────────────────────────────────────

  /// Debounced, best-effort save of the current cards + edges to the active
  /// board. Never persists the offline sample (there's no board to write to)
  /// and never blocks the UI — failures are swallowed.
  void _scheduleSave() {
    if (_isSample) return;
    final repo = widget.repository;
    final board = widget.board;
    if (repo == null || board == null) return;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () {
      final nodes = _cards.map(_nodeFromCard).toList();
      final edges = _edges.map(_jsonFromEdge).toList();
      repo.update(board.id, nodes: nodes, edges: edges).ignore();
    });
  }

  /// Serializes a card to its persisted node JSON. Shape:
  /// `{id, kind, left, top, rotation, title, sub?, tag?, memId?}`.
  Map<String, dynamic> _nodeFromCard(_CardSpec c) {
    final pos = _positions[c.id] ?? Offset(c.left, c.top);
    return {
      'id': c.id,
      'kind': c.kind.name,
      'left': pos.dx,
      'top': pos.dy,
      'rotation': c.rotation,
      'title': c.title,
      if (c.sub != null) 'sub': c.sub,
      if (c.tag != null) 'tag': c.tag,
      if (c.memId != null) 'memId': c.memId,
    };
  }

  /// Serializes a user connection to its persisted edge JSON `{a, b, label}`.
  Map<String, dynamic> _jsonFromEdge(_BoardEdge e) => {
    'a': e.from,
    'b': e.to,
    'label': e.label,
  };

  /// Suggested relation text for a new edge, biased by card content so the
  /// midpoint pill reads sensibly (e.g. "with someone", "reminder").
  String _relationLabel(String from, String to) {
    final a = _specById(from);
    final b = _specById(to);
    if (a.kind == _CardKind.person || b.kind == _CardKind.person) {
      final person = a.kind == _CardKind.person ? a : b;
      return 'with ${person.title}';
    }
    if (a.kind == _CardKind.voice || b.kind == _CardKind.voice) {
      return 'reminder';
    }
    if (a.kind == _CardKind.book || b.kind == _CardKind.book) {
      return 'to read';
    }
    return 'related';
  }

  _CardSpec _specById(String id) => _cards.firstWhere(
    (c) => c.id == id,
    orElse: () => const _CardSpec(
      id: '',
      kind: _CardKind.note,
      left: 0,
      top: 0,
      rotation: 0,
    ),
  );

  /// Centre of a card in board coordinates, from its live position + size.
  Offset _centerOf(String id) {
    final pos = _positions[id] ?? Offset.zero;
    final size = _specById(id).approxSize;
    return pos + Offset(size.width / 2, size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        // Draw the dragging card last so it floats above its siblings.
        final ordered = [..._cards]
          ..sort((a, b) {
            if (a.id == _draggingId) return 1;
            if (b.id == _draggingId) return -1;
            return 0;
          });
        return Stack(
          children: [
            // Board canvas background — goes dark in dark mode.
            Positioned.fill(child: ColoredBox(color: rd.bg)),
            Positioned.fill(
              child: CustomPaint(painter: _DotGridPainter(color: rd.line)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              // In add-mode, a tap on empty canvas drops a new card there.
              onTapUp: _addMode
                  ? (d) => _addCardAt((d.localPosition - _offset) / _scale)
                  : null,
              child: ClipRect(
                child: Transform.translate(
                  offset: _offset,
                  child: Transform.scale(
                    scale: _scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 1200,
                      height: 1200,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BoardEdgePainter(
                                edges: _edges,
                                centerOf: _centerOf,
                                edgeColor: rd.peri,
                                userColor: rd.navy,
                              ),
                            ),
                          ),
                          // midpoint relation-label pills for user edges
                          for (final e in _edges) _relationPill(rd, e),
                          for (final c in ordered)
                            Positioned(
                              left: _positions[c.id]!.dx,
                              top: _positions[c.id]!.dy,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _DraggableCard(
                                    spec: c,
                                    lifted: _draggingId == c.id,
                                    isSource: _connectSource == c.id,
                                    connectMode: _connectMode,
                                    selected: _selectedCard == c.id,
                                    onPanStart: () => _onCardDragStart(c.id),
                                    onPanUpdate: (delta) =>
                                        _onCardDragUpdate(c.id, delta),
                                    onPanEnd: _onCardDragEnd,
                                    onTap: () => _onCardTap(c.id),
                                  ),
                                  if (_selectedCard == c.id &&
                                      !_connectMode) ...[
                                    Positioned(
                                      top: -9,
                                      right: -9,
                                      child: _cardDelete(c.id),
                                    ),
                                    Positioned(
                                      top: -9,
                                      left: -9,
                                      child: _cardEdit(c.id),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Neutral empty state when the board has no cards yet.
            if (_cards.isEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.rdCanvasBoardEmpty,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        color: rd.muted,
                      ),
                    ),
                  ),
                ),
              ),
            // right toolbar
            Positioned(
              right: 14,
              top: 118,
              child: _Toolbar(
                selected: _tool,
                onSelect: (i) => setState(() {
                  _tool = i;
                  // Leaving connect-mode drops any pending source.
                  if (i != _connectTool) _connectSource = null;
                  _selectedCard = null; // switching tools clears selection
                }),
              ),
            ),
            // zoom / fit
            Positioned(
              left: 14,
              bottom: 116,
              child: _ZoomChip(
                level: _scale,
                onOut: () => _zoom(-0.15, viewport),
                onIn: () => _zoom(0.15, viewport),
              ),
            ),
            // Mira connection suggestion — design2 `.c-suggest`
            if (_suggestVisible &&
                _cards.length >= 2 &&
                !_connectMode &&
                !_addMode)
              Positioned(
                left: 14,
                right: 14,
                bottom: 168,
                child: _SuggestBanner(
                  onAdd: () => setState(() {
                    _tool = _connectTool;
                    _connectSource = _cards.first.id;
                  }),
                  onDismiss: () => setState(() => _suggestVisible = false),
                ),
              ),
            // connect-mode banner (top) — explains the two-tap flow + Done
            if (_connectMode)
              Positioned(
                left: 14,
                right: 14,
                top: 118,
                child: _ConnectBanner(
                  hasSource: _connectSource != null,
                  onDone: _exitConnect,
                ),
              ),
            // add-mode hint (top) — tap the canvas to drop a card
            if (_addMode)
              Positioned(
                left: 14,
                right: 14,
                top: 118,
                child: _AddBanner(onDone: () => setState(() => _tool = 0)),
              ),
          ],
        );
      },
    );
  }

  /// A small pill at the midpoint of a user edge, describing the relation.
  Widget _relationPill(RdTheme rd, _BoardEdge e) {
    final mid = Offset.lerp(_centerOf(e.from), _centerOf(e.to), 0.5)!;
    const w = 96.0;
    const h = 22.0;
    return Positioned(
      left: mid.dx - w / 2,
      top: mid.dy - h / 2,
      child: IgnorePointer(
        child: Container(
          constraints: const BoxConstraints(minWidth: 0, maxWidth: w),
          height: h,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: rd.peri.withValues(alpha: 0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF141628).withValues(alpha: 0.12),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            e.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: rd.navy,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a `_BoardCard` with drag + connect-mode interactions. Keeps rotation
/// and applies a "lifted" transform while dragging and a pulsing source
/// highlight while it is the connect source.
class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.spec,
    required this.lifted,
    required this.isSource,
    required this.connectMode,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onTap,
    this.selected = false,
  });

  final _CardSpec spec;
  final bool lifted;
  final bool isSource;
  final bool connectMode;
  final bool selected;
  final VoidCallback onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onPanStart: (_) => onPanStart(),
      onPanUpdate: (d) => onPanUpdate(d.delta),
      onPanEnd: (_) => onPanEnd(),
      onPanCancel: onPanEnd,
      child: Transform.rotate(
        angle: spec.rotation * math.pi / 180,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: lifted ? 1.05 : 1,
          child: _BoardCard(
            spec: spec,
            lifted: lifted,
            highlighted: isSource || selected,
          ),
        ),
      ),
    );
  }
}

/// Dark suggestion chip — «connect these two?» from design2 `.c-suggest`.
class _SuggestBanner extends StatelessWidget {
  const _SuggestBanner({required this.onAdd, required this.onDismiss});

  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141828).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const RdOrb(size: 30),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l10n.rdCanvasSuggestConnect,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.rdCanvasSuggestAction,
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF14328C),
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          ),
        ],
      ),
    );
  }
}

/// Connect-mode banner shown at the top of the board — explains the two-tap
/// flow and offers a Done affordance to exit connect-mode.
class _ConnectBanner extends StatelessWidget {
  const _ConnectBanner({required this.hasSource, required this.onDone});

  final bool hasSource;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: rd.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rd.navy.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const RdIcon(
            RdIcons.connect,
            size: 18,
            stroke: '#FFFFFF',
            strokeWidth: 2,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              hasSource
                  ? AppLocalizations.of(context)!.rdCanvasConnectTapSecond
                  : AppLocalizations.of(context)!.rdCanvasConnectMode,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDone,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                AppLocalizations.of(context)!.rdCommonDone,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: rd.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add-mode hint shown at the top of the board — tells the user to tap the
/// canvas to drop a card, with a Done affordance to exit add-mode.
class _AddBanner extends StatelessWidget {
  const _AddBanner({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: rd.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rd.navy.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const RdIcon(
            RdIcons.addCard,
            size: 18,
            stroke: '#FFFFFF',
            strokeWidth: 2,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.rdCanvasAddMode,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDone,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                AppLocalizations.of(context)!.rdCommonDone,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: rd.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});

  /// Dot tint — the theme line colour, passed from the widget so the grid
  /// tracks the active [RdTheme] (painters cannot read `context`).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 22.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

class _BoardEdgePainter extends CustomPainter {
  _BoardEdgePainter({
    this.edges = const [],
    this.centerOf,
    required this.edgeColor,
    required this.userColor,
  });

  /// User-created connections to render as cubic beziers between card centres.
  final List<_BoardEdge> edges;

  /// Resolves a card id to its live centre in board coordinates.
  final Offset Function(String id)? centerOf;

  /// Ambient/decorative edge tint (periwinkle) and the user-edge tint (navy),
  /// passed from the widget so both track the active [RdTheme].
  final Color edgeColor;
  final Color userColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = edgeColor.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    void bez(
      double ax,
      double ay,
      double c1x,
      double c1y,
      double c2x,
      double c2y,
      double bx,
      double by,
    ) {
      final path = Path()
        ..moveTo(ax, ay)
        ..cubicTo(c1x, c1y, c2x, c2y, bx, by);
      canvas.drawPath(path, paint);
    }

    // Ambient, decorative links that give the board its lived-in feel.
    bez(250, 300, 300, 340, 300, 380, 268, 430);
    bez(330, 300, 380, 330, 420, 360, 452, 402);
    bez(300, 470, 360, 500, 400, 520, 452, 470);
    bez(250, 560, 300, 590, 360, 600, 300, 640);

    final dashed = Paint()
      ..style = PaintingStyle.stroke
      ..color = edgeColor.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // dashed bezier, drawn as short segments
    final path = Path()
      ..moveTo(492, 452)
      ..cubicTo(520, 520, 470, 590, 392, 636);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final seg = metric.extractPath(d, d + 2);
        canvas.drawPath(seg, dashed);
        d += 9;
      }
    }

    // User-created connections — solid cubic beziers between the two card
    // centres, gently bowed so multiple edges stay readable.
    final resolve = centerOf;
    if (resolve != null) {
      final userPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = userColor.withValues(alpha: 0.85)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (final e in edges) {
        final a = resolve(e.from);
        final b = resolve(e.to);
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        // Control points offset perpendicular to the line for a soft curve.
        final len = math.sqrt(dx * dx + dy * dy);
        final nx = len == 0 ? 0.0 : -dy / len;
        final ny = len == 0 ? 0.0 : dx / len;
        final bow = (len * 0.16).clamp(10.0, 48.0);
        final c1 = Offset(
          a.dx + dx * 0.33 + nx * bow,
          a.dy + dy * 0.33 + ny * bow,
        );
        final c2 = Offset(
          a.dx + dx * 0.66 + nx * bow,
          a.dy + dy * 0.66 + ny * bow,
        );
        final userPath = Path()
          ..moveTo(a.dx, a.dy)
          ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
        canvas.drawPath(userPath, userPaint);
        // Small endpoint dots to anchor the connection visually.
        final dot = Paint()..color = userColor.withValues(alpha: 0.85);
        canvas.drawCircle(a, 3, dot);
        canvas.drawCircle(b, 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_BoardEdgePainter old) =>
      old.edges != edges ||
      old.centerOf != centerOf ||
      old.edgeColor != edgeColor ||
      old.userColor != userColor;
}

enum _CardKind { note, photo, voice, link, sticky, book, person }

class _CardSpec {
  const _CardSpec({
    required this.id,
    required this.kind,
    required this.left,
    required this.top,
    required this.rotation,
    this.title = '',
    this.sub,
    this.tag,
    this.memId,
  });

  final String id;
  final _CardKind kind;
  final double left;
  final double top;
  final double rotation;
  final String title;
  final String? sub;
  final String? tag;

  /// Optional memory reference — set when this card mirrors a memory node.
  final String? memId;

  _CardSpec copyWith({String? title, String? sub, String? tag}) => _CardSpec(
    id: id,
    kind: kind,
    left: left,
    top: top,
    rotation: rotation,
    title: title ?? this.title,
    sub: sub ?? this.sub,
    tag: tag ?? this.tag,
    memId: memId,
  );

  /// Approximate rendered size per card kind — used to derive card centres for
  /// connect-mode edges. Widths mirror the layout constants in `_BoardCard`;
  /// heights are eyeballed to the designed content so the bezier endpoints land
  /// roughly on each card's middle.
  Size get approxSize {
    switch (kind) {
      case _CardKind.photo:
        return const Size(158, 150);
      case _CardKind.sticky:
        return const Size(150, 150);
      case _CardKind.person:
        return const Size(128, 64);
      case _CardKind.note:
        return const Size(158, 96);
      case _CardKind.voice:
      case _CardKind.link:
      case _CardKind.book:
        return const Size(158, 92);
    }
  }
}

double _asDouble(Object? v, double fallback) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

_CardKind _cardKindFromName(String? name) {
  for (final k in _CardKind.values) {
    if (k.name == name) return k;
  }
  return _CardKind.note;
}

/// Deserializes a persisted board node into a `_CardSpec`. Tolerant of missing
/// keys so a partially-formed node still renders. Returns null only if there's
/// no usable id.
_CardSpec? _cardFromNode(Map<String, dynamic> n) {
  final id = n['id'];
  if (id is! String || id.isEmpty) return null;
  final kind = _cardKindFromName(n['kind'] as String?);
  final title = (n['title'] as String?) ?? '';
  final sub = n['sub'] as String?;
  // Person/photo/sticky cards render sub differently; the person card asserts a
  // non-null sub, so guarantee one when the kind needs it.
  final safeSub = (kind == _CardKind.person && (sub == null || sub.isEmpty))
      ? ' '
      : sub;
  return _CardSpec(
    id: id,
    kind: kind,
    left: _asDouble(n['left'], 0),
    top: _asDouble(n['top'], 0),
    rotation: _asDouble(n['rotation'], 0),
    title: title,
    sub: safeSub,
    tag: n['tag'] as String?,
    memId: n['memId'] as String?,
  );
}

/// Deserializes a persisted edge `{a, b, label}` into a `_BoardEdge`.
_BoardEdge? _edgeFromJson(Map<String, dynamic> e) {
  final a = e['a'];
  final b = e['b'];
  if (a is! String || b is! String || a.isEmpty || b.isEmpty) return null;
  return _BoardEdge(
    from: a,
    to: b,
    label: (e['label'] as String?) ?? 'related',
  );
}

({Color bg, String stroke}) _tagStyle(String tag) {
  switch (tag) {
    case 'Voice':
      return (bg: const Color(0xFFE7EFEA), stroke: '#2E7D4F');
    case 'Link':
      return (bg: const Color(0xFFFBEFE7), stroke: '#B65A2E');
    case 'Book':
    case 'Note':
    default:
      return (bg: RdColors.periSoft, stroke: '#14328C');
  }
}

String _tagIcon(String tag) {
  switch (tag) {
    case 'Voice':
      return RdIcons.micSimple;
    case 'Link':
      return RdIcons.linkChain;
    case 'Book':
      return RdIcons.book;
    default:
      return RdIcons.pencil;
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({
    required this.spec,
    this.lifted = false,
    this.highlighted = false,
  });

  final _CardSpec spec;

  /// True while the card is being dragged — bigger shadow.
  final bool lifted;

  /// True when the card is the connect-mode source — peri highlight border.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    switch (spec.kind) {
      case _CardKind.sticky:
        return _sticky(rd);
      case _CardKind.person:
        return _person(rd);
      case _CardKind.photo:
        return _photo(rd);
      default:
        return _basic(rd);
    }
  }

  /// Border colour/width picks up the connect-source highlight.
  Border _borderOf(RdTheme rd) => Border.all(
    color: highlighted ? rd.peri : rd.line,
    width: highlighted ? 2 : 1,
  );

  BoxDecoration _shellOf(RdTheme rd) => BoxDecoration(
    color: rd.card,
    borderRadius: BorderRadius.circular(16),
    border: _borderOf(rd),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF141628).withValues(alpha: lifted ? 0.42 : 0.28),
        blurRadius: lifted ? 40 : 24,
        spreadRadius: lifted ? -10 : -14,
        offset: Offset(0, lifted ? 20 : 10),
      ),
      if (highlighted)
        BoxShadow(
          color: rd.peri.withValues(alpha: 0.45),
          blurRadius: 0,
          spreadRadius: 3,
        ),
    ],
  );

  Widget _tagPill(String tag) {
    final style = _tagStyle(tag);
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(_tagIcon(tag), size: 11, stroke: style.stroke, strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            tag,
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(
                int.parse('FF${style.stroke.substring(1)}', radix: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(RdTheme rd) => Text(
    spec.title,
    style: GoogleFonts.vazirmatn(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: rd.ink,
      height: 1.32,
    ),
  );

  Widget _sub(RdTheme rd) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      spec.sub!,
      style: GoogleFonts.vazirmatn(
        fontSize: 11.5,
        color: rd.muted,
        height: 1.4,
      ),
    ),
  );

  Widget _basic(RdTheme rd) {
    return Container(
      width: 158,
      decoration: _shellOf(rd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spec.tag != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 0),
              child: _tagPill(spec.tag!),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [_title(rd), if (spec.sub != null) _sub(rd)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(RdTheme rd) {
    return Container(
      width: 158,
      decoration: _shellOf(rd),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 92,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C5578), Color(0xFF16324F)],
              ),
            ),
            child: Text(
              spec.sub ?? '',
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 13),
            child: _title(rd),
          ),
        ],
      ),
    );
  }

  Widget _sticky(RdTheme rd) {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? rd.peri : const Color(0x4DBEA046),
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF78641E,
            ).withValues(alpha: lifted ? 0.42 : 0.28),
            blurRadius: lifted ? 40 : 24,
            spreadRadius: lifted ? -10 : -14,
            offset: Offset(0, lifted ? 20 : 10),
          ),
          if (highlighted)
            BoxShadow(
              color: rd.peri.withValues(alpha: 0.45),
              blurRadius: 0,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spec.title,
            style: GoogleFonts.vazirmatn(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6A5312),
            ),
          ),
          if (spec.sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                spec.sub!,
                style: GoogleFonts.vazirmatn(
                  fontSize: 11.5,
                  color: const Color(0xFF7A6526),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _person(RdTheme rd) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(12),
      decoration: _shellOf(rd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.28, -0.4),
                colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
              ),
            ),
            child: Center(
              child: Text(
                spec.title.isNotEmpty ? spec.title[0].toUpperCase() : '?',
                style: GoogleFonts.dosis(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spec.title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
              if (spec.sub != null) ...[
                const SizedBox(height: 1),
                Text(
                  spec.sub!,
                  style: GoogleFonts.vazirmatn(fontSize: 11, color: rd.muted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _tools = [
    RdIcons.move,
    RdIcons.addCard,
    RdIcons.textT,
    RdIcons.connect,
  ];

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628).withValues(alpha: 0.35),
            blurRadius: 26,
            spreadRadius: -12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _tools.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected == i ? rd.navy : Colors.transparent,
                ),
                child: Center(
                  child: RdIcon(
                    _tools[i],
                    size: 20,
                    color: selected == i ? Colors.white : rd.muted,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ZoomChip extends StatelessWidget {
  const _ZoomChip({
    required this.level,
    required this.onOut,
    required this.onIn,
  });

  final double level;
  final VoidCallback onOut;
  final VoidCallback onIn;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(rd, '−', onOut),
          SizedBox(
            width: 40,
            child: Text(
              '${(level * 100).round()}%',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rd.muted,
              ),
            ),
          ),
          _btn(rd, '+', onIn),
        ],
      ),
    );
  }

  Widget _btn(RdTheme rd, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 18, color: rd.muted, height: 1),
        ),
      ),
    );
  }
}
