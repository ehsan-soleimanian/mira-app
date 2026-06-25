import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/graph_models.dart';

void main() {
  group('GraphTaskDto', () {
    test('parses camelCase API payload', () {
      final dto = GraphTaskDto.fromJson({
        'taskId': 'task_1',
        'title': 'Call Alex',
        'actionType': 'CALL',
        'status': 'OPEN',
        'captureId': 'cap_1',
      });
      expect(dto.taskId, 'task_1');
      expect(dto.title, 'Call Alex');
      expect(dto.status, 'OPEN');
      expect(dto.captureId, 'cap_1');
    });

    test('parses snake_case fallback', () {
      final dto = GraphTaskDto.fromJson({
        'task_id': 'task_2',
        'title': 'Send deck',
        'action_type': 'SEND',
        'status': 'DONE',
        'capture_id': 'cap_2',
      });
      expect(dto.taskId, 'task_2');
      expect(dto.status, 'DONE');
    });
  });

  group('ArchiveCaptureResponse', () {
    test('parses archive counts', () {
      final res = ArchiveCaptureResponse.fromJson({
        'archived': true,
        'captureId': 'cap_old',
        'assertionsRejected': 2,
        'tasksCancelled': 1,
        'edgesDemoted': 3,
      });
      expect(res.archived, isTrue);
      expect(res.captureId, 'cap_old');
      expect(res.assertionsRejected, 2);
      expect(res.tasksCancelled, 1);
      expect(res.edgesDemoted, 3);
    });
  });
}
