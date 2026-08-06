import 'package:mira_app/models/api/workspace_models.dart';

/// Stable visual taxonomy shared by Library filters, cards, and Canvas export.
///
/// Backend `library_capture.v1` metadata is authoritative when present. The
/// legacy aliases keep rolling deployments and older saved items readable.
enum RdLibraryItemKind {
  task('task'),
  event('event'),
  reminder('reminder'),
  meeting('meeting'),
  meetingResult('meeting_result'),
  screenshot('screenshot'),
  note('note'),
  document('document'),
  summary('summary'),
  voice('voice'),
  link('link'),
  person('person');

  const RdLibraryItemKind(this.id);

  final String id;
}

RdLibraryItemKind rdLibraryItemKindFor(LibraryItem item) {
  final contract = item.metadata['capture_contract'];
  if (contract is Map) {
    final displayKind = contract['displayKind'];
    if (displayKind is String && displayKind.trim().isNotEmpty) {
      return rdLibraryItemKindFromValue(displayKind);
    }
  }
  return rdLibraryItemKindFromValue(item.type);
}

RdLibraryItemKind rdLibraryItemKindFromValue(String value) {
  switch (value.trim().toLowerCase()) {
    case 'task':
      return RdLibraryItemKind.task;
    case 'event':
    case 'calendar':
      return RdLibraryItemKind.event;
    case 'reminder':
      return RdLibraryItemKind.reminder;
    case 'meeting':
      return RdLibraryItemKind.meeting;
    case 'meeting_result':
    case 'meeting result':
    case 'live_meeting':
      return RdLibraryItemKind.meetingResult;
    case 'image':
    case 'photo':
    case 'screenshot':
      return RdLibraryItemKind.screenshot;
    case 'file':
    case 'pdf':
    case 'resource':
    case 'document':
    case 'document_knowledge':
    case 'camera_scan':
      return RdLibraryItemKind.document;
    case 'summary':
      return RdLibraryItemKind.summary;
    case 'voice':
    case 'audio':
      return RdLibraryItemKind.voice;
    case 'link':
    case 'url':
    case 'article':
      return RdLibraryItemKind.link;
    case 'person':
    case 'contact':
      return RdLibraryItemKind.person;
    case 'decision':
    case 'commitment':
    case 'message':
    case 'integration_event':
    case 'bundle':
    case 'text':
    case 'note':
    default:
      return RdLibraryItemKind.note;
  }
}
