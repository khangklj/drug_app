import 'package:drug_app/models/drug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favorite_drugs';

  Future<void> saveFavoriteDrug(Drug drug) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteDrugs = prefs.getStringList(_key) ?? [];

    if (!favoriteDrugs.contains(drug.id)) {
      favoriteDrugs.add(drug.id);
      await prefs.setStringList(_key, favoriteDrugs);
    }
  }

  Future<void> removeFavoriteDrug(Drug drug) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteDrugs = prefs.getStringList(_key) ?? [];
    if (favoriteDrugs.contains(drug.id)) {
      favoriteDrugs.remove(drug.id);
      await prefs.setStringList(_key, favoriteDrugs);
    }
  }

  Future<List<String>> fetchFavoriteDrugs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
