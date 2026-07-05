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
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/uploads',
      data: formData,
    );
    return LibraryItem.fromJson(response.data!);
  }
}
