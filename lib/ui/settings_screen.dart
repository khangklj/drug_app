import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/notification_service.dart';
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
              _buildScanningModeWidget(),
              const SizedBox(height: 15.0),
              const Divider(thickness: 1.2),
              const SizedBox(height: 15.0),
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

  Widget _buildScanningModeWidget() {
    return Consumer<SettingsManager>(
      builder: (context, settingsManager, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chức năng quét nhanh',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          RadioListTile<ScanningModes>(
            value: ScanningModes.camera,
            groupValue: settingsManager.scanningMode,
            onChanged: (value) {
              settingsManager.toogleScanningOptions(value!);
            },
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Luôn chọn ảnh từ ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'camera',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          RadioListTile<ScanningModes>(
            value: ScanningModes.gallery,
            groupValue: settingsManager.scanningMode,
            onChanged: (value) {
              settingsManager.toogleScanningOptions(value!);
            },
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Luôn chọn ảnh từ ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'thư viện ảnh',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          RadioListTile<ScanningModes>(
            value: ScanningModes.both,
            groupValue: settingsManager.scanningMode,
            onChanged: (value) {
              settingsManager.toogleScanningOptions(value!);
            },
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Chọn ảnh từ ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'camera',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' hoặc ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'thư viện ảnh',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSceduleTimeWidget() {
    return Consumer<NotificationManager>(
      builder: (context, manager, child) {
        return Column(
          spacing: 6.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thông báo", style: Theme.of(context).textTheme.titleLarge),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (manager.notificationStatus.isGranted) ...[
                  Text("Ứng dụng đã được cấp quyền thông báo"),
                  const Icon(Icons.check_circle),
                ] else if (manager.notificationStatus.isDenied) ...[
                  Text("Ứng dụng chưa được cấp quyền thông báo"),
                  TextButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    onPressed: manager.requestNotificationPermission,
                    label: Text("Bật thông báo"),
                  ),
                ] else if (manager.notificationStatus.isPermanentlyDenied) ...[
                  Text("Thông báo đã bị tắt"),
                  TextButton.icon(
                    icon: const Icon(Icons.settings),
                    onPressed: manager.requestPermanentNotificationPermission,
                    label: Text("Chỉnh sửa"),
                  ),
                ] else ...[
                  Text("Không truy cập được quyền thông báo"),
                  TextButton.icon(
                    icon: const Icon(Icons.settings),
                    onPressed: manager.requestPermanentNotificationPermission,
                    label: Text("Chỉnh sửa"),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              "Mốc thời gian thông báo",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...TimeOfDayValues.values.map((timeOfDay) {
              final scheduledTime = manager.notificationTimes[timeOfDay];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(timeOfDay.toDisplayString()),
                  if (scheduledTime == null) ...[
                    Text("Chưa đặt thời gian"),
                  ] else ...[
                    Text(DateFormat('HH:mm:ss').format(scheduledTime)),
                  ],
                  TextButton(
                    onPressed: () {
                      DatePicker.showTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (newScheduledTime) {
                          manager.setScheduledTime(timeOfDay, newScheduledTime);
                          final activeNotifcationTimes = context
                              .read<DrugPrescriptionManager>()
                              .getActiveNotificationTimes();
                          if (activeNotifcationTimes.contains(timeOfDay)) {
                            manager.scheduleDailyNotification(timeOfDay);
                          }
                        },
                        currentTime: scheduledTime ?? DateTime.now(),
                        locale: LocaleType.vi,
                      );
                    },
                    child: Text(
                      'Chọn thời gian',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              );
            }),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () async {
                  await manager.removeAllScheduledTimes();
                },
                label: Text("Đặt lại tất cả mốc thời gian"),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () async {
                  await NotificationService().printAllPendingNotifications();
                },
                label: Text("LOGGING"),
              ),
            ),
          ],
        );
      },
    );
  }
}
