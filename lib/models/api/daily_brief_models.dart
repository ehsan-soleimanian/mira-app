/// API models for the redesigned `GET /daily-brief` contract.
class DailyBriefResponse {
  const DailyBriefResponse({
    required this.date,
    required this.state,
    required this.greeting,
    required this.summary,
    required this.sections,
    required this.counts,
  });

  factory DailyBriefResponse.fromJson(Map<String, dynamic> json) {
    final sectionsRaw = json['sections'] as List<dynamic>? ?? const [];
    final countsRaw = json['counts'] as Map<String, dynamic>? ?? const {};
    return DailyBriefResponse(
      date: DateTime.parse(json['date'] as String).toLocal(),
      state: json['state'] as String? ?? 'full',
      greeting: json['greeting'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sections: sectionsRaw
          .whereType<Map<String, dynamic>>()
          .map(DailyBriefSection.fromJson)
          .toList(),
      counts: countsRaw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  final DateTime date;
  final String state;
  final String greeting;
  final String summary;
  final List<DailyBriefSection> sections;
  final Map<String, int> counts;

  DailyBriefSection? section(String id) {
    for (final s in sections) {
      if (s.id == id) return s;
    }
    return null;
  }
}

class DailyBriefSection {
  const DailyBriefSection({
    required this.id,
    required this.title,
    required this.items,
  });

  factory DailyBriefSection.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? const [];
    return DailyBriefSection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: itemsRaw.whereType<Map<String, dynamic>>().toList(),
    );
  }

  final String id;
  final String title;
  final List<Map<String, dynamic>> items;
}

class DailyBriefActionResult {
  const DailyBriefActionResult({
    required this.itemId,
    required this.action,
    this.snoozedUntil,
  });

  factory DailyBriefActionResult.fromJson(Map<String, dynamic> json) =>
      DailyBriefActionResult(
        itemId: json['itemId'] as String? ?? json['item_id'] as String? ?? '',
        action: json['action'] as String? ?? '',
        snoozedUntil: json['snoozedUntil'] != null || json['snoozed_until'] != null
            ? DateTime.tryParse(
                (json['snoozedUntil'] ?? json['snoozed_until']) as String,
              )?.toLocal()
            : null,
      );

  final String itemId;
  final String action;
  final DateTime? snoozedUntil;
}
