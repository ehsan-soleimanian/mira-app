import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/collection_models.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

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
  final Set<String> _selected = {};

  /// User collections from the backend (null until loaded / unreachable).
  List<MemoryCollection>? _cols;

  /// When a collection card is opened, the Library filters to its members.
  Set<String>? _colFilterIds;
  String? _colFilterName;

  /// Live items from the backend; null until the first load. Falls back to the
  /// sample set when the backend is unreachable.
  List<_LibMem>? _items;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final services = AppScope.servicesOf(context);
    try {
      final items = await services.libraryRepository.list();
      final mapped = items.map(_toLibMem).toList();
      if (mounted) setState(() => _items = mapped);
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

  static _LibMem _toLibMem(LibraryItem item) {
    final type = _memTypeFor(item.type);
    final title = item.title.trim();
    return _LibMem(
      id: item.id,
      day: _dayBucket(item.createdAt),
      type: type,
      title: title.isEmpty ? 'Untitled' : title,
      sub: item.summary,
      metaType: _typeLabelFor(type),
      metaTime: _relativeTime(item.createdAt),
      searchText: '${item.title} ${item.summary}'.toLowerCase(),
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

  static String _typeLabelFor(_MemType t) {
    switch (t) {
      case _MemType.voice:
        return 'Voice';
      case _MemType.link:
        return 'Link';
      case _MemType.photo:
        return 'Photo';
      case _MemType.event:
        return 'Event';
      case _MemType.note:
        return 'Note';
    }
  }

  static String _dayBucket(DateTime dt) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days < 7) return 'This week';
    return 'Earlier';
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  List<_LibMem> get _visible {
    final source = _items ?? _mems;
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: RdColors.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
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
    final choice = await showModalBottomSheet<_ColChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _CollectionPickerSheet(collections: _cols ?? const []),
    );
    if (choice == null || !mounted) return;
    try {
      final target = choice.collection ??
          await services.collectionsRepository.create(name: choice.name!);
      final updated =
          await services.collectionsRepository.addItems(target.id, ids);
      final refreshed = await services.collectionsRepository.list();
      if (!mounted) return;
      setState(() => _cols = refreshed);
      _exitSelect();
      _toast('Added ${ids.length} to “${updated.name}”');
    } catch (_) {
      _toast('Couldn’t add to collection. Check your connection.');
    }
  }

  /// "Delete" action — remove the selected memories via `libraryRepository.delete`
  /// (optimistically dropped from the list first for a responsive feel).
  Future<void> _deleteSelected() async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final services = AppScope.servicesOf(context);
    setState(() {
      _items =
          (_items ?? _mems).where((m) => !_selected.contains(m.id)).toList();
    });
    _exitSelect();
    var failed = 0;
    for (final id in ids) {
      try {
        await services.libraryRepository.delete(id);
      } catch (_) {
        failed++;
      }
    }
    _toast(failed == 0
        ? '${ids.length} ${ids.length == 1 ? "memory" : "memories"} deleted'
        : 'Deleted ${ids.length - failed} of ${ids.length}');
  }

  // Pin / Archive are optimistic (client-side) for now — their backend flags
  // land in a follow-up; Collection + Delete above are fully wired.
  void _pinSelected() {
    final n = _selected.length;
    if (n == 0) return;
    _exitSelect();
    _toast('Pinned $n ${n == 1 ? "memory" : "memories"}');
  }

  void _archiveSelected() {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    setState(() {
      _items =
          (_items ?? _mems).where((m) => !_selected.contains(m.id)).toList();
    });
    _exitSelect();
    _toast('Archived ${ids.length} ${ids.length == 1 ? "memory" : "memories"}');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final days = <String>[];
    for (final m in visible) {
      if (!days.contains(m.day)) days.add(m.day);
    }

    return Scaffold(
      backgroundColor: RdColors.bg,
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
                      ],
                    ],
                    if (visible.isEmpty)
                      _emptyHint()
                    else
                      for (final day in days) ...[
                        _dayLabel(day),
                        for (final m in visible.where((x) => x.day == day))
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00F4F4F1), RdColors.bg],
                    stops: [0.0, 0.55],
                  ),
                ),
                child: RdBottomNav(active: 'library', go: widget.go),
              ),
            ),
        ],
      ),
    );
  }

  // ── header ──────────────────────────────────────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR MEMORY',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: RdColors.peri,
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
                      'Library',
                      style: GoogleFonts.dosis(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: RdColors.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '342 memories, all held safe',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: RdColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.go('account'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: RdColors.card,
                    border: Border.all(color: RdColors.line, width: 1),
                  ),
                  child: const Center(
                    child: RdIcon(
                      RdIcons.gear,
                      size: 19,
                      stroke: '#6B6C73',
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
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 20, 26, 0),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: RdColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RdColors.line, width: 1),
      ),
      child: Row(
        children: [
          const RdIcon(RdIcons.search, size: 19, stroke: '#B7B8BE', strokeWidth: 2),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v),
              cursorColor: RdColors.navy,
              style: GoogleFonts.vazirmatn(fontSize: 15, color: RdColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search your memory…',
                hintStyle:
                    GoogleFonts.vazirmatn(fontSize: 15, color: RdColors.faint),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RdColors.periSoft,
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
        ],
      ),
    );
  }

  // ── filter chips ────────────────────────────────────────────────────
  Widget _filters() {
    const chips = [
      ('all', 'All', null),
      ('note', 'Notes', RdIcons.pencil),
      ('voice', 'Voice', RdIcons.micSimple),
      ('photo', 'Photos', RdIcons.photo),
      ('link', 'Links', RdIcons.linkChain),
      ('event', 'Events', RdIcons.calendar),
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
                        const TextSpan(text: 'No matches'),
                        if (q.isNotEmpty) TextSpan(text: ' for “$q”'),
                        if (_colFilterName != null)
                          TextSpan(text: ' in ${_colFilterName!}'),
                      ]
                    : [
                        TextSpan(
                          text: '$count',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: RdColors.ink,
                          ),
                        ),
                        TextSpan(text: count == 1 ? ' memory' : ' memories'),
                        if (q.isNotEmpty) TextSpan(text: ' for “$q”'),
                        if (_colFilterName != null)
                          TextSpan(text: ' in ${_colFilterName!}'),
                      ],
                style: GoogleFonts.vazirmatn(fontSize: 13, color: RdColors.muted),
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
              'Clear',
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: RdColors.peri,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── collections ─────────────────────────────────────────────────────
  Widget _collectionsLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const RdIcon(RdIcons.folder, size: 15, stroke: '#7E8BC9', strokeWidth: 2),
              const SizedBox(width: 8),
              Text(
                'MIRA GROUPED FOR YOU',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: RdColors.faint,
                ),
              ),
            ],
          ),
          Text(
            'See all',
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: RdColors.peri,
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
    if (cols == null || cols.isEmpty) return _sampleCollections();
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

  Widget _sampleCollections() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 4),
      child: Row(
        children: const [
          _CollectionCard(
            icon: RdIcons.people,
            name: 'People',
            count: '28 memories · 9 people',
            colors: [Color(0xFFEEF1FA), Color(0xFFE3E8F6)],
          ),
          SizedBox(width: 12),
          _CollectionCard(
            icon: RdIcons.pin,
            name: 'Coast trip',
            count: '14 memories · planning',
            colors: [Color(0xFFF0EEF7), Color(0xFFE8E3F2)],
          ),
          SizedBox(width: 12),
          _CollectionCard(
            icon: RdIcons.work,
            name: 'Work',
            count: '41 memories · 3 projects',
            colors: [Color(0xFFEAF1EE), Color(0xFFDFEDE6)],
          ),
        ],
      ),
    );
  }

  static String _countLabel(int n) => '$n ${n == 1 ? "memory" : "memories"}';

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
      _toast('Couldn’t open “${c.name}”.');
    }
  }

  // ── list scaffolding ────────────────────────────────────────────────
  Widget _dayLabel(String day) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 4),
      child: Text(
        day.toUpperCase(),
        style: GoogleFonts.vazirmatn(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: RdColors.faint,
        ),
      ),
    );
  }

  Widget _emptyHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Text(
        'Nothing here under this filter.\nEverything you capture will settle in quietly.',
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 13.5,
          color: RdColors.faint,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _end() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
      child: Text(
        'You’ve kept 342 memories.\nMira holds them so you don’t have to.',
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          color: RdColors.faint,
          height: 1.5,
        ),
      ),
    );
  }

  // ── selection chrome ────────────────────────────────────────────────
  Widget _selBar(List<String> ids) {
    final allSelected = ids.isNotEmpty && ids.every(_selected.contains);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 14),
      decoration: const BoxDecoration(
        color: RdColors.bg,
        border: Border(bottom: BorderSide(color: RdColors.line, width: 1)),
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
                color: RdColors.card,
                border: Border.all(color: RdColors.line, width: 1),
              ),
              child: const Center(
                child: RdIcon(
                  RdIcons.close,
                  size: 17,
                  stroke: '#1B1C24',
                  strokeWidth: 2.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selected.isEmpty
                  ? 'Select memories'
                  : '${_selected.length} selected',
              style: GoogleFonts.dosis(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: RdColors.ink,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _toggleAll(ids),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                allSelected ? 'Deselect all' : 'Select all',
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RdColors.peri,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selActions() {
    final enabled = _selected.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF9).withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: RdColors.line, width: 1)),
      ),
      child: Row(
        children: [
          _SelAction(
            icon: RdIcons.folder,
            label: 'Collection',
            enabled: enabled,
            onTap: _addSelectedToCollection,
          ),
          _SelAction(
            icon: RdIcons.pushpin,
            label: 'Pin',
            enabled: enabled,
            onTap: _pinSelected,
          ),
          _SelAction(
            icon: RdIcons.archive,
            label: 'Archive',
            enabled: enabled,
            onTap: _archiveSelected,
          ),
          _SelAction(
            icon: RdIcons.trash,
            label: 'Delete',
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
    required this.day,
    required this.type,
    required this.title,
    required this.sub,
    required this.metaType,
    required this.metaTime,
    required this.searchText,
    this.links = 0,
  });

  final String id;
  final String day;
  final _MemType type;
  final String title;
  final String sub;
  final String metaType;
  final String metaTime;
  final String searchText;
  final int links;
}

const _mems = <_LibMem>[
  _LibMem(
    id: 'm0',
    day: 'Today',
    type: _MemType.note,
    title: 'Contract with John',
    sub:
        'Needs a call to confirm the terms before Friday. Connects to the meeting note from last week.',
    metaType: 'Note',
    metaTime: '2h ago',
    links: 3,
    searchText: 'contract with john call confirm terms',
  ),
  _LibMem(
    id: 'm1',
    day: 'Today',
    type: _MemType.voice,
    title: 'Book Maya recommended',
    sub: '“The Overstory” — a quiet weekend read for the coast trip.',
    metaType: 'Voice · 0:12',
    metaTime: 'Today, 8:30 AM',
    searchText: 'book maya recommended the overstory',
  ),
  _LibMem(
    id: 'm2',
    day: 'This week',
    type: _MemType.event,
    title: 'Blue Note — live jazz',
    sub: 'Fri, Jul 18 · 8 PM at The Corner Room. From a photo you took.',
    metaType: 'Event',
    metaTime: 'Tue',
    links: 2,
    searchText: 'blue note live jazz corner room tickets',
  ),
  _LibMem(
    id: 'm3',
    day: 'This week',
    type: _MemType.link,
    title: 'On calm technology',
    sub: 'Saved article about designing tools that ask for less attention.',
    metaType: 'Link',
    metaTime: 'Mon',
    searchText: 'article calm technology second brain design',
  ),
  _LibMem(
    id: 'm4',
    day: 'This week',
    type: _MemType.photo,
    title: 'Whiteboard sketch',
    sub: 'Roadmap from the studio session — Mira read the three phases.',
    metaType: 'Photo',
    metaTime: 'Mon',
    searchText: 'whiteboard sketch product roadmap studio',
  ),
  _LibMem(
    id: 'm5',
    day: 'Earlier',
    type: _MemType.note,
    title: 'A quiet weekend on the coast',
    sub: 'Idea for spring — somewhere slow, near the water.',
    metaType: 'Note',
    metaTime: 'Jun 28',
    searchText: 'idea quiet weekend coast spring',
  ),
  _LibMem(
    id: 'm6',
    day: 'Earlier',
    type: _MemType.voice,
    title: 'Flight SA 482 booked',
    sub: 'Aug 2 departure. Check-in reminder set for the day before.',
    metaType: 'Voice · 0:08',
    metaTime: 'Jun 24',
    searchText: 'flight sa 482 august trip booking',
  ),
];

// Type → icon body + colour treatment for the memory tile's leading square.
({String icon, Color bg, String stroke, List<Color>? gradient}) _typeStyle(
    _MemType t) {
  switch (t) {
    case _MemType.note:
      return (icon: RdIcons.pencil, bg: RdColors.periSoft, stroke: '#14328C', gradient: null);
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
    final style = _typeStyle(mem.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? RdColors.periSoft : RdColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? RdColors.peri : RdColors.line,
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
                  _title(),
                  const SizedBox(height: 3),
                  Text(
                    mem.sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12.5,
                      color: RdColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _meta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    final base = GoogleFonts.vazirmatn(
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      color: RdColors.ink,
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
              color: RdColors.navy,
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

  Widget _meta() {
    return Row(
      children: [
        Container(
          height: 21,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RdColors.periSoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            mem.metaType,
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: RdColors.navy,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            mem.metaTime,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(fontSize: 11.5, color: RdColors.faint),
          ),
        ),
        if (mem.links > 0) ...[
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RdColors.faint,
            ),
          ),
          const SizedBox(width: 8),
          const RdIcon(RdIcons.link, size: 12, stroke: '#7E8BC9', strokeWidth: 2),
          const SizedBox(width: 4),
          Text(
            '${mem.links} links',
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: RdColors.peri,
            ),
          ),
        ],
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 11),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? RdColors.navy : Colors.white,
        border: selected ? null : Border.all(color: RdColors.faint, width: 1.8),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? RdColors.navy : RdColors.card,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: RdColors.line, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              RdIcon(
                icon!,
                size: 14,
                stroke: active ? '#FFFFFF' : '#8A8B92',
                strokeWidth: 2,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : RdColors.muted,
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
  });

  final String icon;
  final String name;
  final String count;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
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
          const SizedBox(height: 40),
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
    final color = danger ? const Color(0xFFC0492A) : RdColors.muted;
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
                  color: RdColors.card,
                  border: Border.all(color: RdColors.line, width: 1),
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

/// The user's pick from the "add to collection" sheet: an existing collection,
/// or a request to create a new one named [name].
class _ColChoice {
  const _ColChoice.existing(this.collection) : name = null;
  const _ColChoice.create(this.name) : collection = null;

  final MemoryCollection? collection;
  final String? name;
}

/// Bottom sheet that lists the user's collections and offers to create a new
/// one, returning a [_ColChoice] via `Navigator.pop`.
class _CollectionPickerSheet extends StatefulWidget {
  const _CollectionPickerSheet({required this.collections});

  final List<MemoryCollection> collections;

  @override
  State<_CollectionPickerSheet> createState() => _CollectionPickerSheetState();
}

class _CollectionPickerSheetState extends State<_CollectionPickerSheet> {
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
    Navigator.of(context).pop(_ColChoice.create(name));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RdColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                color: RdColors.line,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add to collection',
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: RdColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          if (_creating)
            _newRow()
          else ...[
            if (widget.collections.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final c in widget.collections) _row(c)],
                  ),
                ),
              ),
            _createRow(),
          ],
        ],
      ),
    );
  }

  Widget _row(MemoryCollection c) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(_ColChoice.existing(c)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: RdColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RdColors.line, width: 1),
        ),
        child: Row(
          children: [
            const RdIcon(RdIcons.folder, size: 18, stroke: '#14328C', strokeWidth: 1.8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: RdColors.ink,
                ),
              ),
            ),
            Text(
              '${c.itemCount}',
              style: GoogleFonts.vazirmatn(fontSize: 12.5, color: RdColors.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRow() {
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
                color: RdColors.peri,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'New collection',
              style: GoogleFonts.vazirmatn(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: RdColors.peri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: RdColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RdColors.line, width: 1),
            ),
            child: Center(
              child: TextField(
                controller: _newCtl,
                autofocus: true,
                cursorColor: RdColors.navy,
                style: GoogleFonts.vazirmatn(fontSize: 15, color: RdColors.ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Collection name',
                  hintStyle:
                      GoogleFonts.vazirmatn(fontSize: 15, color: RdColors.faint),
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
              color: RdColors.navy,
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
