String sanitizeAssistantAnswer(String value) {
  var cleaned = value.replaceAll(
    RegExp(
      r'\s*[\[(]\s*Source memory:\s*[0-9a-fA-F-]{8,}\s*[\])]',
      caseSensitive: false,
    ),
    '',
  );
  cleaned = cleaned.replaceAll(
    RegExp(r'\s*\(capture=[^)]+\)', caseSensitive: false),
    '',
  );
  return cleaned.trim();
}
