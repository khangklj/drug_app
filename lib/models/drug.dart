import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_data.dart';

class Drug {
  final String id;
  final String name;
  final String image;
  final List<DrugData>? data;
  final List<DrugAlias>? aliases;

  Drug({
    required this.id,
    required this.name,
    required this.image,
    this.data = const [],
    this.aliases = const [],
  });
  Drug copyWith({
    String? id,
    String? name,
    String? image,
    List<DrugData>? data,
    List<DrugAlias>? aliases,
  }) {
    return Drug(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      data: data ?? this.data,
      aliases: aliases ?? this.aliases,
    );
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      data: json['data'],
      aliases: json['aliases'],
    );
  }
}
