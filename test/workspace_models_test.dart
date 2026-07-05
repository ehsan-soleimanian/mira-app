import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/workspace_models.dart';

void main() {
  test('ImportSourceDto parses import hub manifest', () {
    final source = ImportSourceDto.fromJson({
      'id': 'whatsapp_export',
      'name': 'WhatsApp exports',
      'category': 'Messaging',
      'action': 'share_or_upload_export',
      'status': 'ready',
      'description': 'Export a chat as .txt.',
      'extensions': ['.txt', '.zip'],
    });

    expect(source.id, 'whatsapp_export');
    expect(source.isGuide, isTrue);
    expect(source.extensions, contains('.txt'));
  });

  test('ImportSourceDto identifies link and connector actions', () {
    final link = ImportSourceDto.fromJson({
      'id': 'youtube',
      'name': 'YouTube',
      'category': 'Video',
      'action': 'paste_link',
      'status': 'metadata_ready',
      'description': 'Save video links.',
    });
    final connector = ImportSourceDto.fromJson({
      'id': 'google_drive',
      'name': 'Google Drive',
      'category': 'Connectors',
      'action': 'connect_provider',
      'status': 'ready',
      'description': 'Connect Drive.',
    });

    expect(link.isLink, isTrue);
    expect(connector.isConnector, isTrue);
  });
}
