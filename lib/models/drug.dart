import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_data.dart';

class Drug {
  final String id;
  final String name;
  final String _image;
  final List<DrugData>? data;
  final List<DrugAlias>? aliases;

  Drug({
    required this.id,
    required this.name,
    required String image,
    this.data = const [],
    this.aliases = const [],
  }) : _image = image;
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
      image: image ?? _image,
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

  String getImage({String? thumb}) {
    if (thumb == null) return _image;
    if (_image.contains('?thumb')) {
      return '$_image&thumb=$thumb';
    } else {
      return '$_image?thumb=$thumb';
    }
  }
}
