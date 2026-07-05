import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class LibraryRepository {
  LibraryRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<LibraryItem>> list({String? query, String? type}) async {
    final params = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (type != null) {
      params['type'] = type;
    }
    final response = await _dio.get<List<dynamic>>(
      '/library/items',
      queryParameters: params,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LibraryItem.fromJson)
        .toList();
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
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mimeType == null ? null : DioMediaType.parse(mimeType),
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
