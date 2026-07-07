import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/daily_update_models.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Daily Brief — Mira's morning summary. Wired to `dailyBriefRepository`
/// (`/daily-update`): tasks render in "needs you", notes/images in "recent",
/// grouped by day, with the greeting name from the signed-in user. Falls back
/// to the designed mock (timeline / resurfaced / handled) when the backend is
/// unreachable, so the screen still reads well offline.
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
      final update = await services.dailyBriefRepository.fetchDailyUpdate();
      if (mounted) setState(() => _items = update.items);
    } catch (_) {}
  }

  Future<void> _toggleTask(String id, bool done) async {
    try {
      final services = AppScope.servicesOf(context);
      await services.graphRepository.updateTaskStatus(id, done ? 'DONE' : 'OPEN');
    } catch (_) {
      // Best-effort — the checkbox already reflects the change locally.
    }
  }

  List<Widget> _bodyChildren() {
    final items = _items;
    if (items != null && items.isNotEmpty) return _liveChildren(items);
    return _mockChildren();
  }

  List<Widget> _liveChildren(List<DailyUpdateItem> items) {
    final tasks = items.where(_isTask).toList();
    final others = items.where((i) => !_isTask(i)).toList();
    return [
      _header(),
      const _Summary(),
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
      if (others.isNotEmpty) ...[
        _SectionHeader(
          icon: RdIcons.resurface,
          label: 'RECENT',
          count: '${others.length}',
        ),
        for (final o in others)
          _ResCard(
            icon: _isImage(o) ? RdIcons.vinyl : RdIcons.book,
            image: _isImage(o),
            why: _sectionLabel(o.createdAt),
            title: o.title.trim().isEmpty ? 'Untitled memory' : o.title,
            sub: o.summary.trim().isEmpty ? o.title : o.summary,
          ),
      ],
      _dbEnd(),
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
    return Scaffold(
      backgroundColor: RdColors.bg,
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00F4F4F1), RdColors.bg],
                  stops: [0.0, 0.55],
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
                      'Daily Brief',
                      style: GoogleFonts.dosis(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: RdColors.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_greetingForNow()}, $_name',
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

  Widget _dbEnd() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 26, 40, 0),
      child: Text(
        'That’s your day.\nEverything else is safe in memory.',
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          color: RdColors.faint,
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
                  color: RdColors.faint,
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
                color: RdColors.faint,
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    RdColors.periSoft,
                    RdColors.peri,
                    RdColors.peri,
                    RdColors.periSoft,
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
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
                      color: RdColors.muted,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    suffix,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: RdColors.faint,
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
    if (now) {
      return Container(
        width: 11,
        height: 11,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RdColors.peri,
          boxShadow: [BoxShadow(color: RdColors.periSoft, spreadRadius: 4)],
        ),
      );
    }
    return Container(
      width: 11,
      height: 11,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: RdColors.peri,
        boxShadow: [BoxShadow(color: RdColors.periSoft, spreadRadius: 3)],
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: RdColors.card,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: RdColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RdColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.vazirmatn(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: RdColors.ink,
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
                    color: RdColors.muted,
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
                color: RdColors.periSoft,
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
        color: RdColors.periSoft,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: RdColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RdColors.line, width: 1),
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
                color: _done ? RdColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: _done
                    ? null
                    : Border.all(color: RdColors.peri, width: 1.8),
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
                    color: _done ? RdColors.faint : RdColors.ink,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RdColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RdColors.line, width: 1),
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
                    color: RdColors.peri,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: RdColors.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    color: RdColors.muted,
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
        color: image ? null : RdColors.periSoft,
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
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: solid ? RdColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: solid ? null : Border.all(color: RdColors.line, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: solid ? Colors.white : RdColors.muted,
        ),
      ),
    );
  }
}

class _Handled extends StatelessWidget {
  const _Handled();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(26, 8, 22, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RdColors.line, width: 1),
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
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: RdColors.line, width: 1)),
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
    final baseStyle = GoogleFonts.vazirmatn(
      fontSize: 12.5,
      height: 1.4,
      color: RdColors.muted,
    );
    final boldStyle = GoogleFonts.vazirmatn(
      fontSize: 12.5,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: RdColors.ink,
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
