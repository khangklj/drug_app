class DrugCategory {
  final String id;
  final String name;

  DrugCategory({required this.id, required this.name});

  factory DrugCategory.fromJson(Map<String, dynamic> json) {
    return DrugCategory(id: json['id'], name: json['name']);
  }
}
