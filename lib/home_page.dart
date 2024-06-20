import 'package:flutter/material.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'favorites_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController(); // 텍스트 입력 컨트롤러
  Map<String, dynamic>? _examples; // 예문 데이터
  bool _isLoading = false; // 로딩 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPT 영어 예문 생성'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () async {
              try {
                final favorites = await StorageService.loadFavorites();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(favorites: favorites)),
                );
              } catch (e) {
                print('Error loading favorites: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('즐겨찾기를 불러오는데 실패했습니다.')),
                );
              }
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
              child: _isLoading ? CircularProgressIndicator() : Text('예문 생성하기'),
            ),
            SizedBox(height: 16),
            _examples != null ? _buildExamples() : Container(),
          ],
        ),
      ),
    );
  }

  // 예문을 가져오는 함수
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

  // 예문을 표시하는 위젯
  Widget _buildExamples() {
    return Expanded(
      child: ListView(
        children: [
          Text('단어: ${_examples!['word']}', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
          SizedBox(height: 8),
          Text('정의: ${_examples!['definition']}', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
          SizedBox(height: 16),
          Text('예문:', style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
          ..._examples!['examples'].map<Widget>((example) {
            return ListTile(
              title: Text('Example: ${example['example']}', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
              subtitle: Text('Description: ${example['explanation']}', style: TextStyle(height: 1.5)),
              trailing: IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () async {
                  try {
                    await StorageService.addFavorite(_examples!['word'], _examples!['definition'], {
                      'example': example['example'],
                      'explanation': example['explanation'],
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('추가 되었습니다')),
                    );
                  } catch (e) {
                    if (e.toString().contains('Duplicate example')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('중복된 예문입니다.')),
                      );
                    } else {
                      print('Error adding favorite: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('즐겨찾기에 추가하는데 실패했습니다.')),
                      );
                    }
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
