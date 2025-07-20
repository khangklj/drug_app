import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraFloatingButton extends StatelessWidget {
  const CameraFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    File? file;
    final imagePicker = ImagePicker();

    void pickImage(ImageSource source) async {
      final pickedFile = await imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        file = File(pickedFile.path);
        print(file);
      }
    }

    void showSourceSelectionDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              padding: EdgeInsets.all(0),
              child: Dialog(
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
                        onTap: () {
                          pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Thư viện ảnh'),
                        onTap: () {
                          pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
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
