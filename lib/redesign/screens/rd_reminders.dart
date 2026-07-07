import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/models/api/reminder_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// Reminders — a pushed screen listing everything the user asked Mira to hold
/// onto. Reminders load from `RemindersRepository` (`/reminders`); the full set
/// is split into **Upcoming** (open) and **Done**. Each open reminder can be
/// completed, snoozed a day, or deleted — all optimistic with a best-effort
/// backend sync, so it stays responsive offline. Styled to match the redesign
/// (rounded cards, Dosis/Vazirmatn) and dark-aware from the start via
/// `context.rd`.
class RdRemindersScreen extends StatefulWidget {
  const RdRemindersScreen({
    super.key,
    required this.go,
    required this.onBack,
    this.backLabel = 'Home',
  });

  final RdGo go;
  final VoidCallback onBack;

  /// Label shown next to the back chevron — "Home" or "Account" depending on
  /// where the user came from.
  final String backLabel;

  @override
  State<RdRemindersScreen> createState() => _RdRemindersScreenState();
}

class _RdRemindersScreenState extends State<RdRemindersScreen> {
  /// Live reminders from the backend; null until the first load. Falls back to
  /// the sample set when the backend is unreachable.
  List<Reminder>? _items;
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
    try {
      final services = AppScope.servicesOf(context);
      final items =
          await RemindersRepository(apiClient: services.apiClient).list();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      // Backend unreachable — keep the sample reminders.
    }
  }

  /// The reminders to render — live set once loaded, sample set until then.
  List<Reminder> get _source => _items ?? _sample;

  List<Reminder> get _open =>
      _source.where((r) => !r.done).toList()..sort(_byRemindAt);

  List<Reminder> get _done =>
      _source.where((r) => r.done).toList()..sort(_byRemindAt);

  /// Sort by soonest `remindAt` first; reminders without a time sink to the
  /// bottom (they have no schedule to order by).
  static int _byRemindAt(Reminder a, Reminder b) {
    final at = a.remindAt;
    final bt = b.remindAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return at.compareTo(bt);
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

  /// Mark a reminder done — flip it optimistically (it moves to the Done group)
  /// and push the flag best-effort.
  Future<void> _markDone(Reminder r) async {
    setState(() => _replace(r, done: true));
    _toast('Marked done');
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient)
          .update(r.id, done: true);
    } catch (_) {
      // Optimistic — the card already moved locally.
    }
  }

  /// Snooze a reminder to tomorrow — bump its `remindAt` optimistically and push
  /// the new time best-effort.
  Future<void> _snooze(Reminder r) async {
    final next = DateTime.now().add(const Duration(days: 1));
    setState(() => _replace(r, remindAt: next));
    _toast('Snoozed until tomorrow');
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient)
          .update(r.id, remindAt: next);
    } catch (_) {
      // Optimistic — the card already updated locally.
    }
  }

  /// Delete a reminder — drop it optimistically and push the delete best-effort.
  Future<void> _delete(Reminder r) async {
    setState(() => _items = _source.where((x) => x.id != r.id).toList());
    _toast('Reminder deleted');
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient).delete(r.id);
    } catch (_) {
      // Optimistic — the card is already gone locally.
    }
  }

  /// Replace a reminder in the working set with a copy carrying the given
  /// changes (used for optimistic done / snooze updates).
  void _replace(Reminder r, {bool? done, DateTime? remindAt}) {
    _items = _source
        .map((x) => x.id == r.id
            ? Reminder(
                id: x.id,
                title: x.title,
                done: done ?? x.done,
                remindAt: remindAt ?? x.remindAt,
                sourceNodeId: x.sourceNodeId,
                createdAt: x.createdAt,
                updatedAt: DateTime.now(),
              )
            : x)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final open = _open;
    final done = _done;
    final empty = open.isEmpty && done.isEmpty;

    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _back(),
              _heading(open.length),
              if (empty)
                _emptyState()
              else ...[
                if (open.isNotEmpty) ...[
                  _sectionLabel('Upcoming'),
                  for (final r in open)
                    _ReminderCard(
                      reminder: r,
                      onDone: () => _markDone(r),
                      onSnooze: () => _snooze(r),
                      onDelete: () => _delete(r),
                    ),
                ],
                if (done.isNotEmpty) ...[
                  _sectionLabel('Done'),
                  for (final r in done)
                    _ReminderCard(
                      reminder: r,
                      onDelete: () => _delete(r),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _back() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 20, 0),
      child: GestureDetector(
        onTap: widget.onBack,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RdIcon(RdIcons.chevronLeft, size: 20, color: rd.navy, strokeWidth: 2),
              const SizedBox(width: 3),
              Text(
                widget.backLabel,
                style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.navy),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(int openCount) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders',
            style: GoogleFonts.dosis(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            openCount == 0
                ? 'Nothing waiting on you'
                : openCount == 1
                    ? '1 thing Mira is holding for you'
                    : '$openCount things Mira is holding for you',
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              height: 1.5,
              color: rd.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 10),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.vazirmatn(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: rd.faint,
        ),
      ),
    );
  }

  Widget _emptyState() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rd.periSoft,
              ),
              child: Center(
                child: RdIcon(
                  RdIcons.dueClock,
                  size: 28,
                  color: rd.peri,
                  strokeWidth: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No reminders yet',
              style: GoogleFonts.dosis(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: rd.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask Mira to remind you about something,\nand it will settle in here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 13.5,
                color: rd.faint,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample reminders — shown until the real list loads, or if it can't. Times
  // are anchored to "now" so the relative labels stay sensible.
  static List<Reminder> get _sample {
    final now = DateTime.now();
    Reminder make(
      String id,
      String title,
      bool done, {
      Duration? offset,
    }) =>
        Reminder(
          id: id,
          title: title,
          done: done,
          remindAt: offset == null ? null : now.add(offset),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        );

    return [
      make('s0', 'Call John to confirm the contract terms', false,
          offset: const Duration(hours: 3)),
      make('s1', 'Book the coast trip before prices rise', false,
          offset: const Duration(days: 2)),
      make('s2', 'Reply to Maya about the book recommendation', false),
      make('s3', 'Renew the parking permit', true,
          offset: const Duration(days: -1)),
    ];
  }
}

/// A single reminder card — title, a relative time from `remindAt` when present,
/// and inline actions. Open reminders show Done + Snooze + Delete; done ones are
/// struck through with just a Delete. Matches the library tile aesthetic.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    this.onDone,
    this.onSnooze,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback? onDone;
  final VoidCallback? onSnooze;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final done = reminder.done;
    final when = _relativeTime(reminder.remindAt);
    final overdue = !done &&
        reminder.remindAt != null &&
        reminder.remindAt!.isBefore(DateTime.now());
    // Overdue chips read in the danger tone; otherwise the calm periwinkle.
    final chipColor = overdue ? _danger : rd.peri;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Done toggle for open reminders; a filled check for done ones.
          GestureDetector(
            onTap: onDone,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? rd.success : Colors.transparent,
                border:
                    done ? null : Border.all(color: rd.faint, width: 1.8),
              ),
              child: done
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
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title.trim().isEmpty
                      ? 'Untitled reminder'
                      : reminder.title.trim(),
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: done ? rd.faint : rd.ink,
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: rd.faint,
                  ),
                ),
                if (when != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RdIcon(RdIcons.clock,
                          size: 13, color: chipColor, strokeWidth: 2),
                      const SizedBox(width: 5),
                      Text(
                        when,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: chipColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!done && (onSnooze != null || onDone != null)) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (onDone != null)
                        _CardAction(
                          icon: RdIcons.check,
                          label: 'Done',
                          onTap: onDone!,
                        ),
                      if (onSnooze != null) ...[
                        const SizedBox(width: 8),
                        _CardAction(
                          icon: RdIcons.resurface,
                          label: 'Snooze',
                          onTap: onSnooze!,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Trailing delete — available on every card.
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: RdIcon(RdIcons.trash,
                  size: 18, color: rd.faint, strokeWidth: 1.8),
            ),
          ),
        ],
      ),
    );
  }

  /// A human relative label for a reminder time: "Overdue", "In 3h", "Tomorrow",
  /// "In 2d", etc. Null when the reminder has no `remindAt`.
  static String? _relativeTime(DateTime? at) {
    if (at == null) return null;
    final now = DateTime.now();
    final diff = at.difference(now);
    if (diff.isNegative) {
      final ago = now.difference(at);
      if (ago.inMinutes < 60) return 'Overdue';
      if (ago.inHours < 24) return 'Overdue by ${ago.inHours}h';
      if (ago.inDays == 1) return 'Overdue since yesterday';
      return 'Overdue by ${ago.inDays}d';
    }
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'In ${diff.inHours}h';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays}d';
    return '${at.month}/${at.day}';
  }
}

/// A small pill action inside a reminder card (Done / Snooze).
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: rd.periSoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(icon, size: 14, color: rd.navy, strokeWidth: 2),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: rd.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Danger red for the overdue chip — fixed across themes (never a text tone).
const _danger = Color(0xFFC0392B);
