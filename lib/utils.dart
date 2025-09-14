import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

Future<String> getDeviceId({bool isEncoded = true}) async {
  var logger = Logger();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late final String id;

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    id = androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    id = iosInfo.identifierForVendor ?? '';
  } else {
    logger.e('Platform not supported');
    return '';
  }

  return isEncoded ? base64.encode(utf8.encode(id)) : id;
}

Future<File?> pickImage(ImageSource source) async {
  File? imageFile;
  final imagePicker = ImagePicker();
  final pickedFile = await imagePicker.pickImage(source: source);

  if (pickedFile != null) {
    imageFile = File(pickedFile.path);
    return imageFile;
  }
  return null;
}
