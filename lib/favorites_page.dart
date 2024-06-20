import 'package:flutter/material.dart';
import 'storage_service.dart';

class FavoritesPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> favorites;

  FavoritesPage({required this.favorites});

  @override
  Widget build(BuildContext context) {
    final sortedWords = favorites.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: ListView.builder(
        itemCount: sortedWords.length,
        itemBuilder: (context, index) {
          String word = sortedWords[index];
          String definition = favorites[word]!['definition'];
          return ListTile(
            title: Text(word),
            subtitle: Text('Definition: $definition'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await StorageService.removeFavorite(word);
                final updatedFavorites = await StorageService.loadFavorites();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(favorites: updatedFavorites)),
                );
              },
            ),
            onTap: () {
              _showExamplesDialog(context, word, definition, List<Map<String, dynamic>>.from(favorites[word]!['examples']));
            },
          );
        },
      ),
    );
  }

  void _showExamplesDialog(BuildContext context, String word, String definition, List<Map<String, dynamic>> examples) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(word),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Definition: $definition', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Examples:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...examples.map((example) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Example: ${example['example']}'),
                      Text('Description: ${example['explanation']}'),
                      SizedBox(height: 8),
                    ],
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
