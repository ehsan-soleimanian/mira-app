/// API models for the backend `/collections` endpoints — user-curated groupings
/// of memories (e.g. "People", "Coast trip", "Work"). Membership references
/// memories by their opaque library-item id.
class MemoryCollection {
  const MemoryCollection({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
  });

  factory MemoryCollection.fromJson(Map<String, dynamic> json) => MemoryCollection(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  final String id;
  final String name;
  final String? icon;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// A collection plus the ids of the memories it holds (from `GET /collections/{id}`).
class MemoryCollectionDetail extends MemoryCollection {
  const MemoryCollectionDetail({
    required super.id,
    required super.name,
    required super.itemCount,
    required super.createdAt,
    required super.updatedAt,
    required this.memoryIds,
    super.icon,
  });

  factory MemoryCollectionDetail.fromJson(Map<String, dynamic> json) =>
      MemoryCollectionDetail(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
        memoryIds: ((json['memory_ids'] as List<dynamic>?) ?? const [])
            .whereType<String>()
            .toList(),
      );

  final List<String> memoryIds;
}
