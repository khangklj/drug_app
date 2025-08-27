import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/services/favorite_service.dart';
import 'package:flutter/material.dart';

class DrugFavoriteManager with ChangeNotifier {
  late final FavoriteService _favoriteService;
  late final DrugManager _drugManager;
  List<Drug> _drugs = [];

  DrugFavoriteManager() {
    _favoriteService = FavoriteService();
    _drugManager = DrugManager();
  }

  List<Drug> get drugs => _drugs;

  Future<void> fetchFavoriteDrugs() async {
    if (drugs.isNotEmpty) return;
    List<String> drugIds = await _favoriteService.fetchFavoriteDrugs();
    _drugs = _drugManager.searchDrugsMetadataByIds(drugIds);
    notifyListeners();
  }

  bool isFavorite(Drug drug) {
    return _drugs.any((e) => e.id == drug.id);
  }

  Future<void> saveFavoriteDrug(Drug drug) async {
    await _favoriteService.saveFavoriteDrug(drug);
    _drugs.insert(0, drug);
    _drugs.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    notifyListeners();
  }

  Future<void> removeFavoriteDrug(Drug drug) async {
    await _favoriteService.removeFavoriteDrug(drug);
    _drugs.removeWhere((e) => e.id == drug.id);
    notifyListeners();
  }
}
