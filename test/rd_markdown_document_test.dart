import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/redesign/models/rd_markdown_document.dart';

LibraryItem _item({
  String? mimeType,
  Map<String, dynamic> metadata = const {},
}) {
  final now = DateTime(2026);
  return LibraryItem(
    id: 'doc-1',
    type: 'document',
    title: 'File uploaded: API_BOOK.md',
    summary: 'Uploaded document',
    source: 'capture:file',
    extractionStatus: 'ready',
    createdAt: now,
    updatedAt: now,
    mimeType: mimeType,
    metadata: metadata,
  );
}

void main() {
  test('recognizes markdown from mime, extension, and legacy metadata', () {
    expect(rdIsMarkdownLibraryItem(_item(mimeType: 'text/markdown')), isTrue);
    expect(rdIsMarkdownLibraryItem(_item()), isTrue);
    expect(
      rdIsMarkdownLibraryItem(
        _item(
          metadata: const {
            'capture_source': {'content_type': 'text/x-markdown'},
          },
        ),
      ),
      isTrue,
    );
  });

  test('normalizes title and rejects a metadata-only legacy body', () {
    expect(rdMarkdownFilename('File uploaded: API_BOOK.md'), 'API_BOOK.md');
    expect(
      rdHasReadableMarkdown(
        "Resource: file upload 'API_BOOK.md' (text/markdown, 92802 bytes).",
      ),
      isFalse,
    );
    expect(rdHasReadableMarkdown('# API\n\nReadable body.'), isTrue);
  });

  test('uses the first meaningful letter for reader direction', () {
    expect(rdMarkdownDirection('# API book'), TextDirection.ltr);
    expect(rdMarkdownDirection('# راهنمای میرا'), TextDirection.rtl);
  });
}
