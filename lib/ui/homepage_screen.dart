import 'dart:io';

import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/manager/settings_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/ocr_drug_label_model.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/image_source_dialog.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_screen.dart';
import 'package:drug_app/ui/drug/drug_search_delegate.dart';
import 'package:drug_app/ui/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  static const String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late Future<void> _fetchDrugsMetadata;
  late Future<void> _fetchFavoriteDrugs;

  @override
  void initState() {
    super.initState();
    _fetchDrugsMetadata = context.read<DrugManager>().fetchDrugsMetadata();
    _fetchFavoriteDrugs = context
        .read<DrugFavoriteManager>()
        .fetchFavoriteDrugs();
  }

  @override
  Widget build(BuildContext context) {
    int textBreakPoints = 600;
    return FutureBuilder(
      future: Future.wait([_fetchDrugsMetadata, _fetchFavoriteDrugs]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(body: const Placeholder());
        }
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
            title: Text(
              "MediApp",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          drawer: MediAppDrawer(),
          body: MainWidget(textBreakPoints: textBreakPoints),
        );
      },
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key, required this.textBreakPoints});

  final int textBreakPoints;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                width: 100,
                child: Image.asset("assets/icons/app_icon.png"),
              ),
              Text("MediApp", style: Theme.of(context).textTheme.displaySmall),
              Text(
                "Ứng dụng tra cứu thuốc tiện ích",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "Phiên bản 1.0.0",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 20),

              OCRSearchEntry(textBreakPoints: textBreakPoints),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Expanded(child: Divider(height: 36, thickness: 3)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'HOẶC',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Expanded(child: Divider(height: 36, thickness: 3)),
                ],
              ),
              const SizedBox(height: 20),

              KeywordSearchEntry(),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(TestScreen.routeName);
                },
                child: const Text("Demo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeywordSearchEntry extends StatelessWidget {
  const KeywordSearchEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(
                "Tìm kiếm thuốc bằng từ khóa",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                decoration: InputDecoration(
                  hintText: "Tìm kiếm thuốc...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                readOnly: true,
                onTap: () {
                  showSearch(context: context, delegate: DrugSearchDelegate());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OCRSearchEntry extends StatelessWidget {
  const OCRSearchEntry({super.key, required this.textBreakPoints});

  final int textBreakPoints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            spacing: 5.0,
            children: [
              Text(
                "Tìm kiếm thuốc bằng OCR",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (MediaQuery.of(context).size.width < textBreakPoints)
                Text(
                  "Sử dụng hỉnh ảnh để nhanh chóng\ntìm kiếm tên thuốc",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  "Sử dụng hình ảnh để nhanh chóng tìm kiếm tên thuốc",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              ScanningButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanningButton extends StatefulWidget {
  const ScanningButton({super.key});

  @override
  State<ScanningButton> createState() => _ScanningButtonState();
}

class _ScanningButtonState extends State<ScanningButton> {
  bool _isLoading = false;

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text("Đang tìm kiếm thông tin thuốc..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanningModes = context.watch<SettingsManager>().scanningMode;
    return FilledButton.icon(
      onPressed: _isLoading
          ? null
          : () async {
              late final File? file;
              setState(() {
                _isLoading = true;
              });
              if (scanningModes == ScanningModes.camera) {
                file = await ImageSourceDialog.pickImage(ImageSource.camera);
              } else if (scanningModes == ScanningModes.gallery) {
                file = await ImageSourceDialog.pickImage(ImageSource.gallery);
              } else if (context.mounted) {
                file = await showDialog<File?>(
                  context: context,
                  builder: (BuildContext context) {
                    return const ImageSourceDialog();
                  },
                );
              }

              if (file == null) {
                setState(() {
                  _isLoading = false;
                });
                return;
              }
              _showLoadingDialog();
              final OCRDrugLabelModel? ocrResult = await OcrService().postImage(
                file,
              );
              // Hide loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              setState(() {
                _isLoading = false;
              });
              if (ocrResult == null || !context.mounted) {
                return;
              }

              final drugIds = ocrResult.ids;
              if (drugIds.isEmpty) {
                final List<Drug> drugs = [];
                Navigator.of(context).pushNamed(
                  DrugSearchResultsScreen.routeName,
                  arguments: drugs,
                );
                return;
              } else if (drugIds.length == 1) {
                Navigator.of(context).pushNamed(
                  DrugDetailsScreen.routeName,
                  arguments: drugIds.first,
                );
              } else {
                final List<Drug> drugs = context
                    .read<DrugManager>()
                    .searchDrugsMetadataByIds(drugIds);
                Navigator.of(context).pushNamed(
                  DrugSearchResultsScreen.routeName,
                  arguments: drugs,
                );
              }
            },
      icon: const Icon(Icons.camera_alt),
      label: Text(
        'Quét nhanh',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
