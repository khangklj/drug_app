class Patient {
  final String? id;
  final String? name;
  final int? year;
  final String? gender;
  final String? deviceId;

  Patient({this.id, this.name, this.year, this.gender, this.deviceId});

  Patient copyWith({
    String? id,
    String? name,
    int? year,
    String? gender,
    String? deviceId,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      gender: gender ?? this.gender,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      gender: json['gender'],
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'gender': gender,
      'device_id': deviceId,
    };
  }
}
