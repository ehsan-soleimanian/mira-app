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
    this.taskId,
    this.calendarEventId,
    this.captureId,
    this.status = 'PENDING',
    this.timezone = 'UTC',
    this.remindText,
    this.lastSentAt,
    this.snoozedUntil,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    done: json['done'] as bool? ?? false,
    remindAt: _parseOptionalDate(json['remind_at']),
    sourceNodeId: json['source_node_id'] as String?,
    taskId: json['task_id'] as String?,
    calendarEventId: json['calendar_event_id'] as String?,
    captureId: json['capture_id'] as String?,
    status: json['status'] as String? ?? 'PENDING',
    timezone: json['timezone'] as String? ?? 'UTC',
    remindText: json['remind_text'] as String?,
    lastSentAt: _parseOptionalDate(json['last_sent_at']),
    snoozedUntil: _parseOptionalDate(json['snoozed_until']),
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );

  final String id;
  final String title;
  final bool done;
  final DateTime? remindAt;
  final String? sourceNodeId;
  final String? taskId;
  final String? calendarEventId;
  final String? captureId;
  final String status;
  final String timezone;
  final String? remindText;
  final DateTime? lastSentAt;
  final DateTime? snoozedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime? get effectiveRemindAt => snoozedUntil ?? remindAt;
}

DateTime? _parseOptionalDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
