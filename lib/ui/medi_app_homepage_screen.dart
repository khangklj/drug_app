import 'dart:io';

import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/ocr_drug_label_model.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/ui/components/medi_app_modal_bottom_sheet_icon.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_favorite_screen.dart';
import 'package:drug_app/ui/drug/drug_search_delegate.dart';
import 'package:drug_app/ui/drug/drug_search_results_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_edit_screen.dart';
import 'package:drug_app/ui/drug_prescription/drug_prescription_screen.dart';
import 'package:drug_app/ui/settings_screen.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MediAppHomepageScreen extends StatefulWidget {
  const MediAppHomepageScreen({super.key});

  static const routeName = "/medi_app_homepage_screen";

  @override
  State<MediAppHomepageScreen> createState() => _MediAppHomepageScreenState();
}

class _MediAppHomepageScreenState extends State<MediAppHomepageScreen> {
  void _showScanningDrugLabelOptions() {
    void handlePickedFile(File? file) async {
      if (file != null && mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const MediAppLoadingDialog();
          },
        );
        final OCRDrugLabelModel? ocrResult = await OcrService()
            .postDrugLabelImage(file);
        if (ocrResult == null) {
          return;
        }
        if (mounted) {
          final drugIds = ocrResult.ids;
          if (drugIds.isEmpty) {
            final List<Drug> drugs = [];
            Navigator.of(context).popAndPushNamed(
              DrugSearchResultsScreen.routeName,
              arguments: drugs,
            );
            return;
          } else if (drugIds.length == 1) {
            Navigator.of(context).popAndPushNamed(
              DrugDetailsScreen.routeName,
              arguments: drugIds.first,
            );
          } else {
            final List<Drug> drugs = context
                .read<DrugManager>()
                .searchDrugsMetadataByIds(drugIds);
            Navigator.of(context).popAndPushNamed(
              DrugSearchResultsScreen.routeName,
              arguments: drugs,
            );
          }
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
                "Chọn phương thức quét nhãn thuốc",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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

  void _showScanningDrugPrescriptionOptions() {
    void handlePickedFile(File? file) async {
      if (file != null && mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const MediAppLoadingDialog();
          },
        );
        List<DrugPrescriptionItem> dpItems = await OcrService()
            .postDrugPrescriptionImage(file);
        DrugPrescription newDP = DrugPrescription(
          id: null,
          customName: null,
          deviceId: null,
          isActive: false,
          items: dpItems,
        );
        if (mounted) {
          Navigator.of(context).popAndPushNamed(
            DrugPrescriptionEditScreen.routeName,
            arguments: newDP,
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
                "Chọn phương thức quét toa thuốc",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text("Trang chủ", style: Theme.of(context).textTheme.titleLarge),
      ),
      drawer: MediAppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background/bg_2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    spacing: 10.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "MediApp",
                        style: Theme.of(context).textTheme.displaySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Image.asset(
                        "assets/icons/app_icon.png",
                        height: 50,
                        width: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ỨNG DỤNG THUỐC TIỆN ÍCH",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Phiên bản 1.0",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Các tiện ích quét nhanh",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MediAppIconEntry(
                        icon: const Icon(Icons.format_shapes_sharp),
                        text: Text(
                          "Quét\nnhãn thuốc",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        onTap: _showScanningDrugLabelOptions,
                      ),
                      MediAppIconEntry(
                        icon: const Icon(Icons.document_scanner_outlined),
                        text: Text(
                          "Quét\ntoa thuốc",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        onTap: _showScanningDrugPrescriptionOptions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Các tiện ích khác",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Gõ từ khóa để tìm kiếm thuốc...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                    ),
                    readOnly: true,
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: DrugSearchDelegate(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MediAppIconEntry(
                        icon: const Icon(Icons.list_alt_outlined),
                        text: Text(
                          "Quản lý\ntoa thuốc",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(DrugPrescriptionScreen.routeName);
                        },
                      ),
                      MediAppIconEntry(
                        icon: const Icon(Icons.star_border_outlined),
                        text: Text(
                          "Danh sách\nyêu thích",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(DrugFavoriteScreen.routeName);
                        },
                      ),
                      MediAppIconEntry(
                        icon: const Icon(Icons.settings_outlined),
                        text: Text(
                          "Cài đặt\n",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(SettingsScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediAppIconEntry extends StatelessWidget {
  const MediAppIconEntry({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final Text text;
  final Icon icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 5.0,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: icon,
                    ),
                  ),
                ),
                const SizedBox(height: 3.0),
                text,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
