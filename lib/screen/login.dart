// o //
import 'dart:convert'; // jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_fridge_app__/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      // 1. 카카오 로그인 시도
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk()
          .catchError((_) async {
        return await UserApi.instance.loginWithKakaoAccount();
      });

      // 2. API URL 읽기
      final rawIp = dotenv.env['API_URL'] ?? '';
      if (rawIp.isEmpty) {
        _showError(context, "API_URL이 설정되지 않았습니다 (.env 확인)");
        return;
      }

      // 3. URL 구성
      final String fullUrl = "$rawIp/auth/login/kakao";
      final Uri url = Uri.parse(fullUrl);

      // 4. 토큰을 Authorization 헤더에 담아서 요청
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.accessToken}',
        },
      );

      // 5. 결과 처리
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // 서버에서 오는 JWT Token 꺼내기
        final jwtToken = body["JWT Token"];
        if (jwtToken == null) {
          _showError(context, "JWT 토큰이 응답에 없습니다.");
          return;
        }

        // SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", jwtToken);

        debugPrint("✅ 로그인 성공, JWT 저장됨: $jwtToken");

        // 메인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => HomeScreen(jwtToken: jwtToken), // ✅ 토큰 전달
          ),
        );
      } else {
        _showError(context, "로그인 실패: ${response.statusCode}");
      }
    } catch (e) {
      _showError(context, "로그인 중 오류 발생: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
                onTap: () => _login(context),
                child: Image.asset(
                  'assets/kakao_login.png',
                  width: 300,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
