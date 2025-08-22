import 'package:drug_app/models/drug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  static const _key = 'search_history';
  static const maxHistoryLength = 5;

  Future<void> saveSearchHistory(Drug drug) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    history.remove(drug.id);
    history.insert(0, drug.id);

    if (history.length > maxHistoryLength) {
      history = history.sublist(0, maxHistoryLength);
    }

    await prefs.setStringList(_key, history);
  }

  Future<void> removeSearchHistory(Drug drug) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    history.remove(drug.id);
    await prefs.setStringList(_key, history);
  }

  Future<List<String>> fetchSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
