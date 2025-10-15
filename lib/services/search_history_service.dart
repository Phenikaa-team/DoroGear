import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'search_history';
  static const _maxHistory = 10;

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addTerm(String term) async {
    if (term.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    history.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    history.insert(0, term);

    if (history.length > _maxHistory) {
      history = history.sublist(0, _maxHistory);
    }

    await prefs.setStringList(_key, history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}