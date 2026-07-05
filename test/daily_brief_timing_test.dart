import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/daily_brief_models.dart';

void main() {
  test('task cards prefer dueAt over createdAt for time labels', () {
    final response = DailyUpdateResponse.fromJson({
      'items': [
        {
          'id': 'task_1',
          'node_type': 'Task',
          'title': 'Visit Salar',
          'summary': 'Visit Salar',
          'created_at': '2026-07-05T03:04:00+03:30',
          'due_at': '2026-07-06T17:00:00+03:30',
          'due_precision': 'datetime',
        },
      ],
    });

    final task = DailyBriefData.fromDailyUpdateItems(response.items).single;

    expect(task, isA<BriefTask>());
    final briefTask = task as BriefTask;
    expect(briefTask.dueAt, isNotNull);
    expect(briefTask.timeLabel, contains('5:00 P.M'));
  });
}
