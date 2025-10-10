import 'package:flutter/material.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/recommend/recommend_screen2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchScreen2 extends StatelessWidget {
  final String jwtToken;
  final String recipe;
  const SearchScreen2({super.key, required this.jwtToken, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> foodList = [
      {'id': '1', 'name': '산채비빔밥', 'kcal': 730},
      {'id': '2', 'name': '꼬막비빔밥', 'kcal': 965},
      {'id': '3', 'name': '육회비빔밥', 'kcal': 880},
      {'id': '4', 'name': '소불고기덮밥', 'kcal': 1104},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '어떤 음식을 찾고있나요?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '음식을 검색하세요',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: foodList.length,
                  itemBuilder: (context, index) {
                    final food = foodList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendScreen2(
                              jwtToken: jwtToken,
                              recipeId: food['id'], // ID 전달
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              food['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${food['kcal']} Kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: jwtToken),
    );
  }
}
