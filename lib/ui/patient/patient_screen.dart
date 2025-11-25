import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});
  static const routeName = '/patient';

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final _patientYearTextController = TextEditingController();

  void _showEditPatientDialog(BuildContext context, {Patient? patient}) {
    final formKey = GlobalKey<FormState>();
    late bool isEditState;
    DateTime selectedDate;
    if (patient == null || patient.year == null) {
      patient = Patient(gender: "male", year: DateTime.now().year);
      selectedDate = DateTime.now();
      isEditState = false;
    } else {
      selectedDate = DateTime(patient.year!);
      isEditState = true;
    }
    _patientYearTextController.text = selectedDate.year.toString();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<PatientManager>(
          builder: (context, patientManger, child) {
            return AlertDialog(
              title: const Text("Thông tin người bệnh"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          initialValue: patient?.name ?? "",
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên',
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          onChanged: (value) {
                            setState(() {
                              patient = patient!.copyWith(name: value);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            if (patient?.id == null) {
                              return patientManger.patients.any(
                                    (patient) => patient.name == value,
                                  )
                                  ? 'Họ và tên đã được dùng'
                                  : null;
                            } else if (patient!.id != null) {
                              return patientManger.patients.any(
                                    (p) =>
                                        p.name == value && p.id != patient!.id,
                                  )
                                  ? 'Họ và tên đã được dùng'
                                  : null;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownMenuFormField(
                                label: const Text('Giới tính'),
                                initialSelection: patient?.gender ?? 'male',
                                dropdownMenuEntries: [
                                  DropdownMenuEntry(
                                    value: 'male',
                                    label: 'Nam',
                                  ),
                                  DropdownMenuEntry(
                                    value: 'female',
                                    label: 'Nữ',
                                  ),
                                ],
                                onSelected: (value) {
                                  setState(() {
                                    patient = patient!.copyWith(gender: value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: _patientYearTextController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Năm sinh',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Chọn năm sinh"),
                                        content: SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: YearPicker(
                                            firstDate: DateTime(
                                              DateTime.now().year - 100,
                                              1,
                                            ),
                                            lastDate: DateTime(
                                              DateTime.now().year,
                                              1,
                                            ),
                                            selectedDate: selectedDate,
                                            onChanged: (DateTime dateTime) {
                                              Navigator.pop(context);
                                              setState(() {
                                                _patientYearTextController
                                                    .text = dateTime.year
                                                    .toString();
                                                patient = patient!.copyWith(
                                                  year: dateTime.year,
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng chọn ngày tái khám';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Hủy bỏ"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const MediAppLoadingDialog();
                        },
                      );

                      if (isEditState) {
                        await patientManger.updatePatient(patient!);
                      } else {
                        await patientManger.addPatient(patient!);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        if (patientManger.hasError) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.scale,
                            headerAnimationLoop: false,
                            title: "Lỗi kết nối",
                            desc: patientManger.errorMessage,
                            btnOkText: "OK",
                            btnOkOnPress: () {},
                            btnOkColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            onDismissCallback: (type) {
                              return;
                            },
                          ).show();
                          patientManger.clearError();
                          return;
                        }

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.scale,
                          title: isEditState
                              ? "Cập nhật thành công"
                              : "Thêm thành công",
                          btnOkOnPress: () {
                            Navigator.of(context).pop();
                          },
                          onDismissCallback: (type) {
                            if (type != DismissType.btnOk) {
                              Navigator.of(context).pop();
                            }
                          },
                          btnOkIcon: Icons.check_circle,
                          btnCancel: null,
                          btnOkText: 'OK',
                        ).show();
                      }
                    }
                  },
                  child: isEditState
                      ? const Text("Cập nhật")
                      : const Text("Thêm mới"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeletePatientDiaglog(
    BuildContext context, {
    required Patient patient,
  }) async {
    final patientManger = context.read<PatientManager>();
    final drugPrescriptionManager = context.read<DrugPrescriptionManager>();

    Future<bool> showFirstDialog(BuildContext context) {
      final completer = Completer<bool>();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Xóa người bệnh',
        desc:
            'Thao tác này sẽ xóa người bệnh khỏi ứng dụng. Bạn có muốn tiếp tục không?',
        btnOkOnPress: () {
          completer.complete(true);
        },
        btnCancelOnPress: () {
          completer.complete(false);
        },
        btnOkText: "Đồng ý",
        btnCancelText: "Từ chối",
        btnOkIcon: Icons.check_circle,
        btnCancelIcon: Icons.cancel,
      ).show();

      return completer.future;
    }

    Future<bool> showSecondDialog(BuildContext context, int count) {
      final completer = Completer<bool>();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Cảnh báo',
        desc:
            'Hiện người bệnh này còn có $count toa thuốc. Tiếp tục sẽ xóa tất cả toa thuốc người này đang sử dụng.\nBạn chắc chắn chứ?',
        btnOkOnPress: () {
          completer.complete(true);
        },
        btnCancelOnPress: () {
          completer.complete(false);
        },
        btnOkText: "Chắc chắn",
        btnCancelText: "Hủy bỏ",
        btnOkIcon: Icons.check_circle,
        btnCancelIcon: Icons.cancel,
      ).show();

      return completer.future;
    }

    bool isConfirmDelete = false;

    // first confirmation
    final first = await showFirstDialog(context);

    if (!first) return;

    final dpList = drugPrescriptionManager.findDrugPrescriptionByPatient(
      patient,
    );

    if (dpList.isEmpty) {
      isConfirmDelete = true;
    } else if (context.mounted) {
      final second = await showSecondDialog(context, dpList.length);

      if (second) {
        isConfirmDelete = true;
      }
    }

    if (!isConfirmDelete) return;

    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const MediAppLoadingDialog();
        },
      );

      // Delete drug prescriptions
      for (final dp in dpList) {
        await drugPrescriptionManager.deleteDrugPrescription(dp.id!);
      }

      // Delete patient
      await patientManger.deletePatient(patient.id!);

      if (context.mounted) {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'Xóa người bệnh',
          desc: 'Người bệnh ${patient.name!} đã xóa khỏi ứng dụng thành công!',
          btnOkOnPress: () {},
          btnOkText: "OK",
          btnOkIcon: Icons.check_circle,
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPatientList() {
      return Consumer<PatientManager>(
        builder: (context, patientManager, child) {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: patientManager.patients.length,
            itemBuilder: (context, index) {
              final patient = patientManager.patients[index];
              return ListTile(
                onTap: () {
                  _showEditPatientDialog(context, patient: patient);
                },
                title: Text(patient.name!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeletePatientDiaglog(context, patient: patient);
                  },
                ),
                subtitle: Text(
                  "Sinh năm ${patient.year}. Giới tính: ${genderDisplayStringMap[patient.gender]}",
                ),
              );
            },
          );
        },
      );
    }

    final patients = context.watch<PatientManager>().patients;

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách người bệnh"), elevation: 4.0),
      drawer: MediAppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditPatientDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: patients.isEmpty
          ? Center(
              child: Text(
                "Danh sách trống",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : buildPatientList(),
    );
  }
}
