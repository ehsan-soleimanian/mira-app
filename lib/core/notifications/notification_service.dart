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

class NotificationScheduleSnapshot {
  const NotificationScheduleSnapshot({
    required this.notificationsEnabled,
    required this.permissionGranted,
    required this.scheduledTaskIds,
    required this.leadTime,
  });

  final bool notificationsEnabled;
  final bool permissionGranted;
  final List<String> scheduledTaskIds;
  final Duration leadTime;

  int get scheduledCount => scheduledTaskIds.length;
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'mira_task_reminders';
  static const _channelName = 'Task reminders';
  static const _scheduledIdsKey = 'mira_notification_scheduled_task_ids';
  static const _notificationsEnabledKey = 'mira_settings_notifications';
  static const _permissionGrantedKey = 'mira_notification_permission_granted';
  static const _leadMinutesKey = 'mira_notification_lead_minutes';
  static const defaultLeadTime = Duration(minutes: 10);

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
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      await prefs.setBool(_permissionGrantedKey, false);
      return false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) {
      await prefs.setBool(_permissionGrantedKey, androidGranted);
      return androidGranted;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosGranted != null) {
      await prefs.setBool(_permissionGrantedKey, iosGranted);
      return iosGranted;
    }

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final granted =
        await mac?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    await prefs.setBool(_permissionGrantedKey, granted);
    return granted;
  }

  Future<NotificationScheduleSnapshot> snapshot() async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    return NotificationScheduleSnapshot(
      notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
      permissionGranted: prefs.getBool(_permissionGrantedKey) ?? false,
      scheduledTaskIds: List<String>.unmodifiable(
        prefs.getStringList(_scheduledIdsKey) ?? const <String>[],
      ),
      leadTime: Duration(
        minutes: prefs.getInt(_leadMinutesKey) ?? defaultLeadTime.inMinutes,
      ),
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    if (!enabled) await cancelAllTaskReminders();
  }

  Future<void> setReminderLeadTime(Duration leadTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_leadMinutesKey, leadTime.inMinutes);
  }

  Future<void> cancelAllTaskReminders() async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    for (final id
        in prefs.getStringList(_scheduledIdsKey) ?? const <String>[]) {
      await _plugin.cancel(id: _notificationId(id));
    }
    await prefs.setStringList(_scheduledIdsKey, const <String>[]);
  }

  Future<void> syncTaskReminders(
    Iterable<TaskReminderRequest> reminders,
  ) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_notificationsEnabledKey) == false) {
      await cancelAllTaskReminders();
      return;
    }

    final granted = await requestPermissions();
    if (!granted) return;

    for (final id
        in prefs.getStringList(_scheduledIdsKey) ?? const <String>[]) {
      await _plugin.cancel(id: _notificationId(id));
    }

    final scheduled = <String>[];
    final now = DateTime.now();
    final leadTime = Duration(
      minutes: prefs.getInt(_leadMinutesKey) ?? defaultLeadTime.inMinutes,
    );
    for (final reminder in reminders) {
      if (reminder.dueAt.isBefore(now.add(const Duration(minutes: 1)))) {
        continue;
      }
      await _scheduleTaskReminder(reminder, leadTime: leadTime);
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

  Future<void> _scheduleTaskReminder(
    TaskReminderRequest reminder, {
    required Duration leadTime,
  }) async {
    final now = DateTime.now();
    var fireAt = reminder.dueAt.subtract(leadTime);
    if (fireAt.isBefore(now.add(const Duration(minutes: 1)))) {
      fireAt = reminder.dueAt;
    }
    final scheduledDate = tz.TZDateTime.from(fireAt, tz.local);
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
