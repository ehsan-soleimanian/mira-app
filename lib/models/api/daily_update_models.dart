class DailyUpdateResponse {
  const DailyUpdateResponse({required this.items});

  factory DailyUpdateResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return DailyUpdateResponse(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(DailyUpdateItem.fromJson)
          .toList(),
    );
  }

  final List<DailyUpdateItem> items;
}

class DailyUpdateItem {
  const DailyUpdateItem({
    required this.id,
    required this.nodeType,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.captureType,
    this.thumbnailB64,
  });

  factory DailyUpdateItem.fromJson(Map<String, dynamic> json) =>
      DailyUpdateItem(
        id: json['id'] as String,
        nodeType: json['node_type'] as String,
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        captureType: json['capture_type'] as String?,
        thumbnailB64: json['thumbnail_b64'] as String?,
      );

  final String id;
  final String nodeType;
  final String title;
  final String summary;
  final DateTime createdAt;
  final String? captureType;
  final String? thumbnailB64;
}
