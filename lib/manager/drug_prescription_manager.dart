import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/drug_prescription_service.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';

class DrugPrescriptionManager with ChangeNotifier {
  List<DrugPrescription> _drugPrescriptionList = [];
  List<DrugPrescription> get drugPrescriptions => _drugPrescriptionList;
  late final DrugPrescriptionService _drugPrescriptionService;

  DrugPrescriptionManager() {
    _drugPrescriptionService = DrugPrescriptionService();
  }

  Future<void> fetchDrugPrescriptions() async {
    _drugPrescriptionList = await _drugPrescriptionService
        .fetchDrugPrescriptions();
    notifyListeners();
  }

  Future<void> addDrugPrescription(DrugPrescription drugPrescription) async {
    // Add device id
    final deviceId = await getDeviceId();
    drugPrescription = drugPrescription.copyWith(deviceId: deviceId);

    final newDP = await _drugPrescriptionService.addDrugPrescription(
      drugPrescription,
    );
    if (newDP == null) return;
    _drugPrescriptionList.add(newDP);
    notifyListeners();
  }

  Future<void> updateDrugPrescription(DrugPrescription drugPrescription) async {
    final updatedDP = await _drugPrescriptionService.updateDrugPrescription(
      drugPrescription,
    );
    if (updatedDP == null) return;
    _drugPrescriptionList.removeWhere((dp) => dp.id == updatedDP.id);
    _drugPrescriptionList.add(updatedDP);
    notifyListeners();
  }

  Future<void> deleteDrugPrescription(String id) async {
    final isDeleted = await _drugPrescriptionService.removeDrugPrescription(id);
    if (!isDeleted) return;
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
}
