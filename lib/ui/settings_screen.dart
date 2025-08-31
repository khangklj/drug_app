import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:flutter/material.dart';
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
    final settingsManager = context.read<SettingsManager>();
    final isDarkTheme = context.watch<SettingsManager>().isDarkTheme;
    final scanningMode = context.watch<SettingsManager>().scanningMode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 4.0,
        title: Text("Cài đặt", style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Giao diện",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 15.0),
                  AnimatedToggleSwitch<bool>.dual(
                    current: isDarkTheme,
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
                      settingsManager.toggleTheme();
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
                      indicatorBorderRadius: BorderRadius.circular(
                        b ? 50.0 : 4.0,
                      ),
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
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              const Divider(thickness: 1.2),
              const SizedBox(height: 15.0),
              Text(
                'Chức năng quét nhanh',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              RadioListTile<ScanningModes>(
                value: ScanningModes.camera,
                groupValue: scanningMode,
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
                groupValue: scanningMode,
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
                groupValue: scanningMode,
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
        ),
      ),
    );
  }
}
