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
    String? thumb = '100x100f',
  }) async {
    _drugs = await _drugService.fetchDrugs(
      page: page,
      perPage: perPage,
      filter: filter,
      thumb: thumb,
    );
    notifyListeners();
  }

  Future<Drug?> fetchDrugDetails({required String id, String? thumb}) async {
    final drug = await _drugService.fetchDrugDetails(id, thumb: thumb);
    return drug;
  }
}
