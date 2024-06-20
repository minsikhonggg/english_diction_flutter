import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY']!;  // 환경 변수에서 API 키 로드

  // 단어의 정의와 예문을 가져오는 비동기 함수
  static Future<Map<String, dynamic>> fetchExamples(String word) async {
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
            'content': 'Define the following word and provide 3 example sentences with explanations for each. Format the response as:\n\n'
                'Word: {word}\n'
                'Definition: {definition}\n\n'
                '1. Example: {example1}\n'
                '- Explanation: {explanation1}\n\n'
                '2. Example: {example2}\n'
                '- Explanation: {explanation2}\n\n'
                '3. Example: {example3}\n'
                '- Explanation: {explanation3}\n\n'
                'Word: "$word".'
          }
        ],
        'max_tokens': 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseText = data['choices'][0]['message']['content'] as String;

      // 응답을 원하는 형식으로 파싱
      final lines = responseText.split('\n').where((line) => line.isNotEmpty).toList();
      final wordDefinition = {
        'word': word,
        'definition': '',
        'examples': <Map<String, String>>[]
      };

      // 정의와 예문 추출
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('Definition: ')) {
          wordDefinition['definition'] = lines[i].substring('Definition: '.length).trim();
        } else if (lines[i].startsWith('1. Example: ')) {
          (wordDefinition['examples'] as List<Map<String, String>>).add({
            'example': lines[i].substring('1. Example: '.length).trim(),
            'explanation': lines[i + 1].substring('- Explanation: '.length).trim()
          });
        } else if (lines[i].startsWith('2. Example: ')) {
          (wordDefinition['examples'] as List<Map<String, String>>).add({
            'example': lines[i].substring('2. Example: '.length).trim(),
            'explanation': lines[i + 1].substring('- Explanation: '.length).trim()
          });
        } else if (lines[i].startsWith('3. Example: ')) {
          (wordDefinition['examples'] as List<Map<String, String>>).add({
            'example': lines[i].substring('3. Example: '.length).trim(),
            'explanation': lines[i + 1].substring('- Explanation: '.length).trim()
          });
        }
      }

      return wordDefinition;
    } else {
      // 요청 실패 시 처리
      print('Failed to fetch examples: ${response.body}');
      return {
        'word': word,
        'definition': 'Failed to fetch definition.',
        'examples': [
          {
            'example': 'Failed to fetch examples.',
            'explanation': ''
          }
        ]
      };
    }
  }
}
