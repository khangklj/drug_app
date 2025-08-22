import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/services/search_service.dart';
import 'package:flutter/widgets.dart';

class SearchHistoryManager with ChangeNotifier {
  late final SearchService _searchService;
  late final DrugManager _drugManager;
  List<Drug> _drugs = [];
  final int maxHistoryLength = SearchService.maxHistoryLength;

  List<Drug> get drugs => _drugs;

  SearchHistoryManager() {
    _searchService = SearchService();
    _drugManager = DrugManager();
  }

  Future<void> saveSearchHistory(Drug drug) async {
    await _searchService.saveSearchHistory(drug);
    _drugs.removeWhere((e) => e.id == drug.id);
    _drugs.insert(0, drug);
    if (_drugs.length > maxHistoryLength) {
      _drugs = _drugs.sublist(0, maxHistoryLength);
    }
    notifyListeners();
  }

  Future<void> removeSearchHistory(Drug drug) async {
    await _searchService.removeSearchHistory(drug);
    drugs.removeWhere((e) => e.id == drug.id);
    notifyListeners();
  }

  Future<void> fetchSearchHistory() async {
    if (drugs.isEmpty) {
      final ids = await _searchService.fetchSearchHistory();
      final List<Drug> drugs = _drugManager.searchDrugsMetadataByIds(ids);
      this.drugs.addAll(drugs);
    }
    notifyListeners();
  }
}
