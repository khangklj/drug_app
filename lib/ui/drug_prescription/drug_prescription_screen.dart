import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/notification_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_modal_bottom_sheet_icon.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/ui/patient/patient_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum _FilterDrugPrescriptionOptions { all, active, inActive }

enum _SortDrugPrescriptionOptions { nodAsc, nodDesc }

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
  late _SortDrugPrescriptionOptions _sortOption;
  late _FilterDrugPrescriptionOptions _filterOption;
  late Patient? _filterPatient;
  final _filterPatientTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sortOption = _SortDrugPrescriptionOptions.nodAsc;
    _filterOption = _FilterDrugPrescriptionOptions.all;
    _filterPatient = null;
    _filterPatientTextController.text = "Tất cả";
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

  (List<DrugPrescription>, List<DrugPrescription>) _applySortAndFilter(
    List<DrugPrescription> original, {
    required _SortDrugPrescriptionOptions sortOption,
    required _FilterDrugPrescriptionOptions filterStatusOption,
  }) {
    final List<DrugPrescription> newList = original
        .where((dp) {
          // Filter
          if (filterStatusOption == _FilterDrugPrescriptionOptions.active) {
            return dp.isActive;
          } else if (filterStatusOption ==
              _FilterDrugPrescriptionOptions.inActive) {
            return !dp.isActive;
          } else {
            return true;
          }
        })
        .where((dp) {
          if (_filterPatient == null) return true;
          return dp.patient!.id == _filterPatient!.id;
        })
        .toList();

    final activeDPs = newList.where((dp) => dp.isActive).sorted((a, b) {
      if (_sortOption == _SortDrugPrescriptionOptions.nodAsc) {
        return b.activeDate!.compareTo(a.activeDate!);
      } else if (_sortOption == _SortDrugPrescriptionOptions.nodDesc) {
        return a.activeDate!.compareTo(b.activeDate!);
      }

      return b.activeDate!.compareTo(a.activeDate!);
    }).toList();
    final inactiveDPs = newList.where((dp) => !dp.isActive).toList();

    return (activeDPs, inactiveDPs);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrugPrescription> drugPrescriptions = context
        .watch<DrugPrescriptionManager>()
        .drugPrescriptions;
    final patients = context.watch<PatientManager>().patients;

    final (activeDPs, inactiveDPs) = _applySortAndFilter(
      drugPrescriptions,
      sortOption: _sortOption,
      filterStatusOption: _filterOption,
    );

    final dpsListFilteredByStatus =
        _filterOption == _FilterDrugPrescriptionOptions.active
        ? activeDPs
        : inactiveDPs;

    return Scaffold(
      appBar: AppBar(elevation: 4.0, title: const Text("Quản lý toa thuốc")),
      drawer: MediAppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddingOptions();
        },
        child: const Icon(Icons.add),
      ),
      body: patients.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Chưa có người bệnh\n Vui lòng thêm người bệnh trước khi dùng chức năng này",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_right_alt),
                      label: Text("Chuyển đến trang"),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popAndPushNamed(PatientScreen.routeName);
                      },
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(height: 1.6),
                                  ),
                                  TextSpan(
                                    text: "cài đặt",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.filter_list_alt),
                        const SizedBox(width: 5),
                        Text(
                          "Bộ lọc",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    DropdownMenu(
                      width: double.infinity,
                      label: const Text("Trạng thái theo dõi"),
                      initialSelection: _filterOption,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          label: "Tất cả",
                          value: _FilterDrugPrescriptionOptions.all,
                          trailingIcon:
                              _filterOption ==
                                  _FilterDrugPrescriptionOptions.all
                              ? const Icon(Icons.check)
                              : null,
                        ),
                        DropdownMenuEntry(
                          label: "Đang theo dõi",
                          value: _FilterDrugPrescriptionOptions.active,
                          trailingIcon:
                              _filterOption ==
                                  _FilterDrugPrescriptionOptions.active
                              ? const Icon(Icons.check)
                              : null,
                        ),
                        DropdownMenuEntry(
                          label: "Không theo dõi",
                          value: _FilterDrugPrescriptionOptions.inActive,
                          trailingIcon:
                              _filterOption ==
                                  _FilterDrugPrescriptionOptions.inActive
                              ? const Icon(Icons.check)
                              : null,
                        ),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _filterOption = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownMenu(
                      menuHeight: 200,
                      enableSearch: true,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      width: double.infinity,
                      label: const Text("Người bệnh"),
                      initialSelection: _filterPatient,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          label: "Tất cả",
                          value: null,
                          trailingIcon: _filterPatient == null
                              ? const Icon(Icons.check)
                              : null,
                        ),
                        ...patients.map((patient) {
                          return DropdownMenuEntry(
                            label: patient.name!,
                            value: patient,
                            trailingIcon: _filterPatient == patient
                                ? const Icon(Icons.check)
                                : null,
                          );
                        }),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _filterPatient = value;
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Expanded(child: const Divider(thickness: 5)),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            icon:
                                _sortOption ==
                                    _SortDrugPrescriptionOptions.nodAsc
                                ? const Icon(Icons.arrow_upward)
                                : const Icon(Icons.arrow_downward),
                            label: Text("Số ngày theo dõi"),
                            onPressed: () {
                              setState(() {
                                _sortOption =
                                    _sortOption ==
                                        _SortDrugPrescriptionOptions.nodAsc
                                    ? _SortDrugPrescriptionOptions.nodDesc
                                    : _SortDrugPrescriptionOptions.nodAsc;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_filterOption ==
                        _FilterDrugPrescriptionOptions.all) ...[
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
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
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
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontStyle: FontStyle.italic),
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
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
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
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dpsListFilteredByStatus.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final drugPrescription =
                              dpsListFilteredByStatus[index];
                          final groupedDPItems = groupDPItemsByTimeOfDay(
                            drugPrescription,
                          );
                          return ExpansionTileDrugPrescription(
                            drugPrescription: drugPrescription,
                            groupedDPItems: groupedDPItems,
                          );
                        },
                      ),

                      if (dpsListFilteredByStatus.isEmpty) ...[
                        Text(
                          "Không có toa thuốc nào thuộc mục này",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
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
    final int? numberOfDay = drugPrescription.isActive
        ? DateTime.now().difference(drugPrescription.activeDate!).inDays
        : null;
    return ExpansionTile(
      title: Text(drugPrescription.customName!),
      subtitle: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text:
                  "của ${drugPrescription.patient!.name!} - ${drugPrescription.patient!.year!}",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (numberOfDay != null) ...[
              TextSpan(text: "\nĐã theo dõi được "),
              TextSpan(
                text: "$numberOfDay ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "ngày."),
            ],
          ],
        ),
      ),

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
            shape: Border(),
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
