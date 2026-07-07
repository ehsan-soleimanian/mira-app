import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class LibraryRepository {
  LibraryRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<LibraryItem>> list({
    String? query,
    String? type,
    bool includeArchived = false,
  }) async {
    final params = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (type != null) {
      params['type'] = type;
    }
    if (includeArchived) params['includeArchived'] = true;
    final response = await _dio.get<List<dynamic>>(
      '/library/items',
      queryParameters: params,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryItem.fromJson)
        .toList();
  }

  /// Delete a library item (memory). Backend: `DELETE /library/items/{id}`.
  Future<void> delete(String itemId) async {
    await _dio.delete<void>('/library/items/$itemId');
  }

  /// Apply a Library selection-bar action to many items in one request.
  /// Backend: `POST /library/items/bulk-actions`. [action] ∈
  /// pin / unpin / archive / restore / delete / add_to_space / remove_from_space.
  Future<void> bulkAction(
    List<String> itemIds,
    String action, {
    String? spaceId,
  }) async {
    final data = <String, dynamic>{'itemIds': itemIds, 'action': action};
    if (spaceId != null) data['spaceId'] = spaceId;
    await _dio.post<Map<String, dynamic>>(
      '/library/items/bulk-actions',
      data: data,
    );
  }

  Future<LibrarySearchResponse> searchV2({
    String query = '',
    String? type,
    int limit = 20,
  }) async {
    final data = <String, dynamic>{'q': query.trim(), 'limit': limit};
    if (type != null) data['type'] = type;
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/search-v2',
      data: data,
    );
    return LibrarySearchResponse.fromJson(response.data!);
  }

  Future<List<ImportSourceDto>> importSources() async {
    final response = await _dio.get<List<dynamic>>('/library/import-sources');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ImportSourceDto.fromJson)
        .toList();
  }

  Future<List<LibraryChunk>> chunks(String itemId) async {
    final response = await _dio.get<List<dynamic>>(
      '/library/items/$itemId/chunks',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryChunk.fromJson)
        .toList();
  }

  Future<List<LibraryAnnotation>> annotations(String itemId) async {
    final response = await _dio.get<List<dynamic>>(
      '/library/items/$itemId/annotations',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryAnnotation.fromJson)
        .toList();
  }

  Future<LibraryAnnotation> createAnnotation({
    required String itemId,
    String? chunkId,
    required String quote,
    required String note,
    String color = 'yellow',
    int? startMs,
    int? endMs,
  }) async {
    final data = <String, dynamic>{
      'anchorType': chunkId == null ? 'item' : 'chunk',
      'quote': quote,
      'note': note,
      'color': color,
    };
    if (chunkId != null) data['chunkId'] = chunkId;
    if (startMs != null) data['startMs'] = startMs;
    if (endMs != null) data['endMs'] = endMs;
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/items/$itemId/annotations',
      data: data,
    );
    return LibraryAnnotation.fromJson(response.data!);
  }

  Future<void> deleteAnnotation(String id) async {
    await _dio.delete<void>('/library/annotations/$id');
  }

  Future<LibraryItem> retryExtraction(String itemId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/items/$itemId/extract',
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryGraphSaveResult> saveToGraph(String itemId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/items/$itemId/save-to-graph',
    );
    return LibraryGraphSaveResult.fromJson(response.data!);
  }

  Future<LibraryItem> createNote({
    required String title,
    required String content,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/items',
      data: {
        'type': 'note',
        'title': title,
        'summary': content.length > 240 ? content.substring(0, 240) : content,
        'contentText': content,
      },
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryItem> uploadBytes({
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    final resolvedMimeType = mimeType ?? _mimeTypeFromFilename(filename);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: resolvedMimeType == null
            ? null
            : DioMediaType.parse(resolvedMimeType),
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/uploads',
      data: formData,
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryItem> importLink({
    required String url,
    String? title,
    String? sourceId,
    String? note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/imports/link',
      data: {
        'url': url,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (sourceId != null && sourceId.trim().isNotEmpty)
          'sourceId': sourceId.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryItem> importText({
    required String text,
    required String sourceId,
    String? title,
    String? mimeType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/imports/text',
      data: {
        'text': text,
        'sourceId': sourceId,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (mimeType != null && mimeType.trim().isNotEmpty)
          'mimeType': mimeType.trim(),
      },
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryItem> importMeetingTranscript({
    required String title,
    required String transcript,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'transcript': transcript,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/meetings',
      data: formData,
    );
    return LibraryItem.fromJson(response.data!);
  }

  Future<LibraryItem> importMeetingAudio({
    required String title,
    required String audioPath,
    String filename = 'meeting.m4a',
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'file': await MultipartFile.fromFile(
        audioPath,
        filename: filename,
        contentType: mimeType == null ? null : DioMediaType.parse(mimeType),
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/meetings',
      data: formData,
    );
    return LibraryItem.fromJson(response.data!);
  }
}

String? _mimeTypeFromFilename(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0 || dot == filename.length - 1) return null;
  final extension = filename.substring(dot + 1).toLowerCase();
  return switch (extension) {
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'md' || 'markdown' => 'text/markdown',
    'html' || 'htm' => 'text/html',
    'json' => 'application/json',
    'csv' => 'text/csv',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'pptx' =>
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'epub' => 'application/epub+zip',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'mp3' => 'audio/mpeg',
    'm4a' => 'audio/mp4',
    'wav' => 'audio/wav',
    'ogg' => 'audio/ogg',
    'aac' => 'audio/aac',
    'mp4' => 'video/mp4',
    'mov' => 'video/quicktime',
    'webm' => 'video/webm',
    'mkv' => 'video/x-matroska',
    'avi' => 'video/x-msvideo',
    _ => null,
  };
}
