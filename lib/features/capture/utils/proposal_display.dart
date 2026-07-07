/// Resolves user-facing approval details for legacy and Graph V2 proposals.
class ProposalDisplay {
  const ProposalDisplay({
    required this.title,
    required this.summary,
    required this.nodeType,
    required this.sourceTitle,
    required this.sourceType,
    required this.deadline,
    required this.relatedLabels,
    required this.insightLabels,
  });

  final String title;
  final String summary;
  final String nodeType;
  final String sourceTitle;
  final String sourceType;
  final String deadline;
  final List<String> relatedLabels;
  final List<String> insightLabels;

  bool get hasContent => title.isNotEmpty || summary.isNotEmpty;
  bool get hasSource => sourceTitle.isNotEmpty || sourceType.isNotEmpty;

  bool get needsMoreContext {
    if (!hasSource) return false;
    final normalizedTitle = title.trim().toLowerCase();
    final normalizedSource = sourceTitle.trim().toLowerCase();
    final normalizedSummary = summary.trim().toLowerCase();
    return normalizedSummary.isEmpty ||
        normalizedSummary == normalizedTitle ||
        normalizedSummary == normalizedSource;
  }
}

/// Whether [proposal] uses graph_extraction.v2 without legacy fields.
bool isGraphV2Proposal(Map<String, dynamic> proposal) {
  final schema = proposal['schemaVersion']?.toString();
  if (schema == 'graph_extraction.v2') return true;
  final hasLegacy =
      _nonEmpty(proposal['title']) || _nonEmpty(proposal['summary']);
  if (hasLegacy) return false;
  return proposal['assertions'] is List ||
      proposal['entities'] is List ||
      proposal['mentions'] is List;
}

/// Build display strings for approval UI from any supported proposal shape.
ProposalDisplay resolveProposalDisplay(Map<String, dynamic> proposal) {
  final legacyTitle = proposal['title']?.toString().trim();
  final legacySummary = proposal['summary']?.toString().trim();
  final nodeType =
      proposal['node_type']?.toString() ?? _inferNodeType(proposal);
  final source = _resolveSource(proposal);
  final deadline = _resolveDeadline(proposal);
  final relatedLabels = _collectRelatedLabels(proposal);

  if (_nonEmpty(legacyTitle) || _nonEmpty(legacySummary)) {
    return ProposalDisplay(
      title: legacyTitle ?? 'Memory',
      summary: legacySummary ?? '',
      nodeType: nodeType,
      sourceTitle: source.title,
      sourceType: source.type,
      deadline: deadline,
      relatedLabels: relatedLabels,
      insightLabels: _collectLegacyInsights(proposal),
    );
  }

  if (!isGraphV2Proposal(proposal)) {
    return ProposalDisplay(
      title: 'Memory',
      summary: '',
      nodeType: nodeType,
      sourceTitle: source.title,
      sourceType: source.type,
      deadline: deadline,
      relatedLabels: relatedLabels,
      insightLabels: const [],
    );
  }

  final evidenceTexts = _collectEvidenceTexts(proposal);
  final roleLabels = _collectAssertionRoles(proposal);
  final taskTitles = _collectTaskTitles(proposal);

  String title = evidenceTexts.isNotEmpty
      ? evidenceTexts.first
      : (taskTitles.isNotEmpty ? taskTitles.first : '');

  if (title.isEmpty && roleLabels.isNotEmpty) {
    title = roleLabels.join(' / ');
  }

  String summary = '';
  if (roleLabels.isNotEmpty) {
    final roles = roleLabels.join(' / ');
    if (roles != title) {
      summary = roles;
    }
  }

  if (title.isEmpty) {
    title = 'Memory';
  }

  return ProposalDisplay(
    title: title,
    summary: summary,
    nodeType: nodeType,
    sourceTitle: source.title,
    sourceType: source.type,
    deadline: deadline,
    relatedLabels: relatedLabels,
    insightLabels: [...taskTitles, ...roleLabels, ...evidenceTexts.skip(1)],
  );
}

class _ProposalSource {
  const _ProposalSource({required this.title, required this.type});

  final String title;
  final String type;
}

bool _nonEmpty(Object? value) {
  final text = value?.toString().trim();
  return text != null && text.isNotEmpty;
}

String _inferNodeType(Map<String, dynamic> proposal) {
  final tasks = proposal['tasks'];
  if (tasks is List && tasks.isNotEmpty) return 'Task';
  return 'Note';
}

_ProposalSource _resolveSource(Map<String, dynamic> proposal) {
  final source = proposal['source'];
  final metadata = proposal['metadata'];
  final sourceMap = source is Map ? source : const {};
  final metadataMap = metadata is Map ? metadata : const {};

  final type = _firstText([
    sourceMap['capture_type'],
    proposal['capture_type'],
    sourceMap['type'],
    metadataMap['capture_type'],
  ]);
  final title = _firstText([
    sourceMap['filename'],
    sourceMap['fileName'],
    metadataMap['filename'],
    metadataMap['fileName'],
    sourceMap['url'],
    metadataMap['url'],
    metadataMap['canonical_url'],
    sourceMap['title'],
  ]);

  return _ProposalSource(title: title, type: type);
}

String _resolveDeadline(Map<String, dynamic> proposal) {
  final time = proposal['time'];
  final timeMap = time is Map ? time : const {};
  return _firstText([
    timeMap['resolved'],
    proposal['deadline'],
    timeMap['raw'],
  ]);
}

List<String> _collectLegacyInsights(Map<String, dynamic> proposal) {
  final insights = <String>[];
  final deadline = _resolveDeadline(proposal);
  if (deadline.isNotEmpty) insights.add(deadline);
  return insights;
}

List<String> _collectEvidenceTexts(Map<String, dynamic> proposal) {
  final texts = <String>[];
  final assertions = proposal['assertions'];
  if (assertions is! List) return texts;
  for (final item in assertions) {
    if (item is! Map) continue;
    final text = item['evidenceText']?.toString().trim();
    if (text != null && text.isNotEmpty && !texts.contains(text)) {
      texts.add(text);
    }
  }
  return texts;
}

List<String> _collectAssertionRoles(Map<String, dynamic> proposal) {
  final roles = <String>[];
  final assertions = proposal['assertions'];
  if (assertions is! List) return roles;
  for (final item in assertions) {
    if (item is! Map) continue;
    final role = item['role']?.toString().trim();
    if (role != null && role.isNotEmpty && !roles.contains(role)) {
      roles.add(role);
    }
  }
  return roles;
}

List<String> _collectRelatedLabels(Map<String, dynamic> proposal) {
  final labels = <String>[];
  final related = proposal['related_nodes'];
  if (related is List) {
    for (final item in related) {
      if (item is! Map) continue;
      final title = item['title']?.toString().trim();
      if (title == null || title.isEmpty) continue;
      final type = item['type']?.toString().trim();
      final label = type != null && type.isNotEmpty ? '$type: $title' : title;
      if (!labels.contains(label)) labels.add(label);
    }
  }

  final relationships = proposal['relationships'];
  if (relationships is List) {
    for (final item in relationships) {
      if (item is! Map) continue;
      final target = (item['target_title'] ?? item['target_node_title'])
          ?.toString()
          .trim();
      if (target == null || target.isEmpty) continue;
      final relationship = item['relationship']?.toString().trim();
      final label = relationship != null && relationship.isNotEmpty
          ? '$relationship: $target'
          : target;
      if (!labels.contains(label)) labels.add(label);
    }
  }

  return labels;
}

List<String> _collectTaskTitles(Map<String, dynamic> proposal) {
  final titles = <String>[];
  final tasks = proposal['tasks'];
  if (tasks is! List) return titles;
  for (final item in tasks) {
    if (item is! Map) continue;
    final title = (item['title'] ?? item['text'])?.toString().trim();
    if (title != null && title.isNotEmpty && !titles.contains(title)) {
      titles.add(title);
    }
  }
  return titles;
}

String _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}
