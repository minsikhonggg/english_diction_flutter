import 'package:flutter/material.dart';
import 'dart:math'; // dart:math 패키지 임포트
import 'home_page.dart';

// 튜토리얼 페이지 위젯
class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

// 튜토리얼 페이지 상태 관리 클래스
class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController(); // 페이지 컨트롤러
  int _currentPage = 0; // 현재 페이지 인덱스

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page; // 페이지 변경 시 상태 업데이트
              });
            },
            children: [
              // 튜토리얼 페이지 생성
              buildPage(
                context,
                "검색할 단어를 입력하세요.",
                "🔍", // 검색 이모지
              ),
              buildPage(
                context,
                "원하는 예문이나 단어를 저장하세요.",
                "💾", // 저장 이모지
              ),
              buildPage(
                context,
                "저장한 단어와 예문을 확인하세요.",
                "📋", // 확인 이모지
              ),
              buildPage(
                context,
                "시작 하세요!",
                "🚀", // 시작 이모지
                isLastPage: true, // 마지막 페이지 여부 설정
              ),
            ],
          ),
          // 페이지 하단의 네비게이션 버튼 및 인디케이터
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        // 페이지 인디케이터 애니메이션
                        double selectedness = Curves.easeOut.transform(
                          max(0.0, 1.0 - ((_pageController.page ?? _pageController.initialPage) - index).abs()),
                        );
                        double zoom = 1.0 + (1.5 - 1.0) * selectedness;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          width: 10.0 * zoom,
                          height: 10.0 * zoom,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        );
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 이전 페이지로 이동 버튼
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _currentPage == 0
                            ? null
                            : () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                      // 현재 페이지가 마지막이 아닌 경우 Skip 버튼 표시
                      if (_currentPage != 3)
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage()),
                            );
                          },
                          child: Text('Skip', style: TextStyle(color: Colors.black)),
                        ),
                      // 다음 페이지로 이동 버튼
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_currentPage == 3) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage()),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 페이지 내용을 생성하는 함수
  Widget buildPage(BuildContext context, String text, String emoji, {bool isLastPage = false}) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 100), // 이모지 크기 조정
              ),
              SizedBox(height: 20),
              Text(
                text,
                style: TextStyle(fontSize: 24, color: Colors.black, height: 2), // 텍스트 스타일 및 라인 높이 설정
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
