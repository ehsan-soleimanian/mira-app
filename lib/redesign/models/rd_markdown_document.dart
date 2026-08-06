import 'package:flutter/material.dart';

import 'package:mira_app/models/api/workspace_models.dart';

bool rdIsMarkdownLibraryItem(LibraryItem item) {
  final mime = (item.mimeType ?? '').split(';').first.trim().toLowerCase();
  final captureSource = item.metadata['capture_source'];
  final capturedMime = captureSource is Map<String, dynamic>
      ? (captureSource['content_type'] ?? '').toString().toLowerCase()
      : '';
  final filename = '${item.title} ${item.metadata['filename'] ?? ''}'
      .toLowerCase();
  return mime == 'text/markdown' ||
      mime == 'text/x-markdown' ||
      capturedMime.startsWith('text/markdown') ||
      capturedMime.startsWith('text/x-markdown') ||
      RegExp(r'\.(md|markdown)(?:\s|$)').hasMatch(filename);
}

String rdMarkdownFilename(String title) => title
    .replaceFirst(RegExp(r'^file\s+uploaded:\s*', caseSensitive: false), '')
    .trim();

bool rdHasReadableMarkdown(String value) {
  final text = value.trim();
  if (text.isEmpty) return false;
  return !RegExp(
    r"^Resource:\s*file\s+upload\s+'[^']+'\s*\([^)]*\)\.?$",
    caseSensitive: false,
  ).hasMatch(text);
}

TextDirection rdMarkdownDirection(String value) {
  final firstLetter = RegExp(
    r'[A-Za-z\u0600-\u06FF]',
  ).firstMatch(value)?.group(0);
  return firstLetter != null && RegExp(r'[\u0600-\u06FF]').hasMatch(firstLetter)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
