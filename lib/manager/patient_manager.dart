import 'package:collection/collection.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/services/patient_service.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/foundation.dart';

class PatientManager with ChangeNotifier {
  late final PatientService patientService;
  List<Patient> _patients = [];
  bool _hasError = false;
  String _errorMessage = '';

  List<Patient> get patients => _patients;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  PatientManager() {
    patientService = PatientService();
  }

  Future<void> fetchPatients() async {
    _patients = await patientService.fetchPatients();
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    // Add device id
    final deviceId = await getDeviceId();
    patient = patient.copyWith(deviceId: deviceId);
    final newPatient = await patientService.addPatient(patient);
    if (newPatient == null) {
      _hasError = true;
      _errorMessage = 'Lưu thông tin người bệnh thất bại';
      return;
    }
    _patients.add(newPatient);
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    final updatedPatient = await patientService.updatePatient(patient);
    if (updatedPatient == null) {
      _hasError = true;
      _errorMessage = 'Lưu thông tin người bệnh thất bại';
      return;
    }
    _patients.removeWhere((patient) => patient.id == updatedPatient.id);
    _patients.add(updatedPatient);
    notifyListeners();
  }

  Future<void> deletePatient(String id) async {
    final isDeleted = await patientService.removePatient(id);
    if (!isDeleted) {
      _hasError = true;
      _errorMessage = 'Xóa người bệnh thất bại';
      return;
    }
    _patients.removeWhere((patient) => patient.id == id);
    notifyListeners();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  Patient? findPatientByName(String name) {
    return _patients.firstWhereOrNull(
      (patient) => patient.name!.toLowerCase() == name.toLowerCase(),
    );
  }
}
