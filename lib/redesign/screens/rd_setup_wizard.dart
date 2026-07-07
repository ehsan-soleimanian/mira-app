import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';
import 'rd_home_screen.dart';

/// Setup wizard — the post-registration flow that teaches Mira the shape of
/// you before Home. 13 steps, a live progress bar over the input steps, and a
/// coach-mark tour over the real Home. Faithful to `setupwizard.jsx` (`.wz-*`).
/// The collected model is local; it's persisted to the profile once wired.
class RdSetupWizard extends StatefulWidget {
  const RdSetupWizard({super.key, required this.go, this.initialDisplayName});

  final RdGo go;

  /// Name collected on the Details step — pre-fills the wizard address field.
  final String? initialDisplayName;

  @override
  State<RdSetupWizard> createState() => _RdSetupWizardState();
}

// Fixed brand accents — identical in light and dark (navy CTAs, peri orbs/dots).
const _navy = Color(0xFF14328C);
const _peri = Color(0xFF7E8BC9);

const _steps = [
  'welcome', 'address', 'focus', 'people', 'rhythm', 'privacy', 'sources',
  'import', 'permissions', 'weaving', 'ready', 'tour', 'invite',
];
const _inputSteps = [
  'address', 'focus', 'people', 'rhythm', 'privacy', 'sources', 'import', 'permissions',
];

class _RdSetupWizardState extends State<RdSetupWizard> {
  int _i = 0;
  int _tourI = 0;

  final _nameCtl = TextEditingController();
  final _peopleCtl = TextEditingController();

  String _tone = 'calm';
  final Set<String> _focus = {};
  final List<String> _people = [];
  String _briefTime = 'morning';
  bool _quiet = true;
  final Set<String> _sources = {};
  final Set<String> _imports = {};
  bool _syncOn = true;
  bool _improveOn = false;
  bool _micOn = true;
  bool _notifOn = true;
  bool _copied = false;

  Timer? _weaveTimer;

  String get _step => _steps[_i];

  @override
  void initState() {
    super.initState();
    final name = widget.initialDisplayName?.trim();
    if (name != null && name.isNotEmpty) {
      _nameCtl.text = name;
    }
  }

  @override
  void dispose() {
    _weaveTimer?.cancel();
    _nameCtl.dispose();
    _peopleCtl.dispose();
    super.dispose();
  }

  void _setStep(int idx) {
    _weaveTimer?.cancel();
    setState(() => _i = idx.clamp(0, _steps.length - 1));
    if (_steps[_i] == 'weaving') {
      _weaveTimer = Timer(const Duration(milliseconds: 2600), _next);
    }
  }

  void _next() => _setStep(_i + 1);

  void _back() {
    if (_i == 0) {
      widget.go('details');
    } else {
      _setStep(_i - 1);
    }
  }

  /// Assemble the wizard selections into the backend setup payload. Keys are
  /// camelCase to match the API's [CamelModel] alias convention
  /// (`POST /auth/onboarding/setup`). Fields the wizard doesn't collect
  /// (e.g. quiet-hours window) are left to the server's defaults.
  Map<String, dynamic> _collectPrefs() {
    final name = _nameCtl.text.trim();
    return {
      if (name.isNotEmpty) 'displayName': name,
      'tone': _tone,
      'focusAreas': _focus.toList(),
      'importantPeople': _people,
      'briefTime': _briefTime,
      'quietHoursEnabled': _quiet,
      'syncEnabled': _syncOn,
      'improveEnabled': _improveOn,
      'connectedSources': _sources.toList(),
      'importSources': _imports.toList(),
      'microphonePermission': _micOn,
      'notificationPermission': _notifOn,
      'completeOnboarding': true,
    };
  }

  void _finish() {
    // Persist best-effort; never block the transition to Home on the network.
    final prefs = _collectPrefs();
    final repo = AppScope.servicesOf(context).onboardingRepository;
    unawaited(() async {
      try {
        await repo.submitSetup(prefs);
      } catch (_) {
        // Setup answers are non-critical; ignore failures and let the user in.
      }
    }());
    widget.go('home');
  }

  int get _importTotal => _imports.fold(
      0, (s, id) => s + _importApps.firstWhere((a) => a.id == id).count);

  static String _fmtK(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}k'
      : '$n';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.rd.bg,
      body: SafeArea(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 'welcome':
        return _welcome();
      case 'address':
        return _address();
      case 'focus':
        return _focusStep();
      case 'people':
        return _peopleStep();
      case 'rhythm':
        return _rhythm();
      case 'privacy':
        return _privacy();
      case 'sources':
        return _sourcesStep();
      case 'import':
        return _importStep();
      case 'permissions':
        return _permissions();
      case 'weaving':
        return _weaving();
      case 'ready':
        return _ready();
      case 'tour':
        return _tour();
      case 'invite':
        return _invite();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── chrome ──────────────────────────────────────────────────────────
  Widget _chrome({
    required List<Widget> children,
    required String ctaLabel,
    VoidCallback? onCta,
    bool skip = false,
  }) {
    final rd = context.rd;
    final progIdx = _inputSteps.indexOf(_step);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: _back,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RdIcon(RdIcons.chevronLeft, size: 22, color: rd.ink, strokeWidth: 2),
                ),
              ),
              const SizedBox(width: 8),
              if (progIdx >= 0)
                Expanded(
                  child: Row(
                    children: [
                      for (var k = 0; k < _inputSteps.length; k++) ...[
                        if (k > 0) const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: k <= progIdx ? _navy : rd.line,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: skip
                    ? GestureDetector(
                        onTap: _next,
                        child: Text(
                          'Skip',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.vazirmatn(fontSize: 14, color: rd.muted),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: _WzButton(label: ctaLabel, onTap: onCta ?? _next),
        ),
      ],
    );
  }

  Widget _h(String text, {double size = 25}) => Text(
        text,
        style: GoogleFonts.dosis(
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1.18,
          color: context.rd.ink,
        ),
      );

  Widget _desc(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          text,
          style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.5, color: context.rd.muted),
        ),
      );

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Text(
          text,
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.rd.muted,
          ),
        ),
      );

  // ── welcome ─────────────────────────────────────────────────────────
  Widget _welcome() {
    final rd = context.rd;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RdOrb(size: 112),
                  const SizedBox(height: 30),
                  Text(
                    'Let’s set up\nyour second mind.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dosis(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.16,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 280,
                    child: Text(
                      'A few quick questions so Mira remembers the way you do. About two minutes — and you can change any of it later.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13.5,
                        height: 1.5,
                        color: rd.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ctaStack([
          _WzButton(label: 'Begin setup', onTap: _next),
          _WzButton(label: 'Skip for now', variant: _WzVariant.ghost, onTap: _finish),
        ]),
      ],
    );
  }

  // ── address ─────────────────────────────────────────────────────────
  Widget _address() {
    return _chrome(
      ctaLabel: 'Continue',
      children: [
        _h('What should Mira\ncall you?'),
        _desc('This is how your Brief and reminders will greet you.'),
        const SizedBox(height: 20),
        _WzInput(controller: _nameCtl, hint: 'Your name'),
        _fieldLabel('And how should it speak?'),
        for (final t in _tones) ...[
          _ToneCard(
            label: t.$2,
            sub: t.$3,
            on: _tone == t.$1,
            onTap: () => setState(() => _tone = t.$1),
          ),
          if (t != _tones.last) const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ── focus ───────────────────────────────────────────────────────────
  Widget _focusStep() {
    return _chrome(
      ctaLabel: _focus.isEmpty ? 'Pick a few' : 'Continue',
      skip: true,
      children: [
        _h('What matters\nto you?'),
        _desc('Mira will cluster your memories around these. Choose any that fit.'),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final f in _foci)
              _FocusChip(
                label: f.$2,
                icon: f.$3,
                on: _focus.contains(f.$1),
                onTap: () => setState(() =>
                    _focus.contains(f.$1) ? _focus.remove(f.$1) : _focus.add(f.$1)),
              ),
          ],
        ),
      ],
    );
  }

  // ── people ──────────────────────────────────────────────────────────
  Widget _peopleStep() {
    void add() {
      final v = _peopleCtl.text.trim();
      if (v.isNotEmpty && !_people.contains(v)) {
        setState(() => _people.add(v));
      }
      _peopleCtl.clear();
    }

    return _chrome(
      ctaLabel: 'Continue',
      skip: true,
      children: [
        _h('Who’s important\nto you?'),
        _desc('Mira links what you capture to the people in your life. Add a few — first names are enough.'),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _WzInput(controller: _peopleCtl, hint: 'Add a name', onSubmitted: (_) => add())),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: add,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: RdIcon('<path d="M12 5v14M5 12h14"/>',
                      size: 22, stroke: '#FFFFFF', strokeWidth: 2.2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_people.isEmpty)
          Text(
            'No one yet — Mira will still learn as you capture.',
            style: GoogleFonts.vazirmatn(fontSize: 12.5, color: context.rd.faint),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _people)
                _PersonChip(
                  name: p,
                  onRemove: () => setState(() => _people.remove(p)),
                ),
            ],
          ),
      ],
    );
  }

  // ── rhythm ──────────────────────────────────────────────────────────
  Widget _rhythm() {
    return _chrome(
      ctaLabel: 'Continue',
      children: [
        _h('When should your\nBrief arrive?'),
        _desc('A calm once-a-day summary of what needs you — nothing more.'),
        const SizedBox(height: 22),
        Row(
          children: [
            for (final t in _times) ...[
              Expanded(
                child: _TimeCard(
                  label: t.$2,
                  sub: t.$3,
                  on: _briefTime == t.$1,
                  onTap: () => setState(() => _briefTime = t.$1),
                ),
              ),
              if (t != _times.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _ToggleRow(
          title: 'Quiet hours',
          sub: 'No nudges 22:00 – 07:00',
          on: _quiet,
          onTap: () => setState(() => _quiet = !_quiet),
        ),
      ],
    );
  }

  // ── privacy ─────────────────────────────────────────────────────────
  Widget _privacy() {
    return _chrome(
      ctaLabel: 'Continue',
      children: [
        _h('Your memory\nstays yours.'),
        _desc('Before you connect anything, here’s the promise Mira is built on.'),
        const SizedBox(height: 20),
        for (final a in _assurances) ...[
          _AssuranceRow(bg: a.$1, icon: a.$2, title: a.$3, sub: a.$4),
          const SizedBox(height: 10),
        ],
        _fieldLabel('Your choices'),
        _ToggleRow(
          icon: '<path d="M4 12a8 8 0 0 1 14-5l2 2M20 12a8 8 0 0 1-14 5l-2-2M18 4v5h-5M6 20v-5h5"/>',
          title: 'Sync across my devices',
          sub: 'Encrypted backup so your memory follows you.',
          on: _syncOn,
          onTap: () => setState(() => _syncOn = !_syncOn),
        ),
        const SizedBox(height: 14),
        _ToggleRow(
          icon: '<path d="M12 3v3M12 18v3M3 12h3M18 12h3M6 6l2 2M16 16l2 2M6 18l2-2M16 8l2-2"/>',
          title: 'Help improve Mira',
          sub: 'Share anonymous, aggregated usage — never your content.',
          on: _improveOn,
          onTap: () => setState(() => _improveOn = !_improveOn),
        ),
      ],
    );
  }

  // ── sources ─────────────────────────────────────────────────────────
  Widget _sourcesStep() {
    return _chrome(
      ctaLabel: 'Continue',
      skip: true,
      children: [
        _h('Connect\nyour world.'),
        _desc('Give Mira a head start. It only reads what you connect, and processes it privately.'),
        const SizedBox(height: 22),
        for (final s in _sourceList) ...[
          _SourceRow(
            bg: s.$4,
            icon: s.$5,
            title: s.$2,
            sub: s.$3,
            connected: _sources.contains(s.$1),
            onTap: () => setState(() =>
                _sources.contains(s.$1) ? _sources.remove(s.$1) : _sources.add(s.$1)),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ── import ──────────────────────────────────────────────────────────
  Widget _importStep() {
    return _chrome(
      ctaLabel: _imports.isEmpty ? 'Continue' : 'Import ${_fmtK(_importTotal)} notes',
      skip: true,
      children: [
        _h('Bring your\nnotes with you.'),
        _desc('Already keep notes elsewhere? Import them once and Mira will weave them into your graph. Nothing is deleted from the original app.'),
        const SizedBox(height: 22),
        for (final a in _importApps) ...[
          _ImportRow(
            bg: a.bg,
            icon: a.icon,
            title: a.label,
            sub: '~${_fmtK(a.count)} notes found',
            on: _imports.contains(a.id),
            onTap: () => setState(() =>
                _imports.contains(a.id) ? _imports.remove(a.id) : _imports.add(a.id)),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RdIcon(
              '<path d="M12 8v5M12 16h.01M10.3 3.9 2 18a2 2 0 0 0 1.7 3h16.6a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"/>',
              size: 15,
              color: context.rd.faint,
              strokeWidth: 1.8,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                _imports.isEmpty
                    ? 'You can also import later from Settings.'
                    : 'Mira will import in the background — you can start using it right away.',
                style: GoogleFonts.vazirmatn(fontSize: 12.5, height: 1.5, color: context.rd.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── permissions ─────────────────────────────────────────────────────
  Widget _permissions() {
    return _chrome(
      ctaLabel: 'Continue',
      children: [
        _h('Let Mira\nhelp quietly.'),
        _desc('Two permissions, both optional. Turn off anything, anytime.'),
        const SizedBox(height: 22),
        _ToggleRow(
          icon: '<path d="M12 3a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V6a3 3 0 0 0-3-3ZM5 11a7 7 0 0 0 14 0M12 18v3"/>',
          title: 'Microphone',
          sub: 'So you can speak a memory anytime',
          on: _micOn,
          onTap: () => setState(() => _micOn = !_micOn),
        ),
        const SizedBox(height: 14),
        _ToggleRow(
          icon: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0"/>',
          title: 'Notifications',
          sub: 'Only your Brief and reminders you set',
          on: _notifOn,
          onTap: () => setState(() => _notifOn = !_notifOn),
        ),
      ],
    );
  }

  // ── weaving ─────────────────────────────────────────────────────────
  Widget _weaving() {
    final echoes = <String>[];
    if (_focus.isNotEmpty) {
      echoes.add('${_focus.length} focus ${_focus.length == 1 ? 'area' : 'areas'}');
    }
    if (_people.isNotEmpty) {
      echoes.add('${_people.length} ${_people.length == 1 ? 'person' : 'people'}');
    }
    if (_sources.isNotEmpty) {
      echoes.add('${_sources.length} ${_sources.length == 1 ? 'source' : 'sources'}');
    }
    if (_importTotal > 0) echoes.add('${_fmtK(_importTotal)} imported notes');
    final line = echoes.isEmpty ? 'your preferences' : echoes.join(' · ');
    final rd = context.rd;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RdOrb(size: 128),
            const SizedBox(height: 30),
            Text(
              'Weaving your\nmemory…',
              textAlign: TextAlign.center,
              style: GoogleFonts.dosis(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.16,
                color: rd.ink,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 260,
              child: Text(
                'Mira is arranging $line into the shape of your mind.',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.5, color: rd.muted),
              ),
            ),
            const SizedBox(height: 26),
            const _WeaveDots(),
          ],
        ),
      ),
    );
  }

  // ── ready ───────────────────────────────────────────────────────────
  Widget _ready() {
    final rd = context.rd;
    final greet = _nameCtl.text.trim().isEmpty
        ? 'you'
        : _nameCtl.text.trim().split(' ').first;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1F8A5B), Color(0xFF34A56F)],
                      ),
                    ),
                    child: const Center(
                      child: RdIcon(RdIcons.checkThick,
                          size: 34, stroke: '#FFFFFF', strokeWidth: 2.6),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Your second\nmind is ready.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dosis(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.16,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 290,
                    child: Text(
                      'Everything you capture from here, $greet, has a place to live — and a way back to you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.5, color: rd.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ctaStack([
          _WzButton(
            label: 'Take a quick tour',
            onTap: () {
              setState(() => _tourI = 0);
              _setStep(_steps.indexOf('tour'));
            },
          ),
          _WzButton(
            label: 'Skip the tour',
            variant: _WzVariant.ghost,
            onTap: () => _setStep(_steps.indexOf('invite')),
          ),
        ]),
      ],
    );
  }

  // ── tour (coach-marks over Home) ────────────────────────────────────
  Widget _tour() {
    const stops = [
      ('One place to capture', 'Type, speak, or snap a photo — everything you save starts right here.', 0.30, 62.0, 18.0, true),
      ('Everything lands here', 'Each capture joins your timeline, already linked to what it relates to.', 0.50, 74.0, 14.0, true),
      ('Capture from anywhere', 'Tap the mic any time — even mid-conversation — to save a thought in a breath.', 0.88, 76.0, 38.0, false),
      ('Move around calmly', 'Home, Library, Canvas and your Daily Brief all live down here.', 0.94, 84.0, 20.0, false),
    ];
    final stop = stops[_tourI];
    final last = _tourI == stops.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cy = h * stop.$3;
        final boxH = stop.$4;
        final radius = stop.$5;
        final below = stop.$6;
        final rect = Rect.fromLTWH(24, cy - boxH / 2, w - 48, boxH);

        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RdHomeScreen(go: (_, {arg}) {}, live: false),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(hole: rect, radius: radius),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: below ? rect.bottom + 14 : null,
              bottom: below ? null : h - rect.top + 14,
              child: _TourCard(
                index: _tourI,
                total: stops.length,
                title: stop.$1,
                body: stop.$2,
                last: last,
                onSkip: () => _setStep(_steps.indexOf('invite')),
                onNext: () {
                  if (last) {
                    _setStep(_steps.indexOf('invite'));
                  } else {
                    setState(() => _tourI++);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── invite (referral) ───────────────────────────────────────────────
  Widget _invite() {
    const code = 'MIRA-7F3K';
    final rd = context.rd;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 0),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3550C4), Color(0xFF1B2570)],
                    ),
                  ),
                  child: const Center(
                    child: RdIcon(
                      '<path d="M20 12v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8M2 8h20v4H2zM12 8v13M12 8S9.5 4 7.5 4a2.5 2.5 0 0 0 0 5H12ZM12 8s2.5-4 4.5-4a2.5 2.5 0 0 1 0 5H12"/>',
                      size: 30,
                      stroke: '#FFFFFF',
                      strokeWidth: 1.9,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Give someone a\ncalmer mind.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dosis(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.16,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  child: Text(
                    'Mira is better with the people you think alongside. Invite a few — they skip the waitlist, and you both get a month of Plus.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.5, color: rd.muted),
                  ),
                ),
                const SizedBox(height: 26),
                _inviteCode(code),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final c in _channels) ...[
                      Expanded(
                        child: _ChannelCard(bg: c.$2, icon: c.$3, label: c.$1),
                      ),
                      if (c != _channels.last) const SizedBox(width: 10),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        _ctaStack([
          _WzButton(label: 'Share your invite', onTap: _finish),
          _WzButton(label: 'Maybe later', variant: _WzVariant.ghost, onTap: _finish),
        ]),
      ],
    );
  }

  Widget _inviteCode(String code) {
    final rd = context.rd;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR INVITE CODE',
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: rd.muted,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: _navy,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _copied = true);
                  Future.delayed(const Duration(milliseconds: 1600), () {
                    if (mounted) setState(() => _copied = false);
                  });
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: _copied ? const Color(0xFF1F8A5B) : _navy,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      RdIcon(
                        _copied
                            ? RdIcons.checkThick
                            : '<path d="M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V10a1 1 0 0 1 1-1ZM5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1"/>',
                        size: 15,
                        stroke: '#FFFFFF',
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _copied ? 'Copied' : 'Copy',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctaStack(List<Widget> buttons) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          for (var k = 0; k < buttons.length; k++) ...[
            if (k > 0) const SizedBox(height: 12),
            buttons[k],
          ],
        ],
      ),
    );
  }
}

// ══ data ═══════════════════════════════════════════════════════════════
const _tones = [
  ('calm', 'Calm', 'Gentle, unhurried'),
  ('concise', 'Concise', 'Short and clear'),
  ('warm', 'Warm', 'Friendly, personal'),
];

const _foci = [
  ('work', 'Work & projects', '<path d="M4 7h16v13H4zM8 7V4h8v3"/>'),
  ('ideas', 'Ideas & sparks', '<path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10c1 1 1 2 1 3h6c0-1 0-2 1-3a6 6 0 0 0-4-10Z"/>'),
  ('people', 'People', '<path d="M16 20v-2a4 4 0 0 0-8 0v2M12 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z"/>'),
  ('reading', 'Reading & links', '<path d="M4 5a2 2 0 0 1 2-2h13v17H6a2 2 0 0 1-2-2zM19 3v17"/>'),
  ('health', 'Health', '<path d="M20.8 6.6a5 5 0 0 0-8.8-2 5 5 0 0 0-8.8 3.2C3.2 12 12 20 12 20s8.8-8 8.8-13.4Z"/>'),
  ('money', 'Money', '<path d="M12 2v20M17 6H10a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6H6"/>'),
  ('travel', 'Travel & places', '<path d="M12 21c-4-5-7-8-7-11a7 7 0 0 1 14 0c0 3-3 6-7 11ZM12 12a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z"/>'),
  ('learning', 'Learning', '<path d="M22 10 12 5 2 10l10 5 10-5ZM6 12v5c0 1 3 3 6 3s6-2 6-3v-5"/>'),
];

const _times = [
  ('morning', 'Morning', '7:00'),
  ('midday', 'Midday', '12:30'),
  ('evening', 'Evening', '18:00'),
];

const _assurances = [
  (Color(0x181F8A5B), '<path d="M6 10V8a6 6 0 0 1 12 0v2M5 10h14a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8a1 1 0 0 1 1-1ZM12 14v3"/>', 'Processed privately', 'Your captures are analysed on-device whenever possible.'),
  (Color(0x185B8DEF), '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10ZM9 12l2 2 4-4"/>', 'Encrypted end-to-end', 'Only you can read your memories — not even Mira can.'),
  (Color(0x18E94848), '<path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18ZM5.6 5.6l12.8 12.8"/>', 'Never sold, ever', 'We don’t sell or share your data. No ads, no exceptions.'),
];

const _sourceList = [
  ('calendar', 'Calendar', 'Meetings feed your Brief', Color(0x18E94848), '<path d="M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2ZM2 9h20M8 3v3M16 3v3"/>'),
  ('notes', 'Notes', 'Your written thoughts', Color(0x18F0B545), '<path d="M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1ZM8 8h8M8 12h8M8 16h5"/>'),
  ('photos', 'Photos', 'Screenshots & scans', Color(0x185B8DEF), '<path d="M3 5h18v14H3zM3 15l5-4 4 3 3-2 6 5"/>'),
  ('gmail', 'Gmail', 'Important mail', Color(0x18EA4335), '<path d="M3 5h18v14H3zM3 7l9 6 9-6"/>'),
];

class _ImportApp {
  const _ImportApp(this.id, this.label, this.count, this.bg, this.icon);
  final String id;
  final String label;
  final int count;
  final Color bg;
  final String icon;
}

const _importApps = [
  _ImportApp('apple', 'Apple Notes', 430, Color(0x22F2C94C), '<path d="M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1ZM8 8h8M8 12h8M8 16h5"/>'),
  _ImportApp('notion', 'Notion', 210, Color(0x228A8A8A), '<path d="M5 4h9l5 5v11a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1ZM14 4v5h5"/>'),
  _ImportApp('evernote', 'Evernote', 1240, Color(0x224BAF50), '<path d="M12 3a4 4 0 0 0-4 4v2H6a3 3 0 0 0 0 6h1v2a4 4 0 0 0 8 0v-2h1a3 3 0 0 0 0-6h-2V7a4 4 0 0 0-4-4Z"/>'),
  _ImportApp('bear', 'Bear', 180, Color(0x22E86868), '<path d="M6 6a3 3 0 1 0-1 3M18 6a3 3 0 1 1 1 3M12 21a6 6 0 0 0 6-6c0-3-2.7-6-6-6s-6 3-6 6a6 6 0 0 0 6 6ZM10 15h4"/>'),
  _ImportApp('keep', 'Google Keep', 95, Color(0x22F0B545), '<path d="M9 3h6l4 6-7 12L5 9l4-6ZM9 3l3 6 3-6M5 9h14"/>'),
  _ImportApp('obsidian', 'Obsidian', 340, Color(0x227C6BEA), '<path d="M12 2l7 6-4 14H9L5 8l7-6ZM9 22l3-9 3 9M5 8l7 5 7-5"/>'),
];

const _channels = [
  ('Messages', Color(0x181F8A5B), '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>'),
  ('Mail', Color(0x185B8DEF), '<path d="M4 4h16a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1ZM3 6l9 7 9-7"/>'),
  ('Copy link', Color(0x188A6BEF), '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>'),
];

// ══ shared widgets ═════════════════════════════════════════════════════
enum _WzVariant { navy, ghost }

class _WzButton extends StatelessWidget {
  const _WzButton({required this.label, required this.onTap, this.variant = _WzVariant.navy});

  final String label;
  final VoidCallback onTap;
  final _WzVariant variant;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final navy = variant == _WzVariant.navy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: navy ? _navy : rd.card,
          borderRadius: BorderRadius.circular(12),
          border: navy ? null : Border.all(color: _navy, width: 1.4),
        ),
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: navy ? Colors.white : _navy,
          ),
        ),
      ),
    );
  }
}

class _WzInput extends StatelessWidget {
  const _WzInput({required this.controller, required this.hint, this.onSubmitted});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        cursorColor: const Color(0xFF3D63F5),
        style: GoogleFonts.vazirmatn(fontSize: 14, color: rd.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.vazirmatn(fontSize: 14, color: rd.faint),
          filled: true,
          fillColor: rd.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: rd.line, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3D63F5), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _WzSwitch extends StatelessWidget {
  const _WzSwitch({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 28,
      decoration: BoxDecoration(
        color: on ? _navy : context.rd.line,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({required this.label, required this.sub, required this.on, required this.onTap});

  final String label;
  final String sub;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? _navy : rd.line, width: on ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dosis(fontSize: 16, fontWeight: FontWeight.w700, color: rd.ink)),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted)),
          ],
        ),
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({required this.label, required this.icon, required this.on, required this.onTap});

  final String label;
  final String icon;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: on ? rd.periSoft : rd.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: on ? _navy : rd.line, width: on ? 1.6 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(icon, size: 19, color: on ? rd.peri : rd.muted, strokeWidth: 1.8),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: on ? rd.peri : rd.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.sub, required this.on, required this.onTap});

  final String label;
  final String sub;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: on ? rd.periSoft : rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? _navy : rd.line, width: on ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.dosis(fontSize: 15, fontWeight: FontWeight.w700, color: rd.ink)),
            const SizedBox(height: 3),
            Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted)),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, required this.sub, required this.on, required this.onTap, this.icon});

  final String title;
  final String sub;
  final bool on;
  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: rd.periSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: RdIcon(icon!, size: 20, color: rd.peri, strokeWidth: 1.8),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink)),
                  const SizedBox(height: 2),
                  Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _WzSwitch(on: on),
          ],
        ),
      ),
    );
  }
}

class _AssuranceRow extends StatelessWidget {
  const _AssuranceRow({required this.bg, required this.icon, required this.title, required this.sub});

  final Color bg;
  final String icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          _Tile(bg: bg, icon: icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, height: 1.4, color: rd.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.bg,
    required this.icon,
    required this.title,
    required this.sub,
    required this.connected,
    required this.onTap,
  });

  final Color bg;
  final String icon;
  final String title;
  final String sub;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          _Tile(bg: bg, icon: icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: connected ? const Color(0xFFE6F4EC) : rd.periSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (connected) ...[
                    const RdIcon(RdIcons.checkThick, size: 14, stroke: '#1F8A5B', strokeWidth: 2.6),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    connected ? 'Connected' : 'Connect',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: connected ? const Color(0xFF1F8A5B) : _navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportRow extends StatelessWidget {
  const _ImportRow({
    required this.bg,
    required this.icon,
    required this.title,
    required this.sub,
    required this.on,
    required this.onTap,
  });

  final Color bg;
  final String icon;
  final String title;
  final String sub;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? _navy : rd.line, width: on ? 1.6 : 1),
        ),
        child: Row(
          children: [
            _Tile(bg: bg, icon: icon),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink)),
                  const SizedBox(height: 2),
                  Text(sub, style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? _navy : Colors.transparent,
                border: on ? null : Border.all(color: rd.faint, width: 1.6),
              ),
              child: on
                  ? const Center(child: RdIcon(RdIcons.checkThick, size: 14, stroke: '#FFFFFF', strokeWidth: 3))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.bg, required this.icon});

  final Color bg;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
      child: Center(child: RdIcon(icon, size: 20, color: context.rd.ink, strokeWidth: 1.8)),
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: rd.periSoft),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.dosis(fontSize: 13, fontWeight: FontWeight.w700, color: rd.peri),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: GoogleFonts.vazirmatn(fontSize: 13.5, color: rd.ink)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: RdIcon(RdIcons.close, size: 13, color: rd.faint, strokeWidth: 2.4),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.bg, required this.icon, required this.label});

  final Color bg;
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: RdIcon(icon, size: 20, color: rd.ink, strokeWidth: 1.8)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.vazirmatn(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navy),
          ),
        ],
      ),
    );
  }
}

class _WeaveDots extends StatefulWidget {
  const _WeaveDots();

  @override
  State<_WeaveDots> createState() => _WeaveDotsState();
}

class _WeaveDotsState extends State<_WeaveDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Builder(builder: (context) {
                final phase = (_c.value - i * 0.2) % 1.0;
                final lift = (phase < 0.5 ? phase : 1 - phase) * 2; // 0..1
                return Transform.translate(
                  offset: Offset(0, -5 * lift),
                  child: Opacity(
                    opacity: 0.3 + 0.7 * lift,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _peri),
                    ),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.hole, required this.radius});

  final Rect hole;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0x9E0F1120));
    canvas.drawRRect(
      RRect.fromRectAndRadius(hole, Radius.circular(radius)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(hole, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.92)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.radius != radius;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.index,
    required this.total,
    required this.title,
    required this.body,
    required this.last,
    required this.onSkip,
    required this.onNext,
  });

  final int index;
  final int total;
  final String title;
  final String body;
  final bool last;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0C1E).withValues(alpha: 0.55),
            blurRadius: 54,
            spreadRadius: -14,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var k = 0; k < total; k++) ...[
                if (k > 0) const SizedBox(width: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: k == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: k == index ? _navy : const Color(0xFFD8D8DE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Fixed dark ink — the tour card is a light popover over the dark
          // spotlight scrim, so it keeps light-mode inks in both themes.
          Text(title, style: GoogleFonts.dosis(fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1A1C29))),
          const SizedBox(height: 5),
          Text(
            body,
            style: GoogleFonts.vazirmatn(fontSize: 13.5, height: 1.5, color: const Color(0xFF6E6E76)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!last)
                GestureDetector(
                  onTap: onSkip,
                  child: Text('Skip tour', style: GoogleFonts.vazirmatn(fontSize: 14, color: const Color(0xFF9A9A9A))),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    last ? 'Finish' : 'Next',
                    style: GoogleFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
