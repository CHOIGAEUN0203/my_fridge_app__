import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

// Screens
import 'package:my_fridge_app__/screen/login.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 SDK 초기화 (env에서 불러오기 권장)
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );

  // 디버깅용: 앱 실행 시 해시키 출력
  try {
    final keyHash = await KakaoSdk.origin;
    debugPrint('💡 카카오 해시키: $keyHash');
  } catch (e) {
    debugPrint('❌ 해시키를 가져오는 중 오류: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fridge App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // jwtToken은 push할 때 arguments로 넘겨줄 것
      },
    );
  }
}

