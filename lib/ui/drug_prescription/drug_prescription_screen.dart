import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_modal_bottom_sheet_icon.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum FilterDrugPrescriptionOptions { all, active, notActive }

enum SortDrugPrescriptionOptions { nameAZ, nameZA }

Map<String, List<DrugPrescriptionItem>> groupDPItemsByTimeOfDay(
  DrugPrescription dp,
) {
  Map<String, List<DrugPrescriptionItem>> groupItems = groupBy(
    dp.items,
    (item) => item.timeOfDay.toString(),
  );
  // Sort by drugName
  groupItems.forEach(
    (key, value) => value.sort((a, b) => a.drugName.compareTo(b.drugName)),
  );
  return groupItems;
}

class DrugPrescriptionScreen extends StatefulWidget {
  const DrugPrescriptionScreen({super.key});
  static const routeName = '/drug_prescription';

  @override
  State<DrugPrescriptionScreen> createState() => _DrugPrescriptionScreenState();
}

class _DrugPrescriptionScreenState extends State<DrugPrescriptionScreen> {
  late SortDrugPrescriptionOptions _sortOption;
  late FilterDrugPrescriptionOptions _filterOption;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _sortOption = SortDrugPrescriptionOptions.nameAZ;
    _filterOption = FilterDrugPrescriptionOptions.all;
  }

  void _showAddingOptions() {
    void handlePickedFile(File? file) async {
      if (file != null && mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const MediAppLoadingDialog();
          },
        );
        // List<DrugPrescriptionItem>? dpItems = await OcrService()
        //     .postDrugPrescriptionImage(file);
        final dp = await OcrService().postDrugPrescriptionImage(file);
        if (dp == null) {
          if (mounted) {
            Navigator.of(context).pop();
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.scale,
              headerAnimationLoop: false,
              title: "Lỗi kết nối",
              desc: "Vui lòng thử lại.",
              btnOkText: "OK",
              btnOkOnPress: () {},
              btnOkColor: Theme.of(context).colorScheme.primaryContainer,
              onDismissCallback: (type) {
                return;
              },
            ).show();
          }
          return;
        }
        // DrugPrescription newDP = DrugPrescription(
        //   id: null,
        //   customName: null,
        //   deviceId: null,
        //   isActive: true,
        //   items: dpItems,
        // );
        if (mounted) {
          Navigator.of(context).popAndPushNamed(
            DrugPrescriptionEditScreen.routeName,
            arguments: dp,
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Chọn phương thức thêm toa thuốc",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 100,
                    child: MediAppModalBottomSheetIcon(
                      text: Text("Thủ công"),
                      icon: Icon(Icons.edit_outlined),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).popAndPushNamed(DrugPrescriptionEditScreen.routeName);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: MediAppModalBottomSheetIcon(
                      text: Text("Camera"),
                      icon: Icon(Icons.camera_alt_outlined),
                      onTap: () async {
                        final pickedFile = await pickImage(ImageSource.camera);
                        handlePickedFile(pickedFile);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: MediAppModalBottomSheetIcon(
                      text: Text("Thư viện ảnh"),
                      icon: Icon(Icons.photo_library_outlined),
                      onTap: () async {
                        final pickedFile = await pickImage(ImageSource.gallery);
                        handlePickedFile(pickedFile);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<DrugPrescription> _applySortAndFilter(
    List<DrugPrescription> original, {
    required SortDrugPrescriptionOptions sortOption,
    required FilterDrugPrescriptionOptions filterOption,
  }) {
    final List<DrugPrescription> newList = original
        .sorted((a, b) {
          // Sort
          if (sortOption == SortDrugPrescriptionOptions.nameAZ) {
            return a.customName!.compareTo(b.customName!);
          } else if (sortOption == SortDrugPrescriptionOptions.nameZA) {
            return b.customName!.compareTo(a.customName!);
          } else {
            return a.customName!.compareTo(b.customName!);
          }
        })
        .where((dp) {
          // Filter
          if (filterOption == FilterDrugPrescriptionOptions.active) {
            return dp.isActive;
          } else if (filterOption == FilterDrugPrescriptionOptions.notActive) {
            return !dp.isActive;
          } else {
            return true;
          }
        })
        .toList();

    return newList;
  }

  @override
  Widget build(BuildContext context) {
    final List<DrugPrescription> drugPrescriptions = context
        .watch<DrugPrescriptionManager>()
        .drugPrescriptions;
    final patients = context.watch<PatientManager>().patients;
    final sortedAndFilteredDPs = _applySortAndFilter(
      drugPrescriptions,
      sortOption: _sortOption,
      filterOption: _filterOption,
    );
    final activeDPs = sortedAndFilteredDPs.where((dp) => dp.isActive).toList();
    final inactiveDPs = sortedAndFilteredDPs
        .where((dp) => !dp.isActive)
        .toList();

    if (patients.isEmpty && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dialogShown = true;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // TODO: Implement dialog to navigate to patient screen
            );
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        title: const Text("Quản lý toa thuốc"),
        actions: [
          SortDPPopUpMenuButton(
            sortOption: _sortOption,
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
          ),
          FilterDPPopUpMenuButton(
            filterOption: _filterOption,
            onSelected: (value) {
              setState(() {
                _filterOption = value;
              });
            },
          ),
        ],
      ),
      drawer: MediAppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddingOptions();
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<NotificationManager>(
              builder: (context, manager, child) {
                if (!manager.notificationStatus.isGranted) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "⚠️ Thông báo chưa được bật!\nVào ",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(height: 1.6),
                          ),
                          TextSpan(
                            text: "cài đặt",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(
                                  context,
                                ).pushNamed(SettingsScreen.routeName);
                              },
                          ),
                          TextSpan(
                            text: " để bật thông báo.",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 8),
            if (_filterOption == FilterDrugPrescriptionOptions.all) ...[
              ExpansionTile(
                initiallyExpanded: true,
                shape: const Border(),
                trailing: const Icon(Icons.add),
                title: Text(
                  "--- Đang theo dõi (${activeDPs.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeDPs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final drugPrescription = activeDPs[index];
                      final groupedDPItems = groupDPItemsByTimeOfDay(
                        drugPrescription,
                      );
                      return ExpansionTileDrugPrescription(
                        drugPrescription: drugPrescription,
                        groupedDPItems: groupedDPItems,
                      );
                    },
                  ),

                  if (activeDPs.isEmpty) ...[
                    Text(
                      "Không có toa thuốc nào thuộc mục này",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),

              ExpansionTile(
                initiallyExpanded: true,
                shape: const Border(),
                trailing: const Icon(Icons.add),
                title: Text(
                  "--- Không theo dõi (${inactiveDPs.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inactiveDPs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final drugPrescription = inactiveDPs[index];
                      final groupedDPItems = groupDPItemsByTimeOfDay(
                        drugPrescription,
                      );
                      return ExpansionTileDrugPrescription(
                        drugPrescription: drugPrescription,
                        groupedDPItems: groupedDPItems,
                      );
                    },
                  ),

                  if (inactiveDPs.isEmpty) ...[
                    Text(
                      "Không có toa thuốc nào thuộc mục này",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedAndFilteredDPs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final drugPrescription = sortedAndFilteredDPs[index];
                  final groupedDPItems = groupDPItemsByTimeOfDay(
                    drugPrescription,
                  );
                  return ExpansionTileDrugPrescription(
                    drugPrescription: drugPrescription,
                    groupedDPItems: groupedDPItems,
                  );
                },
              ),

              if (sortedAndFilteredDPs.isEmpty) ...[
                Text(
                  "Không có toa thuốc nào thuộc mục này",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class SortDPPopUpMenuButton extends StatelessWidget {
  const SortDPPopUpMenuButton({
    super.key,
    required SortDrugPrescriptionOptions sortOption,
    required this.onSelected,
  }) : _sortOption = sortOption;

  final SortDrugPrescriptionOptions _sortOption;
  final void Function(SortDrugPrescriptionOptions) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: _sortOption,
      onSelected: onSelected,
      icon: const Icon(Icons.sort),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SortDrugPrescriptionOptions.nameAZ,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sắp xếp tên A-Z"),
              if (_sortOption == SortDrugPrescriptionOptions.nameAZ) ...[
                const Icon(Icons.check),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: SortDrugPrescriptionOptions.nameZA,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sắp xếp tên Z-A"),
              if (_sortOption == SortDrugPrescriptionOptions.nameZA) ...[
                const Icon(Icons.check),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class FilterDPPopUpMenuButton extends StatelessWidget {
  const FilterDPPopUpMenuButton({
    super.key,
    required FilterDrugPrescriptionOptions filterOption,
    required this.onSelected,
  }) : _filterOption = filterOption;

  final FilterDrugPrescriptionOptions _filterOption;
  final void Function(FilterDrugPrescriptionOptions) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: _filterOption,
      onSelected: onSelected,
      icon: const Icon(Icons.filter_alt_outlined),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: FilterDrugPrescriptionOptions.all,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tất cả"),
              if (_filterOption == FilterDrugPrescriptionOptions.all) ...[
                Icon(Icons.check),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterDrugPrescriptionOptions.active,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Đang theo dõi"),
              if (_filterOption == FilterDrugPrescriptionOptions.active) ...[
                Icon(Icons.check),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: FilterDrugPrescriptionOptions.notActive,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Không theo dõi"),
              if (_filterOption == FilterDrugPrescriptionOptions.notActive) ...[
                Icon(Icons.check),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ExpansionTileDrugPrescription extends StatelessWidget {
  const ExpansionTileDrugPrescription({
    super.key,
    required this.drugPrescription,
    required this.groupedDPItems,
  });

  final DrugPrescription drugPrescription;
  final Map<String, List<DrugPrescriptionItem>> groupedDPItems;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(drugPrescription.customName!),
      childrenPadding: const EdgeInsets.only(left: 4.0),
      children: [
        ...TimeOfDayValues.values.map((timeOfDay) {
          final key = timeOfDay.toString();
          final timeOfDayTitle = timeOfDay.toDisplayString();
          if (!groupedDPItems.containsKey(key)) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(title: Text("$timeOfDayTitle - Không có")),
            );
          }
          return ExpansionTile(
            childrenPadding: const EdgeInsets.only(left: 24.0, right: 8.0),
            leading: const Icon(Icons.add),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(timeOfDayTitle),
            children: [
              Table(
                columnWidths: const {
                  0: FractionColumnWidth(0.6),
                  1: FractionColumnWidth(0.2),
                  2: FractionColumnWidth(0.2),
                },
                border: TableBorder.all(color: Colors.grey),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          "Tên thuốc",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "Số lượng",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "ĐVT",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...groupedDPItems[key]!.map((item) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(item.drugName),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              formatDoubleNumberToString(item.quantity!),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(child: Text(item.measurement!)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        }),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              DrugPrescriptionEditScreen.routeName,
              arguments: drugPrescription,
            );
          },
          child: Text("Xem chi tiết..."),
        ),
      ],
    );
  }
}

class CapsuleWidget extends StatelessWidget {
  final Color fillColor;
  final Color textColor;
  final String label;
  final double ribbonHeight;
  final double ribbonRadius;

  const CapsuleWidget({
    super.key,
    this.fillColor = Colors.white,
    this.textColor = Colors.black,
    required this.label,
    required this.ribbonHeight,
    this.ribbonRadius = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(height: ribbonHeight, color: fillColor),
        ),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(ribbonRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Expanded(
          child: Container(height: ribbonHeight, color: fillColor),
        ),
      ],
    );
  }
}
