import 'dart:io';
import 'package:drug_app/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraFloatingButton extends StatelessWidget {
  const CameraFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    File? file;
    final imagePicker = ImagePicker();

    Future<File?> pickImage(ImageSource source) async {
      final pickedFile = await imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        file = File(pickedFile.path);
        return file;
      }
      return null;
    }

    void showSourceSelectionDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Container(
              padding: EdgeInsets.all(15),
              child: Wrap(
                children: [
                  Text('Chọn nguồn ảnh để tìm kiếm'),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () async {
                      final pickedFile = await pickImage(ImageSource.camera);
                      if (pickedFile != null && context.mounted) {
                        Navigator.of(context).pop();
                        OcrService service = OcrService();
                        service.postImage(pickedFile);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Thư viện ảnh'),
                    onTap: () async {
                      final pickedFile = await pickImage(ImageSource.gallery);
                      if (pickedFile != null && context.mounted) {
                        Navigator.of(context).pop();
                        OcrService service = OcrService();
                        service.postImage(pickedFile);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return FloatingActionButton(
      shape: const CircleBorder(),
      child: Icon(Icons.camera_alt),
      onPressed: () {
        showSourceSelectionDialog();
      },
    );
  }
}
