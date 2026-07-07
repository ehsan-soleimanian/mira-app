import 'package:dio/dio.dart';

import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/collection_models.dart';

/// Client for the backend `/collections` endpoints — user-curated groupings of
/// memories the Library surfaces as "Mira grouped for you". Auth is applied
/// automatically by the shared [ApiClient] interceptor.
class CollectionsRepository {
  CollectionsRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<MemoryCollection>> list({int limit = 100, int offset = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/collections',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final items = response.data?['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MemoryCollection.fromJson)
        .toList();
  }

  Future<MemoryCollection> create({required String name, String? icon}) async {
    final data = <String, dynamic>{'name': name};
    if (icon != null) data['icon'] = icon;
    final response = await _dio.post<Map<String, dynamic>>('/collections', data: data);
    return MemoryCollection.fromJson(response.data!);
  }

  Future<MemoryCollectionDetail> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/collections/$id');
    return MemoryCollectionDetail.fromJson(response.data!);
  }

  Future<MemoryCollection> rename(String id, {String? name, String? icon}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (icon != null) data['icon'] = icon;
    final response = await _dio.patch<Map<String, dynamic>>('/collections/$id', data: data);
    return MemoryCollection.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/collections/$id');
  }

  /// Add memories (by library-item id) to a collection. Idempotent per id;
  /// returns the collection with its refreshed [MemoryCollection.itemCount].
  Future<MemoryCollection> addItems(String id, List<String> memoryIds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/collections/$id/items',
      data: {'memory_ids': memoryIds},
    );
    return MemoryCollection.fromJson(response.data!);
  }

  Future<MemoryCollection> removeItem(String id, String memoryId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/collections/$id/items/$memoryId',
    );
    return MemoryCollection.fromJson(response.data!);
  }
}
