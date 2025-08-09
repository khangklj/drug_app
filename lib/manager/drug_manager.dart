import 'package:drug_app/models/drug.dart';
import 'package:drug_app/services/drug_service.dart';
import 'package:flutter/material.dart';

class DrugManager with ChangeNotifier {
  late final DrugService _drugService;
  List<Drug> _drugs = [];

  DrugManager() {
    _drugService = DrugService();
  }

  List<Drug> get drugs => [..._drugs];

  Future<void> fetchDrugs({
    int page = 1,
    int perPage = 10,
    String? filter,
  }) async {
    _drugs = await _drugService.fetchDrugs(
      page: page,
      perPage: perPage,
      filter: filter,
    );
    notifyListeners();
  }

  Future<Drug?> fetchDrugDetails({required String id}) async {
    final drug = await _drugService.fetchDrugDetails(id);
    return drug;
  }

  Future<void> fetchDrugsMetadata() async {
    _drugs = await _drugService.fetchDrugMetadata();
    notifyListeners();
  }

  List<Drug> searchDrugsMetadataByQuery(String? query) {
    if (query == null || query.isEmpty) {
      return _drugs;
    }
    return _drugs.where((drug) {
      final name = drug.name.toLowerCase();
      final queryLower = query.toLowerCase();
      final aliasesMatch =
          drug.aliases?.any(
            (element) => element.name.toLowerCase().contains(queryLower),
          ) ??
          false;
      return aliasesMatch || name.contains(queryLower);
    }).toList();
  }

  List<Drug> searchDrugsMetadataByIds(List<String> ids) {
    return _drugs.where((drug) => ids.contains(drug.id)).toList();
  }
}
