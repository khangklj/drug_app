import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceDialog extends StatefulWidget {
  const ImageSourceDialog({super.key});

  @override
  State<ImageSourceDialog> createState() => _ImageSourceDialogState();
}

class _ImageSourceDialogState extends State<ImageSourceDialog> {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn nguồn ảnh',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                final pickedFile = await pickImage(ImageSource.camera);
                if (pickedFile != null && context.mounted) {
                  Navigator.of(context).pop(pickedFile);
                } else if (context.mounted) {
                  Navigator.of(context).pop(null);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ Thư viện'),
              onTap: () async {
                final pickedFile = await pickImage(ImageSource.gallery);
                if (pickedFile != null && context.mounted) {
                  Navigator.of(context).pop(pickedFile);
                }
              },
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
