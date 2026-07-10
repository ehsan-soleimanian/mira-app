import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/api/reminder_models.dart';

import '../theme/rd_theme.dart';
import '../theme/rd_typography.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Home — calm hero orb, capture field, person-context reminders ("waiting for
/// the right moment"), and recently captured memories. Faithful to design2
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
    try {
      final user = await services.authRepository.fetchMe();
      final first = user.displayName.trim().split(' ').first;
      if (mounted && first.isNotEmpty) setState(() => _name = first);
    } catch (_) {}

    try {
      final update = await services.dailyBriefRepository.fetchDailyUpdate();
      final items = update.items.take(6).map(_toRecent).toList();
      if (mounted) setState(() => _recents = items);
    } catch (_) {}

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

  static RdRecent _toRecent(DailyUpdateItem item) {
    final isVoice = (item.captureType ?? '').toLowerCase() == 'voice';
    final title = item.title.trim().isEmpty ? item.summary : item.title;
    return RdRecent(
      title: title,
      kind: isVoice ? RdRecentKind.voice : RdRecentKind.note,
      time: _relativeTime(item.createdAt),
    );
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.month}/${dt.day}';
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
      return 'Later today';
    }
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays > 1 && diff.inDays < 7) return 'In ${diff.inDays} days';
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
      await RemindersRepository(apiClient: services.apiClient)
          .update(r.id, remindAt: next);
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
      RemindersRepository(apiClient: services.apiClient)
          .update(s.id, remindAt: s.previousRemindAt);
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
            const SizedBox(height: 20),
            _hero(l10n),
            const SizedBox(height: 22),
            _captureField(l10n),
            if (_visibleWaiting.isNotEmpty) ...[
              const SizedBox(height: 20),
              _waitingSection(l10n),
            ],
            const SizedBox(height: 24),
            Expanded(child: _recentsSection(l10n)),
            RdBottomNav(active: 'home', go: widget.go),
          ],
        ),
      ),
    );
  }

  Widget _header(String greeting) {
    final rd = context.rd;
    final hasWaiting = _waiting.any((r) => !r.done);
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
            onTap: () => widget.go('ask'),
            child: RdIcon(
              RdIcons.search,
              size: 18,
              color: rd.gearIcon,
              strokeWidth: 1.8,
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _CircleButton(
                size: 42,
                onTap: () => widget.go('reminders'),
                child: RdIcon(
                  RdIcons.bell,
                  size: 18,
                  color: rd.gearIcon,
                  strokeWidth: 1.8,
                ),
              ),
              if (hasWaiting)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rd.peri,
                      border: Border.all(color: rd.card, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
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
    return Column(
      children: [
        const RdOrb(size: 74),
        const SizedBox(height: 18),
        Text(
          l10n.rdHomeMemoryReady,
          textAlign: TextAlign.center,
          style: RdText.title.copyWith(color: context.rd.ink),
        ),
      ],
    );
  }

  Widget _captureField(AppLocalizations l10n) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: GestureDetector(
        onTap: () => widget.go('capture'),
        child: Container(
          height: 62,
          padding: const EdgeInsets.only(left: 20, right: 8),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: rd.line, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(30, 34, 70, 0.30),
                blurRadius: 22,
                spreadRadius: -14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              RdIcon(
                RdIcons.pencil,
                size: 20,
                color: rd.faint,
                strokeWidth: 1.7,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.rdHomeComposerHint,
                  style: RdText.placeholder.copyWith(color: rd.faint),
                ),
              ),
              _MicButton(size: 46, onTap: () => widget.go('capture')),
            ],
          ),
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
        label: snoozed.label,
        undoLabel: l10n.rdSnoozeUndo,
        onUndo: _undoSnooze,
      );
    }
    if (_pickingId == r.id) {
      return _SnoozePicker(
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
                onTap: () => widget.go('daily'),
                child: Text(
                  l10n.rdSeeAll,
                  style: RdText.seeAll.copyWith(color: rd.peri),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_recents.isEmpty)
            Expanded(child: _recentsEmpty())
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
                        colors: [
                          rd.periSoft,
                          rd.peri,
                          rd.peri,
                          rd.periSoft,
                        ],
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
                        title: _recents[i].title,
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

  Widget _recentsEmpty() {
    final rd = context.rd;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Text(
          'Your recent memories will appear here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.vazirmatn(
              fontSize: 13.5, height: 1.5, color: rd.faint),
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
    required this.options,
    required this.onCancel,
    required this.onPick,
  });

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
                'Remind again…',
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
    required this.label,
    required this.undoLabel,
    required this.onUndo,
  });

  final String label;
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
              'Snoozed · $label',
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
    required this.title,
    required this.kind,
    required this.time,
    this.links = 0,
  });

  final String title;
  final RdRecentKind kind;
  final String time;
  final int links;
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.item,
    required this.isLast,
    this.onTap,
  });

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
  const _MetaRow({required this.isNote, required this.time, required this.links});

  final bool isNote;
  final String time;
  final int links;

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
        Text(isNote ? 'Note' : 'Voice', style: RdText.meta.copyWith(color: rd.faint)),
        const _MetaSep(),
        Text(time, style: RdText.meta.copyWith(color: rd.faint)),
        if (links > 0) ...[
          const _MetaSep(),
          RdIcon(RdIcons.link, size: 12, color: rd.peri, strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            '$links links',
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
        boxShadow: [
          BoxShadow(color: rd.periSoft, spreadRadius: 3),
        ],
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rd.card,
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

class _MicButton extends StatelessWidget {
  const _MicButton({required this.size, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.24, -0.4),
            radius: 0.9,
            colors: [Color(0xFF3A5AD0), Color(0xFF14328C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(20, 50, 140, 0.55),
              blurRadius: 18,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: RdIcon(RdIcons.mic, size: 20, stroke: '#FFFFFF', strokeWidth: 1.8),
        ),
      ),
    );
  }
}
