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

  test('Library media item exposes source url and thumbnail metadata', () {
    final item = LibraryItem.fromJson({
      'id': 'item-1',
      'type': 'video',
      'title': 'Reel',
      'summary': 'Queued',
      'source': 'import:reels',
      'extractionStatus': 'queued',
      'metadata': {
        'url': 'https://www.instagram.com/reel/abc/',
        'media': {'thumbnail_url': 'https://cdn.example/thumb.jpg'},
      },
      'createdAt': '2026-07-05T12:00:00Z',
      'updatedAt': '2026-07-05T12:00:00Z',
    });

    expect(item.isMedia, isTrue);
    expect(item.sourceUrl, 'https://www.instagram.com/reel/abc/');
    expect(item.thumbnailUrl, 'https://cdn.example/thumb.jpg');
  });

  test('LibraryChunk parses timestamp metadata', () {
    final chunk = LibraryChunk.fromJson({
      'id': 'chunk-1',
      'itemId': 'item-1',
      'chunkType': 'transcript',
      'chunkIndex': 0,
      'text': 'timestamped transcript',
      'startMs': 1000,
      'endMs': 4000,
      'locator': '0:01-0:04',
      'metadata': {'source': 'youtube_transcript_api'},
      'createdAt': '2026-07-05T12:00:00Z',
    });

    expect(chunk.hasTimestamp, isTrue);
    expect(chunk.locator, '0:01-0:04');
    expect(chunk.text, contains('timestamped'));
  });
}
