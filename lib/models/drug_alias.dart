class DrugAlias {
  String id;
  String name;

  DrugAlias({required this.id, required this.name});

  factory DrugAlias.fromJson(Map<String, dynamic> json) {
    return DrugAlias(id: json['id'], name: json['name']);
  }
}
