import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/calendar_models.dart';

void main() {
  test('parses calendar occurrence and preserves operational fields', () {
    final occurrence = CalendarOccurrence.fromJson({
      'occurrence_id': 'event-1:20260730T100000+0330',
      'starts_at': '2026-07-30T06:30:00Z',
      'ends_at': '2026-07-30T07:30:00Z',
      'event': {
        'id': 'event-1',
        'title': 'جلسه محصول',
        'description': null,
        'starts_at': '2026-07-30T06:30:00Z',
        'ends_at': '2026-07-30T07:30:00Z',
        'timezone': 'Asia/Tehran',
        'all_day': false,
        'status': 'SCHEDULED',
        'location': 'اتاق آبی',
        'attendees': ['سارا', 'رضا'],
        'recurrence_rule': 'FREQ=WEEKLY',
        'excluded_dates': ['2026-08-06'],
        'source': 'capture',
        'capture_id': 'capture-1',
        'revision': 2,
        'created_at': '2026-07-29T10:00:00Z',
        'updated_at': '2026-07-29T10:00:00Z',
      },
    });

    expect(occurrence.event.title, 'جلسه محصول');
    expect(occurrence.event.timezone, 'Asia/Tehran');
    expect(occurrence.event.attendees, ['سارا', 'رضا']);
    expect(occurrence.event.recurrenceRule, 'FREQ=WEEKLY');
    expect(occurrence.event.revision, 2);
    expect(occurrence.startsAt.isUtc, isFalse);
  });
}
