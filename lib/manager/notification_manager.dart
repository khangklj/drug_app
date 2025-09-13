import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationManager with ChangeNotifier {
  late PermissionStatus _notificationStatus;
  late final NotificationService _notificationService;
  late final Map<TimeOfDayValues, DateTime> _notificationTimes;

  PermissionStatus get notificationStatus => _notificationStatus;
  Map<TimeOfDayValues, DateTime> get notificationTimes => _notificationTimes;

  NotificationManager({
    required PermissionStatus notificationStatus,
    required Map<TimeOfDayValues, DateTime> notificationTimes,
  }) {
    _notificationStatus = notificationStatus;
    _notificationTimes = notificationTimes;
    _notificationService = NotificationService();
  }

  Future<void> updateNotification(DrugPrescriptionManager dpManager) async {
    final activeNotificationTimes = dpManager.getActiveNotificationTimes();
    final inactiveNotificationTimes = TimeOfDayValues.values
        .toSet()
        .difference(activeNotificationTimes.toSet())
        .toList();
    for (final activeNotificationTime in activeNotificationTimes) {
      scheduleDailyNotification(activeNotificationTime);
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
    _notificationTimes[timeOfDay] = time;
    //TODO: store time here
    notifyListeners();
  }

  Future<void> cancelAllDailyNotifications() async {
    _notificationTimes.forEach(
      (key, value) => _notificationTimes[key] =
          NotificationService().defaultNotificationTimes[key]!,
    );
    await _notificationService.cancelAllDailyNotifications();
    notifyListeners();
  }

  Future<void> scheduleDailyNotification(TimeOfDayValues timeOfDay) async {
    final scheduledTime = _notificationTimes[timeOfDay];
    if (scheduledTime == null) return;
    await _notificationService.scheduleDailyNotification(
      timeOfDay,
      scheduledTime,
    );
  }

  Future<void> cancelDailyNotification(TimeOfDayValues timeOfDay) async {
    await _notificationService.cancelDailyNotification(timeOfDay);
  }
}
