/// Resolves user-facing title/summary for legacy and Graph V2 capture proposals.
class ProposalDisplay {
  const ProposalDisplay({
    required this.title,
    required this.summary,
    required this.nodeType,
  });

  final String title;
  final String summary;
  final String nodeType;

  bool get hasContent => title.isNotEmpty || summary.isNotEmpty;
}

/// Whether [proposal] uses graph_extraction.v2 (or equivalent) without legacy fields.
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
  final nodeType = proposal['node_type']?.toString() ?? _inferNodeType(proposal);

  if (_nonEmpty(legacyTitle) || _nonEmpty(legacySummary)) {
    return ProposalDisplay(
      title: legacyTitle ?? 'Memory',
      summary: legacySummary ?? '',
      nodeType: nodeType,
    );
  }

  if (!isGraphV2Proposal(proposal)) {
    return ProposalDisplay(title: 'Memory', summary: '', nodeType: nodeType);
  }

  final evidenceTexts = _collectEvidenceTexts(proposal);
  final roleLabels = _collectAssertionRoles(proposal);
  final taskTitles = _collectTaskTitles(proposal);

  String title = evidenceTexts.isNotEmpty
      ? evidenceTexts.first
      : (taskTitles.isNotEmpty ? taskTitles.first : '');

  if (title.isEmpty && roleLabels.isNotEmpty) {
    title = roleLabels.join(' · ');
  }

  String summary = '';
  if (roleLabels.isNotEmpty) {
    final roles = roleLabels.join(' · ');
    if (roles != title) {
      summary = roles;
    }
  }

  if (title.isEmpty) {
    title = 'Memory';
  }

  return ProposalDisplay(title: title, summary: summary, nodeType: nodeType);
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
