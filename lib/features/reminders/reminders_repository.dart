import 'package:dio/dio.dart';

import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/reminder_models.dart';

/// Client for the backend `/reminders` endpoints (relational reminders the user
/// attaches to captures, tasks, and memories). Auth is applied automatically by
/// the shared [ApiClient] interceptor.
class RemindersRepository {
  RemindersRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<Reminder>> list({bool? done, int limit = 100, int offset = 0}) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (done != null) params['done'] = done;
    final response = await _dio.get<Map<String, dynamic>>(
      '/reminders',
      queryParameters: params,
    );
    final items = response.data?['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Reminder.fromJson)
        .toList();
  }

  Future<Reminder> create({
    required String title,
    DateTime? remindAt,
    String? sourceNodeId,
  }) async {
    final data = <String, dynamic>{'title': title};
    if (remindAt != null) data['remind_at'] = remindAt.toUtc().toIso8601String();
    if (sourceNodeId != null) data['source_node_id'] = sourceNodeId;
    final response = await _dio.post<Map<String, dynamic>>('/reminders', data: data);
    return Reminder.fromJson(response.data!);
  }

  Future<Reminder> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/reminders/$id');
    return Reminder.fromJson(response.data!);
  }

  Future<Reminder> update(
    String id, {
    String? title,
    DateTime? remindAt,
    bool? done,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (remindAt != null) data['remind_at'] = remindAt.toUtc().toIso8601String();
    if (done != null) data['done'] = done;
    final response = await _dio.patch<Map<String, dynamic>>(
      '/reminders/$id',
      data: data,
    );
    return Reminder.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/reminders/$id');
  }
}
