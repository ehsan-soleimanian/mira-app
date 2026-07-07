import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// Ask Mira — a calm, memory-grounded chat. Mira answers by drawing on
/// connected memories, cited inline as small cards. Faithful to `chat.jsx`
/// (`.rd-chat`), grounded in the "Contract with John" note context. Answers
/// are scripted; the compose bar and starter chips drive the conversation.
class RdChatScreen extends StatefulWidget {
  const RdChatScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdChatScreen> createState() => _RdChatScreenState();
}

const _ink = Color(0xFF1B1C24);
const _navy = Color(0xFF14328C);
const _peri = Color(0xFF7E8BC9);
const _muted = Color(0xFF8A8B92);
const _faint = Color(0xFFB7B8BE);
const _card = Color(0xFFFBFBF9);
const _line = Color(0x12141C2D);

class _Cite {
  const _Cite(this.type, this.title, this.sub);
  final String type;
  final String title;
  final String sub;
}

class _Msg {
  _Msg.me(this.text)
      : mira = false,
        cites = const [],
        action = false;
  _Msg.mira(this.text, {this.cites = const [], this.action = false}) : mira = true;

  final bool mira;
  final String text;
  final List<_Cite> cites;
  final bool action;
}

class _Answer {
  const _Answer(this.text, {this.cites = const [], this.action = false});
  final String text;
  final List<_Cite> cites;
  final bool action;
}

const _anchor = 'Contract with John';
const _opening =
    'This one’s about the partnership contract with John. Ask me anything — what’s open, how it connects, or I can draft something for you.';
const _firstQ = 'What’s still open before Friday?';
const _starters = ['When did we last talk?', 'What’s the Q3 scope?', 'Draft a reminder'];

const _answers = <String, _Answer>{
  'What’s still open before Friday?': _Answer(
    'Two things. Confirm the narrowed Q3 scope with John, and send the signed copy back. The signed PDF is already in your Library from last week’s meeting — so really it’s just the call.',
    cites: [
      _Cite('event', 'Meeting with John', 'Last Thursday'),
      _Cite('photo', 'Signed contract — page 1', 'Photo · read by Mira'),
    ],
  ),
  'When did we last talk?': _Answer(
    'Last Thursday, in your 2pm meeting. That’s where the partnership scope first came up — you noted John wanted it narrowed to Q3 before signing.',
    cites: [_Cite('event', 'Meeting with John', 'Thu · 2:00 PM')],
  ),
  'Draft a reminder': _Answer(
    'Here’s a gentle one: “Call John to confirm the Q3 scope — before Friday.” I can add it to Thursday morning so it surfaces in your Brief. Want me to set it?',
    action: true,
  ),
  'What’s the Q3 scope?': _Answer(
    'From your notes: the partnership narrows to Q3 deliverables only — onboarding and the launch story — with the feature roadmap deferred. John asked to keep it tight before committing.',
    cites: [
      _Cite('note', 'Q3 partnership terms', 'Note · 3 days ago'),
      _Cite('voice', 'Idea for the Q3 launch', 'Voice · 2h ago'),
    ],
  ),
};

class _RdChatScreenState extends State<RdChatScreen> {
  final _scroll = ScrollController();
  final _draftCtl = TextEditingController();
  final Set<String> _asked = {_firstQ};

  late final List<_Msg> _msgs = [
    _Msg.mira(_opening),
    _Msg.me(_firstQ),
    _Msg.mira(_answers[_firstQ]!.text, cites: _answers[_firstQ]!.cites, action: _answers[_firstQ]!.action),
  ];
  bool _typing = false;
  bool _remSet = false;

  Future<void> _setReminder() async {
    if (_remSet) return;
    setState(() => _remSet = true);
    try {
      final services = AppScope.servicesOf(context);
      await RemindersRepository(apiClient: services.apiClient).create(
        title: 'Call John to confirm the Q3 scope — before Friday',
      );
    } catch (_) {
      // Best-effort — the confirmation is already shown.
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _draftCtl.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _ask(String q) {
    final key = _answers.keys.firstWhere(
      (k) => k.toLowerCase() == q.toLowerCase(),
      orElse: () => '',
    );
    final ans = key.isNotEmpty
        ? _answers[key]!
        : _Answer(
            'I don’t have anything on that yet — but the moment you capture it, I’ll connect it here. For now, this memory links to the rest of your “$_anchor” thread.',
            cites: const [_Cite('event', 'Meeting with John', 'Last Thursday')],
          );
    if (key.isNotEmpty) _asked.add(key);
    setState(() {
      _msgs.add(_Msg.me(q));
      _typing = true;
      _draftCtl.clear();
    });
    _scrollDown();
    Timer(const Duration(milliseconds: 1150), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _msgs.add(_Msg.mira(ans.text, cites: ans.cites, action: ans.action));
      });
      _scrollDown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _starters.where((s) => !_asked.contains(s)).toList();
    final lastIsMira = _msgs.isNotEmpty && _msgs.last.mira && !_typing;
    final hasDraft = _draftCtl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: RdColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                children: [
                  for (final m in _msgs) ...[
                    _bubble(m),
                    const SizedBox(height: 16),
                  ],
                  if (_typing) ...[const _TypingBubble(), const SizedBox(height: 16)],
                  if (lastIsMira && remaining.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in remaining)
                            GestureDetector(
                              onTap: () => _ask(s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _card,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _peri.withValues(alpha: 0.4), width: 1),
                                ),
                                child: Text(s, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _navy)),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _compose(hasDraft),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Row(
        children: [
          _IcBtn(icon: '<path d="M15 5l-7 7 7 7"/>', onTap: widget.onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ask Mira', style: GoogleFonts.dosis(fontSize: 19, fontWeight: FontWeight.w700, color: _ink, height: 1)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const RdIcon('<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>', size: 12, stroke: '#7E8BC9', strokeWidth: 1.9),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('About “$_anchor”',
                          overflow: TextOverflow.ellipsis, style: GoogleFonts.vazirmatn(fontSize: 12, color: _muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IcBtn(
            icon: '<circle cx="6" cy="12" r="2.4"/><circle cx="18" cy="6" r="2.4"/><circle cx="18" cy="18" r="2.4"/><path d="M8.2 10.9 15.8 7"/><path d="M8.2 13.1 15.8 17"/>',
            onTap: () => widget.go('canvas'),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m) {
    if (!m.mira) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: const BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Text(m.text, style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.5, color: Colors.white)),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ChatOrb(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: _line, width: 1),
                  ),
                  child: Text(m.text, style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.55, color: const Color(0xFF262832))),
                ),
              ),
              if (m.cites.isNotEmpty) ...[
                const SizedBox(height: 9),
                Text('FROM YOUR MEMORIES', style: GoogleFonts.vazirmatn(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: _faint)),
                const SizedBox(height: 5),
                for (final c in m.cites) ...[
                  _CiteCard(cite: c, onTap: () => widget.go('memory')),
                  const SizedBox(height: 7),
                ],
              ],
              if (m.action) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _setReminder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: _remSet ? const Color(0xFFE7F3EC) : _navy,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RdIcon(
                          _remSet ? '<path d="M20 6 9 17l-5-5"/>' : '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5"/>',
                          size: 16,
                          stroke: _remSet ? '#1F8A5B' : '#FFFFFF',
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _remSet ? 'Added to Thursday morning' : 'Set this reminder',
                          style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _remSet ? const Color(0xFF1F8A5B) : Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _compose(bool hasDraft) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line, width: 1))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _line, width: 1),
              ),
              child: TextField(
                controller: _draftCtl,
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) _ask(v.trim());
                },
                cursorColor: _peri,
                style: GoogleFonts.vazirmatn(fontSize: 14, color: _ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Ask about your memories…',
                  hintStyle: GoogleFonts.vazirmatn(fontSize: 14, color: _faint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (hasDraft) {
                _ask(_draftCtl.text.trim());
              } else {
                widget.go('capture');
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasDraft ? _navy : _card,
                border: hasDraft ? null : Border.all(color: _line, width: 1),
              ),
              child: Center(
                child: hasDraft
                    ? const RdIcon('<path d="M5 12h14M13 6l6 6-6 6"/>', size: 20, stroke: '#FFFFFF', strokeWidth: 2)
                    : const RdIcon('<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>', size: 20, stroke: '#14328C', strokeWidth: 1.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IcBtn extends StatelessWidget {
  const _IcBtn({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line, width: 1),
        ),
        child: Center(child: RdIcon(icon, size: 19, stroke: '#3A3B45', strokeWidth: 1.9)),
      ),
    );
  }
}

class _ChatOrb extends StatelessWidget {
  const _ChatOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: Alignment(-0.32, -0.4), colors: [Color(0xFF9AA6D8), Color(0xFF3F4E9E)]),
      ),
      child: Center(
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ),
    );
  }
}

({Color bg, String stroke, String icon}) _citeStyle(String type) {
  switch (type) {
    case 'event':
      return (bg: const Color(0xFFEAF0FF), stroke: '#3B5BD0', icon: '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>');
    case 'photo':
      return (bg: const Color(0xFFEDE9FB), stroke: '#6D5BC0', icon: '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/>');
    case 'voice':
      return (bg: const Color(0xFFFBEDF0), stroke: '#C05B78', icon: '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>');
    default:
      return (bg: const Color(0xFFE9F3EE), stroke: '#2E8A5F', icon: '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>');
  }
}

class _CiteCard extends StatelessWidget {
  const _CiteCard({required this.cite, required this.onTap});

  final _Cite cite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = _citeStyle(cite.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(13), border: Border.all(color: _line, width: 1)),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(9)),
              child: Center(child: RdIcon(s.icon, size: 15, stroke: s.stroke, strokeWidth: 1.85)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cite.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                  Text(cite.sub, style: GoogleFonts.vazirmatn(fontSize: 11, color: _muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ChatOrb(),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: _line, width: 1),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Builder(builder: (context) {
                      final phase = (_c.value - i * 0.16) % 1.0;
                      final lift = phase < 0.4 ? (phase / 0.4) : (phase < 0.8 ? (1 - (phase - 0.4) / 0.4) : 0.0);
                      return Transform.translate(
                        offset: Offset(0, -3 * lift),
                        child: Opacity(
                          opacity: 0.35 + 0.65 * lift,
                          child: Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: _peri)),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
