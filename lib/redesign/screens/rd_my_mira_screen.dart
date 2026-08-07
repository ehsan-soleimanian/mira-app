import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/graph_models.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import '../theme/rd_typography.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// A transparent, editable view of the personal model Mira is building.
///
/// The screen intentionally separates three concerns: model coverage, new
/// assertions awaiting review, and accepted knowledge. Live mode is backed by
/// the knowledge graph; preview mode exists only for visual QA and tests.
class RdMyMiraScreen extends StatefulWidget {
  const RdMyMiraScreen({super.key, required this.go, this.live = true});

  final RdGo go;
  final bool live;

  @override
  State<RdMyMiraScreen> createState() => _RdMyMiraScreenState();
}

class _RdMyMiraScreenState extends State<RdMyMiraScreen> {
  List<_MiraFact> _goals = const [];
  List<_MiraFact> _people = const [];
  List<_MiraFact> _preferences = const [];
  _MiraFact? _review;
  bool _loading = true;
  bool _busy = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (widget.live) {
      _load();
    } else {
      _loadPreview();
    }
  }

  void _loadPreview() {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime(2026, 8, 7);
    setState(() {
      _goals = [
        _MiraFact(
          id: 'preview-goal',
          kind: _FactKind.goal,
          title: l10n.rdMyMiraCurrentGoal,
          body: l10n.rdMyMiraPreviewGoal,
          createdAt: today,
        ),
      ];
      _people = [
        _MiraFact(
          id: 'preview-person',
          kind: _FactKind.person,
          title: l10n.rdMyMiraImportantPerson,
          body: l10n.rdMyMiraPreviewPerson,
          createdAt: DateTime(2026, 7, 21),
        ),
      ];
      _preferences = [
        _MiraFact(
          id: 'preview-preference',
          kind: _FactKind.preference,
          title: l10n.rdMyMiraWorkingPreference,
          body: l10n.rdMyMiraPreviewPreference,
          createdAt: DateTime(2026, 7, 15),
        ),
      ];
      _review = _MiraFact(
        id: 'preview-review',
        kind: _FactKind.goal,
        title: l10n.rdMyMiraPreviewLearning,
        body: l10n.rdMyMiraPreviewLearning,
        createdAt: today,
        confidence: .84,
        pending: true,
      );
      _loading = false;
    });
  }

  Future<void> _load() async {
    try {
      final response = await AppScope.servicesOf(
        context,
      ).graphRepository.fetchGraph(view: GraphViewMode.knowledge);
      final goals = <_MiraFact>[];
      final people = <_MiraFact>[];
      final preferences = <_MiraFact>[];
      final pending = <_MiraFact>[];

      for (final node in response.nodes) {
        final kind = _kindOf(node);
        if (kind == null) continue;
        final fact = _factFromNode(node, kind, response.edges);
        switch (kind) {
          case _FactKind.goal:
            goals.add(fact);
          case _FactKind.person:
            people.add(fact);
          case _FactKind.preference:
            preferences.add(fact);
        }
        if (_isPendingAssertion(node)) {
          pending.add(fact.copyWith(pending: true));
        }
      }

      if (!mounted) return;
      setState(() {
        _goals = _sorted(goals);
        _people = _sorted(people);
        _preferences = _sorted(preferences);
        _review = _sorted(pending).firstOrNull;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static List<_MiraFact> _sorted(List<_MiraFact> facts) {
    return [...facts]..sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
  }

  static _FactKind? _kindOf(GraphNode node) {
    final blob = [
      node.kind,
      node.nodeType,
      node.entityType,
      ...node.labels,
    ].whereType<String>().join(' ').toLowerCase();
    if (blob.contains('preference') || blob.contains('working_style')) {
      return _FactKind.preference;
    }
    if (blob.contains('person') || blob.contains('human')) {
      return _FactKind.person;
    }
    if (blob.contains('task') || blob.contains('goal')) {
      return _FactKind.goal;
    }
    return null;
  }

  static bool _isPendingAssertion(GraphNode node) {
    if (node.kind.toLowerCase() != 'assertion') return false;
    final status = (node.status ?? '').toLowerCase();
    return status.isEmpty ||
        status.contains('pending') ||
        status.contains('proposed') ||
        status.contains('review');
  }

  static _MiraFact _factFromNode(
    GraphNode node,
    _FactKind kind,
    List<GraphEdge> edges,
  ) {
    double? confidence;
    for (final edge in edges) {
      if (edge.sourceId == node.id || edge.targetId == node.id) {
        if (edge.confidence != null &&
            (confidence == null || edge.confidence! > confidence)) {
          confidence = edge.confidence;
        }
      }
    }
    final body = node.summary.trim().isNotEmpty
        ? node.summary.trim()
        : node.displayTitle.trim();
    return _MiraFact(
      id: node.id,
      kind: kind,
      title: node.displayTitle.trim(),
      body: body,
      captureId: node.captureId,
      createdAt: node.createdAt,
      confidence: confidence,
    );
  }

  List<_MiraFact> get _known => [
    ..._goals.take(1),
    ..._people.take(1),
    ..._preferences.take(1),
  ];

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message, style: GoogleFonts.vazirmatn(fontSize: 13)),
        ),
      );
  }

  Future<void> _confirmLearning() async {
    final fact = _review;
    if (fact == null || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      if (widget.live) {
        await AppScope.servicesOf(
          context,
        ).graphRepository.acceptAssertion(fact.id);
      }
      if (!mounted) return;
      setState(() {
        _review = null;
        _busy = false;
      });
      _toast(l10n.rdMyMiraConfirmedToast);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(l10n.rdMyMiraUpdateFailed);
    }
  }

  Future<void> _correctLearning() async {
    final fact = _review;
    if (fact == null || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: fact.body);
    final corrected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rdMyMiraCorrectTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(hintText: l10n.rdMyMiraCorrectHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.rdCommonCancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.rdCommonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (corrected == null || !mounted) return;

    if (!widget.live) {
      setState(
        () => _review = fact.copyWith(body: corrected, title: corrected),
      );
      _toast(l10n.rdMyMiraCorrectedToast);
      return;
    }

    if (fact.captureId == null) {
      widget.go(
        'captureflow',
        arg: RdCaptureModeArg(
          RdCaptureMode.type,
          initialText: corrected,
          returnScreen: 'myMira',
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await AppScope.servicesOf(
        context,
      ).graphRepository.correctCapture(fact.captureId!, corrected);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _review = null;
      });
      _toast(l10n.rdMyMiraCorrectedToast);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(l10n.rdMyMiraUpdateFailed);
    }
  }

  void _openFact(_MiraFact fact) {
    if (fact.captureId == null) return;
    widget.go(
      'memory',
      arg: RdMemoryArg(id: fact.captureId, title: fact.title, body: fact.body),
    );
  }

  void _showAgency() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.rdMyMiraAgencyTitle, style: RdText.title),
              const SizedBox(height: 10),
              Text(
                l10n.rdMyMiraAgencyDetail,
                style: RdText.itemTitle.copyWith(color: context.rd.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.go('account');
                  },
                  child: Text(l10n.rdCommonSettings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _content(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RdBottomNav(active: 'myMira', go: widget.go),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(l10n),
        const SizedBox(height: 14),
        _statusCard(l10n),
        if (_loading) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (_review != null) ...[
          const SizedBox(height: 20),
          _sectionTitle(l10n.rdMyMiraNewLearning),
          const SizedBox(height: 9),
          _reviewCard(l10n, _review!),
        ],
        const SizedBox(height: 8),
        _sectionTitle(l10n.rdMyMiraKnowsTitle),
        const SizedBox(height: 9),
        _knowledgeCard(l10n),
        const SizedBox(height: 8),
        _agencyCard(l10n),
      ],
    );
  }

  Widget _hero(AppLocalizations l10n) {
    final rd = context.rd;
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Semantics(
              label: l10n.rdCommonSettings,
              button: true,
              child: InkResponse(
                key: const ValueKey('rd-my-mira-settings'),
                onTap: () => widget.go('account'),
                radius: 30,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: rd.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: rd.line),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 18,
                        spreadRadius: -8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: RdIcon(
                      RdIcons.gear,
                      size: 22,
                      color: rd.gearIcon,
                      strokeWidth: 1.7,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const RdOrb(size: 70),
                const SizedBox(width: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.rdMyMiraHeroTitle,
                          style:
                              (isPersian
                                      ? GoogleFonts.vazirmatn()
                                      : GoogleFonts.inter())
                                  .copyWith(
                                    color: rd.navy,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    height: 1.14,
                                    letterSpacing: -.35,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.rdMyMiraHeroSubtitle,
                          style:
                              (isPersian
                                      ? GoogleFonts.vazirmatn()
                                      : GoogleFonts.inter())
                                  .copyWith(
                                    color: rd.muted,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                        ),
                      ],
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

  Widget _statusCard(AppLocalizations l10n) {
    final entries = [
      (_FactKind.goal, l10n.rdMyMiraGoals, _goals.isNotEmpty),
      (_FactKind.person, l10n.rdMyMiraPeople, _people.isNotEmpty),
      (_FactKind.preference, l10n.rdMyMiraPreferences, _preferences.isNotEmpty),
    ];
    return _Card(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.rdMyMiraModelStatus,
                style: RdText.itemTitle.copyWith(color: context.rd.muted),
              ),
              const SizedBox(width: 6),
              Icon(Icons.info_outline, size: 15, color: context.rd.faint),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  Container(width: 1, height: 38, color: context.rd.line),
                Expanded(
                  child: _StatusItem(
                    kind: entries[i].$1,
                    label: entries[i].$2,
                    status: entries[i].$3
                        ? l10n.rdMyMiraUpToDate
                        : l10n.rdMyMiraLearning,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 4),
    child: Text(
      title,
      style: RdText.itemTitle.copyWith(
        color: context.rd.faint,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );

  Widget _reviewCard(AppLocalizations l10n, _MiraFact fact) {
    final rd = context.rd;
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FactIcon(kind: fact.kind, featured: true),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fact.body,
                  style: RdText.itemTitle.copyWith(
                    color: rd.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 50),
            child: Wrap(
              spacing: 5,
              runSpacing: 6,
              children: [
                _Meta(text: l10n.rdMyMiraFromConversation),
                if (fact.createdAt != null) _Meta(text: _date(fact.createdAt!)),
                if (fact.confidence != null)
                  _Meta(
                    text: l10n.rdMyMiraConfidence(
                      (fact.confidence! * 100).round(),
                    ),
                    accent: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('rd-my-mira-correct'),
                  onPressed: _busy ? null : _correctLearning,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    side: BorderSide(color: rd.navy, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.rdMyMiraCorrect),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: const ValueKey('rd-my-mira-confirm'),
                  onPressed: _busy ? null : _confirmLearning,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    backgroundColor: rd.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.rdMyMiraConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _knowledgeCard(AppLocalizations l10n) {
    if (!_loading && _known.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const RdOrb(size: 44, ring: false),
            const SizedBox(height: 14),
            Text(
              l10n.rdMyMiraEmptyTitle,
              style: RdText.itemTitle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.rdMyMiraEmptyBody,
              textAlign: TextAlign.center,
              style: RdText.meta.copyWith(color: context.rd.muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: () => widget.go('capture'),
              child: Text(l10n.rdMyMiraTeachMira),
            ),
          ],
        ),
      );
    }
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _known.length; i++) ...[
            _KnowledgeRow(
              fact: _known[i],
              source: l10n.rdMyMiraFromConversation,
              date: _known[i].createdAt == null
                  ? null
                  : _date(_known[i].createdAt!),
              onTap: _known[i].captureId == null
                  ? null
                  : () => _openFact(_known[i]),
            ),
            if (i < _known.length - 1)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 72, end: 18),
                child: Divider(height: 1, color: context.rd.line),
              ),
          ],
          Divider(height: 1, color: context.rd.line),
          InkWell(
            key: const ValueKey('rd-my-mira-view-all'),
            onTap: () => widget.go('canvas', arg: const RdCanvasArg('map')),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.rdMyMiraViewAll,
                    style: RdText.seeAll.copyWith(
                      color: context.rd.navy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Transform.rotate(
                    angle: 3.14159,
                    child: RdIcon(
                      RdIcons.chevronLeft,
                      size: 16,
                      color: context.rd.navy,
                      strokeWidth: 2,
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

  Widget _agencyCard(AppLocalizations l10n) => _Card(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
    child: Row(
      children: [
        const _FactIcon(kind: _FactKind.preference, size: 34, shield: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rdMyMiraAgencyTitle,
                style: RdText.itemTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.rdMyMiraAgencyBody,
                style: RdText.itemTitle.copyWith(
                  color: context.rd.muted,
                  fontSize: 10.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          key: const ValueKey('rd-my-mira-agency'),
          onPressed: _showAgency,
          child: Text(l10n.rdMyMiraReview),
        ),
      ],
    ),
  );

  String _date(DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(date);
  }
}

enum _FactKind { goal, person, preference }

class _MiraFact {
  const _MiraFact({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.captureId,
    this.createdAt,
    this.confidence,
    this.pending = false,
  });

  final String id;
  final _FactKind kind;
  final String title;
  final String body;
  final String? captureId;
  final DateTime? createdAt;
  final double? confidence;
  final bool pending;

  _MiraFact copyWith({String? title, String? body, bool? pending}) => _MiraFact(
    id: id,
    kind: kind,
    title: title ?? this.title,
    body: body ?? this.body,
    captureId: captureId,
    createdAt: createdAt,
    confidence: confidence,
    pending: pending ?? this.pending,
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rd.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 24,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.kind,
    required this.label,
    required this.status,
  });

  final _FactKind kind;
  final String label;
  final String status;

  TextStyle _labelStyle(BuildContext context, {double size = 9.5}) =>
      RdText.meta.copyWith(
        color: context.rd.ink,
        fontWeight: FontWeight.w700,
        fontSize: size,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 96) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FactIcon(kind: kind, size: 30),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: _labelStyle(context, size: 9.5),
            ),
            Text(
              status,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: RdText.meta.copyWith(fontSize: 8.5),
            ),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FactIcon(kind: kind, size: 30),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _labelStyle(context),
                ),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RdText.meta.copyWith(fontSize: 8.5),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _FactIcon extends StatelessWidget {
  const _FactIcon({
    required this.kind,
    this.size = 46,
    this.featured = false,
    this.shield = false,
  });

  final _FactKind kind;
  final double size;
  final bool featured;
  final bool shield;

  IconData get _icon {
    if (shield) return Icons.shield_outlined;
    return switch (kind) {
      _FactKind.goal => featured ? Icons.auto_awesome : Icons.track_changes,
      _FactKind.person => Icons.person_outline,
      _FactKind.preference => Icons.tune,
    };
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.rd.periSoft,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(_icon, size: size * .46, color: context.rd.peri),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.text, this.accent = false});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: RdText.meta.copyWith(
      color: accent ? context.rd.navy : context.rd.muted,
      fontWeight: accent ? FontWeight.w700 : FontWeight.w400,
      fontSize: 10.5,
    ),
  );
}

class _KnowledgeRow extends StatelessWidget {
  const _KnowledgeRow({
    required this.fact,
    required this.source,
    required this.date,
    required this.onTap,
  });

  final _MiraFact fact;
  final String source;
  final String? date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactIcon(kind: fact.kind, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RdText.itemTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: MediaQuery.sizeOf(context).width >= 360
                        ? 12.5
                        : 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fact.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (Localizations.localeOf(context).languageCode == 'fa'
                              ? GoogleFonts.vazirmatn()
                              : GoogleFonts.inter())
                          .copyWith(
                            color: context.rd.muted,
                            fontSize: 9.8,
                            height: 1.35,
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MediaQuery.sizeOf(context).width >= 360 ? 92 : 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RdText.meta.copyWith(fontSize: 10),
                ),
                if (date != null) ...[
                  const SizedBox(height: 3),
                  Text(date!, style: RdText.meta.copyWith(fontSize: 10)),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
