import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class DrugPrescriptionScreen extends StatefulWidget {
  const DrugPrescriptionScreen({super.key});
  static const routeName = '/drug_prescription';

  @override
  State<DrugPrescriptionScreen> createState() => _DrugPrescriptionScreenState();
}

class _DrugPrescriptionScreenState extends State<DrugPrescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    final List<DrugPrescription> drugPrescriptions = context
        .watch<DrugPrescriptionManager>()
        .drugPrescriptions;
    return Scaffold(
      appBar: AppBar(elevation: 4.0, title: const Text("Quản lý toa thuốc")),
      drawer: MediAppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(DrugPrescriptionEditScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: drugPrescriptions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(drugPrescriptions[index].customName!),
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          DrugPrescriptionEditScreen.routeName,
                          arguments: drugPrescriptions[index],
                        );
                      },
                      child: Text("Xem chi tiết..."),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
