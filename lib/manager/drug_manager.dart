import 'package:drug_app/models/drug.dart';
import 'package:drug_app/services/drug_service.dart';
import 'package:flutter/material.dart';

class DrugManager with ChangeNotifier {
  late final DrugService _drugService;
  List<Drug> _drugs = [];
  bool _hasFetchDrugMetadata = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Drug> get drugs => [..._drugs];
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  DrugManager() {
    _drugService = DrugService();
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
  }

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
    if (drug == null) {
      _hasError = true;
      _errorMessage = 'Lấy thông tin thuốc thất bại';
      return null;
    }
    return drug;
  }

  Future<void> fetchDrugsMetadata() async {
    if (_hasFetchDrugMetadata) return;
    _drugs = await _drugService.fetchDrugMetadata();
    if (_drugs.isEmpty) return;
    _hasFetchDrugMetadata = true;
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
