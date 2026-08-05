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
