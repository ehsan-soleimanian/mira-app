import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/graph_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// Canvas — two ways to see your memory. **Board** is a freeform, pan/zoom
/// surface of loose cards you can drag around and connect; **Map** is Mira's
/// automatic memory graph, where tapping a node centres it, highlights its
/// neighbours, and opens a detail panel. Faithful to `.rd-canvas` /
/// `CanvasScreen` in the design.
class RdCanvasScreen extends StatefulWidget {
  const RdCanvasScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdCanvasScreen> createState() => _RdCanvasScreenState();
}

class _RdCanvasScreenState extends State<RdCanvasScreen> {
  String _mode = 'board';

  /// Live memory graph for Map mode; null → use the designed sample. Loaded
  /// from `graphRepository.fetchGraph` (`/v2/graph`) and laid out client-side.
  List<_GNode>? _mapNodes;
  List<List<String>> _mapEdges = const [];
  String _mapContext = 'Your memory · 34 memories · 61 connections';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadGraph();
    }
  }

  Future<void> _loadGraph() async {
    try {
      final services = AppScope.servicesOf(context);
      final graph = await services.graphRepository.fetchGraph();
      final (nodes, edges) = _mapGraphToNodes(graph);
      if (!mounted || nodes.isEmpty) return;
      setState(() {
        _mapNodes = nodes;
        _mapEdges = edges;
        _mapContext =
            'Your memory · ${nodes.length} memories · ${edges.length} connections';
      });
    } catch (_) {
      // Backend unreachable — keep the designed sample graph.
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final live = _mapNodes != null;
    final context_ =
        _mode == 'board' ? 'Coast trip · 8 memories' : _mapContext;

    return Scaffold(
      backgroundColor: rd.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: _mode == 'board'
                ? const _BoardView()
                : _MapView(
                    key: ValueKey(live ? 'map-live' : 'map-sample'),
                    nodes: _mapNodes ?? _graphNodes,
                    edges: live ? _mapEdges : _graphEdges,
                  ),
          ),
          // mode toggle + context (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  children: [
                    _ModeToggle(
                      mode: _mode,
                      onChanged: (m) => setState(() => _mode = m),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: rd.bg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        context_,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: rd.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // bottom nav
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
              child: RdBottomNav(active: 'canvas', go: widget.go),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final String mode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, 'board', RdIcons.grid4, 'Board'),
          const SizedBox(width: 3),
          _seg(context, 'map', RdIcons.navCanvas, 'Map'),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String id, String icon, String label) {
    final rd = context.rd;
    final on = mode == id;
    return GestureDetector(
      onTap: () => onChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: on ? rd.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            RdIcon(
              icon,
              size: 14,
              color: on ? Colors.white : rd.muted,
              strokeWidth: 1.9,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : rd.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Map view — Mira's memory graph
// ══════════════════════════════════════════════════════════════════════

enum _GType { person, task, event, note, book, idea, topic }

class _GNode {
  const _GNode({
    required this.id,
    required this.x,
    required this.y,
    required this.disc,
    required this.type,
    required this.label,
    required this.typ,
    required this.sub,
    this.initial,
  });

  final String id;
  final double x;
  final double y;
  final double disc;
  final _GType type;
  final String label;
  final String typ;
  final String sub;
  final String? initial;
}

const _graphNodes = <_GNode>[
  _GNode(id: 'john', x: 150, y: 250, disc: 68, type: _GType.person, label: 'John', initial: 'J', typ: 'Person', sub: '6 linked memories — mostly the contract and your weekly calls.'),
  _GNode(id: 'contract', x: 92, y: 366, disc: 52, type: _GType.task, label: 'Contract', typ: 'Task', sub: 'Call John before Friday to confirm terms.'),
  _GNode(id: 'meeting', x: 214, y: 384, disc: 44, type: _GType.event, label: 'Meeting', typ: 'Event', sub: 'Tomorrow · 3:00 PM with John.'),
  _GNode(id: 'draft', x: 158, y: 158, disc: 44, type: _GType.note, label: 'Draft v2', typ: 'Note', sub: 'Contract draft — captured 2h ago.'),
  _GNode(id: 'work', x: 236, y: 272, disc: 52, type: _GType.topic, label: 'Work', typ: 'Topic', sub: '12 memories tagged with work.'),
  _GNode(id: 'maya', x: 300, y: 520, disc: 68, type: _GType.person, label: 'Maya', initial: 'M', typ: 'Person', sub: 'Books, jazz, and weekend plans keep coming back to her.'),
  _GNode(id: 'book', x: 336, y: 408, disc: 44, type: _GType.book, label: 'The Overstory', typ: 'Book', sub: 'Recommended by Maya — captured by voice yesterday.'),
  _GNode(id: 'jazz', x: 362, y: 606, disc: 52, type: _GType.topic, label: 'Jazz', typ: 'Topic', sub: '5 memories about live music.'),
  _GNode(id: 'blue', x: 262, y: 640, disc: 44, type: _GType.event, label: 'Blue Note', typ: 'Event', sub: 'Fri, Jul 18 · 8 PM. From a photo you took.'),
  _GNode(id: 'coast', x: 186, y: 520, disc: 44, type: _GType.idea, label: 'Coast weekend', typ: 'Idea', sub: 'A quiet weekend on the coast in spring.'),
];

const _graphEdges = <List<String>>[
  ['john', 'contract'], ['john', 'meeting'], ['john', 'draft'], ['contract', 'meeting'],
  ['john', 'work'], ['contract', 'work'], ['draft', 'work'], ['maya', 'book'],
  ['maya', 'jazz'], ['maya', 'blue'], ['blue', 'jazz'], ['maya', 'coast'], ['coast', 'john'],
];

String _gTypeIcon(_GType t) {
  switch (t) {
    case _GType.task:
      return RdIcons.checkCircle;
    case _GType.event:
      return RdIcons.calendar;
    case _GType.note:
      return RdIcons.pencil;
    case _GType.book:
      return RdIcons.book;
    case _GType.idea:
      return RdIcons.bulb;
    case _GType.topic:
      return RdIcons.hash;
    case _GType.person:
      return RdIcons.people;
  }
}

/// Maps a live memory [GraphResponse] into the Map view's node/edge model,
/// laying nodes out in a deterministic sunflower spiral (higher-degree hubs
/// nearer the centre) since the backend layout is optional. Bounded to keep
/// the graph legible on a phone.
(List<_GNode>, List<List<String>>) _mapGraphToNodes(GraphResponse g) {
  final nodes = g.nodes.take(40).toList();
  final ids = {for (final n in nodes) n.id};
  final edges = <List<String>>[];
  for (final e in g.edges) {
    if (e.sourceId != e.targetId &&
        ids.contains(e.sourceId) &&
        ids.contains(e.targetId)) {
      edges.add([e.sourceId, e.targetId]);
    }
  }
  final degree = {for (final n in nodes) n.id: 0};
  for (final e in edges) {
    degree[e[0]] = (degree[e[0]] ?? 0) + 1;
    degree[e[1]] = (degree[e[1]] ?? 0) + 1;
  }
  final sorted = [...nodes]
    ..sort((a, b) => (degree[b.id] ?? 0).compareTo(degree[a.id] ?? 0));
  const cx = 240.0;
  const cy = 400.0;
  const goldenAngle = 2.399963229728653;
  final out = <_GNode>[];
  for (var i = 0; i < sorted.length; i++) {
    final n = sorted[i];
    final r = 36.0 * math.sqrt(i.toDouble());
    final angle = i * goldenAngle;
    final deg = degree[n.id] ?? 0;
    final type = _gTypeForNode(n);
    final label = _shortGLabel(n.title.isEmpty ? n.summary : n.title);
    out.add(_GNode(
      id: n.id,
      x: cx + r * math.cos(angle),
      y: cy + r * math.sin(angle),
      disc: deg >= 5 ? 68 : (deg >= 2 ? 52 : 44),
      type: type,
      label: label,
      typ: _gTypeLabelFor(type),
      sub: n.summary.trim().isEmpty
          ? '$deg linked ${deg == 1 ? "memory" : "memories"}.'
          : n.summary,
      initial: type == _GType.person && label.isNotEmpty
          ? label.substring(0, 1).toUpperCase()
          : null,
    ));
  }
  return (out, edges);
}

_GType _gTypeForNode(GraphNode n) {
  final t = '${n.entityType ?? ''} ${n.nodeType}'.toLowerCase();
  if (t.contains('person') || t.contains('people')) return _GType.person;
  if (t.contains('task') || t.contains('reminder') || t.contains('todo')) {
    return _GType.task;
  }
  if (t.contains('event') || t.contains('meeting')) return _GType.event;
  if (t.contains('book')) return _GType.book;
  if (t.contains('idea')) return _GType.idea;
  if (t.contains('topic') || t.contains('tag') || t.contains('theme')) {
    return _GType.topic;
  }
  return _GType.note;
}

String _gTypeLabelFor(_GType t) {
  switch (t) {
    case _GType.person:
      return 'Person';
    case _GType.task:
      return 'Task';
    case _GType.event:
      return 'Event';
    case _GType.note:
      return 'Note';
    case _GType.book:
      return 'Book';
    case _GType.idea:
      return 'Idea';
    case _GType.topic:
      return 'Topic';
  }
}

String _shortGLabel(String s) {
  final clean = s.trim().replaceAll('\n', ' ');
  if (clean.length <= 16) return clean;
  return '${clean.substring(0, 15).trimRight()}…';
}

class _MapView extends StatefulWidget {
  const _MapView({
    super.key,
    this.nodes = _graphNodes,
    this.edges = _graphEdges,
  });

  final List<_GNode> nodes;
  final List<List<String>> edges;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> with SingleTickerProviderStateMixin {
  static const _initialPan = Offset(30, 96);

  late final Map<String, _GNode> _byId = {for (final n in widget.nodes) n.id: n};
  late final Map<String, List<String>> _adj = _buildAdjacency();

  String? _selected;
  Offset _pan = _initialPan;

  late final AnimationController _panCtl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..addListener(() {
      final a = _panAnim;
      if (a != null) setState(() => _pan = a.value);
    });
  Animation<Offset>? _panAnim;

  Map<String, List<String>> _buildAdjacency() {
    final adj = {for (final n in widget.nodes) n.id: <String>[]};
    for (final e in widget.edges) {
      adj[e[0]]!.add(e[1]);
      adj[e[1]]!.add(e[0]);
    }
    return adj;
  }

  @override
  void dispose() {
    _panCtl.dispose();
    super.dispose();
  }

  void _animatePanTo(Offset target) {
    _panAnim = Tween(begin: _pan, end: target)
        .animate(CurvedAnimation(parent: _panCtl, curve: Curves.easeOutCubic));
    _panCtl.forward(from: 0);
  }

  void _select(String id, double width) {
    final n = _byId[id]!;
    setState(() => _selected = id);
    _animatePanTo(Offset(width / 2 - n.x, 220 - n.y));
  }

  void _close() {
    setState(() => _selected = null);
    _animatePanTo(_initialPan);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final near = _selected == null
            ? const <String>{}
            : {_selected!, ..._adj[_selected]!};

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selected != null) _close();
          },
          onPanStart: (_) => _panCtl.stop(),
          onPanUpdate: (d) => setState(() => _pan += d.delta),
          child: ClipRect(
            child: Stack(
              children: [
                Transform.translate(
                  offset: _pan,
                  child: SizedBox(
                    width: 480,
                    height: 820,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _EdgePainter(
                              nodes: _byId,
                              edges: widget.edges,
                              selected: _selected,
                              color: rd.peri,
                            ),
                          ),
                        ),
                        for (final n in widget.nodes)
                          Positioned(
                            left: n.x,
                            top: n.y,
                            child: FractionalTranslation(
                              translation: const Offset(-0.5, -0.5),
                              child: _GNodeWidget(
                                node: n,
                                selected: _selected == n.id,
                                dimmed: _selected != null && !near.contains(n.id),
                                onTap: () => _select(n.id, width),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // hint (fixed)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 108,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _selected == null ? 1 : 0,
                      child: const Center(child: _GraphHint()),
                    ),
                  ),
                ),
                // detail panel (fixed)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 108,
                  child: _DetailPanel(
                    node: _selected == null ? null : _byId[_selected],
                    connected: _selected == null
                        ? const []
                        : _adj[_selected]!.map((id) => _byId[id]!).toList(),
                    onClose: _close,
                    onSelectConnected: (id) => _select(id, width),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GNodeWidget extends StatelessWidget {
  const _GNodeWidget({
    required this.node,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final _GNode node;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: dimmed ? 0.28 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: selected ? 1.06 : 1,
              child: _disc(rd),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 84,
              child: Text(
                node.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: node.disc >= 68 ? 12.5 : 11.5,
                  fontWeight: node.disc >= 68 ? FontWeight.w600 : FontWeight.w500,
                  color: rd.ink,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disc(RdTheme rd) {
    final size = node.disc;
    final iconSize = node.disc >= 68 ? 26.0 : (node.disc >= 52 ? 22.0 : 20.0);

    BoxDecoration decoration;
    Widget inner;

    switch (node.type) {
      case _GType.person:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.28, -0.4),
            colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A69B4).withValues(alpha: 0.5),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 12),
            ),
          ],
          border: selected ? Border.all(color: rd.peri, width: 2) : null,
        );
        inner = Text(
          node.initial ?? '',
          style: GoogleFonts.dosis(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      case _GType.topic:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: rd.periSoft,
          border: Border.all(
            color: selected ? rd.peri : const Color(0x807E8BC9),
            width: selected ? 2 : 1.5,
          ),
        );
        inner = RdIcon(_gTypeIcon(node.type),
            size: iconSize, stroke: '#14328C', strokeWidth: 2);
      default:
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          color: rd.card,
          border: Border.all(
            color: selected ? rd.peri : rd.line,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2246).withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: -8,
              offset: const Offset(0, 6),
            ),
          ],
        );
        inner = RdIcon(_gTypeIcon(node.type),
            size: iconSize, color: rd.peri, strokeWidth: 1.8);
    }

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: Center(child: inner),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.nodes,
    required this.edges,
    required this.selected,
    required this.color,
  });

  final Map<String, _GNode> nodes;
  final List<List<String>> edges;
  final String? selected;

  /// Edge tint — the periwinkle accent, passed from the widget so it tracks the
  /// active [RdTheme] (painters cannot read `context`).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
      final a = nodes[e[0]]!;
      final b = nodes[e[1]]!;
      final hot = selected != null && (e[0] == selected || e[1] == selected);
      final dim = selected != null && !hot;

      final paint = Paint()
        ..color = color.withValues(
            alpha: hot ? 0.9 : (dim ? 0.08 : 0.28))
        ..strokeWidth = hot ? 2 : 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), paint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) =>
      old.selected != selected || old.color != color;
}

class _GraphHint extends StatelessWidget {
  const _GraphHint();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(RdIcons.plusCircle, size: 14, color: rd.muted, strokeWidth: 2),
          const SizedBox(width: 7),
          Text(
            'Tap a memory · drag to explore',
            style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.node,
    required this.connected,
    required this.onClose,
    required this.onSelectConnected,
  });

  final _GNode? node;
  final List<_GNode> connected;
  final VoidCallback onClose;
  final ValueChanged<String> onSelectConnected;

  @override
  Widget build(BuildContext context) {
    final showing = node != null;
    return IgnorePointer(
      ignoring: !showing,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        offset: showing ? Offset.zero : const Offset(0, 1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showing ? 1 : 0,
          child: node == null ? const SizedBox.shrink() : _card(context, node!),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, _GNode n) {
    final rd = context.rd;
    final isPerson = n.type == _GType.person;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rd.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628).withValues(alpha: 0.28),
            blurRadius: 50,
            spreadRadius: -20,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isPerson ? null : rd.periSoft,
                  gradient: isPerson
                      ? const RadialGradient(
                          center: Alignment(-0.28, -0.4),
                          colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
                        )
                      : null,
                ),
                child: Center(
                  child: isPerson
                      ? Text(
                          n.initial ?? '',
                          style: GoogleFonts.dosis(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : RdIcon(_gTypeIcon(n.type),
                          size: 22, stroke: '#14328C', strokeWidth: 1.8),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.typ.toUpperCase(),
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: rd.peri,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      n.label,
                      style: GoogleFonts.dosis(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: rd.ink,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: RdIcon(
                    RdIcons.close,
                    size: 18,
                    color: rd.faint,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text(
              n.sub,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                height: 1.5,
                color: rd.muted,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              'CONNECTED TO ${connected.length}',
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: rd.faint,
              ),
            ),
          ),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final c in connected)
                GestureDetector(
                  onTap: () => onSelectConnected(c.id),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: rd.card,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: rd.line, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RdIcon(
                          c.type == _GType.person
                              ? RdIcons.people
                              : _gTypeIcon(c.type),
                          size: 14,
                          color: rd.peri,
                          strokeWidth: 1.8,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c.label,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12.5,
                            color: rd.ink,
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
}

// ══════════════════════════════════════════════════════════════════════
// Board view — freeform card surface (pan + zoom)
// ══════════════════════════════════════════════════════════════════════

/// A user-drawn connection between two board cards, rendered in connect-mode.
class _BoardEdge {
  const _BoardEdge({required this.from, required this.to, required this.label});

  final String from;
  final String to;
  final String label;
}

/// Connect tool lives at toolbar index 3.
const _connectTool = 3;

class _BoardView extends StatefulWidget {
  const _BoardView();

  @override
  State<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<_BoardView> {
  double _scale = 0.72;
  Offset _offset = const Offset(-30, 40);

  double _startScale = 0.72;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  int _tool = 0;
  bool _suggestVisible = true;

  /// Card positions (top-left, board coordinates), seeded from the specs.
  /// Dragging mutates these so cards keep their positions after drop.
  late final Map<String, Offset> _positions = {
    for (final c in _boardCards) c.id: Offset(c.left, c.top),
  };

  /// The card currently under the finger — lifted (bigger shadow, slight
  /// scale) and raised above its siblings.
  String? _draggingId;

  /// Connect-mode: the first-tapped card (source); the second tap creates an
  /// edge and clears this.
  String? _connectSource;

  /// User-created connections (persist for the session).
  final List<_BoardEdge> _edges = [];

  bool get _connectMode => _tool == _connectTool;

  void _onScaleStart(ScaleStartDetails d) {
    _startScale = _scale;
    _startOffset = _offset;
    _startFocal = d.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_startScale * d.scale).clamp(0.4, 1.4);
      _offset = _startOffset + (d.focalPoint - _startFocal);
    });
  }

  void _zoom(double delta, Size viewport) {
    final ns = (_scale + delta).clamp(0.4, 1.4);
    final center = Offset(viewport.width / 2, viewport.height / 2);
    final scene = (center - _offset) / _scale;
    setState(() {
      _offset = center - scene * ns;
      _scale = ns;
    });
  }

  void _onCardDragStart(String id) {
    setState(() => _draggingId = id);
  }

  void _onCardDragUpdate(String id, Offset delta) {
    // Scale-compensate: a finger movement of `delta` in screen space equals
    // `delta / scale` in board space.
    final current = _positions[id] ?? Offset.zero;
    setState(() => _positions[id] = current + delta / _scale);
  }

  void _onCardDragEnd() {
    setState(() => _draggingId = null);
  }

  void _onCardTap(String id) {
    if (!_connectMode) return;
    setState(() {
      if (_connectSource == null) {
        _connectSource = id;
      } else if (_connectSource == id) {
        // Tapping the source again cancels the selection.
        _connectSource = null;
      } else {
        _edges.add(_BoardEdge(
          from: _connectSource!,
          to: id,
          label: _relationLabel(_connectSource!, id),
        ));
        _connectSource = null;
      }
    });
  }

  void _exitConnect() {
    setState(() {
      _tool = 0;
      _connectSource = null;
    });
  }

  /// Suggested relation text for a new edge, biased by card content so the
  /// midpoint pill reads sensibly (e.g. "with Maya", "reminder").
  String _relationLabel(String from, String to) {
    final a = _specById(from);
    final b = _specById(to);
    if (a.kind == _CardKind.person || b.kind == _CardKind.person) {
      final person = a.kind == _CardKind.person ? a : b;
      return 'with ${person.title}';
    }
    if (a.kind == _CardKind.voice || b.kind == _CardKind.voice) {
      return 'reminder';
    }
    if (a.kind == _CardKind.book || b.kind == _CardKind.book) {
      return 'to read';
    }
    return 'related';
  }

  _CardSpec _specById(String id) =>
      _boardCards.firstWhere((c) => c.id == id);

  /// Centre of a card in board coordinates, from its live position + size.
  Offset _centerOf(String id) {
    final pos = _positions[id] ?? Offset.zero;
    final size = _specById(id).approxSize;
    return pos + Offset(size.width / 2, size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        // Draw the dragging card last so it floats above its siblings.
        final ordered = [..._boardCards]..sort((a, b) {
            if (a.id == _draggingId) return 1;
            if (b.id == _draggingId) return -1;
            return 0;
          });
        return Stack(
          children: [
            // Board canvas background — goes dark in dark mode.
            Positioned.fill(child: ColoredBox(color: rd.bg)),
            Positioned.fill(
              child: CustomPaint(painter: _DotGridPainter(color: rd.line)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: ClipRect(
                child: Transform.translate(
                  offset: _offset,
                  child: Transform.scale(
                    scale: _scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 1200,
                      height: 1200,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BoardEdgePainter(
                                edges: _edges,
                                centerOf: _centerOf,
                                edgeColor: rd.peri,
                                userColor: rd.navy,
                              ),
                            ),
                          ),
                          // midpoint relation-label pills for user edges
                          for (final e in _edges)
                            _relationPill(rd, e),
                          Positioned(
                            left: 150,
                            top: 250,
                            child: _Frame(),
                          ),
                          for (final c in ordered)
                            Positioned(
                              left: _positions[c.id]!.dx,
                              top: _positions[c.id]!.dy,
                              child: _DraggableCard(
                                spec: c,
                                lifted: _draggingId == c.id,
                                isSource: _connectSource == c.id,
                                connectMode: _connectMode,
                                onPanStart: () => _onCardDragStart(c.id),
                                onPanUpdate: (delta) =>
                                    _onCardDragUpdate(c.id, delta),
                                onPanEnd: _onCardDragEnd,
                                onTap: () => _onCardTap(c.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // right toolbar
            Positioned(
              right: 14,
              top: 118,
              child: _Toolbar(
                selected: _tool,
                onSelect: (i) => setState(() {
                  _tool = i;
                  // Leaving connect-mode drops any pending source.
                  if (i != _connectTool) _connectSource = null;
                }),
              ),
            ),
            // zoom / fit
            Positioned(
              left: 14,
              bottom: 116,
              child: _ZoomChip(
                level: _scale,
                onOut: () => _zoom(-0.15, viewport),
                onIn: () => _zoom(0.15, viewport),
              ),
            ),
            // connect-mode banner (top) — explains the two-tap flow + Done
            if (_connectMode)
              Positioned(
                left: 14,
                right: 14,
                top: 118,
                child: _ConnectBanner(
                  hasSource: _connectSource != null,
                  onDone: _exitConnect,
                ),
              ),
            // Mira suggestion (hidden while connecting to keep the flow clear)
            if (_suggestVisible && !_connectMode)
              Positioned(
                left: 14,
                right: 14,
                bottom: 168,
                child: _SuggestPill(onDismiss: () => setState(() => _suggestVisible = false)),
              ),
          ],
        );
      },
    );
  }

  /// A small pill at the midpoint of a user edge, describing the relation.
  Widget _relationPill(RdTheme rd, _BoardEdge e) {
    final mid = Offset.lerp(_centerOf(e.from), _centerOf(e.to), 0.5)!;
    const w = 96.0;
    const h = 22.0;
    return Positioned(
      left: mid.dx - w / 2,
      top: mid.dy - h / 2,
      child: IgnorePointer(
        child: Container(
          constraints: const BoxConstraints(minWidth: 0, maxWidth: w),
          height: h,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: rd.peri.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF141628).withValues(alpha: 0.12),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            e.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: rd.navy,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a `_BoardCard` with drag + connect-mode interactions. Keeps rotation
/// and applies a "lifted" transform while dragging and a pulsing source
/// highlight while it is the connect source.
class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.spec,
    required this.lifted,
    required this.isSource,
    required this.connectMode,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onTap,
  });

  final _CardSpec spec;
  final bool lifted;
  final bool isSource;
  final bool connectMode;
  final VoidCallback onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onPanStart: (_) => onPanStart(),
      onPanUpdate: (d) => onPanUpdate(d.delta),
      onPanEnd: (_) => onPanEnd(),
      onPanCancel: onPanEnd,
      child: Transform.rotate(
        angle: spec.rotation * math.pi / 180,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: lifted ? 1.05 : 1,
          child: _BoardCard(
            spec: spec,
            lifted: lifted,
            highlighted: isSource,
          ),
        ),
      ),
    );
  }
}

/// Connect-mode banner shown at the top of the board — explains the two-tap
/// flow and offers a Done affordance to exit connect-mode.
class _ConnectBanner extends StatelessWidget {
  const _ConnectBanner({required this.hasSource, required this.onDone});

  final bool hasSource;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: rd.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rd.navy.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const RdIcon(RdIcons.connect,
              size: 18, stroke: '#FFFFFF', strokeWidth: 2),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              hasSource
                  ? 'Now tap another card to connect them'
                  : 'Connect mode · tap two cards to link them',
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDone,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: rd.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});

  /// Dot tint — the theme line colour, passed from the widget so the grid
  /// tracks the active [RdTheme] (painters cannot read `context`).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 22.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

class _BoardEdgePainter extends CustomPainter {
  _BoardEdgePainter({
    this.edges = const [],
    this.centerOf,
    required this.edgeColor,
    required this.userColor,
  });

  /// User-created connections to render as cubic beziers between card centres.
  final List<_BoardEdge> edges;

  /// Resolves a card id to its live centre in board coordinates.
  final Offset Function(String id)? centerOf;

  /// Ambient/decorative edge tint (periwinkle) and the user-edge tint (navy),
  /// passed from the widget so both track the active [RdTheme].
  final Color edgeColor;
  final Color userColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = edgeColor.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    void bez(double ax, double ay, double c1x, double c1y, double c2x,
        double c2y, double bx, double by) {
      final path = Path()
        ..moveTo(ax, ay)
        ..cubicTo(c1x, c1y, c2x, c2y, bx, by);
      canvas.drawPath(path, paint);
    }

    // Ambient, decorative links that give the board its lived-in feel.
    bez(250, 300, 300, 340, 300, 380, 268, 430);
    bez(330, 300, 380, 330, 420, 360, 452, 402);
    bez(300, 470, 360, 500, 400, 520, 452, 470);
    bez(250, 560, 300, 590, 360, 600, 300, 640);

    final dashed = Paint()
      ..style = PaintingStyle.stroke
      ..color = edgeColor.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // dashed bezier, drawn as short segments
    final path = Path()
      ..moveTo(492, 452)
      ..cubicTo(520, 520, 470, 590, 392, 636);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final seg = metric.extractPath(d, d + 2);
        canvas.drawPath(seg, dashed);
        d += 9;
      }
    }

    // User-created connections — solid cubic beziers between the two card
    // centres, gently bowed so multiple edges stay readable.
    final resolve = centerOf;
    if (resolve != null) {
      final userPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = userColor.withValues(alpha: 0.85)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (final e in edges) {
        final a = resolve(e.from);
        final b = resolve(e.to);
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        // Control points offset perpendicular to the line for a soft curve.
        final len = math.sqrt(dx * dx + dy * dy);
        final nx = len == 0 ? 0.0 : -dy / len;
        final ny = len == 0 ? 0.0 : dx / len;
        final bow = (len * 0.16).clamp(10.0, 48.0);
        final c1 = Offset(
          a.dx + dx * 0.33 + nx * bow,
          a.dy + dy * 0.33 + ny * bow,
        );
        final c2 = Offset(
          a.dx + dx * 0.66 + nx * bow,
          a.dy + dy * 0.66 + ny * bow,
        );
        final userPath = Path()
          ..moveTo(a.dx, a.dy)
          ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
        canvas.drawPath(userPath, userPaint);
        // Small endpoint dots to anchor the connection visually.
        final dot = Paint()..color = userColor.withValues(alpha: 0.85);
        canvas.drawCircle(a, 3, dot);
        canvas.drawCircle(b, 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_BoardEdgePainter old) =>
      old.edges != edges ||
      old.centerOf != centerOf ||
      old.edgeColor != edgeColor ||
      old.userColor != userColor;
}

class _Frame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return SizedBox(
      width: 360,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: rd.peri.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: rd.peri.withValues(alpha: 0.28),
                width: 1.5,
              ),
            ),
          ),
          Positioned(
            top: -12,
            right: 18,
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: rd.peri,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RdIcon(RdIcons.pin, size: 12, stroke: '#FFFFFF', strokeWidth: 2),
                  const SizedBox(width: 6),
                  Text(
                    'Spring · the coast',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11.5,
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
    );
  }
}

enum _CardKind { note, photo, voice, link, sticky, book, person }

class _CardSpec {
  const _CardSpec({
    required this.id,
    required this.kind,
    required this.left,
    required this.top,
    required this.rotation,
    this.title = '',
    this.sub,
    this.tag,
  });

  final String id;
  final _CardKind kind;
  final double left;
  final double top;
  final double rotation;
  final String title;
  final String? sub;
  final String? tag;

  /// Approximate rendered size per card kind — used to derive card centres for
  /// connect-mode edges. Widths mirror the layout constants in `_BoardCard`;
  /// heights are eyeballed to the designed content so the bezier endpoints land
  /// roughly on each card's middle.
  Size get approxSize {
    switch (kind) {
      case _CardKind.photo:
        return const Size(158, 150);
      case _CardKind.sticky:
        return const Size(150, 150);
      case _CardKind.person:
        return const Size(128, 64);
      case _CardKind.note:
        return const Size(158, 96);
      case _CardKind.voice:
      case _CardKind.link:
      case _CardKind.book:
        return const Size(158, 92);
    }
  }
}

const _boardCards = <_CardSpec>[
  _CardSpec(id: 'coast', kind: _CardKind.note, left: 170, top: 200, rotation: -2, tag: 'Note', title: 'A quiet weekend on the coast', sub: 'Somewhere slow, near the water — spring.'),
  _CardSpec(id: 'bigsur', kind: _CardKind.photo, left: 360, top: 196, rotation: 2, title: 'Big Sur shoreline'),
  _CardSpec(id: 'flight', kind: _CardKind.voice, left: 180, top: 400, rotation: -1, tag: 'Voice', title: 'Flight SA 482 · Aug 2', sub: 'Check-in reminder set for Aug 1.'),
  _CardSpec(id: 'cabin', kind: _CardKind.link, left: 380, top: 392, rotation: 1.5, tag: 'Link', title: 'Cabin by the water', sub: 'Airbnb — saved to compare.'),
  _CardSpec(id: 'packlist', kind: _CardKind.sticky, left: 190, top: 596, rotation: -2.5, title: 'Pack list'),
  _CardSpec(id: 'book', kind: _CardKind.book, left: 470, top: 560, rotation: 2, tag: 'Book', title: '“The Overstory”', sub: 'Maya’s rec — a weekend read.'),
  _CardSpec(id: 'maya', kind: _CardKind.person, left: 560, top: 452, rotation: -1.5, title: 'Maya', sub: 'joining · maybe'),
];

({Color bg, String stroke}) _tagStyle(String tag) {
  switch (tag) {
    case 'Voice':
      return (bg: const Color(0xFFE7EFEA), stroke: '#2E7D4F');
    case 'Link':
      return (bg: const Color(0xFFFBEFE7), stroke: '#B65A2E');
    case 'Book':
    case 'Note':
    default:
      return (bg: RdColors.periSoft, stroke: '#14328C');
  }
}

String _tagIcon(String tag) {
  switch (tag) {
    case 'Voice':
      return RdIcons.micSimple;
    case 'Link':
      return RdIcons.linkChain;
    case 'Book':
      return RdIcons.book;
    default:
      return RdIcons.pencil;
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({
    required this.spec,
    this.lifted = false,
    this.highlighted = false,
  });

  final _CardSpec spec;

  /// True while the card is being dragged — bigger shadow.
  final bool lifted;

  /// True when the card is the connect-mode source — peri highlight border.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    switch (spec.kind) {
      case _CardKind.sticky:
        return _sticky(rd);
      case _CardKind.person:
        return _person(rd);
      case _CardKind.photo:
        return _photo(rd);
      default:
        return _basic(rd);
    }
  }

  /// Border colour/width picks up the connect-source highlight.
  Border _borderOf(RdTheme rd) => Border.all(
        color: highlighted ? rd.peri : rd.line,
        width: highlighted ? 2 : 1,
      );

  BoxDecoration _shellOf(RdTheme rd) => BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(16),
        border: _borderOf(rd),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628)
                .withValues(alpha: lifted ? 0.42 : 0.28),
            blurRadius: lifted ? 40 : 24,
            spreadRadius: lifted ? -10 : -14,
            offset: Offset(0, lifted ? 20 : 10),
          ),
          if (highlighted)
            BoxShadow(
              color: rd.peri.withValues(alpha: 0.45),
              blurRadius: 0,
              spreadRadius: 3,
            ),
        ],
      );

  Widget _tagPill(String tag) {
    final style = _tagStyle(tag);
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(_tagIcon(tag), size: 11, stroke: style.stroke, strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            tag,
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(int.parse('FF${style.stroke.substring(1)}', radix: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(RdTheme rd) => Text(
        spec.title,
        style: GoogleFonts.vazirmatn(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: rd.ink,
          height: 1.32,
        ),
      );

  Widget _sub(RdTheme rd) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          spec.sub!,
          style: GoogleFonts.vazirmatn(
            fontSize: 11.5,
            color: rd.muted,
            height: 1.4,
          ),
        ),
      );

  Widget _basic(RdTheme rd) {
    return Container(
      width: 158,
      decoration: _shellOf(rd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spec.tag != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 0),
              child: _tagPill(spec.tag!),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _title(rd),
                if (spec.sub != null) _sub(rd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(RdTheme rd) {
    return Container(
      width: 158,
      decoration: _shellOf(rd),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 92,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C5578), Color(0xFF16324F)],
              ),
            ),
            child: Text(
              'Big Sur · saved photo',
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 13),
            child: _title(rd),
          ),
        ],
      ),
    );
  }

  Widget _sticky(RdTheme rd) {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? rd.peri : const Color(0x4DBEA046),
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78641E)
                .withValues(alpha: lifted ? 0.42 : 0.28),
            blurRadius: lifted ? 40 : 24,
            spreadRadius: lifted ? -10 : -14,
            offset: Offset(0, lifted ? 20 : 10),
          ),
          if (highlighted)
            BoxShadow(
              color: rd.peri.withValues(alpha: 0.45),
              blurRadius: 0,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spec.title,
            style: GoogleFonts.vazirmatn(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6A5312),
            ),
          ),
          _chk('Camera', done: true),
          _chk('Warm layers'),
          _chk('The Overstory'),
        ],
      ),
    );
  }

  Widget _chk(String label, {bool done = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: done ? const Color(0xFFC79A2E) : null,
              border: done
                  ? null
                  : Border.all(color: const Color(0x99A08232), width: 1.5),
            ),
            child: done
                ? const Center(
                    child: RdIcon(RdIcons.checkThick,
                        size: 9, stroke: '#FFFFFF', strokeWidth: 3.4),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: const Color(0xFF7A6526),
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _person(RdTheme rd) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(12),
      decoration: _shellOf(rd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.28, -0.4),
                colors: [Color(0xFFAEB9E8), Color(0xFF7482C2)],
              ),
            ),
            child: Center(
              child: Text(
                'M',
                style: GoogleFonts.dosis(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spec.title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                spec.sub!,
                style: GoogleFonts.vazirmatn(fontSize: 11, color: rd.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _tools = [
    RdIcons.move,
    RdIcons.addCard,
    RdIcons.textT,
    RdIcons.connect,
  ];

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628).withValues(alpha: 0.35),
            blurRadius: 26,
            spreadRadius: -12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _tools.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected == i ? rd.navy : Colors.transparent,
                ),
                child: Center(
                  child: RdIcon(
                    _tools[i],
                    size: 20,
                    color: selected == i ? Colors.white : rd.muted,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ZoomChip extends StatelessWidget {
  const _ZoomChip({required this.level, required this.onOut, required this.onIn});

  final double level;
  final VoidCallback onOut;
  final VoidCallback onIn;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: rd.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(rd, '−', onOut),
          SizedBox(
            width: 40,
            child: Text(
              '${(level * 100).round()}%',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rd.muted,
              ),
            ),
          ),
          _btn(rd, '+', onIn),
        ],
      ),
    );
  }

  Widget _btn(RdTheme rd, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: rd.muted,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _SuggestPill extends StatelessWidget {
  const _SuggestPill({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141628).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141628).withValues(alpha: 0.55),
            blurRadius: 40,
            spreadRadius: -16,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.28, -0.4),
                colors: [Color(0xFFAEB9E8), Color(0xFF6472B6)],
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Blue Note',
                    style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(
                    text: ' plays near the coast that same weekend. Add it to this board?',
                  ),
                ],
                style: GoogleFonts.vazirmatn(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rd.navy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: Center(
                child: RdIcon(
                  RdIcons.close,
                  size: 13,
                  stroke: '#FFFFFF',
                  strokeWidth: 2.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
