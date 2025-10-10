import 'package:flutter/material.dart';

void main() {
  runApp(const MyFridgeApp());
}

class MyFridgeApp extends StatelessWidget {
  const MyFridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '나만의 냉장고',
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            
            // 🔲 기존 UI
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'AI가 추천하는 맞춤 요리,\n지금 바로 확인해보세요',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 45),
                  GestureDetector(
                    onTap: () {
                      // TODO: 카카오 로그인 기능 연결
                    },
                    child: Image.asset(
                      'assets/kakao_login.png',
                      width: 300,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
