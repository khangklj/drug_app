import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationPayload {
  final TimeOfDayValues timeOfDay;
  final DateTime scheduledTime;

  NotificationPayload({required this.timeOfDay, required this.scheduledTime});

  NotificationPayload copyWith({
    TimeOfDayValues? timeOfDay,
    DateTime? scheduledTime,
  }) {
    return NotificationPayload(
      timeOfDay: timeOfDay ?? this.timeOfDay,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeOfDay': timeOfDay.name,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }

  factory NotificationPayload.fromJSON(Map<String, dynamic> json) {
    return NotificationPayload(
      timeOfDay: TimeOfDayValues.values.firstWhere(
        (element) => element.name == json['timeOfDay'],
      ),
      scheduledTime: DateTime.parse(json['scheduledTime']),
    );
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<TimeOfDayValues, int> _notificationMapIds = {
    TimeOfDayValues.morning: 1412,
    TimeOfDayValues.afternoon: 1413,
    TimeOfDayValues.noon: 1414,
    TimeOfDayValues.evening: 1415,
  };
  final AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
        'reminder_channel_id',
        'Daily Notifications',
        channelDescription:
            'Daily reminder notifications for drug prescriptions',
        importance: Importance.max,
        priority: Priority.high,
      );

  Future<void> initSettings(
    Function(String? payload) onSelectNotification,
  ) async {
    // Initialize timezone for scheduled notifications and get local tz
    final locationName = 'Asia/Ho_Chi_Minh';
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(locationName));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification(response.payload);
      },
    );

    final prefs = await SharedPreferences.getInstance();
    for (final id in _notificationMapIds.values) {
      final key = id.toString();
      final hasScheduled = prefs.getBool(key);
      if (hasScheduled == null) {
        await prefs.setBool(key, false);
      }
    }
  }

  Future<bool?> requestNotificationPermission() async {
    return await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<DateTime?> getScheduledNotifcationTime(
    TimeOfDayValues timeOfDay,
  ) async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    late final NotificationPayload payload;
    final targetNotification = pendingNotifications.firstWhereOrNull(
      (notification) => notification.id == _notificationMapIds[timeOfDay],
    );
    if (targetNotification == null) {
      return null;
    }
    payload = NotificationPayload.fromJSON(
      jsonDecode(targetNotification.payload!),
    );
    return payload.scheduledTime;
  }

  //TODO: DELETE DEMO
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // const int insistentFlag = 4;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'Default notifications',
        importance: Importance.max,
        priority: Priority.high,
        // additionalFlags: Int32List.fromList(<int>[insistentFlag]),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }

  //TODO: DELETE DEMO
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification(
    TimeOfDayValues timeOfDay,
    DateTime scheduleTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    final id = _notificationMapIds[timeOfDay]!;
    bool? hasScheduled = prefs.getBool(key);
    if (hasScheduled == null || hasScheduled == false) {
      await prefs.setBool(key, true);
    } else {
      await _flutterLocalNotificationsPlugin.cancel(id);
    }

    final time = nextInstanceOfDailyReminder(scheduleTime);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Nhắc nhở uống thuốc buổi ${timeOfDay.toDisplayString()}',
      'Nhấn vào đây để xem nhanh danh sách thuốc',
      time,
      NotificationDetails(android: _androidNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: jsonEncode(
        NotificationPayload(timeOfDay: timeOfDay, scheduledTime: time).toJson(),
      ),
    );
  }

  tz.TZDateTime nextInstanceOfDailyReminder(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelDailyNotification(TimeOfDayValues timeOfDay) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    final id = _notificationMapIds[timeOfDay]!;
    final hasScheduled = prefs.getBool(key);
    if (hasScheduled == null || hasScheduled == false) return;
    await _flutterLocalNotificationsPlugin.cancel(id);
    await prefs.setBool(key, false);
  }

  Future<void> cancelAllDailyNotifications() async {
    _notificationMapIds.forEach(
      (key, value) async =>
          await _flutterLocalNotificationsPlugin.cancel(value),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  //TODO: DELETE DEMO
  Future<void> printAllPendingNotifications() async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      print(
        "${notification.id} ${notification.title} ${notification.body} ${notification.payload}",
      );
    }
  }
}
