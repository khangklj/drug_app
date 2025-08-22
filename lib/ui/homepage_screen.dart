import 'dart:io';

import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/manager/theme_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/ocr_result.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/image_source_dialog.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_screen.dart';
import 'package:drug_app/ui/drug/drug_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  static const String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late Future<void> _fetchDrugsMetadata;

  @override
  void initState() {
    _fetchDrugsMetadata = context
        .read<DrugManager>()
        .fetchDrugsMetadata(); // Fetch drugs metadata
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int textBreakPoints = 600;
    final currentThemeMode = context.watch<ThemeManager>().themeMode;
    return FutureBuilder(
      future: _fetchDrugsMetadata,
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
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                //TODO: implement appbar drawer
              },
            ),
            title: Text(
              "MediApp",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              IconButton(
                icon: currentThemeMode == ThemeMode.light
                    ? const Icon(Icons.light_mode_outlined)
                    : const Icon(Icons.dark_mode_outlined),
                onPressed: () {
                  context.read<ThemeManager>().toggleTheme();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
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
                    Text(
                      "MediApp",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
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
                        const Expanded(
                          child: Divider(height: 36, thickness: 3),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'HOẶC',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const Expanded(
                          child: Divider(height: 36, thickness: 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    KeywordSearchEntry(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                  "Sử dụng camera để nhanh chóng\nquét tên thuốc",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  "Sử dụng camera để nhanh chóng quét tên thuốc",
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
    return FilledButton.icon(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              final File? file = await showDialog<File?>(
                context: context,
                builder: (BuildContext context) {
                  return const ImageSourceDialog();
                },
              );

              if (file == null) {
                setState(() {
                  _isLoading = false;
                });
                return;
              }
              _showLoadingDialog();
              final OcrResult? ocrResult = await OcrService().postImage(file);
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
        'Bắt đầu quét',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
