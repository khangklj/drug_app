import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
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
    DateTime selectedDate;
    if (patient == null || patient.year == null) {
      patient = Patient();
      selectedDate = DateTime.now();
    } else {
      selectedDate = DateTime(patient.year!);
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
                            labelText: 'Họ và tên (*)',
                          ),
                          onChanged: (value) {
                            setState(() {
                              patient = patient!.copyWith(name: value);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ và tên';
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
                                              DateTime.now().year + 100,
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

                      await patientManger.addPatient(patient!);

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
                          title: 'Thêm thành công',
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
                  child: const Text("Thêm mới"),
                ),
              ],
            );
          },
        );
      },
    );
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
              return Dismissible(
                key: ValueKey(patient.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  color: Colors.red,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(Icons.delete, color: Colors.white),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  patientManager.deletePatient(patient.id!);
                  //TODO: Implement dialog
                },
                child: ListTile(
                  onTap: () {
                    _showEditPatientDialog(context, patient: patient);
                  },
                  title: Text(patient.name!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      patientManager.deletePatient(patient.id!);
                      //TODO: Implement dialog
                    },
                  ),
                  subtitle: Text(
                    "Sinh năm ${patient.year}. Giới tính: ${genderDisplayStringMap[patient.gender]}",
                  ),
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
                "Không có người bệnh",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : buildPatientList(),
    );
  }
}
