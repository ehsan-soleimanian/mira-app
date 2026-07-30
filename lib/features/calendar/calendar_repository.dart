import 'package:dio/dio.dart';

import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/locale/device_locale_context.dart';
import 'package:mira_app/models/api/calendar_models.dart';

class CalendarRepository {
  CalendarRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<List<CalendarOccurrence>> agenda({
    required DateTime from,
    required DateTime to,
    int limit = 200,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/events/agenda',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'limit': limit,
      },
    );
    final rows = response.data?['items'] as List<dynamic>? ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(CalendarOccurrence.fromJson)
        .toList();
  }

  Future<CalendarEvent> create({
    required String title,
    required DateTime startsAt,
    DateTime? endsAt,
    bool allDay = false,
    String? description,
    String? location,
    List<String> attendees = const [],
    String? recurrenceRule,
    String? idempotencyKey,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'timezone': DeviceLocaleContext.timezone,
      'all_day': allDay,
      'attendees': attendees,
    };
    if (endsAt case final value?) {
      data['ends_at'] = value.toUtc().toIso8601String();
    }
    if (description case final value?) data['description'] = value;
    if (location case final value?) data['location'] = value;
    if (recurrenceRule case final value?) data['recurrence_rule'] = value;
    if (idempotencyKey case final value?) data['idempotency_key'] = value;
    final response = await _dio.post<Map<String, dynamic>>(
      '/events',
      data: data,
    );
    return CalendarEvent.fromJson(response.data!);
  }

  Future<CalendarEvent> update(
    String id, {
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    String? status,
    String? statusReason,
  }) async {
    final data = <String, dynamic>{};
    if (title case final value?) data['title'] = value;
    if (startsAt case final value?) {
      data['starts_at'] = value.toUtc().toIso8601String();
    }
    if (endsAt case final value?) {
      data['ends_at'] = value.toUtc().toIso8601String();
    }
    if (status case final value?) data['status'] = value;
    if (statusReason case final value?) data['status_reason'] = value;
    final response = await _dio.patch<Map<String, dynamic>>(
      '/events/$id',
      data: data,
    );
    return CalendarEvent.fromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/events/$id');
}
