import 'package:drug_app/models/drug_prescription_item.dart';

class DrugPrescription {
  final String? id;
  final String? customName;
  final String? deviceId;
  final List<DrugPrescriptionItem> items;
  final bool isActive;
  final String? patientName;
  final int? patientAge;
  final String? patientGender;
  final String? diagnosis;
  final String? doctorName;
  final DateTime? scheduledDate;

  DrugPrescription({
    required this.id,
    required this.customName,
    required this.deviceId,
    required this.items,
    required this.isActive,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.diagnosis,
    this.doctorName,
    this.scheduledDate,
  });

  DrugPrescription copyWith({
    String? id,
    String? customName,
    String? deviceId,
    List<DrugPrescriptionItem>? items,
    bool? isActive,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? diagnosis,
    String? doctorName,
    DateTime? scheduledDate,
  }) {
    return DrugPrescription(
      id: id ?? this.id,
      customName: customName ?? this.customName,
      deviceId: deviceId ?? this.deviceId,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorName: doctorName ?? this.doctorName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  DrugPrescriptionItem findItemByNameAndTime(
    String drugName,
    TimeOfDayValues timeOfDay,
  ) {
    return items.firstWhere(
      (item) => item.drugName == drugName && item.timeOfDay == timeOfDay,
    );
  }

  factory DrugPrescription.fromJson(Map<String, dynamic> json) {
    return DrugPrescription(
      id: json['id'],
      customName: json['custom_name'],
      deviceId: json['device_id'],
      items: json['items'],
      isActive: json['is_active'],
      patientName: json['patient_name'],
      patientAge: json['patient_age'] == null
          ? null
          : int.parse(json['patient_age'].toString()),
      patientGender: json['patient_gender'],
      diagnosis: json['diagnosis'],
      doctorName: json['doctor_name'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'custom_name': customName,
    'device_id': deviceId,
    'is_active': isActive,
    'patient_name': patientName,
    'patient_age': patientAge,
    'patient_gender': patientGender,
    'diagnosis': diagnosis,
    'doctor_name': doctorName,
    'scheduled_date': scheduledDate!.toUtc().toIso8601String(),
  };
}
