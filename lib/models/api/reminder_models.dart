/// API model for a reminder returned by the backend `/reminders` endpoints.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
    required this.updatedAt,
    this.remindAt,
    this.sourceNodeId,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        done: json['done'] as bool? ?? false,
        remindAt: _parseOptionalDate(json['remind_at']),
        sourceNodeId: json['source_node_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  final String id;
  final String title;
  final bool done;
  final DateTime? remindAt;
  final String? sourceNodeId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

DateTime? _parseOptionalDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
