class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.timezone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.endsAt,
    this.allDay = false,
    this.location,
    this.attendees = const [],
    this.recurrenceRule,
    this.excludedDates = const [],
    this.source = 'manual',
    this.captureId,
    this.revision = 1,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
    endsAt: _optionalDate(json['ends_at']),
    timezone: json['timezone'] as String? ?? 'UTC',
    allDay: json['all_day'] as bool? ?? false,
    status: json['status'] as String? ?? 'SCHEDULED',
    location: json['location'] as String?,
    attendees: (json['attendees'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
    recurrenceRule: json['recurrence_rule'] as String?,
    excludedDates: (json['excluded_dates'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
    source: json['source'] as String? ?? 'manual',
    captureId: json['capture_id'] as String?,
    revision: json['revision'] as int? ?? 1,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );

  final String id;
  final String title;
  final String? description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String timezone;
  final bool allDay;
  final String status;
  final String? location;
  final List<String> attendees;
  final String? recurrenceRule;
  final List<String> excludedDates;
  final String source;
  final String? captureId;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CalendarOccurrence {
  const CalendarOccurrence({
    required this.occurrenceId,
    required this.event,
    required this.startsAt,
    this.endsAt,
  });

  factory CalendarOccurrence.fromJson(Map<String, dynamic> json) =>
      CalendarOccurrence(
        occurrenceId: json['occurrence_id'] as String,
        event: CalendarEvent.fromJson(json['event'] as Map<String, dynamic>),
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        endsAt: _optionalDate(json['ends_at']),
      );

  final String occurrenceId;
  final CalendarEvent event;
  final DateTime startsAt;
  final DateTime? endsAt;
}

DateTime? _optionalDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
