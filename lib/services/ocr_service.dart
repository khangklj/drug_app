import 'dart:convert';
import 'dart:io';

import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/ocr_drug_label_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

class OcrService {
  final _logger = Logger();
  final String _apiUrl = dotenv.env['API_URL'] ?? '';

  Future<OCRDrugLabelModel?> postDrugLabelImage(File file) async {
    final endpoint = '$_apiUrl/drug_label';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
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
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final OCRDrugLabelModel result = OCRDrugLabelModel.fromJson(
          jsonResponse,
        );
        _logger.i(result.ids);
        return result;
      } else if (response.statusCode == 400) {
        throw Exception("Invalid file type");
      } else {
        throw Exception("Failed to upload image to ocr services");
      }
    } catch (error) {
      _logger.e(error);
      return null;
    }
  }

  Future<List<DrugPrescriptionItem>> postDrugPrescriptionImage(
    File file,
  ) async {
    final endpoint = '$_apiUrl/drug_prescription';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
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
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        final List<DrugPrescriptionItem> dpItems = [];
        for (final item in jsonResponse['data']['drug_prescription_items']) {
          final dpItem = DrugPrescriptionItem.fromJson(item);
          dpItems.add(dpItem);
        }
        return dpItems;
      } else if (response.statusCode == 400) {
        throw Exception("Invalid file type");
      } else {
        throw Exception("Failed to upload image to ocr services");
      }
    } catch (error) {
      _logger.e(error);
      return [];
    }
  }
}
