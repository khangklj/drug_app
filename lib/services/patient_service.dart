import 'package:drug_app/models/patient.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';

class PatientService {
  var logger = Logger();

  Future<List<Patient>> fetchPatients({required String deviceId}) async {
    final List<Patient> patients = [];
    try {
      final pb = await getPocketBaseInstance();
      final recordList = await pb
          .collection('patient')
          .getFullList(filter: "device_id = '$deviceId'");
      for (final record in recordList) {
        patients.add(Patient.fromJson(record.toJson()));
      }
      return patients;
    } catch (error) {
      logger.e("Fail to fetch patients: $error");
      return patients;
    }
  }

  Future<Patient?> addPatient(Patient patient) async {
    try {
      final pb = await getPocketBaseInstance();
      final patientModel = await pb
          .collection('patient')
          .create(body: patient.toJson());
      final newPatient = Patient.fromJson(patientModel.toJson());
      return newPatient;
    } catch (error) {
      logger.e("Fail to add patient: $error");
      return null;
    }
  }

  Future<Patient?> updatePatient(Patient patient) async {
    try {
      final pb = await getPocketBaseInstance();
      final patientModel = await pb
          .collection('patient')
          .update(patient.id!, body: patient.toJson());
      final newPatient = Patient.fromJson(patientModel.toJson());
      return newPatient;
    } catch (error) {
      logger.e("Fail to update patient: $error");
      return null;
    }
  }

  Future<bool> removePatient(String id) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('patient').delete(id);
      return true;
    } catch (error) {
      logger.e("Fail to remove patient: $error");
      return false;
    }
  }
}
