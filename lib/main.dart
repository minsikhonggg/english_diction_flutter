import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure dotenv is loaded before the app runs
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentence Example App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _examples = [];
  bool _isLoading = false;
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;  // 환경 변수에서 API 키 로드
  List<Map<String, String>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = (prefs.getStringList('favorites') ?? []).map((e) => Map<String, String>.from(jsonDecode(e))).toList();
    });
  }

  Future<void> _addFavorite(Map<String, String> example) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites.add(example);
      prefs.setStringList('favorites', _favorites.map((e) => jsonEncode(e)).toList());
    });
  }

  Future<void> _fetchExamples(String word) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'user',
            'content': 'Explain the following word and give me 3 examples that are used in different situations. "$word".'
          }
        ],
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseText = data['choices'][0]['message']['content'] as String;
      final examples = responseText.split('\n\n').where((line) => line.isNotEmpty).map((line) {
        final parts = line.split('Description:');
        return {
          'example': parts[0].trim(),
          'description': parts.length > 1 ? parts[1].trim() : ''
        };
      }).toList();

      setState(() {
        _examples = examples;
      });
    } else {
      setState(() {
        _examples = [{'example': 'Failed to fetch examples.', 'description': ''}];
      });
      print('Failed to fetch examples: ${response.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPT 영어 예문 생성'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage(favorites: _favorites)),
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
                labelText: 'ex) apple',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _fetchExamples(_controller.text);
                }
              },
              child: Text('예문 확인하기'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _examples.length,
                itemBuilder: (context, index) {
                  final example = _examples[index];
                  final isFavorite = _favorites.contains(example);
                  return ListTile(
                    title: Text('Example: ${example['example']}'),
                    subtitle: Text('Description: ${example['description']}'),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        if (!isFavorite) {
                          _addFavorite(example);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
            subtitle: Text('Description: ${favorite['description']}'),
          );
        },
      ),
    );
  }
}
