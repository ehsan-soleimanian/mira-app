import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Ask — the global "ask anything" search. The second-mind promise: ask across
/// everything and get a grounded answer with the memories it drew from. Reached
/// from the search icon on Home and Library; distinct from Chat (which is
/// anchored to one memory). Wired to `POST /assistant/run` (action `ask`), whose
/// `citations` are the real memories the answer leans on — tapping one opens it.
/// Faithful to design2 `ask.jsx` (`.ask-*`).
class RdAskScreen extends StatefulWidget {
  const RdAskScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdAskScreen> createState() => _RdAskScreenState();
}

class _RdAskScreenState extends State<RdAskScreen> {
  static const _spark =
      '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5 18 18'
      'M18 6l-2.5 2.5M8.5 15.5 6 18"/>';
  static const _arrowRight = '<path d="M5 12h13M13 6l6 6-6 6"/>';

  List<String> _suggestions(AppLocalizations l10n) => [
        l10n.rdAskSuggestionRecent,
        l10n.rdAskSuggestionFollowUp,
        l10n.rdAskSuggestionSummariseWeek,
        l10n.rdAskSuggestionFindByTopic,
      ];

  final _controller = TextEditingController();
  final _focus = FocusNode();
  final List<String> _recent = [];
  bool _thinking = false;
  _Answer? _answer;

  @override
  void initState() {
    super.initState();
    // Let the push transition settle before raising the keyboard.
    Timer(const Duration(milliseconds: 350), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit([String? text]) async {
    final q = (text ?? _controller.text).trim();
    if (q.isEmpty) return;
    _controller.text = q;
    FocusScope.of(context).unfocus();
    setState(() {
      _thinking = true;
      _answer = null;
    });
    try {
      final resp =
          await AppScope.servicesOf(context).assistantRepository.run(q);
      if (!mounted) return;
      setState(() {
        _answer = _Answer(question: q, answer: resp.answer, cites: resp.citations);
        _thinking = false;
        _recent
          ..remove(q)
          ..insert(0, q);
        if (_recent.length > 4) _recent.removeRange(4, _recent.length);
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _answer = _Answer(
          question: q,
          answer: l10n.rdAskErrorConnection,
          cites: const [],
        );
        _thinking = false;
      });
    }
  }

  void _openCite(LibraryItem item) {
    final body = item.summary.isNotEmpty ? item.summary : item.contentText;
    widget.go(
      'memory',
      arg: RdMemoryArg(
        id: item.id,
        title: item.title,
        body: body,
        isVoice: item.type == 'voice',
      ),
    );
  }

  void _reset() {
    setState(() {
      _answer = null;
      _thinking = false;
      _controller.clear();
    });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(rd, l10n),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _field(rd, l10n),
            ),
            Expanded(
              child: _thinking
                  ? _thinkingView(rd, l10n)
                  : _answer != null
                      ? _answerView(rd, l10n, _answer!)
                      : _idleView(rd, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(RdTheme rd, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: RdIcon(RdIcons.chevronLeft,
                  size: 22, strokeWidth: 2, color: rd.ink),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.rdAskTitle,
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(RdTheme rd, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          RdIcon(_spark, size: 19, strokeWidth: 1.7, color: rd.peri),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.vazirmatn(fontSize: 14, color: rd.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: InputBorder.none,
                hintText: l10n.rdAskHint,
                hintStyle:
                    GoogleFonts.vazirmatn(fontSize: 14, color: rd.faint),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _reset,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child:
                    RdIcon(RdIcons.close, size: 16, strokeWidth: 2, color: rd.faint),
              ),
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _submit(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: rd.peri,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: RdIcon(_arrowRight,
                    size: 18, strokeWidth: 2.1, stroke: '#FFFFFF'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── idle: suggestions + recent ─────────────────────────────────────────
  Widget _idleView(RdTheme rd, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        _sectionLabel(rd, l10n.rdAskSectionTry),
        for (final s in _suggestions(l10n)) _suggestTile(rd, s),
        if (_recent.isNotEmpty) ...[
          const SizedBox(height: 18),
          _sectionLabel(rd, l10n.rdAskSectionRecent),
          for (final r in _recent) _recentTile(rd, r),
        ],
      ],
    );
  }

  Widget _sectionLabel(RdTheme rd, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(
        text,
        style: GoogleFonts.vazirmatn(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: rd.muted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _suggestTile(RdTheme rd, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _submit(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rd.line, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.vazirmatn(fontSize: 14, color: rd.ink),
                ),
              ),
              const SizedBox(width: 10),
              RdIcon(RdIcons.chevronLeft,
                  size: 15, strokeWidth: 2, color: rd.faint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentTile(RdTheme rd, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _submit(label),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              RdIcon(RdIcons.clock, size: 15, strokeWidth: 1.8, color: rd.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(fontSize: 13.5, color: rd.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── thinking ───────────────────────────────────────────────────────────
  Widget _thinkingView(RdTheme rd, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RdOrb(size: 46),
          const SizedBox(height: 16),
          Text(
            l10n.rdAskSearching,
            style: GoogleFonts.vazirmatn(fontSize: 13.5, color: rd.muted),
          ),
        ],
      ),
    );
  }

  // ── answer ─────────────────────────────────────────────────────────────
  Widget _answerView(RdTheme rd, AppLocalizations l10n, _Answer a) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          a.question,
          style: GoogleFonts.dosis(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: rd.ink,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: RdOrb(size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a.answer,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14.5,
                  height: 1.55,
                  color: rd.ink,
                ),
              ),
            ),
          ],
        ),
        if (a.cites.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            l10n.rdAskDrawnFrom(a.cites.length),
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: rd.muted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          for (final c in a.cites) _citeCard(rd, l10n, c),
        ],
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _reset,
            child: Text(
              l10n.rdAskSomethingElse,
              style: GoogleFonts.vazirmatn(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: rd.navy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _citeCard(RdTheme rd, AppLocalizations l10n, LibraryItem item) {
    final sub = _citeSub(l10n, item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _openCite(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rd.line, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: rd.periSoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: RdIcon(_typeIcon(item.type),
                      size: 17, strokeWidth: 1.8, color: rd.peri),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isNotEmpty ? item.title : l10n.rdLibraryUntitled,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: rd.ink,
                      ),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                            fontSize: 11.5, color: rd.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RdIcon(RdIcons.chevronLeft,
                  size: 15, strokeWidth: 2, color: rd.faint),
            ],
          ),
        ),
      ),
    );
  }

  String _citeSub(AppLocalizations l10n, LibraryItem item) {
    final kind = switch (item.type) {
      'voice' => l10n.rdLibraryTypeVoice,
      'event' => l10n.rdLibraryTypeEvent,
      'photo' || 'image' => l10n.rdLibraryTypePhoto,
      'link' => l10n.rdLibraryTypeLink,
      _ => l10n.rdLibraryTypeNote,
    };
    return '$kind · ${_relTime(l10n, item.createdAt)}';
  }

  String _relTime(AppLocalizations l10n, DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return l10n.rdLibraryTimeJustNow;
    if (d.inMinutes < 60) return l10n.rdLibraryTimeMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.rdLibraryTimeHoursAgo(d.inHours);
    if (d.inDays == 1) return l10n.rdLibraryTimeYesterday;
    if (d.inDays < 7) return l10n.rdLibraryTimeDaysAgo(d.inDays);
    return l10n.rdLibraryTimeDate(dt.month, dt.day);
  }

  static String _typeIcon(String type) {
    switch (type) {
      case 'voice':
        return RdIcons.micSimple;
      case 'event':
        return RdIcons.calendar;
      case 'photo':
      case 'image':
        return RdIcons.photo;
      case 'link':
        return RdIcons.linkChain;
      default:
        return RdIcons.pencil;
    }
  }
}

class _Answer {
  const _Answer({required this.question, required this.answer, required this.cites});

  final String question;
  final String answer;
  final List<LibraryItem> cites;
}
