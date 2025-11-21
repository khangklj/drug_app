import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool positive = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        title: Text("Cài đặt", style: Theme.of(context).textTheme.titleLarge),
      ),
      drawer: MediAppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchThemeWidget(),
              const SizedBox(height: 15.0),
              const Divider(thickness: 1.2),
              const SizedBox(height: 15.0),
              // _buildScanningModeWidget(),
              // const SizedBox(height: 15.0),
              // const Divider(thickness: 1.2),
              // const SizedBox(height: 15.0),
              _buildSelectSceduleTimeWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchThemeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Giao diện", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 15.0),
        Consumer<SettingsManager>(
          builder: (context, manager, child) => AnimatedToggleSwitch<bool>.dual(
            current: manager.isDarkTheme,
            first: false,
            second: true,
            style: const ToggleStyle(
              borderColor: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            borderWidth: 5.0,
            onChanged: (value) {
              manager.toggleTheme();
            },
            styleBuilder: (b) => ToggleStyle(
              backgroundColor: b
                  ? const Color.fromARGB(255, 26, 6, 61)
                  : const Color.fromARGB(255, 63, 60, 219),
              indicatorColor: b ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(4.0),
                right: Radius.circular(50.0),
              ),
              indicatorBorderRadius: BorderRadius.circular(b ? 50.0 : 4.0),
            ),
            iconBuilder: (value) => Icon(
              value ? Icons.dark_mode : Icons.light_mode,
              size: 35.0,
              color: value ? Colors.white : Colors.amberAccent,
            ),
            textBuilder: (value) => value
                ? Center(
                    child: Text(
                      'TỐI',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : Center(
                    child: Text(
                      'SÁNG',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.white),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Widget _buildScanningModeWidget() {
  //   return Consumer<SettingsManager>(
  //     builder: (context, settingsManager, child) => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Chức năng quét nhanh',
  //           style: Theme.of(context).textTheme.titleLarge,
  //         ),
  //         RadioListTile<ScanningModes>(
  //           value: ScanningModes.camera,
  //           groupValue: settingsManager.scanningMode,
  //           onChanged: (value) {
  //             settingsManager.toogleScanningOptions(value!);
  //           },
  //           title: Text.rich(
  //             TextSpan(
  //               children: [
  //                 TextSpan(
  //                   text: 'Luôn chọn ảnh từ ',
  //                   style: Theme.of(context).textTheme.bodyLarge,
  //                 ),
  //                 TextSpan(
  //                   text: 'camera',
  //                   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         RadioListTile<ScanningModes>(
  //           value: ScanningModes.gallery,
  //           groupValue: settingsManager.scanningMode,
  //           onChanged: (value) {
  //             settingsManager.toogleScanningOptions(value!);
  //           },
  //           title: Text.rich(
  //             TextSpan(
  //               children: [
  //                 TextSpan(
  //                   text: 'Luôn chọn ảnh từ ',
  //                   style: Theme.of(context).textTheme.bodyLarge,
  //                 ),
  //                 TextSpan(
  //                   text: 'thư viện ảnh',
  //                   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         RadioListTile<ScanningModes>(
  //           value: ScanningModes.both,
  //           groupValue: settingsManager.scanningMode,
  //           onChanged: (value) {
  //             settingsManager.toogleScanningOptions(value!);
  //           },
  //           title: Text.rich(
  //             TextSpan(
  //               children: [
  //                 TextSpan(
  //                   text: 'Chọn ảnh từ ',
  //                   style: Theme.of(context).textTheme.bodyLarge,
  //                 ),
  //                 TextSpan(
  //                   text: 'camera',
  //                   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 TextSpan(
  //                   text: ' hoặc ',
  //                   style: Theme.of(context).textTheme.bodyLarge,
  //                 ),
  //                 TextSpan(
  //                   text: 'thư viện ảnh',
  //                   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSelectSceduleTimeWidget() {
    return Consumer<NotificationManager>(
      builder: (context, manager, child) {
        return Column(
          spacing: 6.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thông báo", style: Theme.of(context).textTheme.titleLarge),

            Table(
              columnWidths: const {
                0: FlexColumnWidth(),
                1: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                if (manager.notificationStatus.isGranted)
                  TableRow(
                    children: [
                      Text("Đã cấp quyền thông báo"),
                      const Icon(Icons.check_circle),
                    ],
                  )
                else if (manager.notificationStatus.isDenied)
                  TableRow(
                    children: [
                      Text("Chưa được cấp quyền thông báo"),
                      TextButton.icon(
                        icon: const Icon(Icons.notifications_active_outlined),
                        onPressed: manager.requestNotificationPermission,
                        label: const Text("Bật thông báo"),
                      ),
                    ],
                  )
                else if (manager.notificationStatus.isPermanentlyDenied)
                  TableRow(
                    children: [
                      Text("Thông báo đã bị tắt"),
                      TextButton.icon(
                        icon: const Icon(Icons.settings),
                        onPressed:
                            manager.requestPermanentNotificationPermission,
                        label: const Text("Chỉnh sửa"),
                      ),
                    ],
                  )
                else
                  TableRow(
                    children: [
                      Text("Không truy cập được quyền thông báo"),
                      TextButton.icon(
                        icon: const Icon(Icons.settings),
                        onPressed:
                            manager.requestPermanentNotificationPermission,
                        label: const Text("Chỉnh sửa"),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              "Mốc thời gian thông báo",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5), // For the TimeOfDay Text
                1: FlexColumnWidth(2.5), // For the scheduled time Text
                2: FlexColumnWidth(2.0), // For the TextButton
              },
              children: TimeOfDayValues.values.map((timeOfDay) {
                final currentTime = manager.notificationTimes[timeOfDay];
                return TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Text(
                        timeOfDay.toDisplayString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: currentTime == null
                          ? Text("Chưa đặt thời gian")
                          : Text(
                              DateFormat(
                                'HH:mm:ss',
                              ).format(currentTime.toDateTime()),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: TextButton(
                        onPressed: () {
                          DatePicker.showTimePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (newTime) {
                              final otherTimes = manager
                                  .notificationTimes
                                  .entries
                                  .where((entry) => entry.key != timeOfDay)
                                  .map((entry) => entry.value)
                                  .toList();

                              // Compare hour, minute and second with others times
                              if (otherTimes.any(
                                (otherTime) =>
                                    otherTime!.hour == newTime.hour &&
                                    otherTime.minute == newTime.minute &&
                                    otherTime.second == newTime.second,
                              )) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.scale,
                                  title: 'Đặt mốc thời gian',
                                  desc: 'Thời gian này đã được sử dụng',
                                  btnOkOnPress: () {},
                                  btnOkIcon: Icons.check_circle,
                                  btnOkText: 'OK',
                                ).show();
                                return;
                              }

                              if (!manager.notificationStatus.isGranted) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.scale,
                                  title: 'Đặt thời gian',
                                  desc:
                                      'Chưa được cấp quyền thông báo.\nVui lòng cấp quyền để sử dụng',
                                  btnOkOnPress: () {},
                                  btnOkIcon: Icons.check_circle,
                                  btnOkText: 'OK',
                                ).show();
                                return;
                              }

                              manager.setScheduledTime(timeOfDay, newTime);
                              final activeNotificationTimes = context
                                  .read<DrugPrescriptionManager>()
                                  .getActiveNotificationTimes();
                              if (activeNotificationTimes.contains(timeOfDay)) {
                                manager.scheduleDailyNotification(
                                  timeOfDay: timeOfDay,
                                  scheduledTime: newTime,
                                );
                              }
                            },
                            currentTime: DateTime.now(),
                            locale: LocaleType.vi,
                          );
                        },
                        child: Text(
                          'Chọn thời gian',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () async {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.scale,
                    title: 'Đặt lại mốc thời gian',
                    desc:
                        'Thao tác này sẽ đặt lại tất cả các mốc thời gian. Bạn có muốn tiếp tục không?',
                    btnOkOnPress: () async {
                      if (!manager.notificationStatus.isGranted) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.scale,
                          title: 'Đặt thời gian',
                          desc:
                              'Chưa được cấp quyền thông báo.\nVui lòng cấp quyền để sử dụng',
                          btnOkOnPress: () {},
                          btnOkIcon: Icons.check_circle,
                          btnOkText: 'OK',
                        ).show();
                        return;
                      }
                      await manager.resetAllScheduledTimes();
                    },
                    btnCancelOnPress: () async {},
                    btnOkIcon: Icons.check_circle,
                    btnOkText: 'Đồng ý',
                    btnCancelText: 'Từ chối',
                  ).show();
                },
                label: Text(
                  "Đặt lại tất cả mốc thời gian",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  ),
                ),
              ),
            ),

            // Align(
            //   alignment: Alignment.center,
            //   child: TextButton.icon(
            //     onPressed: () async {
            //       await NotificationService().printAllPendingNotifications();
            //     },
            //     label: Text("LOGGING"),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
