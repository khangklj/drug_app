import 'package:drug_app/models/drug_prescription_item.dart';

class DrugPrescription {
  final String? id;
  final String? customName;
  final String? deviceId;
  final List<DrugPrescriptionItem> items;
  final bool isActive;

  DrugPrescription({
    required this.id,
    required this.customName,
    required this.deviceId,
    required this.items,
    required this.isActive,
  });

  DrugPrescription copyWith({
    String? id,
    String? customName,
    String? deviceId,
    List<DrugPrescriptionItem>? items,
    bool? isActive,
  }) {
    return DrugPrescription(
      id: id ?? this.id,
      customName: customName ?? this.customName,
      deviceId: deviceId ?? this.deviceId,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'custom_name': customName,
    'device_id': deviceId,
    'is_active': isActive,
  };
}
