import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/collection_models.dart';

void main() {
  test('MemoryCollection parses a list payload', () {
    final c = MemoryCollection.fromJson({
      'id': 'c1',
      'name': 'Coast trip',
      'icon': 'beach',
      'item_count': 14,
      'created_at': '2026-07-01T10:00:00Z',
      'updated_at': '2026-07-02T11:00:00Z',
    });
    expect(c.id, 'c1');
    expect(c.name, 'Coast trip');
    expect(c.icon, 'beach');
    expect(c.itemCount, 14);
  });

  test('MemoryCollection defaults a missing icon and count', () {
    final c = MemoryCollection.fromJson({
      'id': 'c2',
      'name': 'Work',
      'icon': null,
      'created_at': '2026-07-01T10:00:00Z',
      'updated_at': '2026-07-01T10:00:00Z',
    });
    expect(c.icon, isNull);
    expect(c.itemCount, 0);
  });

  test('MemoryCollectionDetail parses member ids', () {
    final d = MemoryCollectionDetail.fromJson({
      'id': 'c3',
      'name': 'People',
      'icon': 'people',
      'item_count': 2,
      'created_at': '2026-07-01T10:00:00Z',
      'updated_at': '2026-07-01T10:00:00Z',
      'memory_ids': ['mem-a', 'mem-b'],
    });
    expect(d.memoryIds, ['mem-a', 'mem-b']);
    expect(d.itemCount, 2);
    expect(d.name, 'People');
  });
}
