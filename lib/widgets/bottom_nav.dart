import 'package:flutter/material.dart';
import 'package:my_fridge_app__/screen/home_screen.dart';
import 'package:my_fridge_app__/screen/search/search_screen1.dart';
import 'package:my_fridge_app__/screen/add/add_screen.dart';
import 'package:my_fridge_app__/screen/community_screen.dart';
import 'package:my_fridge_app__/screen/setting_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BottomNav extends StatelessWidget {
  final String jwtToken;
  const BottomNav({super.key, required this.jwtToken});

  int _getCurrentIndex(BuildContext context) {
    final String route = ModalRoute.of(context)?.settings.name ?? '';
    if (route.contains('search')) return 0;
    if (route.contains('add')) return 1;
    if (route.contains('home')) return 2;
    if (route.contains('community')) return 3;
    if (route.contains('setting')) return 4;
    return 2; // 기본값은 홈
  }

   void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'search'),
            builder: (context) => SearchScreen1(jwtToken: jwtToken!),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'add'),
            builder: (context) => AddScreen(jwtToken: jwtToken!),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'home'),
            builder: (context) => HomeScreen(jwtToken: jwtToken!), // ✅ 전달
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'community'),
            builder: (context) => CommunityScreen(jwtToken: jwtToken!),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'setting'),
            builder: (context) => SettingScreen(jwtToken: jwtToken!),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.grey[200],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '음식검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: '재료추가',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
    );
  }
}
