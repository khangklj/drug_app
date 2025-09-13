import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager with ChangeNotifier {
  late PermissionStatus _notificationStatus;
  late final NotificationService _notificationService;
  late final Map<TimeOfDayValues, DateTime?> _notificationTimes;
  late final Map<TimeOfDayValues, DateTime> _defaultNotificationTimes;
  final Map<TimeOfDayValues, int> _notificationMapIds = {
    TimeOfDayValues.morning: 1312,
    TimeOfDayValues.noon: 1313,
    TimeOfDayValues.afternoon: 1314,
    TimeOfDayValues.evening: 1315,
  };

  PermissionStatus get notificationStatus => _notificationStatus;
  Map<TimeOfDayValues, DateTime?> get notificationTimes => _notificationTimes;

  Future<void> initSettings() async {
    _notificationService = NotificationService();
    _notificationStatus = await Permission.notification.status;
    _notificationTimes = {};

    _defaultNotificationTimes = {
      TimeOfDayValues.morning: _notificationService.nextInstanceOfDailyReminder(
        DateTime.now().copyWith(hour: 6, minute: 0, second: 0),
      ),
      TimeOfDayValues.noon: _notificationService.nextInstanceOfDailyReminder(
        DateTime.now().copyWith(hour: 11, minute: 0, second: 0),
      ),
      TimeOfDayValues.afternoon: _notificationService
          .nextInstanceOfDailyReminder(
            DateTime.now().copyWith(hour: 16, minute: 0, second: 0),
          ),
      TimeOfDayValues.evening: _notificationService.nextInstanceOfDailyReminder(
        DateTime.now().copyWith(hour: 21, minute: 0, second: 0),
      ),
    };

    final prefs = await SharedPreferences.getInstance();
    for (final timeOfDay in TimeOfDayValues.values) {
      final key = _notificationMapIds[timeOfDay]!.toString();
      final time = prefs.getString(key);
      if (time != null) {
        _notificationTimes[timeOfDay] = DateTime.parse(time).toLocal();
      } else {
        final DateTime? defaultTime = _defaultNotificationTimes[timeOfDay];
        _notificationTimes[timeOfDay] = defaultTime;
        await prefs.setString(key, defaultTime!.toIso8601String());
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

  Future<void> checkPermissionStatus() async {
    final status = await Permission.notification.status;
    _notificationStatus = status;
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    if (_notificationStatus.isGranted) return;

    final status = await Permission.notification.request();
    _notificationStatus = status;
    notifyListeners();
  }

  Future<void> requestPermanentNotificationPermission() async {
    await openAppSettings();
    await checkPermissionStatus();
  }

  Future<void> setScheduledTime(
    TimeOfDayValues timeOfDay,
    DateTime time,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    await prefs.setString(key, time.toIso8601String());
    _notificationTimes[timeOfDay] = time;
    notifyListeners();
  }

  Future<void> resetScheduledTime(TimeOfDayValues timeOfDay) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notificationMapIds[timeOfDay]!.toString();
    final defaultNotificationTime = _defaultNotificationTimes[timeOfDay]!;
    await prefs.setString(key, defaultNotificationTime.toIso8601String());
    _notificationTimes[timeOfDay] = defaultNotificationTime;
    notifyListeners();
  }

  Future<void> resetAllScheduledTimes() async {
    final prefs = await SharedPreferences.getInstance();
    for (final timeOfDay in TimeOfDayValues.values) {
      final key = _notificationMapIds[timeOfDay]!.toString();
      final defaultNotificationTime = _defaultNotificationTimes[timeOfDay]!;
      await prefs.setString(key, defaultNotificationTime.toIso8601String());

      // Only reschedule if notification is already scheduled
      final DateTime? scheduledTime = await _notificationService
          .getScheduledNotifcationTime(timeOfDay);
      if (scheduledTime != null) {
        await _notificationService.cancelDailyNotification(timeOfDay);
        await _notificationService.scheduleDailyNotification(
          timeOfDay,
          defaultNotificationTime,
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
    scheduledTime ??= _notificationTimes[timeOfDay]!;
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
