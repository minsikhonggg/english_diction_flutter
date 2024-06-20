import 'package:flutter/material.dart';
import 'storage_service.dart';

class FavoritesPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> favorites;

  FavoritesPage({required this.favorites});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String searchQuery = ''; // 검색 쿼리
  String selectedAlphabet = '전체 보기'; // 선택된 알파벳
  late Map<String, Map<String, dynamic>> filteredFavorites; // 필터링된 즐겨찾기

  @override
  void initState() {
    super.initState();
    filteredFavorites = widget.favorites;
  }

  // 즐겨찾기 필터링 함수
  void _filterFavorites(String query) {
    setState(() {
      searchQuery = query;
      filteredFavorites = widget.favorites
          .map((key, value) => MapEntry(key, value))
          .cast<String, Map<String, dynamic>>();
      if (query.isNotEmpty) {
        filteredFavorites.removeWhere(
                (key, value) => !key.toLowerCase().contains(query.toLowerCase()));
      }
    });
  }

  // 알파벳에 따른 필터링 함수
  void _filterByAlphabet(String alphabet) {
    setState(() {
      selectedAlphabet = alphabet;
      filteredFavorites = widget.favorites
          .map((key, value) => MapEntry(key, value))
          .cast<String, Map<String, dynamic>>();
      if (alphabet.isNotEmpty && alphabet != '전체 보기') {
        filteredFavorites.removeWhere(
                (key, value) => key[0].toUpperCase() != alphabet.toUpperCase());
      }
    });
  }

  // 즐겨찾기를 첫 글자로 그룹화하는 함수
  Map<String, List<String>> _groupFavoritesByFirstLetter(
      Map<String, Map<String, dynamic>> favorites) {
    Map<String, List<String>> groupedFavorites = {};
    for (String word in favorites.keys) {
      String firstLetter = word[0].toUpperCase();
      if (!groupedFavorites.containsKey(firstLetter)) {
        groupedFavorites[firstLetter] = [];
      }
      groupedFavorites[firstLetter]!.add(word);
    }
    for (String key in groupedFavorites.keys) {
      groupedFavorites[key]!.sort();
    }
    return groupedFavorites;
  }

  @override
  Widget build(BuildContext context) {
    final groupedFavorites =
    _groupFavoritesByFirstLetter(widget.favorites);

    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterFavorites,
              decoration: InputDecoration(
                labelText: '검색',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedAlphabet,
                  hint: Text('알파벳 선택'),
                  items: ['전체 보기', ...groupedFavorites.keys].map((String letter) {
                    return DropdownMenuItem<String>(
                      value: letter,
                      child: Text(letter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _filterByAlphabet(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: selectedAlphabet.isEmpty || selectedAlphabet == '전체 보기'
                  ? filteredFavorites.keys.map((String word) {
                String definition = filteredFavorites[word]!['definition'];
                return ListTile(
                  title: Text(
                    word,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Definition: $definition'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await StorageService.removeFavorite(word);
                      final updatedFavorites =
                      await StorageService.loadFavorites();
                      setState(() {
                        filteredFavorites = updatedFavorites;
                        _filterFavorites(searchQuery);
                      });
                    },
                  ),
                  onTap: () {
                    _showExamplesDialog(
                        context,
                        word,
                        definition,
                        List<Map<String, dynamic>>.from(
                            filteredFavorites[word]!['examples']));
                  },
                );
              }).toList()
                  : groupedFavorites[selectedAlphabet]!
                  .map((String word) {
                String definition =
                filteredFavorites[word]!['definition'];
                return ListTile(
                  title: Text(
                    word,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Definition: $definition'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await StorageService.removeFavorite(word);
                      final updatedFavorites =
                      await StorageService.loadFavorites();
                      setState(() {
                        filteredFavorites = updatedFavorites;
                        _filterByAlphabet(selectedAlphabet);
                      });
                    },
                  ),
                  onTap: () {
                    _showExamplesDialog(
                        context,
                        word,
                        definition,
                        List<Map<String, dynamic>>.from(
                            filteredFavorites[word]!['examples']));
                  },
                );
              })
                  .toList()
                  .cast<Widget>(),
            ),
          ),
        ],
      ),
    );
  }

  // 예문 다이얼로그를 표시하는 함수
  void _showExamplesDialog(BuildContext context, String word, String definition,
      List<Map<String, dynamic>> examples) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(word),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('정의: $definition',
                    style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
                SizedBox(height: 16),
                Text('예문:', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
                ...examples.map((example) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Example: ${example['example']}', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
                        Text('Description: ${example['explanation']}', style: TextStyle(height: 1.5)),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, size: 20),
                            onPressed: () async {
                              await StorageService.removeExample(
                                word,
                                {
                                  'example': example['example'],
                                  'explanation': example['explanation'],
                                },
                              );
                              Navigator.of(context).pop();
                              final updatedFavorites =
                              await StorageService.loadFavorites();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavoritesPage(
                                        favorites: updatedFavorites)),
                              );
                              _showExamplesDialog(
                                  context,
                                  word,
                                  definition,
                                  List<Map<String, dynamic>>.from(
                                      updatedFavorites[word]!['examples']));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
