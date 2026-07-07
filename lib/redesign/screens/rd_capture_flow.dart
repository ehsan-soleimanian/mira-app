import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Capture flow — the voice path: listen (live transcript with entities) →
/// understanding → review & confirm → kept. Faithful to the voice branch of
/// `capture.jsx` (`.rd-captureflow`). The photo / screenshot / link entry
/// modes are deferred; this is the primary capture experience.
class RdCaptureFlow extends StatefulWidget {
  const RdCaptureFlow({super.key, required this.go});

  final RdGo go;

  @override
  State<RdCaptureFlow> createState() => _RdCaptureFlowState();
}

const _ink = Color(0xFF1B1C24);
const _navy = Color(0xFF14328C);
const _peri = Color(0xFF7E8BC9);
const _periSoft = Color(0xFFEDEFF8);
const _muted = Color(0xFF8A8B92);
const _faint = Color(0xFFB7B8BE);
const _line = Color(0xFFE9E9E4);
const _card = Color(0xFFFBFBF9);

class _Tok {
  const _Tok(this.text, {this.mark = false, this.chip});
  final String text;
  final bool mark;
  final String? chip;
}

const _tokens = [
  _Tok('Call'), _Tok('John', mark: true, chip: '👤 John'), _Tok('before'),
  _Tok('Friday', mark: true, chip: '📅 Friday'), _Tok('to'), _Tok('confirm'), _Tok('the'),
  _Tok('contract', mark: true, chip: '# contract'), _Tok('terms'), _Tok('and'),
  _Tok('send'), _Tok('the'), _Tok('signed'), _Tok('copy.'),
];

class _RdCaptureFlowState extends State<RdCaptureFlow> {
  String _view = 'listen';
  int _sec = 0;
  int _revealed = 0;
  int _steps = 0;

  bool _conn1 = true;
  bool _conn2 = true;
  bool _conn3 = false;
  bool _remind = true;

  Timer? _secTimer;
  Timer? _revealTimer;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _startListen();
  }

  @override
  void dispose() {
    _secTimer?.cancel();
    _revealTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _clearTimers() {
    _secTimer?.cancel();
    _revealTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _startListen() {
    _clearTimers();
    setState(() {
      _view = 'listen';
      _sec = 0;
      _revealed = 0;
    });
    _secTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _sec++));
    _revealTimer = Timer.periodic(const Duration(milliseconds: 340), (t) {
      if (_revealed >= _tokens.length) {
        t.cancel();
        _timers.add(Timer(const Duration(milliseconds: 1400), _toProc));
        return;
      }
      setState(() => _revealed++);
    });
  }

  void _toProc() {
    _clearTimers();
    setState(() {
      _view = 'proc';
      _steps = 0;
    });
    for (var k = 0; k < 3; k++) {
      _timers.add(Timer(Duration(milliseconds: 500 + k * 650), () => setState(() => _steps = k + 1)));
    }
    _timers.add(Timer(const Duration(milliseconds: 500 + 3 * 650 + 500), () => setState(() => _view = 'review')));
  }

  String get _time =>
      '${_sec ~/ 60}:${(_sec % 60).toString().padLeft(2, '0')}';

  /// Confirm the review: create the reminder (if its toggle is on) and show the
  /// "kept in memory" screen. The reminder create is fire-and-forget so the
  /// confirmation is instant.
  void _addToMemory() {
    if (_remind) unawaited(_createReminder());
    setState(() => _view = 'added');
  }

  Future<void> _createReminder() async {
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient).create(
        title: 'Call John before Friday to confirm the contract terms',
      );
    } catch (_) {
      // Best-effort — the capture is still kept.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RdColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(key: ValueKey(_view), child: _current()),
        ),
      ),
    );
  }

  Widget _current() {
    switch (_view) {
      case 'listen':
        return _listen();
      case 'proc':
        return _proc();
      case 'review':
        return _review();
      default:
        return _added();
    }
  }

  // ── listen ──────────────────────────────────────────────────────────
  Widget _listen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circBtn('<path d="M6 6l12 12M18 6 6 18"/>', () => widget.go('home')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(100), border: Border.all(color: _line, width: 1)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE24B4A))),
                    const SizedBox(width: 7),
                    Text(_time, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                  ],
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
        ),
        const Spacer(),
        const RdOrb(size: 120),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Text('Listening…', style: GoogleFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: _peri)),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < _revealed && i < _tokens.length; i++)
                    _tokens[i].mark
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: _periSoft, borderRadius: BorderRadius.circular(6)),
                            child: Text(_tokens[i].text, style: GoogleFonts.vazirmatn(fontSize: 19, fontWeight: FontWeight.w600, color: _navy)),
                          )
                        : Text(_tokens[i].text, style: GoogleFonts.vazirmatn(fontSize: 19, color: _ink)),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _revealed && i < _tokens.length; i++)
                    if (_tokens[i].chip != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(100), border: Border.all(color: _peri.withValues(alpha: 0.4), width: 1)),
                        child: Text(_tokens[i].chip!, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navy)),
                      ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        const _Waveform(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circBtn('<path d="M6 6l12 12M18 6 6 18"/>', () => widget.go('home'), size: 52),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: _toProc,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(center: Alignment(-0.28, -0.4), colors: [Color(0xFF3A5AD0), _navy]),
                  boxShadow: [BoxShadow(color: const Color(0xFF14328C).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: -6, offset: const Offset(0, 10))],
                ),
                child: const Center(child: RdIcon('<path d="m5 12 5 5 9-11"/>', size: 30, stroke: '#FFFFFF', strokeWidth: 2.4)),
              ),
            ),
            const SizedBox(width: 40),
            const SizedBox(width: 52),
          ],
        ),
        const SizedBox(height: 14),
        Text('Tap ✓ when you’re finished', style: GoogleFonts.vazirmatn(fontSize: 12.5, color: _muted)),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── processing ──────────────────────────────────────────────────────
  Widget _proc() {
    const labels = ['Transcribing what you said', 'Recognising type & details', 'Finding connections in memory'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RdOrb(size: 120),
          const SizedBox(height: 26),
          Text('Understanding', style: GoogleFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: _peri)),
          const SizedBox(height: 22),
          for (var k = 0; k < labels.length; k++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: k < _steps ? 1 : 0.4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: k < _steps ? _navy : const Color(0xFFD8D8DE)),
                      child: k < _steps ? const Center(child: RdIcon('<path d="m5 12 5 5 9-11"/>', size: 12, stroke: '#FFFFFF', strokeWidth: 3)) : null,
                    ),
                    const SizedBox(width: 11),
                    Text(labels[k], style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w500, color: _ink)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── review ──────────────────────────────────────────────────────────
  Widget _review() {
    return Column(
      children: [
        _reviewTop('Cancel', () => widget.go('home')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('Mira understood this'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _typeChip('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', 'Task'),
                          Row(
                            children: [
                              const RdIcon('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', size: 13, stroke: '#8A8B92', strokeWidth: 2),
                              const SizedBox(width: 5),
                              Text('Change type', style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w500, color: _muted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Call '),
                            TextSpan(text: 'John', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700)),
                            const TextSpan(text: ' before '),
                            TextSpan(text: 'Friday', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700)),
                            const TextSpan(text: ' to confirm the contract terms and send the signed copy.'),
                          ],
                          style: GoogleFonts.vazirmatn(fontSize: 16, height: 1.5, color: _ink),
                        ),
                      ),
                    ],
                  ),
                ),
                _fieldLabel('Details Mira extracted'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _EChip('👤 John'),
                    _EChip('📅 Friday'),
                    _EChip('# contract'),
                    _EChip('+ Add', add: true),
                  ],
                ),
                _fieldLabel('Connect to existing memory'),
                _connRow('<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>', 'Meeting with John', 'Calendar · Tomorrow, 3:00 PM', _conn1, () => setState(() => _conn1 = !_conn1)),
                const SizedBox(height: 8),
                _connRow('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', 'Contract draft v2', 'Note · Captured 2h ago', _conn2, () => setState(() => _conn2 = !_conn2)),
                const SizedBox(height: 8),
                _connRow('<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>', 'John Carter', 'Person · 6 linked memories', _conn3, () => setState(() => _conn3 = !_conn3)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => setState(() => _remind = !_remind),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(color: _periSoft, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const RdIcon('<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M12 2h0M9 2h6"/>', size: 20, stroke: '#14328C', strokeWidth: 1.8),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Remind me '),
                                TextSpan(text: 'Thursday morning', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700)),
                                const TextSpan(text: ', a day before it’s due'),
                              ],
                              style: GoogleFonts.vazirmatn(fontSize: 13, height: 1.4, color: _navy),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _Tog(on: _remind),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _reviewBar(),
      ],
    );
  }

  // ── added ───────────────────────────────────────────────────────────
  Widget _added() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F8A5B), Color(0xFF34A56F)]),
              ),
              child: const Center(child: RdIcon('<path d="m5 12 5 5 9-11"/>', size: 40, stroke: '#FFFFFF', strokeWidth: 2.4)),
            ),
            const SizedBox(height: 24),
            Text('Kept in memory', style: GoogleFonts.dosis(fontSize: 28, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Linked to '),
                  TextSpan(text: '2 memories', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600, color: _ink)),
                  const TextSpan(text: ' and 1 reminder. Mira will bring it back at the right time.'),
                ],
                style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.5, color: _muted),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _graphDot(11, false),
                _graphLine(),
                _graphDot(20, true),
                _graphLine(),
                _graphDot(11, false),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => widget.go('home'),
              child: Container(
                width: 220,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(14)),
                child: Text('Done', style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── shared bits ─────────────────────────────────────────────────────
  Widget _reviewTop(String backLabel, VoidCallback onBack) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RdIcon('<path d="M15 18l-6-6 6-6"/>', size: 18, stroke: '#8A8B92', strokeWidth: 2),
                const SizedBox(width: 3),
                Text(backLabel, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w500, color: _muted)),
              ],
            ),
          ),
          Text('Review', style: GoogleFonts.dosis(fontSize: 17, fontWeight: FontWeight.w600, color: _ink)),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _reviewBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line, width: 1))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.go('home'),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line, width: 1)),
              child: Text('Discard', style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: _muted)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _addToMemory,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(14)),
                child: Text('Add to memory', style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eyebrow(String text) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _peri)),
        const SizedBox(width: 8),
        Text(text.toUpperCase(), style: GoogleFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: _faint)),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(text, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w500, color: _muted)),
    );
  }

  Widget _typeChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: _periSoft, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(icon, size: 14, stroke: '#14328C', strokeWidth: 2),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navy)),
        ],
      ),
    );
  }

  Widget _connRow(String icon, String name, String sub, bool on, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line, width: 1)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: _periSoft, borderRadius: BorderRadius.circular(10)),
            child: Center(child: RdIcon(icon, size: 18, stroke: '#14328C', strokeWidth: 1.8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, color: _muted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(onTap: onTap, child: _Tog(on: on)),
        ],
      ),
    );
  }

  Widget _circBtn(String icon, VoidCallback onTap, {double size = 42}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _card, border: Border.all(color: _line, width: 1)),
        child: Center(child: RdIcon(icon, size: size * 0.4, stroke: '#6B6C73', strokeWidth: 2.1)),
      ),
    );
  }

  Widget _graphDot(double size, bool hub) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hub ? const RadialGradient(colors: [Color(0xFFAEB9E8), Color(0xFF6472B6)]) : null,
        color: hub ? null : _periSoft,
        border: hub ? null : Border.all(color: _peri, width: 1.5),
      ),
    );
  }

  Widget _graphLine() => Container(width: 34, height: 1.5, color: _peri.withValues(alpha: 0.5));
}

class _EChip extends StatelessWidget {
  const _EChip(this.label, {this.add = false});

  final String label;
  final bool add;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: add ? Colors.transparent : _card,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: add ? _peri.withValues(alpha: 0.5) : _line, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w500, color: add ? _navy : _ink),
      ),
    );
  }
}

class _Tog extends StatelessWidget {
  const _Tog({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(color: on ? _navy : const Color(0xFFD3D5DE), borderRadius: BorderRadius.circular(100)),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    );
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform();

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 27; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Container(
                  width: 3,
                  height: 6 + 26 * (0.5 + 0.5 * math.sin((_c.value * 2 * math.pi) + i * 0.55)).abs(),
                  decoration: BoxDecoration(color: _peri.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(2)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
