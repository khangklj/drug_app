import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/ocr_drug_label_model.dart';
import 'package:drug_app/models/patient.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
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

  Future<DrugPrescription?> postDrugPrescriptionImage(
    File file, {
    List<Patient>? patients,
  }) async {
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
        final data = jsonDecode(responseBody)['data'] as Map<String, dynamic>;

        final List<DrugPrescriptionItem> dpItems = [];
        for (final item in data['items']) {
          final dpItem = DrugPrescriptionItem.fromJson(item);
          dpItems.add(dpItem);
        }
        final scheduledDate = DateFormat(
          "dd/MM/yyyy",
        ).tryParse(data['scheduled_date'] ?? '');
        final Patient? patient = patients?.firstWhereOrNull((patient) {
          return patient.name!.toLowerCase() ==
              (data['patient_name'] as String?)?.toLowerCase();
        });
        data.addAll({
          "id": null,
          "custom_name": null,
          "device_id": null,
          "is_active": true,
          "items": dpItems,
          "patient": patient,
          "scheduled_date": scheduledDate?.toString(),
          "active_date": null,
        });
        DrugPrescription dp = DrugPrescription.fromJson(data);
        return dp;
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
}
