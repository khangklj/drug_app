import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_modal_bottom_sheet_icon.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DrugPrescriptionScreen extends StatefulWidget {
  const DrugPrescriptionScreen({super.key});
  static const routeName = '/drug_prescription';

  @override
  State<DrugPrescriptionScreen> createState() => _DrugPrescriptionScreenState();
}

class _DrugPrescriptionScreenState extends State<DrugPrescriptionScreen> {
  void _showAddingOptions() {
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
                        if (pickedFile != null && context.mounted) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return const MediAppLoadingDialog();
                            },
                          );
                          List<DrugPrescriptionItem> dpItems =
                              await OcrService().postDrugPrescriptionImage(
                                pickedFile,
                              );
                          DrugPrescription newDP = DrugPrescription(
                            id: null,
                            customName: null,
                            deviceId: null,
                            isActive: false,
                            items: dpItems,
                          );
                          if (context.mounted) {
                            Navigator.of(context).popAndPushNamed(
                              DrugPrescriptionEditScreen.routeName,
                              arguments: newDP,
                            );
                          }
                        }
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
                        if (pickedFile != null && context.mounted) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return const MediAppLoadingDialog();
                            },
                          );
                          List<DrugPrescriptionItem> dpItems =
                              await OcrService().postDrugPrescriptionImage(
                                pickedFile,
                              );
                          DrugPrescription newDP = DrugPrescription(
                            id: null,
                            customName: null,
                            deviceId: null,
                            isActive: false,
                            items: dpItems,
                          );
                          if (context.mounted) {
                            Navigator.of(context).popAndPushNamed(
                              DrugPrescriptionEditScreen.routeName,
                              arguments: newDP,
                            );
                          }
                        }
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
          _showAddingOptions();
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
