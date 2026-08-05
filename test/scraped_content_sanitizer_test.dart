import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/utils/scraped_content_sanitizer.dart';

void main() {
  test('decodes markup and removes style and svg noise', () {
    const encoded =
        '%3Cstyle%3E.sparkle-main%20%7B%20animation-delay:%200.22s;%20'
        'transform:%20scale(.76);%20opacity:%20.7;%20%7D%3C/style%3E'
        '%3Csvg%3E%3Cpath%20d=%22M14.9%2013.0L15.0%2014.0%22/%3E%3C/svg%3E'
        '%3Cmain%3E%3Ch1%3EAI HomeDesign Toolbox%3C/h1%3E'
        '%3Cp%3EVirtual staging for real estate.%3C/p%3E%3C/main%3E';

    final cleaned = sanitizeScrapedContentForDisplay(encoded);

    expect(cleaned, contains('AI HomeDesign Toolbox'));
    expect(cleaned, contains('Virtual staging for real estate.'));
    expect(cleaned, isNot(contains('animation-delay')));
    expect(cleaned, isNot(contains('M14.9')));
    expect(cleaned, isNot(contains('%20')));
  });

  test('preserves normal note text', () {
    const note = 'Call Sara tomorrow about the design review.';
    expect(sanitizeScrapedContentForDisplay(note), note);
  });

  test('builds a visual preview from scraped markdown', () {
    const content = '''
![Activity Summary](https://cdn.example.com/activity.webp)
# Community-Powered Motivation
If you're active, this network helps you connect with athletes around the world.
### Start by sweating
Track your activities with a phone or GPS device and share your efforts with friends.
### Get better by analysis
Review useful performance metrics after every workout and compare past attempts.
''';

    final preview = buildScrapedLinkPreview(
      content: content,
      summary: 'A social network for active people.',
    );

    expect(preview.heroImageUrl, 'https://cdn.example.com/activity.webp');
    expect(preview.summary, 'A social network for active people.');
    expect(preview.highlights, hasLength(3));
    expect(preview.highlights.first, contains('Community-Powered Motivation'));
    expect(preview.highlights.join(' '), isNot(contains('https://')));
    expect(preview.highlights.join(' '), isNot(contains('![')));
  });
}
