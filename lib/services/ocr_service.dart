import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

class OcrService {
  final _logger = Logger();
  final String _apiUrl = dotenv.env['API_URL'] ?? '';

  Future<void> postImage(File file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/ocr'));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('image', '*'),
        ),
      );
      final response = await request.send();
      if (response.statusCode == 200) {
        _logger.i(await response.stream.bytesToString());
      } else if (response.statusCode == 400) {
        throw Exception("Invalid file type");
      } else {
        throw Exception("Failed to upload image to ocr services");
      }
    } catch (error) {
      _logger.e(error);
    }
  }
}
