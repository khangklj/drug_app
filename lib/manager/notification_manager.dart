import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTimeData {
  final int hour;
  final int minute;
  final int second;

  NotificationTimeData({
    required this.hour,
    required this.minute,
    required this.second,
  });

  NotificationTimeData copyWith({int? hour, int? minute, int? second}) {
    return NotificationTimeData(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  @override
  String toString() => '$hour:$minute:$second';

  DateTime toDateTime() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      minute,
      second,
    );
  }

  static NotificationTimeData? tryParseFromString(String time) {
    final parts = time.split(':');
    if (parts.length == 3) {
      int? parsedHour = int.tryParse(parts[0]);
      int? parsedMinute = int.tryParse(parts[1]);
      int? parsedSecond = int.tryParse(parts[2]);
      if (parsedHour != null && parsedMinute != null && parsedSecond != null) {
        return NotificationTimeData(
          hour: parsedHour,
          minute: parsedMinute,
          second: parsedSecond,
        );
      }
    }
    return null;
  }

  static NotificationTimeData parseFromDateTime(DateTime time) {
    return NotificationTimeData(
      hour: time.hour,
      minute: time.minute,
      second: time.second,
    );
  }
}

class NotificationManager with ChangeNotifier {
  late PermissionStatus _notificationStatus;
  late final NotificationService _notificationService;
  late final Map<TimeOfDayValues, NotificationTimeData?> _notificationTimes;
  late final Map<TimeOfDayValues, NotificationTimeData>
  _defaultNotificationTimes;
  final Map<TimeOfDayValues, int> _notificationMapIds = {
    TimeOfDayValues.morning: 1312,
    TimeOfDayValues.noon: 1313,
    TimeOfDayValues.afternoon: 1314,
    TimeOfDayValues.evening: 1315,
  };

  PermissionStatus get notificationStatus => _notificationStatus;
  Map<TimeOfDayValues, NotificationTimeData?> get notificationTimes =>
      _notificationTimes;

  Future<void> initSettings() async {
    _notificationService = NotificationService();
    _notificationStatus = await Permission.notification.status;
    _notificationTimes = {};

    _defaultNotificationTimes = {
      TimeOfDayValues.morning: NotificationTimeData(
        hour: 6,
        minute: 0,
        second: 0,
      ),
      TimeOfDayValues.noon: NotificationTimeData(
        hour: 11,
        minute: 0,
        second: 0,
      ),
      TimeOfDayValues.afternoon: NotificationTimeData(
        hour: 16,
        minute: 0,
        second: 0,
      ),
      TimeOfDayValues.evening: NotificationTimeData(
        hour: 21,
        minute: 0,
        second: 0,
      ),
    };

    final prefs = await SharedPreferences.getInstance();
    for (final timeOfDay in TimeOfDayValues.values) {
      final key = _notificationMapIds[timeOfDay]!.toString();
      final time = prefs.getString(key);
      if (time != null) {
        _notificationTimes[timeOfDay] = NotificationTimeData.tryParseFromString(
          time,
        );
        await prefs.setString(key, _notificationTimes[timeOfDay]!.toString());
      } else {
        final NotificationTimeData? defaultTime =
            _defaultNotificationTimes[timeOfDay];
        _notificationTimes[timeOfDay] = defaultTime;
        await prefs.setString(key, defaultTime!.toString());
      }
    }
  }

  Future<void> updateNotification(DrugPrescriptionManager dpManager) async {
    final activeNotificationTimes = dpManager.getActiveNotificationTimes();
    final inactiveNotificationTimes = TimeOfDayValues.values
        .toSet()
        .difference(activeNotificationTimes.toSet())
        .toList();
    for (final activeNotificationTime in activeNotificationTimes) {
      scheduleDailyNotification(timeOfDay: activeNotificationTime);
    }
    for (final inactiveNotificationTime in inactiveNotificationTimes) {
      cancelDailyNotification(inactiveNotificationTime);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (_notificationStatus.isGranted) return;

    final status = await Permission.notification.request();
    _notificationStatus = status;
    notifyListeners();
  }

  Future<void> requestPermanentNotificationPermission() async {
    await openAppSettings();
    final status = await Permission.notification.status;
    _notificationStatus = status;
    notifyListeners();
  }

  Future<void> setScheduledTime(
    TimeOfDayValues timeOfDay,
    DateTime time,
  ) async {
    if (!_notificationStatus.isGranted) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    final NotificationTimeData timeData =
        NotificationTimeData.parseFromDateTime(time);
    await prefs.setString(key, timeData.toString());
    _notificationTimes[timeOfDay] = NotificationTimeData.parseFromDateTime(
      time,
    );
    notifyListeners();
  }

  Future<void> resetScheduledTime(TimeOfDayValues timeOfDay) async {
    if (!_notificationStatus.isGranted) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    final defaultNotificationTime = _defaultNotificationTimes[timeOfDay]!;
    await prefs.setString(key, defaultNotificationTime.toString());
    _notificationTimes[timeOfDay] = defaultNotificationTime;
    notifyListeners();
  }

  Future<void> resetAllScheduledTimes() async {
    if (!_notificationStatus.isGranted) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    for (final timeOfDay in TimeOfDayValues.values) {
      final key = _notificationMapIds[timeOfDay]!.toString();
      final defaultNotificationTime = _defaultNotificationTimes[timeOfDay]!;
      await prefs.setString(key, defaultNotificationTime.toString());

      // Only reschedule if notification is already scheduled
      final DateTime? scheduledTime = await _notificationService
          .getScheduledNotifcationTime(timeOfDay);
      if (scheduledTime != null) {
        await _notificationService.cancelDailyNotification(timeOfDay);
        await _notificationService.scheduleDailyNotification(
          timeOfDay,
          defaultNotificationTime.toDateTime(),
        );
      }

      _notificationTimes[timeOfDay] = defaultNotificationTime;
    }
    notifyListeners();
  }

  Future<void> scheduleDailyNotification({
    required TimeOfDayValues timeOfDay,
    DateTime? scheduledTime,
  }) async {
    scheduledTime ??= _notificationTimes[timeOfDay]!.toDateTime();
    await _notificationService.scheduleDailyNotification(
      timeOfDay,
      scheduledTime,
    );
  }

  Future<void> cancelAllDailyNotifications() async {
    _notificationTimes.forEach(
      (key, value) => _notificationTimes[key] = _defaultNotificationTimes[key]!,
    );
    await _notificationService.cancelAllDailyNotifications();
    notifyListeners();
  }

  Future<void> cancelDailyNotification(TimeOfDayValues timeOfDay) async {
    await _notificationService.cancelDailyNotification(timeOfDay);
  }
}
