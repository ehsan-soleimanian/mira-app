import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/models/api/daily_brief_models.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/api/reminder_models.dart';
import 'package:mira_app/models/api/resurfaced_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Daily Brief — Mira's morning summary. Wired to `dailyBriefRepository`
/// (`/daily-update`): tasks render in "needs you", notes/images in "recent",
/// grouped by day, with the greeting name from the signed-in user. Overdue
/// reminders (`RemindersRepository.list(done: false)`, past their `remindAt`)
/// surface in a "Waiting on you" section with Snooze / Done actions. When there
/// is nothing live — no tasks, no overdue reminders, no recent memories — the
/// screen shows the design's calm empty state. Mira's "resurfaced" cards are
/// wired to `dailyBriefRepository.fetchResurfaced()` (`/v2/resurfaced`): each
/// live item renders its `title` and `reason`. When that feed is empty or the
/// call fails, the designed sample cards stand in so the screen still reads
/// well offline.
class RdDailyBriefScreen extends StatefulWidget {
  const RdDailyBriefScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdDailyBriefScreen> createState() => _RdDailyBriefScreenState();
}

class _RdDailyBriefScreenState extends State<RdDailyBriefScreen> {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _monthsFull = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  List<DailyUpdateItem>? _items;

  /// Rich brief from `GET /daily-brief` when available.
  DailyBriefResponse? _brief;

  /// Task rows parsed from the brief `needs_you` section (id → item map).
  List<Map<String, dynamic>> _briefTasks = const [];

  /// Overdue reminders (past their `remindAt`), newest-overdue first. Null until
  /// the first load resolves; empty once loaded when nothing is overdue.
  List<Reminder>? _overdue;

  /// "Mira resurfaced" items from `/v2/resurfaced`. Null until the first load
  /// resolves or if the call failed; empty once loaded when the feed is empty.
  /// In both the null and empty cases the section falls back to sample cards.
  List<ResurfacedItem>? _resurfaced;

  String _name = 'Sara';
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
      final user = await services.authRepository.fetchMe();
      final first = user.displayName.trim().split(' ').first;
      if (mounted && first.isNotEmpty) setState(() => _name = first);
    } catch (_) {}

    try {
      final brief = await services.dailyBriefRepository.fetchDailyBrief();
      if (mounted) {
        setState(() {
          _brief = brief;
          _briefTasks = brief.section('needs_you')?.items ?? const [];
          final resurfacedSection = brief.section('resurfaced');
          if (resurfacedSection != null && resurfacedSection.items.isNotEmpty) {
            _resurfaced = resurfacedSection.items
                .map(
                  (m) => ResurfacedItem(
                    id: m['id'] as String? ?? '',
                    title: m['title'] as String? ?? 'Memory',
                    reason: m['reason'] as String? ?? 'Recent memory',
                  ),
                )
                .toList();
          }
        });
      }
    } catch (_) {
      try {
        final update = await services.dailyBriefRepository.fetchDailyUpdate();
        if (mounted) setState(() => _items = update.items);
      } catch (_) {}
      try {
        final resurfaced =
            await services.dailyBriefRepository.fetchResurfaced();
        if (mounted) setState(() => _resurfaced = resurfaced);
      } catch (_) {}
    }

    try {
      final reminders = await RemindersRepository(apiClient: services.apiClient)
          .list(done: false);
      final now = DateTime.now();
      final overdue = reminders
          .where((r) => r.remindAt != null && r.remindAt!.isBefore(now))
          .toList()
        ..sort((a, b) => a.remindAt!.compareTo(b.remindAt!));
      if (mounted) setState(() => _overdue = overdue);
    } catch (_) {}
  }

  Future<void> _toggleTask(String id, bool done) async {
    if (!done) return;
    setState(() {
      _briefTasks = _briefTasks.where((t) => t['id'] != id).toList();
      _items = _items?.where((t) => t.id != id).toList();
    });
    try {
      final services = AppScope.servicesOf(context);
      if (_brief != null) {
        await services.dailyBriefRepository.recordAction(
          itemId: id,
          action: 'done',
          itemKind: 'task',
        );
      } else {
        await services.graphRepository.updateTaskStatus(id, 'DONE');
      }
    } catch (_) {}
  }

  /// Snooze an overdue reminder to tomorrow — drop it from the list optimistically
  /// and push the new `remindAt` best-effort.
  Future<void> _snoozeReminder(Reminder reminder) async {
    setState(() =>
        _overdue = (_overdue ?? []).where((r) => r.id != reminder.id).toList());
    _toast('Snoozed until tomorrow');
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient).update(
        reminder.id,
        remindAt: DateTime.now().add(const Duration(days: 1)),
      );
    } catch (_) {
      // The card is already gone locally; a failed sync just means it may
      // reappear on the next load.
    }
  }

  /// Mark an overdue reminder done — drop it from the list optimistically and
  /// push the flag best-effort.
  Future<void> _completeReminder(Reminder reminder) async {
    setState(() =>
        _overdue = (_overdue ?? []).where((r) => r.id != reminder.id).toList());
    _toast('Done');
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient)
          .update(reminder.id, done: true);
    } catch (_) {
      // Optimistic — the card is already gone locally.
    }
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
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
          ),
        ),
      );
  }

  List<Widget> _bodyChildren() {
    if (_items == null && _overdue == null && _brief == null) {
      return _mockChildren();
    }

    final items = _items ?? const <DailyUpdateItem>[];
    final tasks = _briefTasks.isNotEmpty
        ? null
        : items.where(_isTask).toList();
    final recent = items.where((i) => !_isTask(i)).toList();
    final overdue = _overdue ?? const <Reminder>[];

    final hasBriefTasks = _briefTasks.isNotEmpty;
    final hasLegacyTasks = tasks != null && tasks.isNotEmpty;

    if (!hasBriefTasks &&
        !hasLegacyTasks &&
        recent.isEmpty &&
        overdue.isEmpty &&
        (_brief?.state == 'empty')) {
      return [_header(), _EmptyState(onCapture: () => widget.go('capture'))];
    }

    if (!hasBriefTasks && !hasLegacyTasks && recent.isEmpty && overdue.isEmpty) {
      if (_brief?.state == 'empty') {
        return [_header(), _EmptyState(onCapture: () => widget.go('capture'))];
      }
      if (items.isEmpty && _brief == null) {
        return [_header(), _EmptyState(onCapture: () => widget.go('capture'))];
      }
    }

    if (hasBriefTasks) {
      return _briefLiveChildren(overdue: overdue);
    }

    return _liveChildren(
      tasks: tasks ?? const [],
      recent: recent,
      overdue: overdue,
    );
  }

  List<Widget> _briefLiveChildren({required List<Reminder> overdue}) {
    return [
      _header(),
      if (_brief != null && _brief!.summary.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 12),
          child: Text(
            _brief!.summary,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              height: 1.5,
              color: context.rd.muted,
            ),
          ),
        ),
      if (overdue.isNotEmpty) ...[
        _OverdueSummary(),
        _OverdueHeader(count: overdue.length),
        for (final r in overdue)
          _OverdueCard(
            when: _overdueWhen(r.remindAt),
            title: r.title.trim().isEmpty ? 'Reminder' : r.title,
            onSnooze: () => _snoozeReminder(r),
            onDone: () => _completeReminder(r),
          ),
      ],
      if (_briefTasks.isNotEmpty) ...[
        _SectionHeader(
          icon: RdIcons.checkCircle,
          label: 'NEEDS YOU',
          count:
              '${_briefTasks.length} ${_briefTasks.length == 1 ? 'task' : 'tasks'}',
        ),
        for (final t in _briefTasks)
          _TaskCard(
            title: t['title'] as String? ?? 'Task',
            due: _briefTaskDue(t),
            onToggle: (done) => _toggleTask(t['id'] as String? ?? '', done),
          ),
      ],
      ..._resurfacedChildren(),
      _dbEnd(),
    ];
  }

  static String _briefTaskDue(Map<String, dynamic> task) {
    final dueText = task['dueText'] as String?;
    if (dueText != null && dueText.trim().isNotEmpty) return dueText;
    final dueAt = task['dueAt'];
    if (dueAt is String) {
      final dt = DateTime.tryParse(dueAt)?.toLocal();
      if (dt != null) {
        return 'Due ${dt.month}/${dt.day}';
      }
    }
    if (task['overdue'] == true) return 'Overdue';
    return 'Open';
  }

  List<Widget> _liveChildren({
    required List<DailyUpdateItem> tasks,
    required List<DailyUpdateItem> recent,
    required List<Reminder> overdue,
  }) {
    return [
      _header(),
      const _Summary(),
      // "Waiting on you" — overdue reminders, each with Snooze / Done.
      if (overdue.isNotEmpty) ...[
        _OverdueSummary(),
        _OverdueHeader(count: overdue.length),
        for (final r in overdue)
          _OverdueCard(
            when: _overdueWhen(r.remindAt),
            title: r.title.trim().isEmpty ? 'Reminder' : r.title,
            onSnooze: () => _snoozeReminder(r),
            onDone: () => _completeReminder(r),
          ),
      ],
      if (tasks.isNotEmpty) ...[
        _SectionHeader(
          icon: RdIcons.checkCircle,
          label: 'NEEDS YOU',
          count: '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
        ),
        for (final t in tasks)
          _TaskCard(
            title: t.title,
            due: _dueLabel(t),
            onToggle: (done) => _toggleTask(t.id, done),
          ),
      ],
      if (recent.isNotEmpty) ...[
        _SectionHeader(
          icon: RdIcons.resurface,
          label: 'RECENT',
          count: '${recent.length}',
        ),
        for (final o in recent)
          _ResCard(
            icon: _isImage(o) ? RdIcons.vinyl : RdIcons.book,
            image: _isImage(o),
            why: _sectionLabel(o.createdAt),
            title: o.title.trim().isEmpty ? 'Untitled memory' : o.title,
            sub: o.summary.trim().isEmpty ? o.title : o.summary,
          ),
      ],
      // "Mira resurfaced" — live items from `/v2/resurfaced` when available,
      // otherwise the designed SAMPLE content so the section never reads empty.
      ..._resurfacedChildren(),
      _dbEnd(),
    ];
  }

  /// "Mira resurfaced" section. Renders live items from `/v2/resurfaced` when
  /// the feed returned any; otherwise falls back to the designed sample cards
  /// (also used while loading / offline, when `_resurfaced` is still null).
  List<Widget> _resurfacedChildren() {
    final items = _resurfaced ?? const <ResurfacedItem>[];
    if (items.isEmpty) return _resurfacedSample();

    return [
      _SectionHeader(
        icon: RdIcons.resurface,
        label: 'MIRA RESURFACED',
        count: '${items.length}',
      ),
      for (final item in items)
        _ResCard(
          icon: RdIcons.book,
          why: _resurfacedWhy(item.reason),
          title: item.title.trim().isEmpty ? 'A memory' : item.title,
          sub: _resurfacedSub(item),
        ),
    ];
  }

  /// The eyebrow line for a resurfaced card — the backend `reason`, trimmed,
  /// with a gentle fallback when it is blank.
  static String _resurfacedWhy(String reason) {
    final trimmed = reason.trim();
    return trimmed.isEmpty ? 'Brought back for you' : trimmed;
  }

  /// Supporting line for a resurfaced card, composed from the optional `type`
  /// and `date`. Falls back to the reason, then a neutral phrase, so the card
  /// always has a second line to read.
  static String _resurfacedSub(ResurfacedItem item) {
    final type = (item.type ?? '').trim();
    final when = item.date != null ? _sectionLabel(item.date!) : '';
    if (type.isNotEmpty && when.isNotEmpty) return '$type · $when';
    if (type.isNotEmpty) return type;
    if (when.isNotEmpty) return when;
    final reason = item.reason.trim();
    return reason.isEmpty ? 'Saved to your memory' : reason;
  }

  /// Designed SAMPLE resurfaced cards (fallback when the live feed is empty or
  /// unreachable, and during the initial load / offline mock).
  List<Widget> _resurfacedSample() {
    return [
      const _SectionHeader(
          icon: RdIcons.resurface, label: 'MIRA RESURFACED', count: '2'),
      _ResCard(
        icon: RdIcons.vinyl,
        image: true,
        why: 'Because the date is close',
        title: 'Blue Note — Fri, Jul 18',
        sub:
            'From a photo you took. Intimate rooms sell out — worth booking this week?',
        actions: const ['Buy tickets', 'Remind Thursday'],
      ),
      const _ResCard(
        icon: RdIcons.book,
        why: 'Saved 3 days ago, still unread',
        title: '“The Overstory”',
        sub: 'Maya’s recommendation. A quiet weekend read for your coast trip?',
      ),
    ];
  }

  List<Widget> _mockChildren() {
    return [
      _header(),
      const _Summary(),
      const _SectionHeader(icon: RdIcons.clock, label: 'TODAY', count: '2 events'),
      const _Rail(),
      const _SectionHeader(icon: RdIcons.checkCircle, label: 'NEEDS YOU SOON', count: '1 task'),
      const _TaskCard(title: 'Call John to confirm the contract terms', due: 'Due Friday · 2 days'),
      const _SectionHeader(icon: RdIcons.resurface, label: 'MIRA RESURFACED', count: '2'),
      _ResCard(
        icon: RdIcons.vinyl,
        image: true,
        why: 'Because the date is close',
        title: 'Blue Note — Fri, Jul 18',
        sub: 'From a photo you took. Intimate rooms sell out — worth booking this week?',
        actions: const ['Buy tickets', 'Remind Thursday'],
      ),
      const _ResCard(
        icon: RdIcons.book,
        why: 'Saved 3 days ago, still unread',
        title: '“The Overstory”',
        sub: 'Maya’s recommendation. A quiet weekend read for your coast trip?',
      ),
      const _SectionHeader(icon: RdIcons.check, label: 'HANDLED QUIETLY'),
      const _Handled(),
      _dbEnd(),
    ];
  }

  static bool _isTask(DailyUpdateItem item) {
    final t = item.nodeType.trim().toLowerCase();
    return t == 'task' || t == 'reminder';
  }

  static bool _isImage(DailyUpdateItem item) =>
      (item.captureType ?? '').toLowerCase() == 'image';

  String _dueLabel(DailyUpdateItem item) {
    final due = item.dueAt;
    if (due != null) return 'Due ${_sectionLabel(due)}';
    return _relativeTime(item.createdAt);
  }

  static String _sectionLabel(DateTime dt) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days == -1) return 'Tomorrow';
    return '${_months[dt.month - 1]} ${dt.day}';
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  /// "Due yesterday" / "Due N days ago" for an overdue reminder, by calendar day.
  static String _overdueWhen(DateTime? remindAt) {
    if (remindAt == null) return 'Overdue';
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(remindAt.year, remindAt.month, remindAt.day))
        .inDays;
    if (days <= 0) return 'Due earlier today';
    if (days == 1) return 'Due yesterday';
    return 'Due $days days ago';
  }

  static String _greetingForNow() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _dateEyebrow() {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]} · ${_monthsFull[now.month - 1]} ${now.day}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _bodyChildren(),
                ),
              ),
            ),
          ),
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
              child: RdBottomNav(active: 'daily', go: widget.go),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dateEyebrow(),
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
                      'Daily Brief',
                      style: GoogleFonts.dosis(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: rd.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_greetingForNow()}, $_name',
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

  Widget _dbEnd() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 26, 40, 0),
      child: Text(
        'That’s your day.\nEverything else is safe in memory.',
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          color: rd.faint,
          height: 1.5,
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF1FA), Color(0xFFE7EBF7)],
        ),
        border: Border.all(
          color: const Color(0xFF7E8BC9).withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RdOrb(size: 40, ring: false),
          const SizedBox(width: 14),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Two things need you today, and I brought back a memory that’s about to matter — the ',
                  ),
                  TextSpan(
                    text: 'Blue Note tickets',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.w600,
                      color: RdColors.navy,
                    ),
                  ),
                  const TextSpan(text: ' before they sell out.'),
                ],
                style: GoogleFonts.vazirmatn(
                  fontSize: 14.5,
                  height: 1.55,
                  color: const Color(0xFF2B2F45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label, this.count});

  final String icon;
  final String label;
  final String? count;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RdIcon(icon, size: 15, stroke: '#7E8BC9', strokeWidth: 2),
              const SizedBox(width: 9),
              Text(
                label,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: rd.faint,
                ),
              ),
            ],
          ),
          if (count != null)
            Text(
              count!,
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rd.faint,
              ),
            ),
        ],
      ),
    );
  }
}

/// Today's timeline — a periwinkle rail threading time-stamped event cards.
class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 22, 0),
      child: Stack(
        children: [
          Positioned(
            left: 53,
            top: 8,
            bottom: 12,
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
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _TimelineEntry(
                hour: '10',
                suffix: ':00 AM',
                child: _EventCard(
                  title: 'Product review with the team',
                  sub: '30 min · Studio',
                ),
              ),
              _TimelineEntry(
                hour: '3',
                suffix: ':00 PM',
                now: true,
                child: _EventCard(
                  title: 'Meeting with John',
                  sub: 'The contract call',
                  prep: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.hour,
    required this.suffix,
    required this.child,
    this.now = false,
  });

  final String hour;
  final String suffix;
  final Widget child;
  final bool now;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hour,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: rd.muted,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    suffix,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: rd.faint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 18,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Center(child: _RailNode(now: now)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailNode extends StatelessWidget {
  const _RailNode({required this.now});

  final bool now;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    if (now) {
      return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: rd.peri,
          boxShadow: [BoxShadow(color: rd.periSoft, spreadRadius: 4)],
        ),
      );
    }
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rd.peri,
        boxShadow: [BoxShadow(color: rd.periSoft, spreadRadius: 3)],
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rd.card,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.title, required this.sub, this.prep = false});

  final String title;
  final String sub;
  final bool prep;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.vazirmatn(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: rd.ink,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _Pill(
                icon: RdIcons.calendar,
                label: 'Event',
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  sub,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    color: rd.muted,
                  ),
                ),
              ),
            ],
          ),
          if (prep) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                // Fixed light periwinkle tint so the navy prep copy stays
                // legible in dark mode (ambient periSoft flips to dark slate).
                color: const Color(0xFFEDEFF8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RdIcon(
                    RdIcons.bulb,
                    size: 15,
                    stroke: '#14328C',
                    strokeWidth: 1.8,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Mira: bring the '),
                          TextSpan(
                            text: 'signed contract',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: ' — it connects to this meeting.',
                          ),
                        ],
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12.5,
                          color: RdColors.navy,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        // Fixed light periwinkle tint-badge — navy icon + label read on it in
        // both themes (ambient periSoft flips to dark slate).
        color: const Color(0xFFEDEFF8),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          RdIcon(icon, size: 11, stroke: '#14328C', strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: RdColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  const _TaskCard({required this.title, required this.due, this.onToggle});

  final String title;
  final String due;
  final ValueChanged<bool>? onToggle;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _done = !_done);
              widget.onToggle?.call(_done);
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _done ? rd.navy : rd.card,
                borderRadius: BorderRadius.circular(8),
                border: _done
                    ? null
                    : Border.all(color: rd.peri, width: 1.8),
              ),
              child: _done
                  ? const Center(
                      child: RdIcon(
                        RdIcons.checkThick,
                        size: 14,
                        stroke: '#FFFFFF',
                        strokeWidth: 3,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: _done ? rd.faint : rd.ink,
                    decoration:
                        _done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 7),
                _DuePill(text: widget.due),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuePill extends StatelessWidget {
  const _DuePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEEE8),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RdIcon(
            RdIcons.dueClock,
            size: 11,
            stroke: '#B65A2E',
            strokeWidth: 2,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB65A2E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResCard extends StatelessWidget {
  const _ResCard({
    required this.icon,
    required this.why,
    required this.title,
    required this.sub,
    this.image = false,
    this.actions,
  });

  final String icon;
  final String why;
  final String title;
  final String sub;
  final bool image;
  final List<String>? actions;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResIcon(icon: icon, image: image),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  why,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rd.peri,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    color: rd.muted,
                    height: 1.4,
                  ),
                ),
                if (actions != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ResButton(label: actions![0], solid: true),
                      const SizedBox(width: 8),
                      if (actions!.length > 1)
                        _ResButton(label: actions![1], solid: false),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResIcon extends StatelessWidget {
  const _ResIcon({required this.icon, required this.image});

  final String icon;
  final bool image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        // Fixed light periwinkle tile so the navy glyph reads in both themes
        // (ambient periSoft flips to dark slate); image variant keeps its navy
        // gradient.
        color: image ? null : const Color(0xFFEDEFF8),
        gradient: image
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2B6B), Color(0xFF0F1C4D)],
              )
            : null,
      ),
      child: Center(
        child: RdIcon(
          icon,
          size: 22,
          stroke: image ? '#FFFFFF' : '#14328C',
          strokeWidth: 1.7,
        ),
      ),
    );
  }
}

class _ResButton extends StatelessWidget {
  const _ResButton({required this.label, required this.solid});

  final String label;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: solid ? rd.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: solid ? null : Border.all(color: rd.line, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: solid ? Colors.white : rd.muted,
        ),
      ),
    );
  }
}

class _Handled extends StatelessWidget {
  const _Handled();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        children: [
          _HandledRow(
            icon: RdIcons.calendar,
            boldText: 'Flight SA 482',
            rest: ' added to your calendar for Aug 2',
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: rd.line, width: 1)),
            ),
            child: _HandledRow(
              icon: RdIcons.dueClock,
              rest: 'Check-in reminder set for ',
              boldTextTrailing: 'Aug 1',
            ),
          ),
        ],
      ),
    );
  }
}

class _HandledRow extends StatelessWidget {
  const _HandledRow({
    required this.icon,
    this.boldText,
    this.rest = '',
    this.boldTextTrailing,
  });

  final String icon;
  final String? boldText;
  final String rest;
  final String? boldTextTrailing;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final baseStyle = GoogleFonts.vazirmatn(
      fontSize: 12.5,
      height: 1.4,
      color: rd.muted,
    );
    final boldStyle = GoogleFonts.vazirmatn(
      fontSize: 12.5,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: rd.ink,
    );
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F3EC),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: RdIcon(
              icon,
              size: 16,
              stroke: '#2E7D4F',
              strokeWidth: 1.9,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (boldText != null) TextSpan(text: boldText, style: boldStyle),
                TextSpan(text: rest),
                if (boldTextTrailing != null)
                  TextSpan(text: boldTextTrailing, style: boldStyle),
              ],
              style: baseStyle,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Overdue reminders ("Waiting on you") ───────────────────────────────────
// Amber-toned section, faithful to `.ov-*` in the design.

const _ovAmber = Color(0xFFC58E3F);
const _ovAmberDeep = Color(0xFFB8853A);

/// Warm "a few things slipped past" reassurance, shown above the overdue list.
class _OverdueSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBF1E4), Color(0xFFFAEBD8)],
        ),
        border: Border.all(
          color: const Color(0xFFC58E3F).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.28, -0.4),
                radius: 0.9,
                colors: [Color(0xFFE9B770), Color(0xFFC58E3F)],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'A few things slipped past while you were busy. Nothing’s lost — '
              'I held onto them. Let’s clear them together, no rush.',
              style: GoogleFonts.vazirmatn(
                fontSize: 14.5,
                height: 1.55,
                color: const Color(0xFF6A4F24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverdueHeader extends StatelessWidget {
  const _OverdueHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const RdIcon(
                RdIcons.dueClock,
                size: 15,
                stroke: '#B8853A',
                strokeWidth: 2,
              ),
              const SizedBox(width: 9),
              Text(
                'WAITING ON YOU',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: _ovAmberDeep,
                ),
              ),
            ],
          ),
          Text(
            '$count ${count == 1 ? 'reminder' : 'reminders'}',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.rd.faint,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  const _OverdueCard({
    required this.when,
    required this.title,
    required this.onSnooze,
    required this.onDone,
  });

  final String when;
  final String title;
  final VoidCallback onSnooze;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar.
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFD79B45),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 15, 16, 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: RdIcon(
                          RdIcons.dueClock,
                          size: 20,
                          stroke: '#B8853A',
                          strokeWidth: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            when,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _ovAmber,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: rd.ink,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _OverdueButton(
                                label: 'Snooze',
                                solid: false,
                                onTap: onSnooze,
                              ),
                              const SizedBox(width: 8),
                              _OverdueButton(
                                label: 'Done',
                                solid: true,
                                onTap: onDone,
                              ),
                            ],
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
    );
  }
}

class _OverdueButton extends StatelessWidget {
  const _OverdueButton({
    required this.label,
    required this.solid,
    required this.onTap,
  });

  final String label;
  final bool solid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: solid ? rd.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: solid ? null : Border.all(color: rd.line, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: solid ? Colors.white : rd.muted,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
// Calm "nothing needs you today", faithful to `.empty-*` in the design.

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCapture});

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const RdOrb(size: 92, ring: true),
              const SizedBox(height: 20),
              Text(
                'Nothing needs you today',
                textAlign: TextAlign.center,
                style: GoogleFonts.dosis(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'Your day is open and no memory is waiting on you. I’ll keep '
                  'everything safe and speak up the moment something matters.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    height: 1.6,
                    color: rd.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _EmptyStat(
                  icon: RdIcons.check,
                  num: '34',
                  label: 'memories held safe',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _EmptyStat(
                  icon: RdIcons.dueClock,
                  num: '0',
                  label: 'reminders due',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _EmptyCapture(onTap: onCapture),
        ],
      ),
    );
  }
}

class _EmptyStat extends StatelessWidget {
  const _EmptyStat({required this.icon, required this.num, required this.label});

  final String icon;
  final String num;
  final String label;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              // Fixed light periwinkle tile so the navy glyph reads in dark
              // mode (ambient periSoft flips to dark slate).
              color: const Color(0xFFEDEFF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: RdIcon(icon, size: 18, stroke: '#14328C', strokeWidth: 1.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            num,
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: rd.ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              height: 1.3,
              color: rd.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCapture extends StatelessWidget {
  const _EmptyCapture({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEF1FA), Color(0xFFE7EBF7)],
          ),
          border: Border.all(
            color: const Color(0xFF7E8BC9).withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.24, -0.4),
                  radius: 0.9,
                  colors: [Color(0xFF3A5AD0), Color(0xFF14328C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(20, 50, 140, 0.5),
                    blurRadius: 18,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: RdIcon(RdIcons.mic,
                    size: 18, stroke: '#FFFFFF', strokeWidth: 1.8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capture a thought',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: RdColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Drop anything on your mind — I’ll hold it for you.',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12.5,
                      color: RdColors.muted,
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
}
