import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/collection_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_collection_picker.dart';
import '../widgets/rd_icon.dart';

/// A person surfaced from the capture's connected graph entities — the avatar
/// initial plus display name shown in the "People & tags" row.
class _Person {
  const _Person(this.initial, this.name);
  final String initial;
  final String name;
}

/// Memory detail — the pushed view you reach by tapping a memory. Shows the
/// capture (typed note or voice transcript with a player), Mira's reading of
/// it, its connections, people, and source, with inline edit, an action menu,
/// and a delete sheet. Faithful to `memory.jsx` (`.rd-memory`). Defaults to the
/// note variant; pass [isVoice] once the tap carries the memory kind.
class RdMemoryScreen extends StatefulWidget {
  const RdMemoryScreen({
    super.key,
    required this.go,
    required this.onBack,
    this.id,
    this.isVoice = false,
    this.title,
    this.body,
    this.backLabel = 'Home',
  });

  final RdGo go;
  final VoidCallback onBack;
  final bool isVoice;

  /// The tapped memory's library-item id, used to reach the backend for edit /
  /// delete / add-to-collection. Null when opened from a sample (e.g. Home), in
  /// which case those actions stay optimistic (local-only) with just a toast.
  final String? id;

  /// The tapped memory's title/body when opened from a list; falls back to the
  /// sample content when absent.
  final String? title;
  final String? body;
  final String backLabel;

  @override
  State<RdMemoryScreen> createState() => _RdMemoryScreenState();
}

// Fixed literals retained for the brand elements that stay constant across
// light/dark: the navy CTA + orb, the periwinkle brand accents on the fixed
// "Mira noticed" gradient card, and the danger red. Theme-adaptive surfaces and
// text read from `context.rd` instead.
const _ink = Color(0xFF1B1C24);
const _navy = Color(0xFF14328C);
const _peri = Color(0xFF7E8BC9);
const _muted = Color(0xFF8A8B92);
const _danger = Color(0xFFC0392B);
const _clip = 34.0;

class _RdMemoryScreenState extends State<RdMemoryScreen> {
  bool _pinned = false;
  bool _reminded = true;
  bool _menu = false;
  bool _confirm = false;
  bool _sharing = false;
  bool _linkCopied = false;
  bool _deleting = false;
  bool _editing = false;
  bool _edited = false;
  bool _saved = false;
  final Set<int> _fixedFlags = {};

  bool _playing = false;
  double _pos = 0;
  double _speed = 1;
  Timer? _tick;

  late String _title = widget.title ?? 'Untitled memory';
  late String _body = widget.body ?? '';
  late final TextEditingController _titleCtl = TextEditingController();
  late final TextEditingController _bodyCtl = TextEditingController();
  final FocusNode _bodyFocus = FocusNode();

  // Real data pulled from `GET /v2/captures/{id}` when [widget.id] is a graph
  // capture. Each stays null until a successful, non-empty fetch. When a field
  // is null (offline, or the id is a library item that 404s) its section is
  // simply hidden — the screen never shows fabricated content.
  String? _realInsight;
  List<_MemLink>? _realLinks;
  List<_Person>? _realPeople;
  List<String>? _realTags;

  List<_MemLink> get _links => _realLinks ?? const [];

  static const _wave = [
    .28, .42, .6, .35, .5, .78, .55, .4, .66, .9, .62, .44, .3, .52, .72, .85,
    .6, .38, .48, .7, .95, .68, .5, .34, .46, .64, .8, .58, .4, .3, .52, .68, .44, .36, .5, .26,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) unawaited(_loadDetail());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _titleCtl.dispose();
    _bodyCtl.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  /// Best-effort enrichment: fetch the capture's graph detail and replace the
  /// sample insight / connections / people / tags with real data. Any failure
  /// (the id is a library item, the capture isn't in the graph, or the backend
  /// is offline) leaves the sample content untouched — this never throws.
  Future<void> _loadDetail() async {
    final id = widget.id;
    if (id == null) return;
    try {
      final detail =
          await AppScope.servicesOf(context).graphRepository.fetchCaptureDetail(id);
      if (!mounted) return;
      final parsed = _parseDetail(detail);
      final uiState = detail['uiState'] as Map<String, dynamic>? ?? const {};
      final pinned = uiState['pinned'] as bool?;
      setState(() {
        if (parsed.links.isNotEmpty) _realLinks = parsed.links;
        if (parsed.people.isNotEmpty) _realPeople = parsed.people;
        if (parsed.tags.isNotEmpty) _realTags = parsed.tags;
        if (parsed.insight != null) _realInsight = parsed.insight;
        if (pinned != null) _pinned = pinned;
      });
    } catch (_) {
      // Keep the sample content — the id may not be a graph capture.
    }
  }

  /// Maps the `{ capture, connections: { nodes, edges } }` payload into the
  /// screen's view types. Connected captures (kind `CAPTURE`) become tappable
  /// memory links; person entities become people chips; other entities become
  /// `#tag` chips. The insight is synthesised from what was actually linked.
  ({
    List<_MemLink> links,
    List<_Person> people,
    List<String> tags,
    String? insight,
  }) _parseDetail(Map<String, dynamic> detail) {
    final connections =
        detail['connections'] as Map<String, dynamic>? ?? const {};
    final nodes = (connections['nodes'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final links = <_MemLink>[];
    final people = <_Person>[];
    final tags = <String>[];

    for (final node in nodes) {
      final nodeId = node['id'] as String?;
      if (nodeId == null || nodeId == widget.id) continue;
      final kind = (node['kind'] as String? ?? '').toUpperCase();
      final title = (node['title'] as String? ?? '').trim();
      if (title.isEmpty) continue;
      final subtitle = (node['subtitle'] as String? ?? '').trim();
      final entityType = (node['entityType'] as String? ?? '').toUpperCase();

      if (kind == 'CAPTURE') {
        links.add(_MemLink(
          _linkTypeFor(entityType, subtitle),
          title,
          subtitle.isEmpty ? 'Connected memory' : subtitle,
          'Linked',
          id: nodeId,
        ));
      } else if (kind == 'ENTITY') {
        if (entityType == 'PERSON') {
          final initial = title.characters.isEmpty
              ? '?'
              : title.characters.first.toUpperCase();
          if (people.length < 4) people.add(_Person(initial, title));
        } else {
          final tag = _hashTag(title);
          if (tag.isNotEmpty && tags.length < 5 && !tags.contains(tag)) {
            tags.add(tag);
          }
        }
      }
    }

    return (
      links: links.take(5).toList(),
      people: people,
      tags: tags,
      insight: _buildInsight(links.length, people, tags),
    );
  }

  /// Chooses a `_MemLink` visual style from the connected capture's traits.
  String _linkTypeFor(String entityType, String subtitle) {
    final s = subtitle.toLowerCase();
    if (s.contains('voice')) return 'voice';
    if (s.contains('photo') || s.contains('image')) return 'photo';
    if (entityType == 'EVENT' || s.contains('meeting') || s.contains('event')) {
      return 'event';
    }
    return 'note';
  }

  /// Turns an entity name into a lowercase single-word hashtag ("Weekly review"
  /// → "#weekly"). Returns empty when nothing usable remains.
  String _hashTag(String name) {
    final word = name
        .trim()
        .split(RegExp(r'\s+'))
        .firstWhere((w) => w.isNotEmpty, orElse: () => '');
    final cleaned = word.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toLowerCase();
    return cleaned.isEmpty ? '' : '#$cleaned';
  }

  /// Writes a short, human insight from what Mira actually linked, so the
  /// "Mira noticed" card reflects real connections instead of the sample copy.
  String? _buildInsight(int linkCount, List<_Person> people, List<String> tags) {
    final parts = <String>[];
    if (linkCount > 0) {
      parts.add('linked it to $linkCount related '
          '${linkCount == 1 ? 'memory' : 'memories'}');
    }
    if (people.isNotEmpty) {
      final names = people.map((p) => p.name).take(2).join(' and ');
      parts.add('connected $names');
    }
    if (tags.isNotEmpty) {
      parts.add('tagged it ${tags.take(3).join(', ')}');
    }
    if (parts.isEmpty) return null;
    final body = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return 'I read through this and $body so it stays easy to find.';
  }

  /// Opens a connected memory when the link carries a real graph id; otherwise
  /// preserves the sample behaviour of jumping to chat.
  void _openLink(_MemLink link) {
    final id = link.id;
    if (id == null) {
      widget.go('chat');
      return;
    }
    widget.go(
      'memory',
      arg: RdMemoryArg(
        id: id,
        title: link.title,
        isVoice: link.type == 'voice',
      ),
    );
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _tick?.cancel();
    if (_playing) {
      _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          _pos += 0.1 * _speed;
          if (_pos >= _clip) {
            _pos = 0;
            _playing = false;
            _tick?.cancel();
          }
        });
      });
    }
  }

  void _cycleSpeed() =>
      setState(() => _speed = _speed == 1 ? 1.5 : (_speed == 1.5 ? 2 : 1));

  void _toggleReminder() {
    final next = !_reminded;
    setState(() => _reminded = next);
    if (next) unawaited(_createReminder());
  }

  Future<void> _createReminder() async {
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient).create(title: _title);
    } catch (_) {
      // Best-effort — the toggle already reflects the change.
    }
  }

  /// Floating SnackBar toast — mirrors `RdLibraryScreen._toast` so lifecycle
  /// feedback (Pinned / added to collection …) reads the same across screens.
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

  // Optimistic pin toggle: flip local state + toast immediately, then persist
  // to the backend best-effort. A null id (sample memory) or offline backend
  // leaves the optimistic UI as-is.
  void _togglePin() {
    final next = !_pinned;
    setState(() {
      _pinned = next;
      _menu = false;
    });
    _toast(next ? 'Pinned' : 'Unpinned');
    unawaited(_persistPin(next));
  }

  Future<void> _persistPin(bool pinned) async {
    final id = widget.id;
    if (id == null) return;
    try {
      await AppScope.servicesOf(context)
          .graphRepository
          .updateCaptureState(id, pinned: pinned);
    } catch (_) {
      // Ignore — the id may not be a graph capture, or the backend is offline.
    }
  }

  String _fmt(double s) =>
      '${(s ~/ 60)}:${(s % 60).floor().toString().padLeft(2, '0')}';

  void _startEdit() {
    _titleCtl.text = _title;
    _bodyCtl.text = _body;
    setState(() {
      _playing = false;
      _editing = true;
      _menu = false;
      _fixedFlags.clear();
    });
  }

  /// Words Mira may have transcribed with low confidence — capitalised names
  /// mid-sentence and long uncommon tokens (design: flagged-word chips).
  List<String> _transcriptFlags(String text) {
    const skip = {
      'I', 'The', 'So', 'Let', 'People', 'Circle', 'And', 'But', 'We', 'It',
      'This', 'That', 'They', 'There', 'Then', 'When', 'What', 'Who', 'How',
      'Why', 'Not', 'For', 'With', 'From', 'Our', 'Your', 'She', 'He',
    };
    final found = <String>[];
    final seen = <String>{};
    for (final m in RegExp(r'(?<=\s)[A-Z][a-z]{2,}').allMatches(text)) {
      final w = m.group(0)!;
      if (!skip.contains(w) && seen.add(w)) found.add(w);
    }
    for (final m in RegExp(r'\b[a-z]{9,}\b').allMatches(text)) {
      final w = m.group(0)!;
      if (seen.add(w)) found.add(w);
    }
    return found.take(6).toList();
  }

  void _jumpToFlagWord(String word, int index) {
    final text = _bodyCtl.text;
    final idx = text.indexOf(word);
    if (idx >= 0) {
      _bodyCtl.selection = TextSelection(baseOffset: idx, extentOffset: idx + word.length);
      _bodyFocus.requestFocus();
    }
    setState(() {
      if (_fixedFlags.contains(index)) {
        _fixedFlags.remove(index);
      } else {
        _fixedFlags.add(index);
      }
    });
  }

  void _saveEdit() {
    final nextTitle =
        _titleCtl.text.trim().isEmpty ? _title : _titleCtl.text.trim();
    final nextBody = _bodyCtl.text.trim().isEmpty ? _body : _bodyCtl.text.trim();
    setState(() {
      _title = nextTitle;
      _body = nextBody;
      _editing = false;
      _edited = true;
      _saved = true;
    });
    // Write the edit through the shared store so the Library (and any other
    // listener) reflects the new title / summary immediately, without a
    // re-fetch. Guarded on a null id (sample memory) — the store no-ops on ids
    // it hasn't cached anyway.
    final id = widget.id;
    if (id != null) {
      AppScope.servicesOf(context)
          .memoryStore
          .applyLocalEdit(id, title: nextTitle, summary: nextBody);
    }
    // Best-effort persistence of the new title, plus a real re-ingest of the
    // edited body so Mira re-reads it. `widget.id` may be a library item (not a
    // graph capture), so failures are ignored — the local edit and the
    // "re-read" toast already reflect the change.
    unawaited(_persistTitle(nextTitle));
    unawaited(_reread(nextBody));
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _persistTitle(String title) async {
    final id = widget.id;
    if (id == null) return;
    try {
      await AppScope.servicesOf(context).graphRepository.patchCaptureTitle(id, title);
    } catch (_) {
      // Ignore — the id may not be a graph capture, or the backend is offline.
    }
  }

  /// Re-ingests the edited note/transcript body through the graph so Mira
  /// re-reads the corrected content. Best-effort — a null id (sample memory) or
  /// an offline backend is silently ignored.
  Future<void> _reread(String text) async {
    final id = widget.id;
    if (id == null || text.trim().isEmpty) return;
    try {
      await AppScope.servicesOf(context).graphRepository.correctCapture(id, text);
    } catch (_) {
      // Ignore — the id may not be a graph capture, or the backend is offline.
    }
  }

  /// Confirmed delete — best-effort remove from the Library, then leave to it.
  /// The navigation happens regardless so the flow stays consistent even when
  /// the id is a sample (null) or the backend is unreachable.
  Future<void> _deleteMemory() async {
    // Play the fold-away, drop from the store + backend, then leave to Library.
    setState(() {
      _confirm = false;
      _deleting = true;
    });
    final id = widget.id;
    if (id != null) {
      final services = AppScope.servicesOf(context);
      services.memoryStore.removeLocal(id);
      services.libraryRepository.delete(id).ignore();
    }
    await Future<void>.delayed(const Duration(milliseconds: 460));
    if (!mounted) return;
    widget.go('library');
  }

  /// "Add to collection" — pick an existing collection or create one, then add
  /// this memory to it via `collectionsRepository.addItems`. Guards a null id
  /// (sample memory): the picker still opens, but the add is skipped.
  Future<void> _addToCollection() async {
    setState(() => _menu = false);
    final services = AppScope.servicesOf(context);
    List<MemoryCollection> collections = const [];
    try {
      collections = await services.collectionsRepository.list();
    } catch (_) {
      // Fall back to an empty list — the user can still create a new one.
    }
    if (!mounted) return;
    final choice = await showModalBottomSheet<RdColChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RdCollectionPickerSheet(collections: collections),
    );
    if (choice == null || !mounted) return;
    final id = widget.id;
    try {
      final target = choice.collection ??
          await services.collectionsRepository.create(name: choice.name!);
      if (id != null) {
        await services.collectionsRepository.addItems(target.id, [id]);
      }
      if (!mounted) return;
      _toast('Added to “${target.name}”');
    } catch (_) {
      _toast('Couldn’t add to collection. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.rd.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInCubic,
              scale: _deleting ? 0.92 : 1,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 420),
                opacity: _deleting ? 0 : 1,
                child: Column(
                  children: [
                    _head(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 6, 26, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _content(),
                        ),
                      ),
                    ),
                    _actionBar(),
                  ],
                ),
              ),
            ),
            if (_menu) _menuOverlay(),
            if (_saved) _savedToast(),
            if (_confirm) _deleteSheet(),
            if (_sharing) _shareSheet(),
          ],
        ),
      ),
    );
  }

  // ── header ──────────────────────────────────────────────────────────
  Widget _head() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  RdIcon('<path d="M15 5l-7 7 7 7"/>', size: 20, stroke: '#45464E', strokeWidth: 2, color: rd.ink),
                  const SizedBox(width: 3),
                  Text(widget.backLabel,
                      style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: rd.ink)),
                ],
              ),
            ),
          ),
          const Spacer(),
          _iconBtn(
            '<path d="M12 17v5M9 3h6l-1 7 3 3H7l3-3-1-7Z"/>',
            active: _pinned,
            // Filled pin when pinned (mirrors the design's fill="currentColor").
            fill: _pinned ? '#14328C' : 'none',
            onTap: _togglePin,
          ),
          const SizedBox(width: 6),
          _iconBtn(
            '<circle cx="12" cy="5" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="12" cy="19" r="1.4"/>',
            active: _menu,
            strokeWidth: 2,
            onTap: () => setState(() => _menu = !_menu),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(String icon,
      {required VoidCallback onTap,
      bool active = false,
      double strokeWidth = 1.75,
      String fill = 'none'}) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: RdIcon(icon,
            size: 20,
            stroke: active ? '#14328C' : '#45464E',
            // Navy active state stays on-brand; inactive stroke is text-tone.
            color: active ? null : rd.ink,
            strokeWidth: strokeWidth,
            fill: fill),
      ),
    );
  }

  // ── content ─────────────────────────────────────────────────────────
  List<Widget> _content() {
    final rd = context.rd;
    return [
      _typeRow(),
      if (_editing) _editBar(),
      const SizedBox(height: 16),
      _editing
          ? _titleInput()
          : Text(_title,
              style: GoogleFonts.dosis(fontSize: 27, fontWeight: FontWeight.w700, height: 1.18, color: rd.ink)),
      if (widget.isVoice && !_editing) ...[const SizedBox(height: 14), _player()],
      const SizedBox(height: 14),
      _editing ? _bodyInput() : _capture(),
      const SizedBox(height: 22),
      if (_realInsight != null) ...[
        _insight(),
        const SizedBox(height: 26),
      ],
      if (_links.isNotEmpty) ...[
        _connections(),
        const SizedBox(height: 26),
      ],
      if ((_realPeople?.isNotEmpty ?? false) || (_realTags?.isNotEmpty ?? false)) ...[
        _peopleTags(),
        const SizedBox(height: 26),
      ],
      _source(),
    ];
  }

  Widget _typeRow() {
    final rd = context.rd;
    final label = widget.isVoice ? 'Voice note · 0:34' : 'Note';
    final time = _edited
        ? 'Edited just now · today, 4:12 PM'
        : (widget.isVoice ? 'Recorded 2h ago · today, 4:12 PM' : 'Captured 2h ago · today, 4:12 PM');
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          decoration: BoxDecoration(color: rd.periSoft, borderRadius: BorderRadius.circular(100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon stays navy on the periSoft badge (matches Library); the
              // label text uses `peri` so it reads on both light/dark periSoft.
              RdIcon(widget.isVoice ? _voiceIcon : _noteIcon, size: 15, stroke: '#14328C', strokeWidth: 1.9),
              const SizedBox(width: 7),
              Text(label, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: rd.peri)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(time, style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _editBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(color: const Color(0xFFEEF0F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RdIcon('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', size: 15, stroke: '#14328C', strokeWidth: 1.8),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.isVoice
                    ? 'Editing the transcript — Mira will re-read it and refresh connections when you save.'
                    : 'Editing note — Mira will re-read it and refresh connections when you save.',
                style: GoogleFonts.vazirmatn(fontSize: 12.5, height: 1.4, color: const Color(0xFF46485A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleInput() {
    final rd = context.rd;
    return TextField(
      controller: _titleCtl,
      cursorColor: rd.navy,
      maxLines: null,
      style: GoogleFonts.dosis(fontSize: 27, fontWeight: FontWeight.w700, height: 1.18, color: rd.ink),
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.only(bottom: 6),
        hintText: 'Title',
        border: UnderlineInputBorder(borderSide: BorderSide(color: _peri, width: 1.5)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _peri, width: 1.5)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _peri, width: 1.5)),
      ),
    );
  }

  Widget _bodyInput() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final flags = widget.isVoice ? _transcriptFlags(_bodyCtl.text) : const <String>[];
    final unresolved = flags.length - _fixedFlags.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isVoice) ...[
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F1EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _playing = !_playing),
                    child: RdIcon(
                      _playing
                          ? '<rect x="6" y="5" width="4" height="14" rx="1.3"/><rect x="14" y="5" width="4" height="14" rx="1.3"/>'
                          : '<path d="M8 5v14l11-7z"/>',
                      size: 16,
                      color: const Color(0xFF1F8A5B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 28,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(24, (i) {
                        final h = 12.0 + (i % 5) * 4.0;
                        final done = _playing && i / 24 < _pos / _clip;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            height: h,
                            decoration: BoxDecoration(
                              color: done ? const Color(0xFF1F8A5B) : const Color(0xFFD8E8DF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _bodyCtl,
          focusNode: _bodyFocus,
          onChanged: widget.isVoice ? (_) => setState(() {}) : null,
          cursorColor: rd.navy,
          maxLines: widget.isVoice ? 7 : 5,
          minLines: widget.isVoice ? 7 : 5,
          style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.62, color: rd.ink),
          decoration: InputDecoration(
            hintText: widget.isVoice ? 'Transcript…' : 'Write your note…',
            filled: true,
            fillColor: rd.card,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
          ),
        ),
        if (widget.isVoice && flags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RdIcon('<path d="M12 9v4M12 17h.01"/>', size: 14, stroke: '#C58E3F', strokeWidth: 2),
                  const SizedBox(width: 6),
                  Text(
                    unresolved <= 0
                        ? l10n.rdMemoryFlagsAllChecked
                        : l10n.rdMemoryFlagsUnresolved(unresolved),
                    style: GoogleFonts.vazirmatn(fontSize: 12, color: const Color(0xFF8A6D2F)),
                  ),
                ],
              ),
              for (var i = 0; i < flags.length; i++)
                GestureDetector(
                  onTap: () => _jumpToFlagWord(flags[i], i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: _fixedFlags.contains(i) ? const Color(0xFFE7F3EC) : const Color(0xFFFBF3E4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _fixedFlags.contains(i)
                            ? const Color(0xFF1F8A5B).withValues(alpha: 0.3)
                            : const Color(0xFFC58E3F).withValues(alpha: 0.32),
                      ),
                    ),
                    child: Text(
                      flags[i],
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _fixedFlags.contains(i) ? const Color(0xFF1F8A5B) : const Color(0xFF8A6D2F),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rdMemoryFlagsHint,
            style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.faint),
          ),
        ],
      ],
    );
  }

  Widget _capture() {
    final rd = context.rd;
    if (widget.isVoice) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _miniOrb(),
                const SizedBox(width: 8),
                Text('TRANSCRIBED BY MIRA',
                    style: GoogleFonts.vazirmatn(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: rd.peri)),
              ],
            ),
            const SizedBox(height: 10),
            Text(_body, style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.64, color: rd.ink)),
          ],
        ),
      );
    }
    return Text(_body, style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.62, color: rd.ink));
  }

  /// Scrub the voice player to a fraction of its length (tap / drag the wave).
  void _seek(double fraction) {
    setState(() => _pos = fraction.clamp(0.0, 1.0) * _clip);
  }

  Widget _player() {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(center: Alignment(-0.28, -0.4), colors: [Color(0xFF4A6AD8), Color(0xFF14328C)]),
              ),
              child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _seek(d.localPosition.dx / c.maxWidth),
                onHorizontalDragUpdate: (d) =>
                    _seek(d.localPosition.dx / c.maxWidth),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      for (var i = 0; i < _wave.length; i++) ...[
                        if (i > 0) const SizedBox(width: 2.5),
                        Expanded(
                          child: Container(
                            height: 18 + _wave[i] * 30,
                            decoration: BoxDecoration(
                              color: (i + 0.5) / _wave.length <= _pos / _clip
                                  ? rd.peri
                                  : rd.line,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_fmt(_pos)} / ${_fmt(_clip)}',
                  style: GoogleFonts.vazirmatn(fontSize: 11.5, fontWeight: FontWeight.w600, color: rd.muted)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _cycleSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: rd.periSoft, borderRadius: BorderRadius.circular(100)),
                  child: Text('${_speed == _speed.toInt() ? _speed.toInt() : _speed}×',
                      style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w700, color: rd.peri)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _insight() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1F3FB), Color(0xFFE9ECF8)]),
        border: Border.all(color: _peri.withValues(alpha: 0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _miniOrb(size: 24),
              const SizedBox(width: 10),
              Text('Mira noticed', style: GoogleFonts.dosis(fontSize: 14.5, fontWeight: FontWeight.w700, color: _navy)),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            _realInsight ?? '',
            style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.55, color: const Color(0xFF46485A)),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _toggleReminder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(13)),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: const Color(0xFFE7EBF8), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: RdIcon('<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M12 2h0M5 4 3 6M19 4l2 2"/>', size: 17, stroke: '#14328C', strokeWidth: 1.8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reminder',
                            style: GoogleFonts.vazirmatn(fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink)),
                        const SizedBox(height: 2),
                        Text(
                          _reminded
                              ? (widget.isVoice ? 'On — tracked in your Brief' : 'On — Mira will bring this up')
                              : 'Off — tap to remind me',
                          style: GoogleFonts.vazirmatn(fontSize: 11.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  _MiniSwitch(on: _reminded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connections() {
    final rd = context.rd;
    final links = _links;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                RdIcon('<circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="M8.2 10.8 15.8 7"/><path d="M8.2 13.2 15.8 17"/>', size: 16, stroke: '#7E8BC9', strokeWidth: 1.9, color: rd.peri),
                const SizedBox(width: 8),
                Text('Connected memories', style: GoogleFonts.dosis(fontSize: 14.5, fontWeight: FontWeight.w700, color: rd.ink)),
              ],
            ),
            GestureDetector(
              onTap: () => widget.go('canvas'),
              child: Text('See in Canvas', style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: rd.navy)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final l in links) ...[
          _LinkRow(link: l, onTap: () => _openLink(l)),
          if (l != links.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _peopleTags() {
    // People/tags come only from the graph; nothing fabricated. This section is
    // only rendered when at least one of them is present.
    final people = _realPeople ?? const <_Person>[];
    final tags = _realTags ?? const <String>[];
    final rd = context.rd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RdIcon('<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>', size: 16, stroke: '#7E8BC9', strokeWidth: 1.9, color: rd.peri),
            const SizedBox(width: 8),
            Text('People & tags', style: GoogleFonts.dosis(fontSize: 14.5, fontWeight: FontWeight.w700, color: rd.ink)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final person in people)
              Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 13, 5),
                decoration: BoxDecoration(color: rd.card, borderRadius: BorderRadius.circular(100), border: Border.all(color: rd.line, width: 1)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: rd.periSoft),
                      child: Center(child: Text(person.initial, style: GoogleFonts.dosis(fontSize: 13, fontWeight: FontWeight.w700, color: rd.peri))),
                    ),
                    const SizedBox(width: 8),
                    Text(person.name, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: rd.ink)),
                  ],
                ),
              ),
            for (final t in tags)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(color: rd.card, borderRadius: BorderRadius.circular(100), border: Border.all(color: rd.line, width: 1)),
                child: Text(t, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w500, color: rd.muted)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _source() {
    final rd = context.rd;
    return Row(
      children: [
        RdIcon(widget.isVoice ? _voiceIcon : _noteIcon, size: 15, stroke: '#B7B8BE', strokeWidth: 1.8, color: rd.faint),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.isVoice ? 'Recorded on Home · iPhone · not shared' : 'Typed on Home · iPhone · not shared',
            style: GoogleFonts.vazirmatn(fontSize: 11.5, color: rd.faint),
          ),
        ),
      ],
    );
  }

  // ── action bar ──────────────────────────────────────────────────────
  Widget _actionBar() {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: rd.line, width: 1))),
      child: _editing
          ? Row(
              children: [
                _ghostButton('Cancel', () => setState(() => _editing = false)),
                const SizedBox(width: 10),
                Expanded(child: _primaryButton('Save changes', '<path d="M20 6 9 17l-5-5"/>', _saveEdit)),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _primaryButton(
                    'Ask Mira about this',
                    '<path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.5 8.6 8.6 0 0 1-3.9-.9L3 21l1.9-5.6A8.4 8.4 0 0 1 4 11.5 8.5 8.5 0 0 1 12.5 3 8.4 8.4 0 0 1 21 11.5Z"/>',
                    () => widget.go(
                      'chat',
                      arg: RdMemoryArg(
                        id: widget.id,
                        title: _title,
                        body: _body,
                        isVoice: widget.isVoice,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _sqButton('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', _startEdit),
                const SizedBox(width: 10),
                _sqButton('<path d="M12 15V3M8 7l4-4 4 4"/><path d="M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7"/>', _openShare),
              ],
            ),
    );
  }

  Widget _primaryButton(String label, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RdIcon(icon, size: 19, stroke: '#FFFFFF', strokeWidth: 1.9),
            const SizedBox(width: 9),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _sqButton(String icon, VoidCallback onTap) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: rd.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: rd.line, width: 1)),
        child: Center(child: RdIcon(icon, size: 20, stroke: '#55565F', strokeWidth: 1.8, color: rd.ink)),
      ),
    );
  }

  Widget _ghostButton(String label, VoidCallback onTap) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: rd.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: rd.line, width: 1)),
        child: Text(label, style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: rd.ink)),
      ),
    );
  }

  // ── overlays ────────────────────────────────────────────────────────
  Widget _menuOverlay() {
    final rd = context.rd;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(child: GestureDetector(onTap: () => setState(() => _menu = false), behavior: HitTestBehavior.opaque)),
          Positioned(
            top: 50,
            right: 14,
            child: Container(
              width: 194,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: rd.line, width: 1),
                boxShadow: [BoxShadow(color: const Color(0xFF141A32).withValues(alpha: 0.28), blurRadius: 44, spreadRadius: -12, offset: const Offset(0, 18))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuItem('<path d="M12 17v5M9 3h6l-1 7 3 3H7l3-3-1-7Z"/>', _pinned ? 'Unpin' : 'Pin to top', _togglePin),
                  _menuItem('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', 'Edit note', _startEdit),
                  _menuItem('<rect x="3" y="4" width="18" height="16" rx="2.5"/><path d="M3 9h18"/>', 'Add to collection', _addToCollection),
                  _menuItem('<path d="M12 15V3M8 7l4-4 4 4"/><path d="M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7"/>', 'Share memory', _openShare),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Divider(height: 1, color: rd.line)),
                  _menuItem('<path d="M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6"/><path d="M10 11v6M14 11v6"/>', 'Delete memory', () => setState(() { _menu = false; _confirm = true; }), danger: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String icon, String label, VoidCallback onTap, {bool danger = false}) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            // Danger stays fixed red; the neutral items use the muted text tone.
            RdIcon(icon, size: 17, stroke: danger ? '#C0392B' : '#8A8B92', strokeWidth: 1.8, color: danger ? null : rd.muted),
            const SizedBox(width: 11),
            Text(label, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w500, color: danger ? _danger : rd.ink)),
          ],
        ),
      ),
    );
  }

  // The rich "Mira re-read this" confirmation from the design — a positioned
  // overlay pill, distinct from the plain [_toast] SnackBar used elsewhere.
  Widget _savedToast() {
    final rd = context.rd;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 92,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            // Inverting pill (dark in light mode, light in dark) so it stays
            // legible over either background — mirrors the plain [_toast].
            color: rd.ink,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(color: const Color(0xFF141A32).withValues(alpha: 0.5), blurRadius: 34, spreadRadius: -10, offset: const Offset(0, 14))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFF9FB0EA), Color(0xFF14328C)])),
              ),
              const SizedBox(width: 10),
              Text(
                widget.isVoice ? 'Saved — Mira re-read your transcript' : 'Saved — Mira re-read this note',
                style: GoogleFonts.vazirmatn(fontSize: 13.5, fontWeight: FontWeight.w500, color: rd.bg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── share ─────────────────────────────────────────────────────────────
  String get _shareText => _body.trim().isEmpty ? _title : '$_title\n\n$_body';
  String get _shareLink => 'https://miramind.io/m/${widget.id ?? ''}';

  void _openShare() => setState(() {
        _menu = false;
        _linkCopied = false;
        _sharing = true;
      });

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _shareLink));
    if (mounted) setState(() => _linkCopied = true);
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!mounted) return;
    setState(() => _sharing = false);
    _toast('Copied to clipboard');
  }

  /// Hand off to a real OS app (mail / messaging). Falls back to a toast when no
  /// handler is installed (e.g. desktop / simulators).
  Future<void> _shareVia(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        _toast('No app available for that');
        return;
      }
      setState(() => _sharing = false);
    } catch (_) {
      if (mounted) _toast('No app available for that');
    }
  }

  void _shareMail() => _shareVia(Uri.parse(
        'mailto:?subject=${Uri.encodeQueryComponent(_title)}'
        '&body=${Uri.encodeQueryComponent(_shareText)}',
      ));

  void _shareMessage() =>
      _shareVia(Uri.parse('sms:?body=${Uri.encodeQueryComponent(_shareText)}'));

  Widget _shareSheet() {
    final rd = context.rd;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _sharing = false),
              child: Container(color: const Color(0x6B111426)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: rd.line,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  Text('Share memory',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dosis(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: rd.ink)),
                  const SizedBox(height: 4),
                  Text('“$_title”',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted)),
                  const SizedBox(height: 16),
                  _shareRow(
                    _linkCopied
                        ? '<path d="M20 6 9 17l-5-5"/>'
                        : '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
                    _linkCopied ? 'Link copied' : 'Copy link',
                    _copyLink,
                    highlight: _linkCopied,
                  ),
                  _shareRow(
                      '<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/>',
                      'Copy as text',
                      _copyText),
                  _shareRow(
                      '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m4 7 8 6 8-6"/>',
                      'Email',
                      _shareMail),
                  _shareRow(
                      '<path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.5 8.6 8.6 0 0 1-3.9-.9L3 21l1.9-5.6A8.4 8.4 0 0 1 4 11.5 8.5 8.5 0 0 1 12.5 3 8.4 8.4 0 0 1 21 11.5Z"/>',
                      'Message',
                      _shareMessage),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _sharing = false),
                    child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text('Done',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: rd.muted))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareRow(String icon, String label, VoidCallback onTap,
      {bool highlight = false}) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlight ? _navy : rd.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rd.line, width: 1),
              ),
              child: Center(
                child: RdIcon(icon,
                    size: 19,
                    strokeWidth: 1.8,
                    color: highlight ? Colors.white : rd.ink),
              ),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: highlight ? rd.navy : rd.ink)),
          ],
        ),
      ),
    );
  }

  Widget _deleteSheet() {
    final rd = context.rd;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _confirm = false),
              child: Container(color: const Color(0x6B111426)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: rd.line, borderRadius: BorderRadius.circular(100))),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFBEAE7)),
                    child: const Center(child: RdIcon('<path d="M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6"/><path d="M10 11v6M14 11v6"/>', size: 22, stroke: '#C0392B', strokeWidth: 1.8)),
                  ),
                  const SizedBox(height: 16),
                  Text('Delete this memory?', style: GoogleFonts.dosis(fontSize: 21, fontWeight: FontWeight.w700, color: rd.ink)),
                  const SizedBox(height: 9),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '“$_title” and its '),
                        TextSpan(text: '3 connections', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600, color: rd.ink)),
                        const TextSpan(text: ' will be removed from your Library. This can’t be undone.'),
                      ],
                      style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.55, color: rd.muted),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: _deleteMemory,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _danger, borderRadius: BorderRadius.circular(14)),
                      child: Text('Delete memory', style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _confirm = false),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      alignment: Alignment.center,
                      child: Text('Keep it', style: GoogleFonts.vazirmatn(fontSize: 14.5, fontWeight: FontWeight.w600, color: rd.muted)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniOrb({double size = 15}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: Alignment(-0.28, -0.4), colors: [Color(0xFF8FA0DD), Color(0xFF14328C)]),
      ),
    );
  }
}

const _noteIcon = '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>';
const _voiceIcon = '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>';

class _MemLink {
  const _MemLink(this.type, this.title, this.sub, this.rel, {this.id});
  final String type;
  final String title;
  final String sub;
  final String rel;

  /// Graph capture id when this link came from real data — lets the row open
  /// that memory. Null for the sample links, which fall back to opening chat.
  final String? id;
}

({Color bg, String stroke, String icon}) _linkStyle(String type) {
  switch (type) {
    case 'event':
      return (bg: const Color(0xFFEDEFF8), stroke: '#14328C', icon: '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>');
    case 'photo':
      return (bg: const Color(0xFFE7EEFB), stroke: '#4E63A6', icon: '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/>');
    case 'voice':
      return (bg: const Color(0xFFE9F1EC), stroke: '#1F8A5B', icon: _voiceIcon);
    case 'link':
      return (bg: const Color(0xFFEEECF8), stroke: '#6A5EA8', icon: '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>');
    default:
      return (bg: const Color(0xFFEDEFF8), stroke: '#14328C', icon: _noteIcon);
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link, required this.onTap});

  final _MemLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final s = _linkStyle(link.type);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(color: rd.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: rd.line, width: 1)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(11)),
              child: Center(child: RdIcon(s.icon, size: 18, stroke: s.stroke, strokeWidth: 1.8)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink)),
                  const SizedBox(height: 3),
                  Text(link.sub, style: GoogleFonts.vazirmatn(fontSize: 11.5, color: rd.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(link.rel, style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w600, color: rd.peri)),
          ],
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(color: on ? _navy : const Color(0xFFD3D5DE), borderRadius: BorderRadius.circular(100)),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    );
  }
}
