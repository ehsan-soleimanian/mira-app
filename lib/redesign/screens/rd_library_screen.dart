import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/app/memory_store.dart';
import 'package:mira_app/models/api/collection_models.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_collection_picker.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_voice_search_overlay.dart';

/// Library — browse every captured memory: search, type filters, Mira's
/// collections, and a day-grouped list. Long-press a memory to enter
/// multi-select. Faithful to `.rd-library`. Items load from `libraryRepository`
/// (`/library/items`); search and type filters run locally over the loaded set,
/// with a sample fallback when the backend is unreachable.
class RdLibraryScreen extends StatefulWidget {
  const RdLibraryScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdLibraryScreen> createState() => _RdLibraryScreenState();
}

class _RdLibraryScreenState extends State<RdLibraryScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  String _filter = 'all';
  String _query = '';
  bool _selecting = false;
  bool _voiceOverlay = false;
  final Set<String> _selected = {};

  /// User collections from the backend (null until loaded / unreachable).
  List<MemoryCollection>? _cols;

  /// When a collection card is opened, the Library filters to its members.
  Set<String>? _colFilterIds;
  String? _colFilterName;

  /// Archived view: shows only archived memories with a Restore action.
  bool _archivedView = false;
  bool _collectionsGridView = false;
  List<_LibMem>? _archivedItems;

  /// Live items, derived from the shared [MemoryStore]; null until the first
  /// successful load. Falls back to the sample set when the backend is
  /// unreachable (the store never loaded).
  List<_LibMem>? _items;
  bool _loaded = false;

  /// The shared memory cache we read from and subscribe to, so edits made on
  /// other screens (e.g. Memory detail) reflect here live.
  MemoryStore? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppScope.servicesOf(context).memoryStore;
    if (!identical(store, _store)) {
      _store?.removeListener(_onStoreChanged);
      _store = store..addListener(_onStoreChanged);
    }
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  /// Re-maps the browse list from the store whenever it changes (an edit or
  /// removal elsewhere), so the Library stays in sync without a re-fetch.
  void _onStoreChanged() {
    final store = _store;
    if (!mounted || store == null || !store.loaded) return;
    setState(() => _items = store.getAll().map(_toLibMem).toList());
  }

  Future<void> _load() async {
    final services = AppScope.servicesOf(context);
    try {
      // Load through the shared store (source of truth) rather than hitting the
      // repository directly, so this screen and the others share one cache.
      await services.memoryStore.load();
      if (mounted && services.memoryStore.loaded) {
        setState(() =>
            _items = services.memoryStore.getAll().map(_toLibMem).toList());
      }
    } catch (_) {
      // Backend unreachable — keep the sample library.
    }
    try {
      final cols = await services.collectionsRepository.list();
      if (mounted) setState(() => _cols = cols);
    } catch (_) {
      // Keep the sample collections.
    }
  }

  _LibMem _toLibMem(LibraryItem item) {
    final l10n = AppLocalizations.of(context)!;
    final type = _memTypeFor(item.type);
    final title = item.title.trim();
    return _LibMem(
      id: item.id,
      dayBucket: _dayBucket(item.createdAt),
      type: type,
      title: title.isEmpty ? l10n.rdLibraryUntitled : title,
      sub: item.summary,
      createdAt: item.createdAt,
      searchText: '${item.title} ${item.summary}'.toLowerCase(),
      pinned: (item.metadata['pinned'] as bool?) ?? false,
    );
  }

  static _MemType _memTypeFor(String type) {
    switch (type.toLowerCase()) {
      case 'voice':
      case 'audio':
      case 'meeting':
        return _MemType.voice;
      case 'link':
      case 'url':
      case 'article':
        return _MemType.link;
      case 'image':
      case 'photo':
      case 'pdf':
      case 'file':
        return _MemType.photo;
      case 'event':
        return _MemType.event;
      default:
        return _MemType.note;
    }
  }

  String _typeLabelFor(AppLocalizations l10n, _MemType t) {
    switch (t) {
      case _MemType.voice:
        return l10n.rdLibraryTypeVoice;
      case _MemType.link:
        return l10n.rdLibraryTypeLink;
      case _MemType.photo:
        return l10n.rdLibraryTypePhoto;
      case _MemType.event:
        return l10n.rdLibraryTypeEvent;
      case _MemType.note:
        return l10n.rdLibraryTypeNote;
    }
  }

  _DayBucket _dayBucket(DateTime dt) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;
    if (days <= 0) return _DayBucket.today;
    if (days < 7) return _DayBucket.thisWeek;
    return _DayBucket.earlier;
  }

  String _dayBucketLabel(AppLocalizations l10n, _DayBucket bucket) {
    switch (bucket) {
      case _DayBucket.today:
        return l10n.rdLibraryDayToday;
      case _DayBucket.thisWeek:
        return l10n.rdLibraryDayThisWeek;
      case _DayBucket.earlier:
        return l10n.rdLibraryDayEarlier;
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    _searchCtl.dispose();
    super.dispose();
  }

  List<_LibMem> get _visible {
    final source = _items ?? const <_LibMem>[];
    final q = _query.trim().toLowerCase();
    final colIds = _colFilterIds;
    return source.where((m) {
      final matchesCollection = colIds == null || colIds.contains(m.id);
      final matchesFilter = _filter == 'all' || m.type.id == _filter;
      final matchesQuery = q.isEmpty ||
          m.searchText.contains(q) ||
          m.title.toLowerCase().contains(q);
      return matchesCollection && matchesFilter && matchesQuery;
    }).toList();
  }

  bool get _searching =>
      _query.trim().isNotEmpty || _filter != 'all' || _colFilterIds != null;

  void _onMemTap(_LibMem m) {
    if (_selecting) {
      setState(() {
        _selected.contains(m.id) ? _selected.remove(m.id) : _selected.add(m.id);
      });
      return;
    }
    widget.go(
      'memory',
      arg: RdMemoryArg(
        id: m.id,
        title: m.title,
        body: m.sub,
        isVoice: m.type == _MemType.voice,
      ),
    );
  }

  void _enterSelect(String id) {
    setState(() {
      _selecting = true;
      _selected
        ..clear()
        ..add(id);
    });
  }

  void _exitSelect() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _toggleAll(List<String> ids) {
    final allSelected = ids.isNotEmpty && ids.every(_selected.contains);
    setState(() {
      _selected
        ..clear()
        ..addAll(allSelected ? const [] : ids);
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    final rd = context.rd;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: rd.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.bg),
          ),
        ),
      );
  }

  /// "Collection" action — pick an existing collection or create one, then add
  /// the selected memories to it via `collectionsRepository.addItems`.
  Future<void> _addSelectedToCollection() async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final services = AppScope.servicesOf(context);
    final choice = await showModalBottomSheet<RdColChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          RdCollectionPickerSheet(collections: _cols ?? const []),
    );
    if (choice == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final target = choice.collection ??
          await services.collectionsRepository.create(name: choice.name!);
      final updated =
          await services.collectionsRepository.addItems(target.id, ids);
      final refreshed = await services.collectionsRepository.list();
      if (!mounted) return;
      setState(() => _cols = refreshed);
      _exitSelect();
      _toast(l10n.rdLibraryAddedToCollection(ids.length, updated.name));
    } catch (_) {
      _toast(AppLocalizations.of(context)!.rdLibraryAddToCollectionFailed);
    }
  }

  /// Selected memories resolved to their `_LibMem`s — needed to build board
  /// cards (title / type / summary), taken from the currently-loaded source.
  List<_LibMem> _selectedMems() {
    final source = _items ?? const <_LibMem>[];
    return source.where((m) => _selected.contains(m.id)).toList();
  }

  /// "Add to board" action — pick an existing Canvas board (or create one), then
  /// append the selected memories as memory-ref cards. Best-effort: re-fetches
  /// the board first so we append onto (rather than clobber) its current nodes,
  /// then persists via `canvasRepository.update`.
  Future<void> _addSelectedToBoard() async {
    final mems = _selectedMems();
    if (mems.isEmpty) return;
    final repo = AppScope.servicesOf(context).canvasRepository;

    // Load the board list for the picker (best-effort — an empty list still
    // lets the user create a fresh board to drop the memories onto).
    List<CanvasDto> boards;
    try {
      boards = await repo.list();
    } catch (_) {
      boards = const [];
    }
    if (!mounted) return;

    final choice = await showModalBottomSheet<_BoardChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BoardPickerSheet(boards: boards),
    );
    if (choice == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      // Resolve the target board (create it first when "New board" was chosen).
      final target = choice.board ?? await repo.create(title: choice.name!);
      // Re-fetch so we merge onto the freshest node set.
      final board = await repo.fetch(target.id);
      final nodes = [...board.nodes, ..._boardNodesFor(mems, board.nodes, l10n)];
      await repo.update(board.id, nodes: nodes);
      if (!mounted) return;
      final name = board.title.trim().isEmpty
          ? l10n.rdLibraryFallbackBoard
          : board.title.trim();
      _exitSelect();
      _boardAddedToast(mems.length, name);
    } catch (_) {
      _toast(l10n.rdLibraryAddToBoardFailed);
    }
  }

  /// Builds memory-ref board nodes for [mems], matching the board's node shape
  /// `{id, kind, left, top, rotation, title, sub?, tag?, memId}`. New cards flow
  /// in a 3-wide grid dropped below any [existing] cards so they never stack.
  List<Map<String, dynamic>> _boardNodesFor(
    List<_LibMem> mems,
    List<Map<String, dynamic>> existing,
    AppLocalizations l10n,
  ) {
    const startLeft = 170.0;
    const stepX = 185.0;
    const stepY = 155.0;
    const perRow = 3;

    // Drop the batch below the lowest existing card (or near the top on an
    // empty board) so we don't land on top of what's already there.
    var baseTop = 220.0;
    if (existing.isNotEmpty) {
      var maxTop = double.negativeInfinity;
      for (final n in existing) {
        final t = n['top'];
        if (t is num && t.toDouble() > maxTop) maxTop = t.toDouble();
      }
      if (maxTop.isFinite) baseTop = maxTop + stepY;
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final nodes = <Map<String, dynamic>>[];
    for (var i = 0; i < mems.length; i++) {
      final m = mems[i];
      final col = i % perRow;
      final row = i ~/ perRow;
      final sub = m.sub.trim();
      nodes.add(<String, dynamic>{
        'id': 'lib${stamp}_$i',
        'kind': _boardKindFor(m.type),
        'left': startLeft + col * stepX,
        'top': baseTop + row * stepY,
        'rotation': 0.0,
        'title': m.title,
        if (sub.isNotEmpty) 'sub': sub,
        'tag': _typeLabelFor(l10n, m.type),
        'memId': m.id,
      });
    }
    return nodes;
  }

  /// Maps a library memory type to a board card `kind`. The board styles only
  /// voice / link distinctly; everything else reads best as a basic note card
  /// (so the real title + summary show, not the photo card's fixed artwork).
  static String _boardKindFor(_MemType t) {
    switch (t) {
      case _MemType.voice:
        return 'voice';
      case _MemType.link:
        return 'link';
      case _MemType.note:
      case _MemType.photo:
      case _MemType.event:
        return 'note';
    }
  }

  /// Confirms the add, with a shortcut to jump straight to the Canvas board.
  void _boardAddedToast(int n, String board) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: rd.ink,
          content: Text(
            l10n.rdLibraryAddedToBoard(n, board),
            style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.bg),
          ),
          action: SnackBarAction(
            label: l10n.rdCommonView,
            textColor: rd.peri,
            onPressed: () => widget.go('canvas'),
          ),
        ),
      );
  }

  /// "Delete" action — remove the selected memories via `libraryRepository.delete`
  /// (optimistically dropped from the list first for a responsive feel).
  /// Removes the selected memories from the browse list with an Undo affordance.
  /// The backend change (and shared-store drop) is deferred until the Undo
  /// window closes, so "Undo" is lossless — nothing is committed if you tap it.
  void _undoableRemove({
    required Set<String> ids,
    required String Function(AppLocalizations l10n, int count) message,
    required Future<void> Function() commit,
  }) {
    if (ids.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final before = List<_LibMem>.of(_items ?? const <_LibMem>[]);
    setState(() => _items = before.where((m) => !ids.contains(m.id)).toList());
    _exitSelect();
    final n = ids.length;
    var undone = false;
    final controller = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();
    controller
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.rd.ink,
            content: Text(
              message(l10n, n),
              style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
            ),
            action: SnackBarAction(
              label: l10n.rdCommonUndo,
              textColor: Colors.white,
              onPressed: () {
                undone = true;
                if (mounted) setState(() => _items = before);
              },
            ),
          ),
        )
        .closed
        .then((_) {
      if (!undone) commit().ignore();
    });
  }

  Future<void> _deleteSelected() async {
    final services = AppScope.servicesOf(context);
    final ids = _selected.toSet();
    _undoableRemove(
      ids: ids,
      message: (l10n, n) => l10n.rdLibraryDeletedCount(n),
      commit: () async {
        for (final id in ids) {
          services.memoryStore.removeLocal(id);
          try {
            await services.libraryRepository.delete(id);
          } catch (_) {}
        }
      },
    );
  }

  /// "Pin" action — flag the selected memories via bulk-actions (best-effort).
  Future<void> _pinSelected() async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final services = AppScope.servicesOf(context);
    final n = ids.length;
    final pinnedMessage = AppLocalizations.of(context)!.rdLibraryPinnedCount(n);
    _exitSelect();
    try {
      await services.libraryRepository.bulkAction(ids, 'pin');
    } catch (_) {}
    if (!mounted) return;
    _toast(pinnedMessage);
  }

  /// "Archive" action — archive via bulk-actions and drop from the browse list
  /// (archived items move to the Archived view).
  Future<void> _archiveSelected() async {
    final services = AppScope.servicesOf(context);
    final ids = _selected.toSet();
    _undoableRemove(
      ids: ids,
      message: (l10n, n) => l10n.rdLibraryArchivedCount(n),
      commit: () async {
        for (final id in ids) {
          services.memoryStore.removeLocal(id);
        }
        try {
          await services.libraryRepository.bulkAction(ids.toList(), 'archive');
        } catch (_) {}
      },
    );
  }

  /// Open the Archived view — loads archived items (`?includeArchived`) and
  /// filters to the ones flagged `archived` in their metadata.
  Future<void> _openArchived() async {
    setState(() {
      _archivedView = true;
      _archivedItems = null;
    });
    try {
      final services = AppScope.servicesOf(context);
      final items =
          await services.libraryRepository.list(includeArchived: true);
      final archived = items
          .where((i) => (i.metadata['archived'] as bool?) ?? false)
          .map(_toLibMem)
          .toList();
      if (mounted) setState(() => _archivedItems = archived);
    } catch (_) {
      if (mounted) setState(() => _archivedItems = const []);
    }
  }

  Future<void> _unarchive(_LibMem m) async {
    final services = AppScope.servicesOf(context);
    final restoredMessage =
        AppLocalizations.of(context)!.rdLibraryRestored(m.title);
    setState(() => _archivedItems =
        (_archivedItems ?? const []).where((x) => x.id != m.id).toList());
    try {
      await services.libraryRepository.bulkAction([m.id], 'restore');
    } catch (_) {}
    if (!mounted) return;
    _toast(restoredMessage);
  }

  Widget _archivedEntry() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openArchived,
      child: Container(
        margin: const EdgeInsets.fromLTRB(26, 16, 26, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          children: [
            RdIcon(RdIcons.archive, size: 17, color: rd.muted, strokeWidth: 1.8),
            const SizedBox(width: 12),
            Text(
              l10n.rdLibraryArchivedTitle,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: rd.ink,
              ),
            ),
            const Spacer(),
            Text(
              l10n.rdCommonView,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: rd.peri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _archivedScaffold() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final items = _archivedItems;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 26, 8),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _archivedView = false),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: RdIcon(RdIcons.chevronLeft,
                          size: 22, color: rd.ink, strokeWidth: 1.8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.rdLibraryArchivedTitle,
                    style: GoogleFonts.dosis(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: rd.ink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items == null
                  ? Center(child: CircularProgressIndicator(color: rd.peri))
                  : items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              l10n.rdLibraryArchivedEmpty,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 13.5,
                                color: rd.faint,
                                height: 1.5,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: items.length,
                          itemBuilder: (context, i) => _archivedTile(items[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// "See all" collections — a grid of every collection plus the Archived
  /// entry (mirrors the design's `view === "collections"` sub-view).
  Widget _collectionsScaffold() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final cols = _cols ?? const [];
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 26, 8),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _collectionsGridView = false),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: RdIcon(RdIcons.chevronLeft,
                          size: 22, color: rd.ink, strokeWidth: 1.8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.rdLibraryCollections,
                    style: GoogleFonts.dosis(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: rd.ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  for (var i = 0; i < cols.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() => _collectionsGridView = false);
                        _openCollection(cols[i]);
                      },
                      child: _CollectionCard(
                        icon: _iconForCollection(cols[i].icon),
                        name: cols[i].name,
                        count: _countLabel(cols[i].itemCount),
                        colors: _colPalettes[i % _colPalettes.length],
                        expand: true,
                      ),
                    ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _collectionsGridView = false);
                      _openArchived();
                    },
                    child: _CollectionCard(
                      icon: RdIcons.archive,
                      name: l10n.rdLibraryArchivedTitle,
                      count: l10n.rdLibraryOutOfTheWay,
                      colors: const [Color(0xFFF1F1F4), Color(0xFFE7E7EC)],
                      expand: true,
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

  Widget _archivedTile(_LibMem m) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  m.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _unarchive(m),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: rd.periSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                l10n.rdLibraryRestore,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: rd.peri,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    if (_archivedView) return _archivedScaffold();
    if (_collectionsGridView) return _collectionsScaffold();
    final visible = _visible;
    final days = <_DayBucket>[];
    for (final m in visible) {
      if (!days.contains(m.dayBucket)) days.add(m.dayBucket);
    }

    return Scaffold(
      backgroundColor: rd.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: _selecting ? 110 : 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selecting)
                      const SizedBox(height: 78)
                    else ...[
                      _header(),
                      _searchBar(),
                      _filters(),
                      if (_searching)
                        _searchSummary(visible.length)
                      else ...[
                        _collectionsLabel(),
                        _collections(),
                        _archivedEntry(),
                      ],
                    ],
                    if (visible.isEmpty)
                      _emptyHint()
                    else
                      for (final day in days) ...[
                        _dayLabel(day),
                        for (final m
                            in visible.where((x) => x.dayBucket == day))
                          _MemTile(
                            mem: m,
                            selecting: _selecting,
                            selected: _selected.contains(m.id),
                            onTap: () => _onMemTap(m),
                            onLongPress: () => _enterSelect(m.id),
                            query: _query.trim().toLowerCase(),
                          ),
                      ],
                    if (!_selecting && !_searching) _end(),
                  ],
                ),
              ),
            ),
          ),
          if (_selecting) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _selBar(visible.map((m) => m.id).toList()),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _selActions()),
          ] else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [rd.bg.withValues(alpha: 0.0), rd.bg],
                    stops: const [0.0, 0.55],
                  ),
                ),
                child: RdBottomNav(active: 'library', go: widget.go),
              ),
            ),
          if (_voiceOverlay)
            Positioned.fill(
              child: RdVoiceSearchOverlay(
                onResult: _onVoiceResult,
                onCancel: () => setState(() => _voiceOverlay = false),
              ),
            ),
        ],
      ),
    );
  }

  // ── header ──────────────────────────────────────────────────────────
  Widget _header() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rdLibraryYourMemory,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: rd.peri,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rdLibraryTitle,
                      style: GoogleFonts.dosis(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: rd.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.rdLibraryKeptCount(_keptCount),
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: rd.muted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.go('ask'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rd.card,
                    border: Border.all(color: rd.line, width: 1),
                  ),
                  child: Center(
                    child: RdIcon(
                      RdIcons.search,
                      size: 18,
                      color: rd.gearIcon,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => widget.go('account'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rd.card,
                    border: Border.all(color: rd.line, width: 1),
                  ),
                  child: Center(
                    child: RdIcon(
                      RdIcons.gear,
                      size: 19,
                      color: rd.gearIcon,
                      strokeWidth: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── search ──────────────────────────────────────────────────────────
  Widget _searchBar() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 20, 26, 0),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          RdIcon(RdIcons.search, size: 19, color: rd.faint, strokeWidth: 2),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v),
              cursorColor: rd.navy,
              style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.rdLibrarySearchHint,
                hintStyle:
                    GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _voiceSearch,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rd.periSoft,
              ),
              child: const Center(
                child: RdIcon(
                  RdIcons.mic,
                  size: 15,
                  stroke: '#14328C',
                  strokeWidth: 1.9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Voice search — record a phrase, transcribe it, and drop it into the query.
  Future<void> _voiceSearch() async {
    setState(() => _voiceOverlay = true);
  }

  void _onVoiceResult(String text) {
    setState(() {
      _voiceOverlay = false;
      _query = text.trim();
      _searchCtl.text = text.trim();
    });
  }

  // ── filter chips ────────────────────────────────────────────────────
  Widget _filters() {
    final l10n = AppLocalizations.of(context)!;
    final chips = [
      ('all', l10n.rdLibraryFilterAll, null),
      ('note', l10n.rdLibraryFilterNotes, RdIcons.pencil),
      ('voice', l10n.rdLibraryFilterVoice, RdIcons.micSimple),
      ('photo', l10n.rdLibraryFilterPhotos, RdIcons.photo),
      ('link', l10n.rdLibraryFilterLinks, RdIcons.linkChain),
      ('event', l10n.rdLibraryFilterEvents, RdIcons.calendar),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 4),
      child: Row(
        children: [
          for (final c in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: c.$2,
                icon: c.$3,
                active: _filter == c.$1,
                onTap: () => setState(() => _filter = c.$1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchSummary(int count) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final q = _query.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: count == 0
                    ? [
                        TextSpan(text: l10n.rdLibraryNoMatches),
                        if (q.isNotEmpty) TextSpan(text: l10n.rdLibrarySearchFor(q)),
                        if (_colFilterName != null)
                          TextSpan(text: l10n.rdLibrarySearchIn(_colFilterName!)),
                      ]
                    : [
                        TextSpan(
                          text: l10n.rdLibraryMemoryCount(count),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: rd.ink,
                          ),
                        ),
                        if (q.isNotEmpty) TextSpan(text: l10n.rdLibrarySearchFor(q)),
                        if (_colFilterName != null)
                          TextSpan(text: l10n.rdLibrarySearchIn(_colFilterName!)),
                      ],
                style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.muted),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _query = '';
              _filter = 'all';
              _colFilterIds = null;
              _colFilterName = null;
              _searchCtl.clear();
            }),
            child: Text(
              l10n.rdCommonClear,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: rd.peri,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── collections ─────────────────────────────────────────────────────
  Widget _collectionsLabel() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RdIcon(RdIcons.folder, size: 15, color: rd.peri, strokeWidth: 2),
              const SizedBox(width: 8),
              Text(
                l10n.rdLibraryGroupedForYou,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: rd.faint,
                ),
              ),
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _collectionsGridView = true),
            child: Text(
              l10n.rdSeeAll,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: rd.peri,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _colPalettes = [
    [Color(0xFFEEF1FA), Color(0xFFE3E8F6)],
    [Color(0xFFF0EEF7), Color(0xFFE8E3F2)],
    [Color(0xFFEAF1EE), Color(0xFFDFEDE6)],
  ];

  Widget _collections() {
    final cols = _cols;
    if (cols == null || cols.isEmpty) return _emptyCollections();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 4),
      child: Row(
        children: [
          for (var i = 0; i < cols.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openCollection(cols[i]),
              child: _CollectionCard(
                icon: _iconForCollection(cols[i].icon),
                name: cols[i].name,
                count: _countLabel(cols[i].itemCount),
                colors: _colPalettes[i % _colPalettes.length],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyCollections() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 4, 26, 4),
      child: Text(
        l10n.rdLibraryNoCollectionsYet,
        style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.faint),
      ),
    );
  }

  String _countLabel(int n) =>
      AppLocalizations.of(context)!.rdLibraryMemoryCount(n);

  static String _iconForCollection(String? icon) {
    switch ((icon ?? '').toLowerCase()) {
      case 'people':
      case 'person':
        return RdIcons.people;
      case 'work':
      case 'briefcase':
        return RdIcons.work;
      case 'pin':
      case 'trip':
      case 'beach':
      case 'travel':
        return RdIcons.pin;
      default:
        return RdIcons.folder;
    }
  }

  Future<void> _openCollection(MemoryCollection c) async {
    try {
      final detail =
          await AppScope.servicesOf(context).collectionsRepository.get(c.id);
      if (!mounted) return;
      setState(() {
        _colFilterIds = detail.memoryIds.toSet();
        _colFilterName = c.name;
        _query = '';
        _filter = 'all';
        _searchCtl.clear();
      });
    } catch (_) {
      _toast(AppLocalizations.of(context)!
          .rdLibraryCouldntOpenCollection(c.name));
    }
  }

  // ── list scaffolding ────────────────────────────────────────────────
  Widget _dayLabel(_DayBucket day) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 4),
      child: Text(
        _dayBucketLabel(l10n, day).toUpperCase(),
        style: GoogleFonts.vazirmatn(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: rd.faint,
        ),
      ),
    );
  }

  Widget _emptyHint() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Text(
        l10n.rdLibraryEmptyFilter,
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 13.5,
          color: rd.faint,
          height: 1.5,
        ),
      ),
    );
  }

  /// Total memories kept — the real count from the loaded library (0 until
  /// the first load resolves).
  int get _keptCount => _items?.length ?? 0;

  Widget _end() {
    if (_keptCount == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
      child: Text(
        l10n.rdLibraryEndMessage(_keptCount),
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          color: rd.faint,
          height: 1.5,
        ),
      ),
    );
  }

  // ── selection chrome ────────────────────────────────────────────────
  Widget _selBar(List<String> ids) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final allSelected = ids.isNotEmpty && ids.every(_selected.contains);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 14),
      decoration: BoxDecoration(
        color: rd.bg,
        border: Border(bottom: BorderSide(color: rd.line, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _exitSelect,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rd.card,
                border: Border.all(color: rd.line, width: 1),
              ),
              child: Center(
                child: RdIcon(
                  RdIcons.close,
                  size: 17,
                  color: rd.ink,
                  strokeWidth: 2.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selected.isEmpty
                  ? l10n.rdLibrarySelectMemories
                  : l10n.rdLibrarySelectedCount(_selected.length),
              style: GoogleFonts.dosis(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: rd.ink,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _toggleAll(ids),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                allSelected ? l10n.rdLibraryDeselectAll : l10n.rdLibrarySelectAll,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: rd.peri,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selActions() {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final enabled = _selected.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: rd.line, width: 1)),
      ),
      child: Row(
        children: [
          _SelAction(
            icon: RdIcons.folder,
            label: l10n.rdLibraryActionCollection,
            enabled: enabled,
            onTap: _addSelectedToCollection,
          ),
          _SelAction(
            icon: RdIcons.navCanvas,
            label: l10n.rdLibraryActionBoard,
            enabled: enabled,
            onTap: _addSelectedToBoard,
          ),
          _SelAction(
            icon: RdIcons.pushpin,
            label: l10n.rdLibraryActionPin,
            enabled: enabled,
            onTap: _pinSelected,
          ),
          _SelAction(
            icon: RdIcons.archive,
            label: l10n.rdLibraryActionArchive,
            enabled: enabled,
            onTap: _archiveSelected,
          ),
          _SelAction(
            icon: RdIcons.trash,
            label: l10n.rdLibraryActionDelete,
            enabled: enabled,
            danger: true,
            onTap: _deleteSelected,
          ),
        ],
      ),
    );
  }
}

// ── data ──────────────────────────────────────────────────────────────
enum _DayBucket { today, thisWeek, earlier }

enum _MemType {
  note('note'),
  voice('voice'),
  photo('photo'),
  link('link'),
  event('event');

  const _MemType(this.id);
  final String id;
}

class _LibMem {
  const _LibMem({
    required this.id,
    required this.dayBucket,
    required this.type,
    required this.title,
    required this.sub,
    required this.createdAt,
    required this.searchText,
    this.pinned = false,
  });

  final String id;
  final _DayBucket dayBucket;
  final _MemType type;
  final String title;
  final String sub;
  final DateTime createdAt;
  final String searchText;
  final bool pinned;
}

// Type → icon body + colour treatment for the memory tile's leading square.
({String icon, Color bg, String stroke, List<Color>? gradient}) _typeStyle(
    _MemType t) {
  switch (t) {
    case _MemType.note:
      return (icon: RdIcons.pencil, bg: const Color(0xFFEDEFF8), stroke: '#14328C', gradient: null);
    case _MemType.voice:
      return (icon: RdIcons.mic, bg: const Color(0xFFE7EFEA), stroke: '#2E7D4F', gradient: null);
    case _MemType.link:
      return (icon: RdIcons.linkChain, bg: const Color(0xFFFBEFE7), stroke: '#B65A2E', gradient: null);
    case _MemType.event:
      return (icon: RdIcons.calendar, bg: const Color(0xFFEAE7F6), stroke: '#5B4B9E', gradient: null);
    case _MemType.photo:
      return (
        icon: RdIcons.photo,
        bg: const Color(0xFF14328C),
        stroke: '#FFFFFF',
        gradient: const [Color(0xFF1B2B6B), Color(0xFF0F1C4D)],
      );
  }
}

// ── tile ──────────────────────────────────────────────────────────────
class _MemTile extends StatelessWidget {
  const _MemTile({
    required this.mem,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.query,
  });

  final _LibMem mem;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String query;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final style = _typeStyle(mem.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? rd.periSoft : rd.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? rd.peri : rd.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selecting) ...[
              _Check(selected: selected),
              const SizedBox(width: 13),
            ],
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: style.gradient == null ? style.bg : null,
                gradient: style.gradient == null
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: style.gradient!,
                      ),
              ),
              child: Center(
                child: RdIcon(style.icon, size: 20, stroke: style.stroke, strokeWidth: 1.8),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mem.pinned)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 5),
                          child: RdIcon(RdIcons.pushpin,
                              size: 12, color: rd.peri, strokeWidth: 2),
                        ),
                      Expanded(child: _title(rd)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mem.sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12.5,
                      color: rd.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _meta(context, rd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(RdTheme rd) {
    final base = GoogleFonts.vazirmatn(
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      color: rd.ink,
      height: 1.35,
    );
    if (query.isEmpty) {
      return Text(mem.title,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: base);
    }
    final lower = mem.title.toLowerCase();
    final i = lower.indexOf(query);
    if (i < 0) {
      return Text(mem.title,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: base);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: mem.title.substring(0, i)),
          TextSpan(
            text: mem.title.substring(i, i + query.length),
            style: TextStyle(
              backgroundColor: const Color(0xFF7E8BC9).withValues(alpha: 0.28),
              color: rd.peri,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: mem.title.substring(i + query.length)),
        ],
        style: base,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _meta(BuildContext context, RdTheme rd) {
    return Row(
      children: [
        Container(
          height: 21,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rd.periSoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            _typeLabel(context, mem.type),
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: rd.peri,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _relativeTime(context, mem.createdAt),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(fontSize: 11.5, color: rd.faint),
          ),
        ),
      ],
    );
  }

  String _typeLabel(BuildContext context, _MemType t) {
    final l10n = AppLocalizations.of(context)!;
    switch (t) {
      case _MemType.voice:
        return l10n.rdLibraryTypeVoice;
      case _MemType.link:
        return l10n.rdLibraryTypeLink;
      case _MemType.photo:
        return l10n.rdLibraryTypePhoto;
      case _MemType.event:
        return l10n.rdLibraryTypeEvent;
      case _MemType.note:
        return l10n.rdLibraryTypeNote;
    }
  }

  String _relativeTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.rdLibraryTimeJustNow;
    if (diff.inMinutes < 60) {
      return l10n.rdLibraryTimeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) return l10n.rdLibraryTimeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.rdLibraryTimeYesterday;
    if (diff.inDays < 30) return l10n.rdLibraryTimeDaysAgo(diff.inDays);
    return l10n.rdLibraryTimeDate(dt.month, dt.day);
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 11),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF14328C) : rd.card,
        border: selected ? null : Border.all(color: rd.faint, width: 1.8),
      ),
      child: selected
          ? const Center(
              child: RdIcon(
                RdIcons.checkThick,
                size: 13,
                stroke: '#FFFFFF',
                strokeWidth: 3,
              ),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF14328C) : rd.card,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              RdIcon(
                icon!,
                size: 14,
                color: active ? Colors.white : rd.muted,
                strokeWidth: 2,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : rd.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.icon,
    required this.name,
    required this.count,
    required this.colors,
    this.expand = false,
  });

  /// When true the card fills its parent (grid cell) instead of the fixed
  /// 150-wide peek size.
  final bool expand;

  final String icon;
  final String name;
  final String count;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RdColors.line, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.7),
            ),
            child: Center(
              child: RdIcon(icon, size: 20, stroke: '#14328C', strokeWidth: 1.8),
            ),
          ),
          expand ? const Spacer() : const SizedBox(height: 40),
          Text(
            name,
            style: GoogleFonts.dosis(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: RdColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: GoogleFonts.vazirmatn(fontSize: 12, color: RdColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SelAction extends StatelessWidget {
  const _SelAction({
    required this.icon,
    required this.label,
    required this.enabled,
    this.onTap,
    this.danger = false,
  });

  final String icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final color = danger ? const Color(0xFFC0492A) : rd.muted;
    final iconColor = danger ? '#C0492A' : '#14328C';
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: rd.card,
                  border: Border.all(color: rd.line, width: 1),
                ),
                child: Center(
                  child: RdIcon(icon, size: 20, stroke: iconColor, strokeWidth: 1.7),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.vazirmatn(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── add-to-board picker ────────────────────────────────────────────────
/// The user's pick from the "add to board" sheet: an existing board, or a
/// request to create a new one named [name].
class _BoardChoice {
  const _BoardChoice.existing(this.board) : name = null;
  const _BoardChoice.create(this.name) : board = null;

  final CanvasDto? board;
  final String? name;
}

/// Bottom sheet listing the user's Canvas boards with an inline "New board"
/// create row, returning a [_BoardChoice] via `Navigator.pop`. Mirrors
/// `RdCollectionPickerSheet` so the two "add to…" flows feel identical.
class _BoardPickerSheet extends StatefulWidget {
  const _BoardPickerSheet({required this.boards});

  final List<CanvasDto> boards;

  @override
  State<_BoardPickerSheet> createState() => _BoardPickerSheetState();
}

class _BoardPickerSheetState extends State<_BoardPickerSheet> {
  final TextEditingController _newCtl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _newCtl.dispose();
    super.dispose();
  }

  void _submitNew() {
    final name = _newCtl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_BoardChoice.create(name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final mq = MediaQuery.of(context);
    final navGap = (mq.viewPadding.bottom - mq.viewInsets.bottom).clamp(0.0, 64.0);
    return Container(
      decoration: BoxDecoration(
        color: rd.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: mq.viewInsets.bottom + 24 + navGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: rd.line,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rdLibraryAddToBoard,
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
          const SizedBox(height: 12),
          if (_creating)
            _newRow(rd, l10n)
          else ...[
            if (widget.boards.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final b in widget.boards) _row(rd, b, l10n)
                    ],
                  ),
                ),
              ),
            _createRow(rd, l10n),
          ],
        ],
      ),
    );
  }

  Widget _row(RdTheme rd, CanvasDto b, AppLocalizations l10n) {
    final title =
        b.title.trim().isEmpty ? l10n.rdLibraryUntitledBoard : b.title.trim();
    final count = b.nodes.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(_BoardChoice.existing(b)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          children: [
            const RdIcon(RdIcons.grid4,
                size: 18, stroke: '#14328C', strokeWidth: 1.8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
            ),
            Text(
              l10n.rdLibraryCardCount(count),
              style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRow(RdTheme rd, AppLocalizations l10n) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _creating = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Text(
              '+',
              style: GoogleFonts.dosis(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: rd.peri,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.rdLibraryNewBoard,
              style: GoogleFonts.vazirmatn(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: rd.peri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newRow(RdTheme rd, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rd.line, width: 1),
            ),
            child: Center(
              child: TextField(
                controller: _newCtl,
                autofocus: true,
                cursorColor: rd.navy,
                style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: l10n.rdLibraryBoardNameHint,
                  hintStyle:
                      GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
                ),
                onSubmitted: (_) => _submitNew(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _submitNew,
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF14328C),
            ),
            child: const Center(
              child: RdIcon(
                RdIcons.checkThick,
                size: 18,
                stroke: '#FFFFFF',
                strokeWidth: 2.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
