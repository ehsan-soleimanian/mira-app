import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/api/reminder_models.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import '../theme/rd_typography.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Home — calm hero orb, person-context reminders ("waiting for the right
/// moment"), and recently captured memories. Faithful to design2
/// `.rd-home`. Wired to `/auth/me`, `/daily-update`, and `/reminders`.
class RdHomeScreen extends StatefulWidget {
  const RdHomeScreen({super.key, required this.go, this.live = true});

  final RdGo go;

  /// When false, renders sample data without touching the network — used by the
  /// wizard's Home tour, which shows Home behind coach-marks.
  final bool live;

  @override
  State<RdHomeScreen> createState() => _RdHomeScreenState();
}

class _SnoozeOption {
  const _SnoozeOption(this.key, this.label, this.chip);

  final String key;
  final String label;
  final String chip;
  DateTime resolve(DateTime now) {
    switch (key) {
      case '1h':
        return now.add(const Duration(hours: 1));
      case 'eve':
        final evening = DateTime(now.year, now.month, now.day, 19);
        return evening.isAfter(now)
            ? evening
            : evening.add(const Duration(days: 1));
      case 'tom':
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
        return tomorrow;
      case 'wk':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(hours: 1));
    }
  }
}

class _RdHomeScreenState extends State<RdHomeScreen> {
  List<_SnoozeOption> _snoozeOptions(AppLocalizations l10n) => [
    _SnoozeOption('1h', l10n.rdSnoozeInHour, l10n.rdSnoozeInHour),
    _SnoozeOption('eve', l10n.rdSnoozeEvening, l10n.rdSnoozeEvening),
    _SnoozeOption('tom', l10n.rdSnoozeTomorrow, l10n.rdSnoozeTomorrow),
    _SnoozeOption('wk', l10n.rdSnoozeNextWeek, l10n.rdSnoozeNextWeek),
  ];

  String _name = '';
  List<RdRecent> _recents = const [];
  List<Reminder> _waiting = const [];
  bool _useSampleWaiting = false;
  String? _pickingId;
  ({String id, String label, DateTime? previousRemindAt})? _snoozed;
  Timer? _snoozeHideTimer;
  bool _loaded = false;

  @override
  void dispose() {
    _snoozeHideTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (widget.live) {
      _load();
    } else {
      // Tour / preview mode (setup wizard): show the illustrative sample
      // home behind the coach-marks; the live app never uses these.
      _name = 'Sara';
      _recents = _sampleRecents;
      _waiting = _sampleWaiting;
    }
  }

  Future<void> _load() async {
    final services = AppScope.servicesOf(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await services.authRepository.fetchMe();
      final first = user.displayName.trim().split(' ').first;
      if (mounted && first.isNotEmpty) setState(() => _name = first);
    } catch (_) {}

    try {
      // Library is the canonical source for captured memories. Daily Update is
      // task-oriented and can legitimately be empty even when the user has
      // many captures, which previously made Home look blank.
      await services.memoryStore.load();
      final items = services.memoryStore
          .getAll()
          .take(6)
          .map((i) => _toLibraryRecent(i, l10n))
          .toList();
      if (mounted && items.isNotEmpty) setState(() => _recents = items);
    } catch (_) {}

    // Compatibility fallback for accounts whose captures have not yet been
    // projected into Library.
    if (_recents.isEmpty) {
      try {
        final update = await services.dailyBriefRepository.fetchDailyUpdate();
        final items = update.items
            .take(6)
            .map((i) => _toRecent(i, l10n))
            .toList();
        if (mounted) setState(() => _recents = items);
      } catch (_) {}
    }

    try {
      final repo = RemindersRepository(apiClient: services.apiClient);
      final all = await repo.list(done: false);
      final waiting = _pickWaiting(all);
      if (mounted) {
        setState(() {
          _waiting = waiting;
          _useSampleWaiting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _waiting = const [];
          _useSampleWaiting = false;
        });
      }
    }
  }

  /// Person-context reminders: open items without a fixed schedule first, then
  /// other upcoming open reminders — capped at three for the home strip.
  static List<Reminder> _pickWaiting(List<Reminder> open) {
    final withoutTime = open.where((r) => r.remindAt == null).toList();
    final withTime = open.where((r) => r.remindAt != null).toList()
      ..sort((a, b) => a.remindAt!.compareTo(b.remindAt!));
    return [...withoutTime, ...withTime].take(3).toList();
  }

  static String _greetingForNow(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.rdGreetingMorning;
    if (hour < 17) return l10n.rdGreetingAfternoon;
    return l10n.rdGreetingEvening;
  }

  static int _linkCount(DailyUpdateItem item) {
    final blob = '${item.title} ${item.summary}';
    final urls = RegExp(r'https?://\S+').allMatches(blob).length;
    if (urls > 0) return urls;
    final type = (item.captureType ?? item.nodeType).toLowerCase();
    if (type.contains('link')) return 1;
    return 0;
  }

  static RdRecent _toRecent(DailyUpdateItem item, AppLocalizations l10n) {
    final isVoice = (item.captureType ?? '').toLowerCase() == 'voice';
    final title = item.title.trim().isEmpty ? item.summary : item.title;
    return RdRecent(
      id: item.id,
      title: title,
      body: item.summary,
      kind: isVoice ? RdRecentKind.voice : RdRecentKind.note,
      time: _relativeTime(item.createdAt, l10n),
      links: _linkCount(item),
    );
  }

  static RdRecent _toLibraryRecent(LibraryItem item, AppLocalizations l10n) {
    final type = item.type.toLowerCase();
    final isVoice = type == 'voice' || type == 'audio' || type == 'meeting';
    final title = item.title.trim().isEmpty
        ? item.summary.trim()
        : item.title.trim();
    final content = item.contentText?.trim() ?? '';
    return RdRecent(
      id: item.id,
      title: title,
      body: content.isNotEmpty ? content : item.summary,
      kind: isVoice ? RdRecentKind.voice : RdRecentKind.note,
      time: _relativeTime(item.createdAt, l10n),
      links: item.sourceUrl == null ? 0 : 1,
    );
  }

  static String _relativeTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.rdLibraryTimeJustNow;
    if (diff.inMinutes < 60) {
      return l10n.rdLibraryTimeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) return l10n.rdLibraryTimeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.rdLibraryTimeYesterday;
    if (diff.inDays < 7) return l10n.rdLibraryTimeDaysAgo(diff.inDays);
    return l10n.rdLibraryTimeDate(dt.month, dt.day);
  }

  String _whenLabel(Reminder r, AppLocalizations l10n) {
    if (r.remindAt == null) {
      final person = _personFromTitle(r.title);
      if (person != null) return l10n.rdWhenNextSee(person);
      return l10n.rdWhenMomentRight;
    }
    final at = r.remindAt!.toLocal();
    final diff = at.difference(DateTime.now());
    if (diff.inHours < 24 && diff.inHours >= 0) {
      return l10n.rdHomeLaterToday;
    }
    if (diff.inDays == 1) return l10n.rdBriefTomorrow;
    if (diff.inDays > 1 && diff.inDays < 7) {
      return l10n.rdHomeInDays(diff.inDays);
    }
    return '${at.month}/${at.day}';
  }

  static String? _personFromTitle(String title) {
    final match = RegExp(
      r'\b(?:see|with|ask|call|text|meet)\s+([A-Z][a-z]+)',
    ).firstMatch(title);
    return match?.group(1);
  }

  static String _personInitial(Reminder r) {
    final person = _personFromTitle(r.title);
    if (person != null && person.isNotEmpty) return person[0].toUpperCase();
    final words = r.title.trim().split(RegExp(r'\s+'));
    for (final w in words) {
      if (w.isNotEmpty && RegExp(r'^[A-Z]').hasMatch(w)) {
        return w[0].toUpperCase();
      }
    }
    return '?';
  }

  static Color _personTint(Reminder r) {
    const tints = [
      Color(0xFF7E8BC9),
      Color(0xFFC1876F),
      Color(0xFF5E9B9B),
      Color(0xFFC27E88),
      Color(0xFF9A7BB0),
    ];
    return tints[r.id.hashCode.abs() % tints.length];
  }

  Future<void> _applySnooze(Reminder r, _SnoozeOption opt) async {
    final previous = r.remindAt;
    final next = opt.resolve(DateTime.now());
    setState(() {
      _pickingId = null;
      _snoozed = (id: r.id, label: opt.label, previousRemindAt: previous);
    });
    _snoozeHideTimer?.cancel();
    _snoozeHideTimer = Timer(const Duration(milliseconds: 4200), () {
      if (!mounted) return;
      setState(() {
        _waiting = _waiting.where((x) => x.id != r.id).toList();
        _snoozed = null;
      });
    });
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(
        apiClient: services.apiClient,
      ).update(r.id, remindAt: next);
    } catch (_) {}
  }

  void _undoSnooze() {
    final s = _snoozed;
    if (s == null) return;
    _snoozeHideTimer?.cancel();
    setState(() => _snoozed = null);
    if (_useSampleWaiting) return;
    try {
      final services = AppScope.servicesOf(context);
      RemindersRepository(
        apiClient: services.apiClient,
      ).update(s.id, remindAt: s.previousRemindAt);
    } catch (_) {}
  }

  List<Reminder> get _visibleWaiting {
    if (_snoozed == null) return _waiting;
    return _waiting;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = _greetingForNow(l10n);
    return Scaffold(
      backgroundColor: context.rd.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(greeting),
            const SizedBox(height: 12),
            _hero(l10n),
            const SizedBox(height: 10),
            _captureCard(l10n),
            const SizedBox(height: 12),
            _memoryViews(l10n),
            if (_visibleWaiting.isNotEmpty) ...[
              const SizedBox(height: 18),
              _waitingSection(l10n),
            ],
            const SizedBox(height: 16),
            Expanded(child: _recentsSection(l10n)),
            RdBottomNav(active: 'home', go: widget.go),
          ],
        ),
      ),
    );
  }

  Widget _header(String greeting) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: RdText.eyebrow.copyWith(color: rd.muted)),
              const SizedBox(height: 2),
              Text(_name, style: RdText.name.copyWith(color: rd.ink)),
            ],
          ),
          const Spacer(),
          _CircleButton(
            size: 42,
            onTap: () => widget.go('account'),
            child: RdIcon(
              RdIcons.gear,
              size: 19,
              color: rd.gearIcon,
              strokeWidth: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(AppLocalizations l10n) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Semantics(
        button: true,
        label: l10n.rdHomeTwinLabel,
        child: GestureDetector(
          onTap: () => widget.go('myMira'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: rd.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 24,
                  spreadRadius: -15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const RdOrb(size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rdHomeTwinLabel,
                        style: RdText.eyebrow.copyWith(color: rd.peri),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.rdHomeMemoryReady.replaceFirst('\n', ' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RdText.title.copyWith(
                          color: rd.ink,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.rdHomeTwinBody,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11.5,
                          color: rd.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RdIcon(
                  RdIcons.chevronLeft,
                  size: 17,
                  color: rd.faint,
                  strokeWidth: 1.9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _captureCard(AppLocalizations l10n) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 13, 10, 13),
        decoration: BoxDecoration(
          color: rd.periSoft.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rd.peri.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.go('capture'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rdHomeCaptureTitle,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: rd.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.rdHomeCaptureBody,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11.5,
                        color: rd.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _HomeCaptureAction(
              icon: RdIcons.plusCircle,
              label: l10n.rdHomeCaptureAttach,
              onTap: () => widget.go('attachments'),
            ),
            const SizedBox(width: 7),
            _HomeCaptureAction(
              icon: RdIcons.micSimple,
              label: l10n.rdHomeCaptureSpeak,
              filled: true,
              onTap: () => widget.go(
                'captureflow',
                arg: const RdCaptureModeArg(
                  RdCaptureMode.voice,
                  returnScreen: 'home',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memoryViews(AppLocalizations l10n) {
    final rd = context.rd;
    final reduceMotion = AppScope.themeOf(context).reduceMotion;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rdHomeExploreMemory,
            style: RdText.sectionLabel.copyWith(color: rd.faint),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _HomeMemoryShortcut(
                  key: const ValueKey('rd-home-my-mira'),
                  icon: RdIcons.user,
                  label: l10n.rdMyMiraShortTitle,
                  reduceMotion: reduceMotion,
                  onTap: () => widget.go('myMira'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HomeMemoryShortcut(
                  key: const ValueKey('rd-home-brief'),
                  icon: RdIcons.navBrief,
                  label: l10n.rdBriefTitle,
                  reduceMotion: reduceMotion,
                  onTap: () => widget.go('daily'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HomeMemoryShortcut(
                  key: const ValueKey('rd-home-map'),
                  icon: RdIcons.navCanvas,
                  label: l10n.rdCanvasMap,
                  reduceMotion: reduceMotion,
                  onTap: () =>
                      widget.go('canvas', arg: const RdCanvasArg('map')),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (reduceMotion) return content;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: content,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
    );
  }

  Widget _waitingSection(AppLocalizations l10n) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC1876F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rdWaitingSectionTitle,
                    style: RdText.sectionLabel.copyWith(color: rd.faint),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.go('reminders'),
                child: Text(
                  l10n.rdRemindersLink,
                  style: RdText.seeAll.copyWith(color: rd.peri),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final r in _visibleWaiting.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildWaitingCard(r, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(Reminder r, AppLocalizations l10n) {
    final snoozed = _snoozed;
    if (snoozed != null && snoozed.id == r.id) {
      return _SnoozedStrip(
        message: l10n.rdHomeSnoozed(snoozed.label),
        undoLabel: l10n.rdSnoozeUndo,
        onUndo: _undoSnooze,
      );
    }
    if (_pickingId == r.id) {
      return _SnoozePicker(
        title: l10n.rdHomeRemindAgain,
        options: _snoozeOptions(l10n),
        onCancel: () => setState(() => _pickingId = null),
        onPick: (opt) => _applySnooze(r, opt),
      );
    }
    return _WaitingItem(
      reminder: r,
      tint: _personTint(r),
      initial: _personInitial(r),
      when: _whenLabel(r, l10n),
      onOpen: () => widget.go('reminders'),
      onSnooze: () => setState(() => _pickingId = r.id),
    );
  }

  Widget _recentsSection(AppLocalizations l10n) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rd.peri,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rdRecentlyCaptured,
                    style: RdText.sectionLabel.copyWith(color: rd.faint),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.go('library'),
                child: Text(
                  l10n.rdSeeAll,
                  style: RdText.seeAll.copyWith(color: rd.peri),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_recents.isEmpty)
            Expanded(child: _recentsEmpty(l10n))
          else
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: 5.5,
                    top: 22,
                    bottom: 22,
                    child: Container(
                      width: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [rd.periSoft, rd.peri, rd.peri, rd.periSoft],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _recents.length,
                    itemBuilder: (context, i) => _RecentTile(
                      item: _recents[i],
                      isLast: i == _recents.length - 1,
                      onTap: () => widget.go(
                        'memory',
                        arg: RdMemoryArg(
                          id: _recents[i].id,
                          title: _recents[i].title,
                          body: _recents[i].body,
                          isVoice: _recents[i].kind == RdRecentKind.voice,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _recentsEmpty(AppLocalizations l10n) {
    final rd = context.rd;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () => widget.go('capture'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: rd.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: rd.periSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: RdIcon(
                      RdIcons.plusCircle,
                      size: 19,
                      color: rd.peri,
                      strokeWidth: 1.9,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.rdHomeRecentsEmpty,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12.5,
                      height: 1.45,
                      color: rd.muted,
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

  static final List<Reminder> _sampleWaiting = () {
    final now = DateTime.now();
    return [
      Reminder(
        id: 'rp1',
        title: 'Ask how Lisbon went — and about the Overstory ending',
        done: false,
        remindAt: null,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }();

  static const List<RdRecent> _sampleRecents = [
    RdRecent(
      title: 'Contract with John — needs a call to confirm terms',
      kind: RdRecentKind.note,
      time: '2h ago',
      links: 3,
    ),
    RdRecent(
      title: 'Book Maya recommended — “The Overstory”',
      kind: RdRecentKind.voice,
      time: 'Yesterday',
    ),
    RdRecent(
      title: 'Idea — a quiet weekend on the coast in spring',
      kind: RdRecentKind.note,
      time: '2 days ago',
    ),
  ];
}

class _WaitingItem extends StatelessWidget {
  const _WaitingItem({
    required this.reminder,
    required this.tint,
    required this.initial,
    required this.when,
    required this.onOpen,
    required this.onSnooze,
  });

  final Reminder reminder;
  final Color tint;
  final String initial;
  final String when;
  final VoidCallback onOpen;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: tint,
                        child: Text(
                          initial,
                          style: GoogleFonts.dosis(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: RdText.itemTitle.copyWith(
                                color: rd.ink,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              when,
                              style: RdText.meta.copyWith(color: rd.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSnooze,
            icon: RdIcon(
              RdIcons.moon,
              size: 17,
              color: rd.muted,
              strokeWidth: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnoozePicker extends StatelessWidget {
  const _SnoozePicker({
    required this.title,
    required this.options,
    required this.onCancel,
    required this.onPick,
  });

  final String title;
  final List<_SnoozeOption> options;
  final VoidCallback onCancel;
  final void Function(_SnoozeOption opt) onPick;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.peri.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCancel,
                child: RdIcon(RdIcons.close, size: 15, color: rd.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (o) => ActionChip(
                    label: Text(o.label),
                    onPressed: () => onPick(o),
                    backgroundColor: rd.periSoft,
                    labelStyle: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rd.navy,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SnoozedStrip extends StatelessWidget {
  const _SnoozedStrip({
    required this.message,
    required this.undoLabel,
    required this.onUndo,
  });

  final String message;
  final String undoLabel;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rd.periSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          RdIcon(RdIcons.moon, size: 16, color: rd.navy, strokeWidth: 1.9),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: rd.navy,
              ),
            ),
          ),
          GestureDetector(
            onTap: onUndo,
            child: Text(
              undoLabel,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: rd.peri,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RdRecentKind { note, voice }

class RdRecent {
  const RdRecent({
    this.id,
    required this.title,
    this.body,
    required this.kind,
    required this.time,
    this.links = 0,
  });

  final String? id;
  final String title;
  final String? body;
  final RdRecentKind kind;
  final String time;
  final int links;
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.item, required this.isLast, this.onTap});

  final RdRecent item;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final isNote = item.kind == RdRecentKind.note;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: rd.line, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: _TimelineNode(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: RdText.itemTitle.copyWith(color: rd.ink),
                  ),
                  const SizedBox(height: 5),
                  _MetaRow(
                    isNote: isNote,
                    time: item.time,
                    links: item.links,
                    l10n: AppLocalizations.of(context)!,
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.isNote,
    required this.time,
    required this.links,
    required this.l10n,
  });

  final bool isNote;
  final String time;
  final int links;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Row(
      children: [
        RdIcon(
          isNote ? RdIcons.pencil : RdIcons.micSimple,
          size: 12,
          color: rd.peri,
          strokeWidth: 2,
        ),
        const SizedBox(width: 6),
        Text(
          isNote ? l10n.rdHomeKindNote : l10n.rdHomeKindVoice,
          style: RdText.meta.copyWith(color: rd.faint),
        ),
        const _MetaSep(),
        Text(time, style: RdText.meta.copyWith(color: rd.faint)),
        if (links > 0) ...[
          const _MetaSep(),
          RdIcon(RdIcons.link, size: 12, color: rd.peri, strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            l10n.rdHomeLinksCount(links),
            style: RdText.meta.copyWith(
              color: rd.peri,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaSep extends StatelessWidget {
  const _MetaSep();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.rd.faint,
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rd.peri,
        boxShadow: [BoxShadow(color: rd.periSoft, spreadRadius: 3)],
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: rd.card),
        ),
      ),
    );
  }
}

class _HomeMemoryShortcut extends StatefulWidget {
  const _HomeMemoryShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.reduceMotion,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_HomeMemoryShortcut> createState() => _HomeMemoryShortcutState();
}

class _HomeMemoryShortcutState extends State<_HomeMemoryShortcut> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.reduceMotion || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.965 : 1,
          duration: widget.reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: rd.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 16,
                  spreadRadius: -10,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: rd.periSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: RdIcon(
                      widget.icon,
                      size: 17,
                      color: rd.peri,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCaptureAction extends StatelessWidget {
  const _HomeCaptureAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: filled ? rd.navy : rd.card,
            borderRadius: BorderRadius.circular(13),
            border: filled ? null : Border.all(color: rd.line),
          ),
          child: Center(
            child: RdIcon(
              icon,
              size: 18,
              color: filled ? Colors.white : rd.peri,
              strokeWidth: 1.9,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.size, required this.child, this.onTap});

  final double size;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: rd.card,
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}
