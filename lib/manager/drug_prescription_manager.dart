import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/services/drug_prescription_service.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';

class DrugPrescriptionManager with ChangeNotifier {
  List<DrugPrescription> _drugPrescriptionList = [];
  late final DrugPrescriptionService _drugPrescriptionService;
  bool _hasError = false;
  String _errorMessage = '';

  List<DrugPrescription> get drugPrescriptions => _drugPrescriptionList;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  DrugPrescriptionManager() {
    _drugPrescriptionService = DrugPrescriptionService();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  Future<void> fetchDrugPrescriptions() async {
    final deviceId = await getDeviceId();
    _drugPrescriptionList = await _drugPrescriptionService
        .fetchDrugPrescriptions(deviceId: deviceId);
    notifyListeners();
  }

  Future<void> addDrugPrescription(DrugPrescription drugPrescription) async {
    // Add device id
    final deviceId = await getDeviceId();
    drugPrescription = drugPrescription.copyWith(deviceId: deviceId);

    final newDP = await _drugPrescriptionService.addDrugPrescription(
      drugPrescription,
    );
    if (newDP == null) {
      _hasError = true;
      _errorMessage = 'Lưu toa thuốc thất bại.';
      return;
    }
    _drugPrescriptionList.add(newDP);
    notifyListeners();
  }

  Future<void> updateDrugPrescription(DrugPrescription drugPrescription) async {
    final updatedDP = await _drugPrescriptionService.updateDrugPrescription(
      drugPrescription,
    );
    if (updatedDP == null) {
      _hasError = true;
      _errorMessage = 'Lưu toa thuốc thất bại.';
      return;
    }
    _drugPrescriptionList.removeWhere((dp) => dp.id == updatedDP.id);
    _drugPrescriptionList.add(updatedDP);
    notifyListeners();
  }

  Future<void> deleteDrugPrescription(String id) async {
    final isDeleted = await _drugPrescriptionService.removeDrugPrescription(id);
    if (!isDeleted) {
      _hasError = true;
      _errorMessage = 'Xóa toa thuốc thất bại.';
      return;
    }
    _drugPrescriptionList.removeWhere((dp) => dp.id == id);
    notifyListeners();
  }

  Set<TimeOfDayValues> getActiveNotificationTimes() {
    final timeOfDays = <TimeOfDayValues>{};
    for (final dp in _drugPrescriptionList) {
      if (dp.isActive == true) {
        for (final item in dp.items) {
          timeOfDays.add(item.timeOfDay);
          if (timeOfDays.length == TimeOfDayValues.values.length) {
            return timeOfDays;
          }
        }
      }
    }
    return timeOfDays;
  }

  List<DrugPrescription> findDrugPrescriptionByPatient(Patient patient) {
    return _drugPrescriptionList
        .where((dp) => dp.patient!.id == patient.id)
        .toList();
  }
}
