import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZone = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZone));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    final android =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static int _notificationIdForHabit(String habitId) =>
      habitId.hashCode & 0x7fffffff;

  static Future<void> scheduleHabitReminder({
    required String habitId,
    required TimeOfDay time,
    required String habitTitle,
  }) async {
    final id = _notificationIdForHabit(habitId);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders to complete your habits.',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      'It\'s time for your habit.',
      habitTitle,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelHabitReminder(String habitId) async {
    final id = _notificationIdForHabit(habitId);
    await _plugin.cancel(id);
  }
}