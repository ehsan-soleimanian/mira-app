import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/models/api/reminder_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_voice_capture_sheet.dart';

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
  /// Live reminders from the backend; null until the first load. Renders an
  /// empty state when the list is empty or the backend is unreachable.
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
      // Backend unreachable — leave _items null so the empty state renders.
    }
  }

  /// The reminders to render — live set once loaded, empty until then.
  List<Reminder> get _source => _items ?? const <Reminder>[];

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

  DateTime get _startOfTomorrow {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  // Open reminders partitioned for display. Overdue = past-due; Today = due
  // before midnight; Upcoming = later; Waiting = no time (person/"right
  // moment" reminders, which also surface in Home's waiting section).
  List<Reminder> get _overdue => _open
      .where((r) => r.remindAt != null && r.remindAt!.isBefore(DateTime.now()))
      .toList();

  List<Reminder> get _today {
    final now = DateTime.now();
    final end = _startOfTomorrow;
    return _open
        .where((r) =>
            r.remindAt != null &&
            !r.remindAt!.isBefore(now) &&
            r.remindAt!.isBefore(end))
        .toList();
  }

  List<Reminder> get _upcoming {
    final end = _startOfTomorrow;
    return _open
        .where((r) => r.remindAt != null && !r.remindAt!.isBefore(end))
        .toList();
  }

  List<Reminder> get _waiting => _open.where((r) => r.remindAt == null).toList();

  /// Builds a titled group of open reminders (empty groups render nothing).
  List<Widget> _openSection(String label, List<Reminder> items) {
    if (items.isEmpty) return const [];
    return [
      _sectionLabel(label),
      for (final r in items)
        _ReminderCard(
          reminder: r,
          onDone: () => _markDone(r),
          onSnooze: () => _snooze(r),
          onDelete: () => _delete(r),
          onOpenSource: r.sourceNodeId == null ? null : () => _openSource(r),
        ),
    ];
  }

  /// Opens the memory a reminder was created from.
  void _openSource(Reminder r) {
    final id = r.sourceNodeId;
    if (id == null) return;
    widget.go('memory', arg: RdMemoryArg(id: id, title: r.title));
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

  void _toastUndo(String message, VoidCallback onUndo) {
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
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: onUndo,
          ),
        ),
      );
  }

  /// Best-effort push of a done flag after an optimistic flip.
  Future<void> _pushDone(Reminder r, bool done) async {
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient)
          .update(r.id, done: done);
    } catch (_) {}
  }

  /// Mark a reminder done — optimistic, with Undo.
  Future<void> _markDone(Reminder r) async {
    setState(() => _replace(r, done: true));
    _pushDone(r, true).ignore();
    _toastUndo('Marked done', () {
      setState(() => _replace(r, done: false));
      _pushDone(r, false).ignore();
    });
  }

  /// Bring a completed reminder back onto the list (tap its check).
  void _uncomplete(Reminder r) {
    setState(() => _replace(r, done: false));
    _pushDone(r, false).ignore();
    _toast('Back on your list');
  }

  /// Snooze a reminder to tomorrow — optimistic, with Undo restoring the time.
  Future<void> _snooze(Reminder r) async {
    final prev = r.remindAt;
    final next = DateTime.now().add(const Duration(days: 1));
    setState(() => _replace(r, remindAt: next));
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient)
          .update(r.id, remindAt: next);
    } catch (_) {}
    _toastUndo('Snoozed until tomorrow', () {
      if (prev == null) return;
      setState(() => _replace(r, remindAt: prev));
      final services = AppScope.servicesOf(context);
      RemindersRepository(apiClient: services.apiClient)
          .update(r.id, remindAt: prev)
          .ignore();
    });
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

  /// Opens the compose sheet; on "Set reminder" it creates the reminder.
  Future<void> _openCompose() async {
    final result = await showModalBottomSheet<(String, DateTime?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ComposeSheet(),
    );
    if (result == null || !mounted) return;
    await _create(result.$1, result.$2);
  }

  /// Creates a reminder optimistically (prepended), then reconciles with the
  /// row the backend returns.
  Future<void> _create(String title, DateTime? remindAt) async {
    final now = DateTime.now();
    final temp = Reminder(
      id: 'tmp-${now.microsecondsSinceEpoch}',
      title: title,
      done: false,
      remindAt: remindAt,
      createdAt: now,
      updatedAt: now,
    );
    setState(() => _items = [temp, ..._source]);
    _toast('Reminder set');
    try {
      final services = AppScope.servicesOf(context);
      final created = await RemindersRepository(apiClient: services.apiClient)
          .create(title: title, remindAt: remindAt);
      if (mounted) {
        setState(() => _items =
            _source.map((x) => x.id == temp.id ? created : x).toList());
      }
    } catch (_) {
      // Keep the optimistic row — the reminder still reads locally.
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
                ..._openSection('Overdue', _overdue),
                ..._openSection('Today', _today),
                ..._openSection('Upcoming', _upcoming),
                ..._openSection('When the moment’s right', _waiting),
                if (done.isNotEmpty) ...[
                  _sectionLabel('Done'),
                  for (final r in done)
                    _ReminderCard(
                      reminder: r,
                      onDelete: () => _delete(r),
                      onUncomplete: () => _uncomplete(r),
                      onOpenSource:
                          r.sourceNodeId == null ? null : () => _openSource(r),
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
      padding: const EdgeInsets.fromLTRB(26, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          ),
          // Add a reminder — opens the compose sheet.
          GestureDetector(
            onTap: _openCompose,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: rd.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: RdIcon('<path d="M12 5v14M5 12h14"/>',
                    size: 22, stroke: '#FFFFFF', strokeWidth: 2.1),
              ),
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
    this.onUncomplete,
    this.onOpenSource,
  });

  final Reminder reminder;
  final VoidCallback? onDone;
  final VoidCallback? onSnooze;
  final VoidCallback onDelete;

  /// Tapping a done reminder's check brings it back onto the list.
  final VoidCallback? onUncomplete;

  /// Opens the memory this reminder was created from (a source chip appears).
  final VoidCallback? onOpenSource;

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
          // Leading Done toggle for open reminders; tap a done reminder's
          // filled check to bring it back onto the list.
          GestureDetector(
            onTap: done ? onUncomplete : onDone,
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
                if (onOpenSource != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onOpenSource,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RdIcon(RdIcons.link,
                            size: 12, color: rd.muted, strokeWidth: 2),
                        const SizedBox(width: 5),
                        Text('From a memory',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: rd.muted)),
                        const SizedBox(width: 3),
                        RdIcon('<path d="M9 6l6 6-6 6"/>',
                            size: 11, color: rd.faint, strokeWidth: 2),
                      ],
                    ),
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

/// When a new reminder should fire. `someday` maps to a null `remindAt`
/// (a "when the moment's right" reminder, mirrored in Home's waiting section).
enum _When { laterToday, thisEvening, tomorrow, nextWeek, someday, custom }

/// Compose sheet for creating a reminder — a title plus a "when" choice, wired
/// by the caller to `RemindersRepository.create`. Pops `(title, remindAt?)` on
/// "Set reminder", or null on dismiss.
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet();

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _title = TextEditingController();
  _When _when = _When.laterToday;
  DateTime? _custom;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// Dictate the reminder title by voice — records, transcribes, fills the field.
  Future<void> _dictate() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RdVoiceCaptureSheet(
        captureRepository: AppScope.servicesOf(context).captureRepository,
        busyLabel: 'Transcribing…',
      ),
    );
    if (text != null && text.trim().isNotEmpty && mounted) {
      setState(() => _title.text = text.trim());
    }
  }

  DateTime? _resolve() {
    final now = DateTime.now();
    switch (_when) {
      case _When.laterToday:
        return now.add(const Duration(hours: 3));
      case _When.thisEvening:
        final eve = DateTime(now.year, now.month, now.day, 18);
        return eve.isAfter(now) ? eve : eve.add(const Duration(days: 1));
      case _When.tomorrow:
        return DateTime(now.year, now.month, now.day + 1, 9);
      case _When.nextWeek:
        return DateTime(now.year, now.month, now.day + 7, 9);
      case _When.someday:
        return null;
      case _When.custom:
        return _custom;
    }
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;
    final t = time ?? const TimeOfDay(hour: 9, minute: 0);
    setState(() {
      _custom = DateTime(date.year, date.month, date.day, t.hour, t.minute);
      _when = _When.custom;
    });
  }

  String _customLabel() {
    final c = _custom;
    if (c == null) return 'Pick date & time';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(c.month)}/${two(c.day)} · ${two(c.hour)}:${two(c.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final canSet = _title.text.trim().isNotEmpty;
    final mq = MediaQuery.of(context);
    final navGap = (mq.viewPadding.bottom - mq.viewInsets.bottom).clamp(0.0, 64.0);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: EdgeInsets.fromLTRB(22, 12, 22, 22 + navGap),
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
                    color: rd.line, borderRadius: BorderRadius.circular(100)),
              ),
            ),
            Text('New reminder',
                style: GoogleFonts.dosis(
                    fontSize: 20, fontWeight: FontWeight.w700, color: rd.ink)),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
              decoration: InputDecoration(
                hintText: 'Remind me to…',
                hintStyle: GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
                filled: true,
                fillColor: rd.bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: rd.line, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: rd.navy, width: 1.4)),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 46, minHeight: 46),
                suffixIcon: GestureDetector(
                  onTap: _dictate,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    widthFactor: 1,
                    child: RdIcon(
                        '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>',
                        size: 18,
                        color: rd.peri,
                        strokeWidth: 1.9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('WHEN',
                style: GoogleFonts.vazirmatn(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: rd.faint)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Later today', _when == _When.laterToday,
                    () => setState(() => _when = _When.laterToday)),
                _chip('This evening', _when == _When.thisEvening,
                    () => setState(() => _when = _When.thisEvening)),
                _chip('Tomorrow', _when == _When.tomorrow,
                    () => setState(() => _when = _When.tomorrow)),
                _chip('Next week', _when == _When.nextWeek,
                    () => setState(() => _when = _When.nextWeek)),
                _chip('When the moment’s right', _when == _When.someday,
                    () => setState(() => _when = _When.someday)),
                _chip(_customLabel(), _when == _When.custom, _pickCustom),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: canSet
                  ? () =>
                      Navigator.of(context).pop((_title.text.trim(), _resolve()))
                  : null,
              child: Opacity(
                opacity: canSet ? 1 : 0.45,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: rd.navy, borderRadius: BorderRadius.circular(14)),
                  child: Text('Set reminder',
                      style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? rd.navy : rd.bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? rd.navy : rd.line, width: 1),
        ),
        child: Text(label,
            style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : rd.ink)),
      ),
    );
  }
}
