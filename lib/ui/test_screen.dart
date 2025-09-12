import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  static const routeName = '/test';

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  DateTime? _pickedTime;
  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  onChanged: (time) {
                    print('change $time');
                  },
                  onConfirm: (time) {
                    _pickedTime = time;
                    print('confirm $time');
                    setState(() {});
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.vi,
                );
              },
              child: Text(
                'show date time picker',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await notificationService.requestNotificationPermission();
                await notificationService.showInstantNotification(
                  title: 'Hello!',
                  body: 'This is an instant notification',
                  payload: '/reminder',
                );
              },
              child: Text('Show Instant Notification'),
            ),
            ElevatedButton(
              onPressed: () async {
                await notificationService.scheduleNotification(
                  title: 'Reminder',
                  body: 'Check this after 5 seconds',
                  delay: Duration(seconds: 5),
                  payload: '/reminder',
                );
              },
              child: Text('Schedule Notification'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_pickedTime == null) return;
                await notificationService.scheduleDailyNotification(
                  TimeOfDayValues.morning,
                  _pickedTime!,
                );
              },
              child: Text('Schedule At Time'),
            ),

            ElevatedButton(
              onPressed: () async {
                await notificationService.cancelAllNotifications();
              },
              child: Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }
}
