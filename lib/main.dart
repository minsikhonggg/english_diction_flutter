import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_page.dart';
import 'tutorial_page.dart';

void main() async {
  // 앱 실행 전에 dotenv를 로드
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
      home: TutorialPage(),  // 처음 시작 화면을 튜토리얼 페이지로 설정
    );
  }
}
