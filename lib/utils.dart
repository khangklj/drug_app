import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
