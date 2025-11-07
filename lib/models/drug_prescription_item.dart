enum TimeOfDayValues { morning, noon, afternoon, evening }

extension TimeOfDayValuesExtension on TimeOfDayValues {
  String toDisplayString() {
    switch (this) {
      case TimeOfDayValues.morning:
        return 'Sáng';
      case TimeOfDayValues.noon:
        return 'Trưa';
      case TimeOfDayValues.afternoon:
        return 'Chiều';
      case TimeOfDayValues.evening:
        return 'Tối';
    }
  }
}

class DrugPrescriptionItem {
  final String? id;
  final String drugName;
  final TimeOfDayValues timeOfDay;
  final double? quantity;
  final String? measurement;
  final String? drugId;

  DrugPrescriptionItem({
    required this.id,
    required this.drugName,
    required this.timeOfDay,
    this.quantity,
    this.measurement,
    this.drugId,
  });

  DrugPrescriptionItem copyWith({
    String? id,
    String? drugName,
    TimeOfDayValues? timeOfDay,
    double? quantity,
    String? measurement,
    String? drugId,
  }) {
    return DrugPrescriptionItem(
      id: id ?? this.id,
      drugName: drugName ?? this.drugName,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      quantity: quantity ?? this.quantity,
      measurement: measurement ?? this.measurement,
      drugId: drugId ?? this.drugId,
    );
  }

  factory DrugPrescriptionItem.fromJson(Map<String, dynamic> json) {
    return DrugPrescriptionItem(
      id: json['id'],
      drugName: json['drug_name'],
      timeOfDay: TimeOfDayValues.values.byName(json['time_of_day']),
      quantity: double.parse(json['quantity'].toString()),
      measurement: json['measurement'],
      drugId: json['drugId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drug_name': drugName,
      'time_of_day': timeOfDay.name,
      'quantity': quantity,
      'measurement': measurement,
    };
  }
}
