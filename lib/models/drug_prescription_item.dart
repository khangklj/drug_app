enum TimeOfDayValues { morning, noon, afternoon, evening }

class DrugPrescriptionItem {
  final String id;
  final String drugName;
  final TimeOfDayValues timeOfDay;
  final int? quantity;
  final String? measurement;

  DrugPrescriptionItem({
    required this.id,
    required this.drugName,
    required this.timeOfDay,
    this.quantity,
    this.measurement,
  });

  DrugPrescriptionItem copyWith({
    String? id,
    String? drugName,
    TimeOfDayValues? timeOfDay,
    int? quantity,
    String? measurement,
  }) {
    return DrugPrescriptionItem(
      id: id ?? this.id,
      drugName: drugName ?? this.drugName,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      quantity: quantity ?? this.quantity,
      measurement: measurement ?? this.measurement,
    );
  }

  factory DrugPrescriptionItem.fromJson(Map<String, dynamic> json) {
    return DrugPrescriptionItem(
      id: json['id'],
      drugName: json['drug_name'],
      timeOfDay: TimeOfDayValues.values.byName(json['time_of_day']),
      quantity: int.parse(json['quantity'].toString()),
      measurement: json['measurement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_name': drugName,
      'time_of_day': timeOfDay.name,
      'quantity': quantity,
      'measurement': measurement,
    };
  }
}
