import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/daily_brief_models.dart';

void main() {
  test('parses daily update API response', () {
    final response = DailyUpdateResponse.fromJson({
      'items': [
        {
          'id': 'node-1',
          'node_type': 'Task',
          'title': 'Send product notes',
          'summary': 'Follow up with Sara',
          'created_at': '2026-06-21T08:30:00Z',
        },
      ],
    });

    expect(response.items, hasLength(1));
    expect(response.items.single.id, 'node-1');
    expect(response.items.single.nodeType, 'Task');
    expect(response.items.single.title, 'Send product notes');
  });

  test('maps backend task and idea nodes into brief cards', () {
    final now = DateTime.now();
    final items = DailyBriefData.fromDailyUpdateItems([
      DailyUpdateItem(
        id: 'task-1',
        nodeType: 'Task',
        title: 'Send product notes',
        summary: 'Follow up with Sara',
        createdAt: now,
      ),
      DailyUpdateItem(
        id: 'idea-1',
        nodeType: 'Idea',
        title: 'Daily graph highlight',
        summary: 'Surface the newest graph connection.',
        createdAt: now,
      ),
    ]);

    expect(items, hasLength(2));
    expect(items.first, isA<BriefTask>());
    expect((items.first as BriefTask).summary, 'Follow up with Sara');
    expect(items.last, isA<BriefNote>());
    expect((items.last as BriefNote).nodeType, 'Idea');
  });

  test('maps image capture resources into image brief cards', () {
    final now = DateTime.now();
    final items = DailyBriefData.fromDailyUpdateItems([
      DailyUpdateItem(
        id: 'img-1',
        nodeType: 'Resource',
        title: 'pricing.png',
        summary: 'Screenshot of pricing notes',
        createdAt: now,
        captureType: 'image',
        thumbnailB64: 'aW1hZ2U=',
      ),
      DailyUpdateItem(
        id: 'idea-1',
        nodeType: 'Idea',
        title: 'Daily graph highlight',
        summary: 'Surface the newest graph connection.',
        createdAt: now,
      ),
    ]);

    expect(items, hasLength(2));
    expect(items.first, isA<BriefImageItem>());
    final image = items.first as BriefImageItem;
    expect(image.nodeType, 'Image');
    expect(image.thumbnailB64, 'aW1hZ2U=');
    expect(image.imageAsset, isNull);
    expect(items.last, isA<BriefNote>());
  });
}
