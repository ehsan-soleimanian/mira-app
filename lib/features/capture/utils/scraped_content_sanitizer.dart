/// Cleans legacy link captures that accidentally stored percent-encoded
/// frontend markup instead of readable page content.
String sanitizeScrapedContentForDisplay(String value) {
  var text = value.trim();
  if (text.isEmpty || !_looksEncoded(text)) return text;

  for (var pass = 0; pass < 2 && _looksEncoded(text); pass++) {
    try {
      final decoded = Uri.decodeComponent(text);
      if (decoded == text) break;
      text = decoded;
    } on FormatException {
      break;
    }
  }

  final lower = text.toLowerCase();
  final styleClose = lower.lastIndexOf('</style>');
  final styleOpen = styleClose < 0
      ? -1
      : lower.lastIndexOf('<style', styleClose);
  if (styleClose >= 0 && styleOpen < 0) {
    text = text.substring(styleClose + '</style>'.length);
  }

  text = text
      .replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ')
      .replaceAll(
        RegExp(
          r'<(script|style|svg|canvas|template|noscript)\b[^>]*>[\s\S]*?</\1\s*>',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");

  if (_looksLikeFrontendSource(text)) {
    String previous;
    do {
      previous = text;
      text = text.replaceAll(
        RegExp(r'(?:^|\s)[.#@][\w\-:(),.\s>+~]*\{[^{}]*\}'),
        ' ',
      );
    } while (previous != text);
    text = text.replaceAll(
      RegExp(
        r'\b(?:animation(?:-delay)?|transform|opacity|fill|stroke|stroke-width|display|position|inset|top|left|right|bottom|width|height)\s*:\s*[^;]{0,300};',
        caseSensitive: false,
      ),
      ' ',
    );
  }

  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class ScrapedLinkPreview {
  const ScrapedLinkPreview({
    required this.summary,
    required this.highlights,
    this.heroImageUrl,
  });

  final String summary;
  final List<String> highlights;
  final String? heroImageUrl;
}

ScrapedLinkPreview buildScrapedLinkPreview({
  required String content,
  required String summary,
}) {
  final cleanedContent = sanitizeScrapedContentForDisplay(content);
  final imageMatch = RegExp(
    r'https?://[^\s)\]]+\.(?:avif|webp|png|jpe?g)(?:\?[^\s)\]]*)?',
    caseSensitive: false,
  ).firstMatch(cleanedContent);
  final heroImageUrl = imageMatch?.group(0);

  final summaryText = _markdownToPlainText(
    sanitizeScrapedContentForDisplay(summary),
  );
  final highlights = <String>[];
  String? pendingHeading;

  for (final rawLine in cleanedContent.split(RegExp(r'[\r\n]+'))) {
    final line = rawLine.trim();
    if (line.isEmpty ||
        line.startsWith('![') ||
        line.startsWith('Source URL:')) {
      continue;
    }
    if (RegExp(r'^#{1,6}\s+').hasMatch(line)) {
      pendingHeading = _markdownToPlainText(
        line.replaceFirst(RegExp(r'^#{1,6}\s+'), ''),
      );
      continue;
    }

    final plain = _markdownToPlainText(line);
    if (plain.length < 42 || _looksLikeAssetFragment(plain)) continue;
    final candidate = pendingHeading == null || plain.startsWith(pendingHeading)
        ? plain
        : '$pendingHeading — $plain';
    pendingHeading = null;
    final clipped = candidate.length > 180
        ? '${candidate.substring(0, 177).trimRight()}…'
        : candidate;
    if (summaryText.isNotEmpty && _sameMeaning(clipped, summaryText)) continue;
    if (highlights.any((item) => _sameMeaning(item, clipped))) continue;
    highlights.add(clipped);
    if (highlights.length == 3) break;
  }

  final fallbackSummary = highlights.isNotEmpty ? highlights.first : '';
  return ScrapedLinkPreview(
    summary: summaryText.isNotEmpty ? summaryText : fallbackSummary,
    highlights: highlights,
    heroImageUrl: heroImageUrl,
  );
}

String _markdownToPlainText(String value) {
  var text = value
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), ' ')
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]*\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAll(RegExp(r'https?://\S+'), ' ')
      .replaceAll(RegExp(r'^[\-*]+\s*'), '')
      .replaceAll(RegExp(r'[*_`]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.length > 320) text = '${text.substring(0, 317).trimRight()}…';
  return text;
}

bool _looksLikeAssetFragment(String value) {
  final lower = value.toLowerCase();
  return lower.contains('data:image') ||
      RegExp(r'\.(?:avif|webp|png|jpe?g)\)?$').hasMatch(lower) ||
      lower.startsWith('us@1x.');
}

bool _sameMeaning(String left, String right) {
  String key(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), ' ')
      .trim();
  final a = key(left);
  final b = key(right);
  if (a.isEmpty || b.isEmpty) return false;
  return a == b || a.contains(b) || b.contains(a);
}

bool _looksEncoded(String value) {
  final matches = RegExp(
    r'%(?:20|3c|3e|7b|7d|2f|22|27)',
    caseSensitive: false,
  ).allMatches(value);
  return matches.length >= 4;
}

bool _looksLikeFrontendSource(String value) {
  final lower = value.toLowerCase();
  const signals = <String>[
    '@keyframes',
    'animation-delay:',
    'transform:',
    'opacity:',
    'prefers-reduced-motion',
    'stroke-width:',
  ];
  return signals.where(lower.contains).length >= 2;
}
