import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/daily_brief_models.dart';
import 'package:mira_app/models/api/resurfaced_models.dart';

void main() {
  test('daily brief parses complete list highlights and item summaries', () {
    final response = DailyBriefResponse.fromJson({
      'date': '2026-08-03T08:00:00Z',
      'state': 'full',
      'greeting': 'Good morning',
      'summary': 'Today’s important items are listed below.',
      'highlights': [
        'Review the release checklist before noon.',
        'The product meeting starts at 14:30.',
      ],
      'counts': {'tasks': 1},
      'sections': [
        {
          'id': 'needs_you',
          'title': 'Needs you',
          'items': [
            {
              'id': 'task-1',
              'title': 'Review the release checklist',
              'summary': 'Review the release checklist — due before noon.',
            },
          ],
        },
      ],
    });

    expect(response.highlights, hasLength(2));
    expect(response.highlights.first, endsWith('.'));
    expect(
      response.section('needs_you')!.items.single['summary'],
      'Review the release checklist — due before noon.',
    );
  });

  test('resurfaced memory keeps its complete summary', () {
    final item = ResurfacedItem.fromJson({
      'id': 'memory-1',
      'title': 'Release plan',
      'summary':
          'Sara will review the final release before it reaches the customer.',
      'reason': 'Recent memory',
    });

    expect(
      item.summary,
      'Sara will review the final release before it reaches the customer.',
    );
  });
}
