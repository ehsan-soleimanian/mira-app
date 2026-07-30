import 'package:dio/dio.dart';

import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/locale/device_locale_context.dart';
import 'package:mira_app/core/notifications/notification_service.dart';
import 'package:mira_app/models/api/reminder_models.dart';

/// Client for the backend `/reminders` endpoints (relational reminders the user
/// attaches to captures, tasks, and memories). Auth is applied automatically by
/// the shared [ApiClient] interceptor.
class RemindersRepository {
  RemindersRepository({
    required ApiClient apiClient,
    NotificationService? notificationService,
  }) : _dio = apiClient.dio,
       _notifications = notificationService;

  final Dio _dio;
  final NotificationService? _notifications;

  Future<List<Reminder>> list({
    bool? done,
    int limit = 100,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (done != null) params['done'] = done;
    final response = await _dio.get<Map<String, dynamic>>(
      '/reminders',
      queryParameters: params,
    );
    final items = response.data?['items'] as List<dynamic>? ?? const [];
    final reminders = items
        .whereType<Map<String, dynamic>>()
        .map(Reminder.fromJson)
        .toList();
    await _notifications?.syncReminders(reminders);
    return reminders;
  }

  Future<Reminder> create({
    required String title,
    DateTime? remindAt,
    String? sourceNodeId,
    String? taskId,
    String? calendarEventId,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'timezone': DeviceLocaleContext.timezone,
    };
    if (remindAt != null) {
      data['remind_at'] = remindAt.toUtc().toIso8601String();
    }
    if (sourceNodeId != null) data['source_node_id'] = sourceNodeId;
    if (taskId != null) data['task_id'] = taskId;
    if (calendarEventId != null) {
      data['calendar_event_id'] = calendarEventId;
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/reminders',
      data: data,
    );
    final reminder = Reminder.fromJson(response.data!);
    await syncLocalNotifications();
    return reminder;
  }

  Future<Reminder> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/reminders/$id');
    return Reminder.fromJson(response.data!);
  }

  Future<Reminder> update(
    String id, {
    String? title,
    DateTime? remindAt,
    bool clearRemindAt = false,
    String? timezone,
    bool? done,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (remindAt != null) {
      data['remind_at'] = remindAt.toUtc().toIso8601String();
    } else if (clearRemindAt) {
      data['remind_at'] = null;
    }
    if (timezone != null) data['timezone'] = timezone;
    if (done != null) data['done'] = done;
    final response = await _dio.patch<Map<String, dynamic>>(
      '/reminders/$id',
      data: data,
    );
    final reminder = Reminder.fromJson(response.data!);
    await syncLocalNotifications();
    return reminder;
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/reminders/$id');
    await syncLocalNotifications();
  }

  Future<Reminder> snooze(String id, DateTime until) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/reminders/$id/snooze',
      data: {'until': until.toUtc().toIso8601String()},
    );
    final reminder = Reminder.fromJson(response.data!);
    await syncLocalNotifications();
    return reminder;
  }

  Future<Reminder> markSent(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/reminders/$id/sent',
    );
    final reminder = Reminder.fromJson(response.data!);
    await syncLocalNotifications();
    return reminder;
  }

  Future<void> syncLocalNotifications() async {
    if (_notifications == null) return;
    await list(limit: 500);
  }
}
