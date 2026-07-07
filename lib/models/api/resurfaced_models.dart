/// API model for a single "Mira resurfaced" item returned by `GET /v2/resurfaced`.
///
/// The backend brings back a memory (task, note, event, …) that is about to
/// matter, along with a short human [reason] explaining why it surfaced now.
/// [date] and [type] are optional — the backend sends them as `null` when it
/// has nothing to attach.
class ResurfacedItem {
  const ResurfacedItem({
    required this.id,
    required this.title,
    required this.reason,
    this.date,
    this.type,
  });

  factory ResurfacedItem.fromJson(Map<String, dynamic> json) => ResurfacedItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        date: _parseOptionalDate(json['date']),
        type: json['type'] as String?,
      );

  final String id;
  final String title;
  final String reason;
  final DateTime? date;
  final String? type;
}

/// Envelope for `GET /v2/resurfaced` — a `count` plus the `items` list.
class ResurfacedResponse {
  const ResurfacedResponse({required this.count, required this.items});

  factory ResurfacedResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(ResurfacedItem.fromJson)
        .toList();
    return ResurfacedResponse(
      count: json['count'] as int? ?? items.length,
      items: items,
    );
  }

  final int count;
  final List<ResurfacedItem> items;
}

DateTime? _parseOptionalDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
