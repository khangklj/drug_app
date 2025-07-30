import 'dart:io';

import 'package:drug_app/models/ocr_result.dart';
import 'package:drug_app/services/ocr_service.dart';
import 'package:drug_app/ui/components/camera_floating_button.dart';
import 'package:drug_app/ui/components/image_source_dialog.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  static const String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    int textBreakPoints = 600;
    return Scaffold(
      // bottomNavigationBar: TabBarWidget(),
      floatingActionButton: CameraFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
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

            SizedBox(
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
                          "Sử dụng camera để nhanh chóng\ntìm kiếm được thông tin thuốc bạn cần",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        )
                      else
                        Text(
                          "Sử dụng camera để nhanh chóng tìm kiếm được thông tin thuốc bạn cần",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),
                      ScanningButton(),
                    ],
                  ),
                ),
              ),
            ),

            TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm thuốc...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceBright,
              ),
              onTap: () {
                // TODO: Implement search functionality
              },
            ),
          ],
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
              if (ocrResult == null || !context.mounted) {
                setState(() {
                  _isLoading = false;
                });
                return;
              }

              final itemIds = ocrResult.ids;
              if (itemIds.isEmpty) {
                // TODO: Implement empty result handling
              } else if (itemIds.length == 1) {
                await Navigator.of(context).pushNamed(
                  DrugDetailsScreen.routeName,
                  arguments: itemIds.first,
                );
                // Hide loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {
                  _isLoading = false;
                });
              } else {
                // TODO: Implement multiple result handling
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
