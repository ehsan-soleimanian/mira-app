import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/redesign/models/rd_library_item_presentation.dart';

void main() {
  test('maps the twelve stable Library presentation kinds', () {
    const values = <String, RdLibraryItemKind>{
      'task': RdLibraryItemKind.task,
      'event': RdLibraryItemKind.event,
      'reminder': RdLibraryItemKind.reminder,
      'meeting': RdLibraryItemKind.meeting,
      'meeting_result': RdLibraryItemKind.meetingResult,
      'screenshot': RdLibraryItemKind.screenshot,
      'note': RdLibraryItemKind.note,
      'document': RdLibraryItemKind.document,
      'summary': RdLibraryItemKind.summary,
      'voice': RdLibraryItemKind.voice,
      'link': RdLibraryItemKind.link,
      'person': RdLibraryItemKind.person,
    };

    for (final entry in values.entries) {
      expect(rdLibraryItemKindFromValue(entry.key), entry.value);
    }
  });

  test('versioned capture contract overrides a legacy generic item type', () {
    final item = LibraryItem.fromJson({
      'id': 'lib-1',
      'type': 'note',
      'title': 'Design review',
      'summary': 'The team agreed on the new flow.',
      'source': 'capture:live_meeting',
      'extractionStatus': 'ready',
      'metadata': {
        'capture_contract': {
          'schemaVersion': 'library_capture.v1',
          'inputKind': 'live_meeting',
          'contentKinds': ['meeting_result'],
          'displayKind': 'meeting_result',
        },
      },
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
    });

    expect(rdLibraryItemKindFor(item), RdLibraryItemKind.meetingResult);
  });

  test('keeps rolling-deployment aliases readable', () {
    expect(
      rdLibraryItemKindFromValue('camera_scan'),
      RdLibraryItemKind.document,
    );
    expect(rdLibraryItemKindFromValue('contact'), RdLibraryItemKind.person);
    expect(rdLibraryItemKindFromValue('audio'), RdLibraryItemKind.voice);
    expect(rdLibraryItemKindFromValue('decision'), RdLibraryItemKind.note);
  });
}
