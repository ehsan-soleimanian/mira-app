import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/capture_models.dart';

void main() {
  test('CaptureResponse keeps link crawl provenance', () {
    final capture = CaptureResponse.fromJson({
      'capture_id': 'capture-1',
      'state': 'processing',
      'capture_type': 'link',
      'proposal': null,
      'source_metadata': {
        'url': 'https://example.com/article',
        'is_scraped_url': true,
        'link_extraction_method': 'firecrawl',
        'scraped_title': 'Useful article',
      },
      'created_at': '2026-07-12T00:00:00Z',
    });

    expect(capture.captureType, 'link');
    expect(capture.sourceMetadata['is_scraped_url'], isTrue);
    expect(capture.sourceMetadata['link_extraction_method'], 'firecrawl');
    expect(capture.sourceMetadata['scraped_title'], 'Useful article');
    expect(capture.createdAt, isNotNull);
  });
}
