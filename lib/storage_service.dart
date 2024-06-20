import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static Future<Map<String, Map<String, dynamic>>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      Map<String, dynamic> favoritesMap = jsonDecode(favoritesJson);
      return favoritesMap.map((key, value) =>
          MapEntry(key as String, value as Map<String, dynamic>));
    }
    return {};
  }

  static Future<void> addFavorite(String word, String definition, Map<String, String> example) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesJson = prefs.getString('favorites');
    Map<String, Map<String, dynamic>> favoritesMap = {};
    if (favoritesJson != null) {
      favoritesMap = jsonDecode(favoritesJson).map<String, Map<String, dynamic>>((key, value) =>
          MapEntry(key as String, value as Map<String, dynamic>)).cast<String, Map<String, dynamic>>();
    }
    if (favoritesMap[word] == null) {
      favoritesMap[word] = {'definition': definition, 'examples': []};
    }
    (favoritesMap[word]!['examples'] as List).add(example);
    prefs.setString('favorites', jsonEncode(favoritesMap));
  }

  static Future<void> removeFavorite(String word) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      Map<String, dynamic> favoritesMap = jsonDecode(favoritesJson);
      favoritesMap.remove(word);
      prefs.setString('favorites', jsonEncode(favoritesMap));
    }
  }

  static Future<void> removeExample(String word, Map<String, String> example) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      Map<String, dynamic> favoritesMap = jsonDecode(favoritesJson);
      if (favoritesMap[word] != null) {
        List<Map<String, String>> examples = List<Map<String, String>>.from((favoritesMap[word]['examples'] as List).map((item) => Map<String, String>.from(item)));
        examples.removeWhere((item) => mapEquals(item, example));
        if (examples.isEmpty) {
          favoritesMap.remove(word);
        } else {
          favoritesMap[word]['examples'] = examples;
        }
        prefs.setString('favorites', jsonEncode(favoritesMap));
      }
    }
  }

  static bool mapEquals(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (String key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}
