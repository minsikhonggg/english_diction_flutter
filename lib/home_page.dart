import 'package:flutter/material.dart';
import 'api_service.dart';
import 'storage_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _examples;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPT 영어 예문 생성'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () async {
              final favorites = await StorageService.loadFavorites();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage(favorites: favorites)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '단어 입력',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchExamples,
              child: _isLoading ? CircularProgressIndicator() : Text('예문 생성하기!'),
            ),
            SizedBox(height: 16),
            _examples != null ? _buildExamples() : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchExamples() async {
    setState(() {
      _isLoading = true;
    });

    final examples = await ApiService.fetchExamples(_controller.text);

    setState(() {
      _examples = examples;
      _isLoading = false;
    });
  }

  Widget _buildExamples() {
    return Expanded(
      child: ListView(
        children: [
          Text('단어: ${_examples!['word']}'),
          SizedBox(height: 8),
          Text('정의: ${_examples!['definition']}'),
          SizedBox(height: 16),
          Text('예문:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._examples!['examples'].map<Widget>((example) {
            return ListTile(
              title: Text('Example: ${example['example']}'),
              subtitle: Text('Description: ${example['explanation']}'),
              trailing: IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  StorageService.addFavorite({
                    'example': example['example'],
                    'explanation': example['explanation'],
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Map<String, String>> favorites;

  FavoritesPage({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          return ListTile(
            title: Text('Example: ${favorite['example']}'),
            subtitle: Text('Description: ${favorite['explanation']}'),
          );
        },
      ),
    );
  }
}
