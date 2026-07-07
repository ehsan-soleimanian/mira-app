import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/models/api/collection_models.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_collection_picker.dart';
import '../widgets/rd_icon.dart';

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

const _ink = Color(0xFF1B1C24);
const _navy = Color(0xFF14328C);
const _peri = Color(0xFF7E8BC9);
const _muted = Color(0xFF8A8B92);
const _faint = Color(0xFFB7B8BE);
const _line = Color(0xFFE9E9E4);
const _periSoft = Color(0xFFEDEFF8);
const _card = Color(0xFFFBFBF9);
const _danger = Color(0xFFC0392B);
const _clip = 34.0;

class _RdMemoryScreenState extends State<RdMemoryScreen> {
  bool _pinned = false;
  bool _reminded = true;
  bool _menu = false;
  bool _confirm = false;
  bool _editing = false;
  bool _edited = false;
  bool _saved = false;

  bool _playing = false;
  double _pos = 0;
  double _speed = 1;
  Timer? _tick;

  late String _title = widget.title ?? (widget.isVoice ? _voiceTitle : _noteTitle);
  late String _body = widget.body ?? (widget.isVoice ? _voiceBody : _noteBody);
  late final TextEditingController _titleCtl = TextEditingController();
  late final TextEditingController _bodyCtl = TextEditingController();
  final Set<int> _fixed = {};

  static const _noteTitle = 'Contract with John';
  static const _noteBody =
      'Needs a call to confirm the terms before Friday. The signed copy is in the folder from last week’s meeting — John wants the partnership scope narrowed to Q3 first.';
  static const _voiceTitle = 'Idea for the Q3 launch';
  static const _voiceBody =
      'So the thought is — we lead the Q3 launch with the onboarding story, not the feature list. People connect with the calm, not the checklist. Let’s ask design for a quiet hero and pull the three testimonials from last quarter. Circle back with Priya on timing.';

  static const _wave = [
    .28, .42, .6, .35, .5, .78, .55, .4, .66, .9, .62, .44, .3, .52, .72, .85,
    .6, .38, .48, .7, .95, .68, .5, .34, .46, .64, .8, .58, .4, .3, .52, .68, .44, .36, .5, .26,
  ];

  @override
  void dispose() {
    _tick?.cancel();
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
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

  // Pin is client-only for now — there is no backend pin flag yet, so the
  // toggle just flips local state and confirms with a toast.
  void _togglePin() {
    final next = !_pinned;
    setState(() {
      _pinned = next;
      _menu = false;
    });
    _toast(next ? 'Pinned' : 'Unpinned');
  }

  String _fmt(double s) =>
      '${(s ~/ 60)}:${(s % 60).floor().toString().padLeft(2, '0')}';

  void _startEdit() {
    _titleCtl.text = _title;
    _bodyCtl.text = _body;
    _fixed.clear();
    setState(() {
      _playing = false;
      _editing = true;
      _menu = false;
    });
  }

  void _saveEdit() {
    final nextTitle =
        _titleCtl.text.trim().isEmpty ? _title : _titleCtl.text.trim();
    setState(() {
      _title = nextTitle;
      _body = _bodyCtl.text.trim().isEmpty ? _body : _bodyCtl.text.trim();
      _editing = false;
      _edited = true;
      _saved = true;
    });
    // Best-effort persistence of the new title. `widget.id` may be a library
    // item (not a graph capture), so failures are ignored — the local edit and
    // the "re-read" toast already reflect the change.
    unawaited(_persistTitle(nextTitle));
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

  /// Confirmed delete — best-effort remove from the Library, then leave to it.
  /// The navigation happens regardless so the flow stays consistent even when
  /// the id is a sample (null) or the backend is unreachable.
  Future<void> _deleteMemory() async {
    setState(() => _confirm = false);
    final id = widget.id;
    if (id != null) {
      try {
        await AppScope.servicesOf(context).libraryRepository.delete(id);
      } catch (_) {
        // Ignore — leave to the Library either way.
      }
    }
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
      backgroundColor: RdColors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
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
            if (_menu) _menuOverlay(),
            if (_saved) _savedToast(),
            if (_confirm) _deleteSheet(),
          ],
        ),
      ),
    );
  }

  // ── header ──────────────────────────────────────────────────────────
  Widget _head() {
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
                  const RdIcon('<path d="M15 5l-7 7 7 7"/>', size: 20, stroke: '#45464E', strokeWidth: 2),
                  const SizedBox(width: 3),
                  Text(widget.backLabel,
                      style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF45464E))),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: RdIcon(icon,
            size: 20,
            stroke: active ? '#14328C' : '#45464E',
            strokeWidth: strokeWidth,
            fill: fill),
      ),
    );
  }

  // ── content ─────────────────────────────────────────────────────────
  List<Widget> _content() {
    return [
      _typeRow(),
      if (_editing) _editBar(),
      const SizedBox(height: 16),
      _editing
          ? _titleInput()
          : Text(_title,
              style: GoogleFonts.dosis(fontSize: 27, fontWeight: FontWeight.w700, height: 1.18, color: _ink)),
      if (widget.isVoice && !_editing) ...[const SizedBox(height: 14), _player()],
      const SizedBox(height: 14),
      _editing ? _bodyInput() : _capture(),
      const SizedBox(height: 22),
      _insight(),
      const SizedBox(height: 26),
      _connections(),
      const SizedBox(height: 26),
      _peopleTags(),
      const SizedBox(height: 26),
      _source(),
    ];
  }

  Widget _typeRow() {
    final label = widget.isVoice ? 'Voice note · 0:34' : 'Note';
    final time = _edited
        ? 'Edited just now · today, 4:12 PM'
        : (widget.isVoice ? 'Recorded 2h ago · today, 4:12 PM' : 'Captured 2h ago · today, 4:12 PM');
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          decoration: BoxDecoration(color: _periSoft, borderRadius: BorderRadius.circular(100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RdIcon(widget.isVoice ? _voiceIcon : _noteIcon, size: 15, stroke: '#14328C', strokeWidth: 1.9),
              const SizedBox(width: 7),
              Text(label, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navy)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(time, style: GoogleFonts.vazirmatn(fontSize: 12, color: _muted), overflow: TextOverflow.ellipsis),
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
    return TextField(
      controller: _titleCtl,
      cursorColor: _navy,
      maxLines: null,
      style: GoogleFonts.dosis(fontSize: 27, fontWeight: FontWeight.w700, height: 1.18, color: _ink),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isVoice) _flags(),
        TextField(
          controller: _bodyCtl,
          cursorColor: _navy,
          maxLines: widget.isVoice ? 7 : 5,
          minLines: widget.isVoice ? 7 : 5,
          style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.62, color: const Color(0xFF34353E)),
          decoration: InputDecoration(
            hintText: widget.isVoice ? 'Transcript…' : 'Write your note…',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _peri, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _flags() {
    const words = ['testimonials', 'Priya'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RdIcon('<path d="M10.3 3.3 1.8 18a1 1 0 0 0 .87 1.5h18.66a1 1 0 0 0 .87-1.5L13.7 3.3a1 1 0 0 0-1.74 0Z"/><path d="M12 9v4M12 17h0"/>', size: 14, stroke: '#C58E3F', strokeWidth: 1.8),
              const SizedBox(width: 7),
              Text(
                _fixed.length >= words.length
                    ? 'All checked — thanks'
                    : '${words.length - _fixed.length} word${words.length - _fixed.length == 1 ? '' : 's'} Mira wasn’t sure of',
                style: GoogleFonts.vazirmatn(fontSize: 12, color: const Color(0xFF8A6D2F)),
              ),
            ],
          ),
          for (var i = 0; i < words.length; i++)
            GestureDetector(
              onTap: () => setState(() => _fixed.add(i)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: _fixed.contains(i) ? const Color(0xFFE7F3EC) : const Color(0xFFFBF3E4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  words[i],
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _fixed.contains(i) ? const Color(0xFF1F8A5B) : const Color(0xFF8A6D2F),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _capture() {
    if (widget.isVoice) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _miniOrb(),
                const SizedBox(width: 8),
                Text('TRANSCRIBED BY MIRA',
                    style: GoogleFonts.vazirmatn(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: _peri)),
              ],
            ),
            const SizedBox(height: 10),
            Text(_body, style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.64, color: const Color(0xFF34353E))),
          ],
        ),
      );
    }
    return Text(_body, style: GoogleFonts.vazirmatn(fontSize: 15.5, height: 1.62, color: const Color(0xFF34353E)));
  }

  Widget _player() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line, width: 1),
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
                          color: (i + 0.5) / _wave.length <= _pos / _clip ? _peri : const Color(0xFFD6D9E6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_fmt(_pos)} / ${_fmt(_clip)}',
                  style: GoogleFonts.vazirmatn(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF6A6C78))),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _cycleSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEEF0F9), borderRadius: BorderRadius.circular(100)),
                  child: Text('${_speed == _speed.toInt() ? _speed.toInt() : _speed}×',
                      style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w700, color: _navy)),
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
            widget.isVoice
                ? 'You were thinking out loud about the launch. I pulled out three actions — brief design, gather testimonials, check timing with Priya — and linked them to your Q3 plan.'
                : 'This looks time-sensitive. I linked it to your meeting with John and the signed contract photo, and set a gentle reminder so it doesn’t slip.',
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
                        Text(widget.isVoice ? '3 actions · added to your list' : 'Reminder · Thursday morning',
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
    final links = widget.isVoice ? _voiceLinks : _noteLinks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const RdIcon('<circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="M8.2 10.8 15.8 7"/><path d="M8.2 13.2 15.8 17"/>', size: 16, stroke: '#7E8BC9', strokeWidth: 1.9),
                const SizedBox(width: 8),
                Text('Connected memories', style: GoogleFonts.dosis(fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF3A3B44))),
              ],
            ),
            GestureDetector(
              onTap: () => widget.go('canvas'),
              child: Text('See in Canvas', style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navy)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final l in links) ...[
          _LinkRow(link: l, onTap: () => widget.go('chat')),
          if (l != links.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _peopleTags() {
    final person = widget.isVoice ? ('P', 'Priya Shah') : ('J', 'John Avery');
    final tags = widget.isVoice ? ['#q3', '#launch', '#idea'] : ['#contract', '#partnership', '#q3'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const RdIcon('<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>', size: 16, stroke: '#7E8BC9', strokeWidth: 1.9),
            const SizedBox(width: 8),
            Text('People & tags', style: GoogleFonts.dosis(fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF3A3B44))),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 13, 5),
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(100), border: Border.all(color: _line, width: 1)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE6EAF7)),
                    child: Center(child: Text(person.$1, style: GoogleFonts.dosis(fontSize: 13, fontWeight: FontWeight.w700, color: _navy))),
                  ),
                  const SizedBox(width: 8),
                  Text(person.$2, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                ],
              ),
            ),
            for (final t in tags)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(100), border: Border.all(color: _line, width: 1)),
                child: Text(t, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w500, color: const Color(0xFF6B6C77))),
              ),
          ],
        ),
      ],
    );
  }

  Widget _source() {
    return Row(
      children: [
        RdIcon(widget.isVoice ? _voiceIcon : _noteIcon, size: 15, stroke: '#B7B8BE', strokeWidth: 1.8),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.isVoice ? 'Recorded on Home · iPhone · not shared' : 'Typed on Home · iPhone · not shared',
            style: GoogleFonts.vazirmatn(fontSize: 11.5, color: _faint),
          ),
        ),
      ],
    );
  }

  // ── action bar ──────────────────────────────────────────────────────
  Widget _actionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line, width: 1))),
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
                    () => widget.go('chat'),
                  ),
                ),
                const SizedBox(width: 10),
                _sqButton('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', _startEdit),
                const SizedBox(width: 10),
                _sqButton('<path d="M12 15V3M8 7l4-4 4 4"/><path d="M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7"/>', () {}),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line, width: 1)),
        child: Center(child: RdIcon(icon, size: 20, stroke: '#55565F', strokeWidth: 1.8)),
      ),
    );
  }

  Widget _ghostButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line, width: 1)),
        child: Text(label, style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF55565F))),
      ),
    );
  }

  // ── overlays ────────────────────────────────────────────────────────
  Widget _menuOverlay() {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _line, width: 1),
                boxShadow: [BoxShadow(color: const Color(0xFF141A32).withValues(alpha: 0.28), blurRadius: 44, spreadRadius: -12, offset: const Offset(0, 18))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuItem('<path d="M12 17v5M9 3h6l-1 7 3 3H7l3-3-1-7Z"/>', _pinned ? 'Unpin' : 'Pin to top', _togglePin),
                  _menuItem('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', 'Edit note', _startEdit),
                  _menuItem('<rect x="3" y="4" width="18" height="16" rx="2.5"/><path d="M3 9h18"/>', 'Add to collection', _addToCollection),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Divider(height: 1, color: _line)),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            RdIcon(icon, size: 17, stroke: danger ? '#C0392B' : '#8A8B92', strokeWidth: 1.8),
            const SizedBox(width: 11),
            Text(label, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w500, color: danger ? _danger : _ink)),
          ],
        ),
      ),
    );
  }

  // The rich "Mira re-read this" confirmation from the design — a positioned
  // overlay pill, distinct from the plain [_toast] SnackBar used elsewhere.
  Widget _savedToast() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 92,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C24),
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
                style: GoogleFonts.vazirmatn(fontSize: 13.5, fontWeight: FontWeight.w500, color: const Color(0xFFF4F4F1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteSheet() {
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
              decoration: const BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: const Color(0xFFDEDEE4), borderRadius: BorderRadius.circular(100))),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFBEAE7)),
                    child: const Center(child: RdIcon('<path d="M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6"/><path d="M10 11v6M14 11v6"/>', size: 22, stroke: '#C0392B', strokeWidth: 1.8)),
                  ),
                  const SizedBox(height: 16),
                  Text('Delete this memory?', style: GoogleFonts.dosis(fontSize: 21, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 9),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '“$_title” and its '),
                        TextSpan(text: '3 connections', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600, color: _ink)),
                        const TextSpan(text: ' will be removed from your Library. This can’t be undone.'),
                      ],
                      style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.55, color: const Color(0xFF64656F)),
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
                      child: Text('Keep it', style: GoogleFonts.vazirmatn(fontSize: 14.5, fontWeight: FontWeight.w600, color: _muted)),
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
  const _MemLink(this.type, this.title, this.sub, this.rel);
  final String type;
  final String title;
  final String sub;
  final String rel;
}

const _noteLinks = [
  _MemLink('event', 'Meeting with John', 'Last Thursday · where this came up', 'Discussed here'),
  _MemLink('photo', 'Signed contract — page 1', 'Photo · read by Mira', 'Attached'),
  _MemLink('note', 'Q3 partnership terms', 'Note · 3 days ago', 'Related topic'),
];
const _voiceLinks = [
  _MemLink('event', 'Q3 launch planning', 'Next Tuesday · on your calendar', 'Related event'),
  _MemLink('note', 'Onboarding story draft', 'Note · last week', 'Builds on'),
  _MemLink('voice', 'Priya — timing thoughts', 'Voice · 5 days ago', 'Same topic'),
];

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
    final s = _linkStyle(link.type);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(15), border: Border.all(color: _line, width: 1)),
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
                  Text(link.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
                  const SizedBox(height: 3),
                  Text(link.sub, style: GoogleFonts.vazirmatn(fontSize: 11.5, color: _muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(link.rel, style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w600, color: _peri)),
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
