import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class TaskReminderRequest {
  const TaskReminderRequest({
    required this.taskId,
    required this.title,
    required this.dueAt,
    this.body,
  });

  final String taskId;
  final String title;
  final DateTime dueAt;
  final String? body;
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'mira_task_reminders';
  static const _channelName = 'Task reminders';
  static const _scheduledIdsKey = 'mira_notification_scheduled_task_ids';

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    if (kIsWeb) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) return androidGranted;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosGranted != null) return iosGranted;

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    return await mac?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
  }

  Future<void> syncTaskReminders(
    Iterable<TaskReminderRequest> reminders,
  ) async {
    await initialize();
    final granted = await requestPermissions();
    if (!granted) return;

    final prefs = await SharedPreferences.getInstance();
    for (final id
        in prefs.getStringList(_scheduledIdsKey) ?? const <String>[]) {
      await _plugin.cancel(id: _notificationId(id));
    }

    final scheduled = <String>[];
    final now = DateTime.now();
    for (final reminder in reminders) {
      if (reminder.dueAt.isBefore(now.add(const Duration(minutes: 1)))) {
        continue;
      }
      await _scheduleTaskReminder(reminder);
      scheduled.add(reminder.taskId);
    }
    await prefs.setStringList(_scheduledIdsKey, scheduled);
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await initialize();
    await _plugin.cancel(id: _notificationId(taskId));
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_scheduledIdsKey) ?? const <String>[];
    await prefs.setStringList(
      _scheduledIdsKey,
      ids.where((id) => id != taskId).toList(),
    );
  }

  Future<void> _scheduleTaskReminder(TaskReminderRequest reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.dueAt, tz.local);
    await _plugin.zonedSchedule(
      id: _notificationId(reminder.taskId),
      scheduledDate: scheduledDate,
      title: 'Mira reminder',
      body: reminder.body ?? reminder.title,
      payload: jsonEncode({'type': 'task', 'taskId': reminder.taskId}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Reminders for Mira tasks with due dates.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  int _notificationId(String taskId) {
    var hash = 0x811c9dc5;
    for (final unit in taskId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
