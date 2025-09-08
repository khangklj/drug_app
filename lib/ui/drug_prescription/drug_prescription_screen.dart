import 'package:flutter/material.dart';

// child: TextButton(
//   onPressed: () async {
//     final hasPermission = await requestScheduleExactAlarmPermission();
//     if (!hasPermission) {
//       //TODO: show error message on denied permission
//       var logger = Logger();
//       logger.e('ScheduleExactAlarm Permission denied');
//       return;
//     }
//     await AndroidAlarmManager.oneShot(
//       const Duration(seconds: 5),
//       wakeup: true,
//       0,
//       AlarmService.playAlarm,
//     );
//   },
//   child: const Text('Set Alarm'),
// ),

// Future<bool> requestScheduleExactAlarmPermission() async {
//     var status = await Permission.scheduleExactAlarm.status;
//     if (status.isDenied) {
//       status = await Permission.scheduleExactAlarm.request();
//     } else if (status.isPermanentlyDenied) {
//       await openAppSettings();
//     }
//     if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
//       return false;
//     }
//     return true;
//   }

class DrugPrescriptionScreen extends StatelessWidget {
  const DrugPrescriptionScreen({super.key});
  static const routeName = '/drug_prescription';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 4.0,
        title: const Text("Quản lý toa thuốc"),
      ),
      body: Center(),
    );
  }
}
