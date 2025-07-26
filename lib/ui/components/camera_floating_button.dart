import 'package:drug_app/ui/components/image_source_dialog.dart';
import 'package:flutter/material.dart';

class CameraFloatingButton extends StatelessWidget {
  const CameraFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      child: Icon(Icons.camera_alt),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImageSourceDialog();
          },
        );
      },
    );
  }
}
