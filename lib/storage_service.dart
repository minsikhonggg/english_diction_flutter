import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static Future<List<Map<String, String>>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('favorites') ?? []).map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  static Future<void> addFavorite(Map<String, String> example) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> favorites = (prefs.getStringList('favorites') ?? []).map((e) => Map<String, String>.from(jsonDecode(e))).toList();
    favorites.add(example);
    prefs.setStringList('favorites', favorites.map((e) => jsonEncode(e)).toList());
  }
}
