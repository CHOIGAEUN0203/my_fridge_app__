// o //
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/screen/recommend/recommend_screen1.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/all_screen.dart';
import 'package:my_fridge_app__/widgets/category_bar.dart';
import 'package:my_fridge_app__/widgets/expiring_items.dart';
import 'package:my_fridge_app__/widgets/ingredients_table.dart';

// 모델 클래스
class ExpiringFood {
  final int quantity;
  final String name;
  final int daysLeft;

  ExpiringFood({
    required this.quantity,
    required this.name,
    required this.daysLeft,
  });

  factory ExpiringFood.fromJson(Map<String, dynamic> json) {
    return ExpiringFood(
      quantity: json['quantity'],
      name: json['name'],
      daysLeft: json['daysLeft'],
    );
  }
}

class AllFood {
  final int id;
  final String name;
  final String type;
  final int quantity;
  final String expDate;

  AllFood({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.expDate,
  });

  factory AllFood.fromJson(Map<String, dynamic> json) {
    return AllFood(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'],
      expDate: json['expDate'],
    );
  }
}

class MainPageData {
  final String nickname;
  final List<ExpiringFood> expiringFoods;
  final List<AllFood> allFoods;
  final Map<String, dynamic> foodTypePercentages;

  MainPageData({
    required this.nickname,
    required this.expiringFoods,
    required this.allFoods,
    required this.foodTypePercentages,
  });

  factory MainPageData.fromJson(Map<String, dynamic> json) {
    return MainPageData(
      nickname: json['nickname'],
      expiringFoods: (json['expiringFoods'] as List)
          .map((e) => ExpiringFood.fromJson(e))
          .toList(),
      allFoods: (json['allFoods'] as List)
          .map((e) => AllFood.fromJson(e))
          .toList(),
      foodTypePercentages: json['foodTypePercentages'],
    );
  }
}

// ... (import, 모델 부분 동일)

class HomeScreen extends StatelessWidget {
  final String jwtToken;

  const HomeScreen({super.key, required this.jwtToken});

  Future<MainPageData> fetchMainPageData() async {
    final baseUrl = dotenv.env['API_URL']!;
    final response = await http.get(
      Uri.parse('$baseUrl/api/mainPage'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return MainPageData.fromJson(json.decode(decoded));
    } else {
      throw Exception('Failed to load main page data');
    }
  }

  // 공통 빈 박스 위젯
  Widget buildEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<MainPageData>(
          future: fetchMainPageData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터가 없습니다'));
            }

            final data = snapshot.data!;

            // ✨ 임박 재료 3개 제한
            final expiringFoodsLimited =
                data.expiringFoods.take(3).toList();

            // ✨ 전체 재료 6개 제한
            final allFoodsLimited =
                data.allFoods.take(6).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 인사말
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Pretendard-Bold',
                          fontSize: 36,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: '${data.nickname}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F7CFF),
                            ),
                          ),
                          const TextSpan(text: '님의\n냉장고를 열어볼게요.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 냉장고 구성 비율
                    const Text(
                      '냉장고 구성은 이렇게 되어있어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CategoryBar(percentages: data.foodTypePercentages),

                    // 유통기한 임박 재료
                    const Text(
                      '유통기한이 얼마 남지 않았어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    expiringFoodsLimited.isEmpty
                        ? buildEmptyBox('등록된 재료가 없어요')
                        : ExpiringItems(items: expiringFoodsLimited),
                    const SizedBox(height: 32),

                    // 전체 재료 한눈에 보기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '전체 재료 한눈에 보기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecommendScreen1(jwtToken: jwtToken),
                              ),
                            );
                          },
                          child: const Text(
                            '추천받으러 가기 >',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    allFoodsLimited.isEmpty
                        ? buildEmptyBox('등록된 재료가 없어요')
                        : IngredientsTable(
                            ingredients: allFoodsLimited
                                .map(
                                  (food) => {
                                    'name': food.name,
                                    'amount': '${food.quantity}개',
                                    'expiry': food.expDate,
                                  },
                                )
                                .toList(),
                          ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllScreen(jwtToken: jwtToken),
                            ),
                          );
                        },
                        child: const Text(
                          '자세히 보기 ▲',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: jwtToken),
    );
  }
}
