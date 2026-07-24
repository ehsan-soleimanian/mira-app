import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mira_app/core/locale/device_locale_context.dart';
import 'package:mira_app/models/api/reminder_models.dart';
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
  static const _quietEnabledKey = 'mira_notification_quiet_enabled';
  static const _quietStartKey = 'mira_notification_quiet_start';
  static const _quietEndKey = 'mira_notification_quiet_end';
  static const defaultLeadTime = Duration(minutes: 10);

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DeviceLocaleContext.timezone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

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

  Future<void> setQuietHours({
    required bool enabled,
    required String start,
    required String end,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quietEnabledKey, enabled);
    await prefs.setString(_quietStartKey, start);
    await prefs.setString(_quietEndKey, end);
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

    if (prefs.getBool(_permissionGrantedKey) != true) return;

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

  Future<void> syncReminders(Iterable<Reminder> reminders) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_notificationsEnabledKey) == false) {
      await cancelAllTaskReminders();
      return;
    }
    // Permission is requested from the explicit notification-settings flow,
    // never as a surprise when the app starts or a list refreshes.
    if (prefs.getBool(_permissionGrantedKey) != true) return;

    for (final id
        in prefs.getStringList(_scheduledIdsKey) ?? const <String>[]) {
      await _plugin.cancel(id: _notificationId(id));
    }
    final now = DateTime.now();
    final scheduled = <String>[];
    for (final reminder in reminders) {
      final when = reminder.effectiveRemindAt;
      if (reminder.done ||
          when == null ||
          !when.isAfter(now.add(const Duration(minutes: 1)))) {
        continue;
      }
      final scheduledAt = _applyQuietHours(when, prefs);
      await _plugin.zonedSchedule(
        id: _notificationId(reminder.id),
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        title: 'Mira',
        body: reminder.remindText ?? reminder.title,
        payload: jsonEncode({
          'type': 'reminder',
          'reminderId': reminder.id,
          if (reminder.taskId != null) 'taskId': reminder.taskId,
        }),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription:
                'Reminders you explicitly asked Mira to deliver.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
      );
      scheduled.add(reminder.id);
    }
    await prefs.setStringList(_scheduledIdsKey, scheduled);
  }

  DateTime _applyQuietHours(DateTime when, SharedPreferences prefs) {
    if (prefs.getBool(_quietEnabledKey) != true) return when;
    final start = _parseClock(prefs.getString(_quietStartKey) ?? '22:00');
    final end = _parseClock(prefs.getString(_quietEndKey) ?? '07:00');
    if (start == null || end == null || start == end) return when;
    final minute = when.hour * 60 + when.minute;
    final inside = start < end
        ? minute >= start && minute < end
        : minute >= start || minute < end;
    if (!inside) return when;
    final endHour = end ~/ 60;
    final endMinute = end % 60;
    final afterStart = start > end && minute >= start;
    return DateTime(
      when.year,
      when.month,
      when.day + (afterStart ? 1 : 0),
      endHour,
      endMinute,
    );
  }

  int? _parseClock(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
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
