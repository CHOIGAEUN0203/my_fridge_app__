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

// ✅ 모델 클래스
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

  MainPageData({
    required this.nickname,
    required this.expiringFoods,
    required this.allFoods,
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
    );
  }
}

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

  /// ✅ 카테고리 비율 계산 함수 (상위 4개 + 기타, 내림차순 정렬)
  Map<String, double> calculateFoodTypePercentages(List<AllFood> foods) {
    if (foods.isEmpty) return {};

    final Map<String, int> typeCounts = {};
    for (var food in foods) {
      typeCounts[food.type] = (typeCounts[food.type] ?? 0) + food.quantity;
    }

    final int total = typeCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return {};

    final sortedEntries = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top4 = sortedEntries.take(4).toList();
    final others = sortedEntries.skip(4).toList();
    final int othersSum = others.fold(0, (sum, e) => sum + e.value);

    // 비율 계산
    final Map<String, double> result = {
      for (var e in top4)
        e.key: double.parse(((e.value / total) * 100).toStringAsFixed(1)),
    };

    if (othersSum > 0) {
      result['기타'] =
          double.parse(((othersSum / total) * 100).toStringAsFixed(1));
    }

    // ✅ 비율 내림차순 정렬해서 Map으로 다시 반환
    final sortedResult = Map.fromEntries(
      result.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sortedResult;
  }

  Widget buildEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
      backgroundColor: const Color(0xFFF7F7F7),
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
            final expiringFoodsLimited = data.expiringFoods.take(3).toList();
            final allFoodsLimited = data.allFoods.take(6).toList();
            final calculatedPercentages =
                calculateFoodTypePercentages(data.allFoods);

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 인사말
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Pretendard-Bold',
                          fontSize: 34,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: '${data.nickname}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F7CFF),
                            ),
                          ),
                          const TextSpan(text: '님의\n냉장고를 열어볼게요.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      '냉장고 구성은 이렇게 되어있어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ 비율 반영된 카테고리 바
                    CategoryBar(percentages: calculatedPercentages),

                    const SizedBox(height: 24),
                    const Text(
                      '유통기한이 얼마 남지 않았어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    expiringFoodsLimited.isEmpty
                        ? buildEmptyBox('등록된 재료가 없어요')
                        : ExpiringItems(items: expiringFoodsLimited),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '전체 재료 한눈에 보기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey),
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
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
