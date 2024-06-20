import 'package:flutter/material.dart';
import 'dart:math'; // Import the dart:math package
import 'home_page.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              buildPage(
                context,
                "검색할 단어를 입력하세요.",
                "🔍", // Search emoji
              ),
              buildPage(
                context,
                "원하는 예문이나 단어를 저장하세요.",
                "💾", // Save emoji
              ),
              buildPage(
                context,
                "저장한 단어와 예문을 확인하세요.",
                "📋", // Check emoji
              ),
              buildPage(
                context,
                "시작 하세요!",
                "🚀", // Start emoji
                isLastPage: true,
              ),
            ],
          ),
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

  Widget buildPage(BuildContext context, String text, String emoji, {bool isLastPage = false}) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 100), // Adjust the size as needed
              ),
              SizedBox(height: 20),
              Text(
                text,
                style: TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
