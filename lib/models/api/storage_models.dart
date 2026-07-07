/// API models for storage usage returned by `GET /storage/usage`.
///
/// The backend reports the account's total used bytes, the plan quota, and a
/// per-category breakdown. Six categories are always present
/// (photos / voice / screenshots / notes / links / other), so the screen can
/// render a stable list without guarding for missing types.
class StorageUsage {
  const StorageUsage({
    required this.usedBytes,
    required this.quotaBytes,
    required this.categories,
  });

  factory StorageUsage.fromJson(Map<String, dynamic> json) => StorageUsage(
        usedBytes: _toInt(json['usedBytes']),
        quotaBytes: _toInt(json['quotaBytes']),
        categories: (json['categories'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StorageCategory.fromJson)
            .toList(),
      );

  /// Total bytes the account is currently using across all categories.
  final int usedBytes;

  /// Plan quota in bytes. Zero when the backend reports no cap.
  final int quotaBytes;

  /// Per-category breakdown, in the order the backend returned them.
  final List<StorageCategory> categories;

  /// Fraction of quota consumed in `0.0..1.0`; 0 when there is no quota.
  double get fraction {
    if (quotaBytes <= 0) return 0;
    return (usedBytes / quotaBytes).clamp(0.0, 1.0);
  }
}

/// One row of the storage breakdown: a category [type] plus how many items it
/// holds and the bytes they occupy.
class StorageCategory {
  const StorageCategory({
    required this.type,
    required this.count,
    required this.bytes,
  });

  factory StorageCategory.fromJson(Map<String, dynamic> json) =>
      StorageCategory(
        type: json['type'] as String? ?? 'other',
        count: _toInt(json['count']),
        bytes: _toInt(json['bytes']),
      );

  /// One of: photos, voice, screenshots, notes, links, other.
  final String type;

  /// Number of items in this category.
  final int count;

  /// Bytes consumed by this category.
  final int bytes;
}

/// Coerces a JSON number (int or double, possibly null) to a non-negative int.
int _toInt(Object? value) {
  if (value is int) return value < 0 ? 0 : value;
  if (value is num) {
    final n = value.toInt();
    return n < 0 ? 0 : n;
  }
  return 0;
}
