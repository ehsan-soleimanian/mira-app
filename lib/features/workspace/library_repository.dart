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

  Future<List<ImportSourceDto>> importSources() async {
    final response = await _dio.get<List<dynamic>>('/library/import-sources');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ImportSourceDto.fromJson)
        .toList();
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
}
