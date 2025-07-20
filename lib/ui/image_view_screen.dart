import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  static const String routeName = '/image_view';
  final File image;
  const ImageViewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Image.file(image));
  }
}
