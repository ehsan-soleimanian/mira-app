import 'package:flutter/material.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/daily_update_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_typography.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Home — the redesigned "second memory" surface: a calm hero orb, a single
/// capture field, and a timeline of recently captured memories. Faithful to
/// `.rd-home`. Wired to the backend: the greeting name comes from the signed-in
/// user and "recently captured" from the daily-update feed, both with a sample
/// fallback so the screen still reads well before a backend is reachable.
class RdHomeScreen extends StatefulWidget {
  const RdHomeScreen({super.key, required this.go, this.live = true});

  final RdGo go;

  /// When false, renders sample data without touching the network — used by the
  /// wizard's Home tour, which shows Home behind coach-marks.
  final bool live;

  @override
  State<RdHomeScreen> createState() => _RdHomeScreenState();
}

class _RdHomeScreenState extends State<RdHomeScreen> {
  final String _greeting = _greetingForNow();
  String _name = 'Sara';
  List<RdRecent> _recents = _sampleRecents;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.live && !_loaded) {
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
    } catch (_) {
      // Not signed in / backend unreachable — keep the sample name.
    }
    try {
      final update = await services.dailyBriefRepository.fetchDailyUpdate();
      final items = update.items.take(6).map(_toRecent).toList();
      if (mounted && items.isNotEmpty) setState(() => _recents = items);
    } catch (_) {
      // Keep the sample recents.
    }
  }

  static String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RdColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 20),
            _hero(),
            const SizedBox(height: 22),
            _captureField(),
            const SizedBox(height: 24),
            Expanded(child: _recentsSection()),
            RdBottomNav(active: 'home', go: widget.go),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: RdText.eyebrow),
              const SizedBox(height: 2),
              Text(_name, style: RdText.name),
            ],
          ),
          const Spacer(),
          _CircleButton(
            size: 42,
            onTap: () => widget.go('account'),
            child: const RdIcon(
              RdIcons.gear,
              size: 19,
              stroke: '#6B6C73',
              strokeWidth: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: [
        const RdOrb(size: 74),
        const SizedBox(height: 18),
        Text(
          'Your memory is\nquiet and ready',
          textAlign: TextAlign.center,
          style: RdText.title,
        ),
      ],
    );
  }

  Widget _captureField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: GestureDetector(
        onTap: () => widget.go('capture'),
        child: Container(
          height: 62,
          padding: const EdgeInsets.only(left: 20, right: 8),
          decoration: BoxDecoration(
            color: RdColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RdColors.line, width: 1),
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
              const RdIcon(
                RdIcons.pencil,
                size: 20,
                stroke: '#B7B8BE',
                strokeWidth: 1.7,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Type or say anything…', style: RdText.placeholder),
              ),
              _MicButton(size: 46, onTap: () => widget.go('capture')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentsSection() {
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: RdColors.peri,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('RECENTLY CAPTURED', style: RdText.sectionLabel),
                ],
              ),
              GestureDetector(
                onTap: () => widget.go('daily'),
                child: Text('See all', style: RdText.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 5.5,
                  top: 22,
                  bottom: 22,
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
                        stops: [0.0, 0.3, 0.7, 1.0],
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
    final isNote = item.kind == RdRecentKind.note;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: RdColors.line, width: 1)),
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
                    style: RdText.itemTitle,
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
    return Row(
      children: [
        RdIcon(
          isNote ? RdIcons.pencil : RdIcons.micSimple,
          size: 12,
          stroke: '#7E8BC9',
          strokeWidth: 2,
        ),
        const SizedBox(width: 6),
        Text(isNote ? 'Note' : 'Voice', style: RdText.meta),
        const _MetaSep(),
        Text(time, style: RdText.meta),
        if (links > 0) ...[
          const _MetaSep(),
          const RdIcon(RdIcons.link, size: 12, stroke: '#7E8BC9', strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            '$links links',
            style: RdText.meta.copyWith(
              color: RdColors.peri,
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: RdColors.faint,
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: RdColors.peri,
        boxShadow: [
          BoxShadow(color: RdColors.periSoft, spreadRadius: 3),
        ],
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: RdColors.card,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: RdColors.card,
          border: Border.all(color: RdColors.line, width: 1),
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
