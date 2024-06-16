import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  List<String> _examples = [];
  bool _isLoading = false;
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;  // 환경 변수에서 API 키 로드

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
            'content': 'Give me 3 example sentences using the word "$word".'
          }
        ],
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _examples = (data['choices'][0]['message']['content'] as String).split('\n').where((line) => line.isNotEmpty).toList();
      });
    } else {
      setState(() {
        _examples = ['Failed to fetch examples.'];
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
        title: Text('Sentence Example App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter an English word',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _fetchExamples(_controller.text);
                }
              },
              child: Text('Get Example Sentences'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _examples.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_examples[index]),
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
