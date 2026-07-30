import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/calendar_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

class RdCalendarScreen extends StatefulWidget {
  const RdCalendarScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdCalendarScreen> createState() => _RdCalendarScreenState();
}

class _RdCalendarScreenState extends State<RdCalendarScreen> {
  List<CalendarOccurrence> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    try {
      final rows = await AppScope.servicesOf(context).calendarRepository.agenda(
        from: start,
        to: start.add(const Duration(days: 30)),
      );
      if (mounted) {
        setState(() {
          _items = rows;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context)!.rdCalendarLoadFailed;
        });
      }
    }
  }

  Future<void> _create() async {
    final saveFailed = AppLocalizations.of(context)!.rdCalendarSaveFailed;
    final draft = await showModalBottomSheet<_EventDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EventComposeSheet(),
    );
    if (draft == null || !mounted) return;
    try {
      await AppScope.servicesOf(context).calendarRepository.create(
        title: draft.title,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        allDay: draft.allDay,
        location: draft.location,
        recurrenceRule: draft.recurrenceRule,
        idempotencyKey:
            'flutter-${DateTime.now().microsecondsSinceEpoch}-${draft.title.hashCode}',
      );
      await _load();
    } catch (_) {
      _toast(saveFailed);
    }
  }

  Future<void> _setStatus(CalendarEvent event, String status) async {
    final saveFailed = AppLocalizations.of(context)!.rdCalendarSaveFailed;
    try {
      await AppScope.servicesOf(context).calendarRepository.update(
        event.id,
        status: status,
        statusReason: 'Updated from calendar',
      );
      await _load();
    } catch (_) {
      _toast(saveFailed);
    }
  }

  Future<void> _delete(CalendarEvent event) async {
    final deleteFailed = AppLocalizations.of(context)!.rdCalendarDeleteFailed;
    try {
      await AppScope.servicesOf(context).calendarRepository.delete(event.id);
      if (mounted) {
        setState(
          () => _items = _items
              .where((item) => item.event.id != event.id)
              .toList(),
        );
      }
    } catch (_) {
      _toast(deleteFailed);
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
            style: GoogleFonts.vazirmatn(color: Colors.white),
          ),
        ),
      );
  }

  Map<DateTime, List<CalendarOccurrence>> get _groups {
    final groups = <DateTime, List<CalendarOccurrence>>{};
    for (final item in _items) {
      final date = DateTime(
        item.startsAt.year,
        item.startsAt.month,
        item.startsAt.day,
      );
      groups.putIfAbsent(date, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 20, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: widget.onBack,
                    icon: RdIcon(RdIcons.chevronLeft, size: 20, color: rd.navy),
                    label: Text(
                      l10n.rdCommonAccount,
                      style: GoogleFonts.vazirmatn(color: rd.navy),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 10, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rdCalendarTitle,
                            style: GoogleFonts.dosis(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: rd.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.rdCalendarSubtitle,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 14,
                              color: rd.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _create,
                      style: IconButton.styleFrom(
                        backgroundColor: rd.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(color: rd.peri),
                  ),
                )
              else if (_error != null)
                _EmptyCalendar(title: _error!, body: l10n.rdCalendarPullToRetry)
              else if (_items.isEmpty)
                _EmptyCalendar(
                  title: l10n.rdCalendarEmptyTitle,
                  body: l10n.rdCalendarEmptyBody,
                )
              else
                for (final entry in _groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 14, 26, 6),
                    child: Text(
                      _dayLabel(context, entry.key),
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: rd.faint,
                      ),
                    ),
                  ),
                  for (final item in entry.value)
                    _EventCard(
                      occurrence: item,
                      onComplete: () => _setStatus(item.event, 'COMPLETED'),
                      onCancel: () => _setStatus(item.event, 'CANCELLED'),
                      onDelete: () => _delete(item.event),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date == today) return l10n.rdCalendarToday;
    if (date == today.add(const Duration(days: 1))) {
      return l10n.rdCalendarTomorrow;
    }
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.occurrence,
    required this.onComplete,
    required this.onCancel,
    required this.onDelete,
  });

  final CalendarOccurrence occurrence;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final event = occurrence.event;
    final time = event.allDay
        ? l10n.rdCalendarAllDay
        : MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(occurrence.startsAt));
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 54,
            decoration: BoxDecoration(
              color: rd.peri,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    time,
                    if (event.location?.isNotEmpty == true) event.location!,
                    if (event.recurrenceRule != null) l10n.rdCalendarRepeats,
                  ].join(' · '),
                  style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: rd.card,
            onSelected: (value) {
              if (value == 'complete') onComplete();
              if (value == 'cancel') onCancel();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'complete',
                child: Text(l10n.rdCalendarComplete),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Text(l10n.rdCalendarCancel),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.rdCalendarDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCalendar extends StatelessWidget {
  const _EmptyCalendar({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 64, 40, 0),
      child: Column(
        children: [
          RdIcon(RdIcons.dueClock, size: 34, color: rd.peri),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(color: rd.muted),
          ),
        ],
      ),
    );
  }
}

class _EventDraft {
  const _EventDraft({
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.allDay,
    required this.location,
    required this.recurrenceRule,
  });

  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool allDay;
  final String? location;
  final String? recurrenceRule;
}

class _EventComposeSheet extends StatefulWidget {
  const _EventComposeSheet();

  @override
  State<_EventComposeSheet> createState() => _EventComposeSheetState();
}

class _EventComposeSheetState extends State<_EventComposeSheet> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 1));
  bool _allDay = false;
  String? _recurrence;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    var selectedTime = TimeOfDay.fromDateTime(_startsAt);
    if (!_allDay) {
      final time = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (!mounted) return;
      selectedTime = time ?? selectedTime;
    }
    setState(
      () => _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        _allDay ? 0 : selectedTime.hour,
        _allDay ? 0 : selectedTime.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rd = context.rd;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final formatted =
        '${MaterialLocalizations.of(context).formatMediumDate(_startsAt)} · '
        '${_allDay ? l10n.rdCalendarAllDay : MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_startsAt))}';
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rdCalendarNewEvent,
              style: GoogleFonts.dosis(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: rd.ink,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.rdCalendarTitleHint),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _location,
              decoration: InputDecoration(
                hintText: l10n.rdCalendarLocationHint,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _allDay,
              title: Text(l10n.rdCalendarAllDay),
              onChanged: (value) => setState(() => _allDay = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(formatted),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _pickStart,
            ),
            DropdownButtonFormField<String?>(
              initialValue: _recurrence,
              decoration: InputDecoration(labelText: l10n.rdCalendarRepeat),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.rdCalendarNever),
                ),
                DropdownMenuItem(
                  value: 'FREQ=DAILY',
                  child: Text(l10n.rdCalendarDaily),
                ),
                DropdownMenuItem(
                  value: 'FREQ=WEEKLY',
                  child: Text(l10n.rdCalendarWeekly),
                ),
                DropdownMenuItem(
                  value: 'FREQ=MONTHLY',
                  child: Text(l10n.rdCalendarMonthly),
                ),
              ],
              onChanged: (value) => setState(() => _recurrence = value),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _title.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      _EventDraft(
                        title: _title.text.trim(),
                        startsAt: _startsAt,
                        endsAt: _allDay
                            ? _startsAt.add(const Duration(days: 1))
                            : _startsAt.add(const Duration(hours: 1)),
                        allDay: _allDay,
                        location: _location.text.trim().isEmpty
                            ? null
                            : _location.text.trim(),
                        recurrenceRule: _recurrence,
                      ),
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: rd.navy,
              ),
              child: Text(l10n.rdCalendarSave),
            ),
          ],
        ),
      ),
    );
  }
}
