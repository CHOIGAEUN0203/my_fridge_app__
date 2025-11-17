import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecommendScreen2 extends StatefulWidget {
  final String jwtToken;
  final String recipeId;
  final bool fromSearch; // ✅ SearchScreen에서 온 경우 구분용 플래그

  const RecommendScreen2({
    super.key,
    required this.jwtToken,
    required this.recipeId,
    this.fromSearch = false, // 기본값 false
  });

  @override
  State<RecommendScreen2> createState() => _RecommendScreen2State();
}

class _RecommendScreen2State extends State<RecommendScreen2> {
  late Future<Map<String, dynamic>> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipeDetails();
  }

  @override
  void didUpdateWidget(covariant RecommendScreen2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId) {
      setState(() {
        _recipeFuture = fetchRecipeDetails();
      });
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    final baseUrl = dotenv.env['API_URL']!;
    final endpoint = widget.fromSearch
        ? "$baseUrl/api/recipes/details-db/${widget.recipeId}"
        : "$baseUrl/api/recipes/details/${widget.recipeId}";

    final url = Uri.parse(endpoint);

    print("🍳 [RecommendScreen2] 요청 URL: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
    );

    print("📡 응답 코드: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print("📦 응답 데이터: $decoded");

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
        return decoded.first;
      }
      throw Exception("예상치 못한 응답 구조: ${decoded.runtimeType}");
    } else {
      throw Exception('레시피 정보를 불러오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('레시피 정보가 없습니다.'));
            } else {
              final data = snapshot.data!;

              // ✅ 이름 통합
              final name = data['name'] ?? data['recipeName'] ?? '추천 레시피';

              // ✅ 재료 목록
              final ingredients = List<Map<String, dynamic>>.from(data['ingredients'] ?? []);

              // ✅ 조리 단계 — 이미지 URL 걸러내기
              final cookingSteps = (data['steps'] as List?)
                      ?.map((step) => step['description']?.toString() ?? '')
                      .where((desc) =>
                          desc.isNotEmpty &&
                          !desc.startsWith('http://') &&
                          !desc.startsWith('https://'))
                      .toList() ??
                  (data['cookingSteps'] as List?)
                      ?.whereType<String>()
                      .where((step) =>
                          !step.startsWith('http://') &&
                          !step.startsWith('https://'))
                      .toList() ??
                  [];

              // ✅ 영양성분 처리 — details-db에는 없을 수 있음
              final nutrition = {
                "kcal": data['energy']?.toString().isNotEmpty == true
                    ? data['energy'].toString()
                    : '정보 없음',
                "탄수화물": data['carbohydrate']?.toString().isNotEmpty == true
                    ? data['carbohydrate'].toString()
                    : '-',
                "단백질": data['protein']?.toString().isNotEmpty == true
                    ? data['protein'].toString()
                    : '-',
                "지방": data['fat']?.toString().isNotEmpty == true
                    ? data['fat'].toString()
                    : '-',
                "나트륨": data['sodium']?.toString().isNotEmpty == true
                    ? data['sodium'].toString()
                    : '-',
              };

              final sodiumTip = data['tip']?.toString() ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '레시피를 알려드릴게요!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ 재료 영역
                    const Text(
                      '이 요리를 위해 필요한 재료들이에요',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: ingredients
                            .map((ing) => IngredientRow(
                                  left: ing['name'] ?? '',
                                  right: ing['amount'] ?? '',
                                ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ 영양 성분 영역
                    const Text(
                      '영양성분은 이렇게 구성됐어요',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (nutrition['kcal'] ?? '0'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Kcal',
                                  style: TextStyle(fontSize: 16, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: nutrition.entries
                                  .where((e) => e.key != 'kcal')
                                  .map((e) => NutrientRow(
                                        label: e.key,
                                        value: e.value.toString(),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ 조리법
                    const Text(
                      '이제 조리법을 알려드릴게요',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cookingSteps.isEmpty
                            ? [const Text("조리 단계 정보가 없습니다.")]
                            : cookingSteps
                                .map((step) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        step,
                                        style: const TextStyle(fontSize: 16, height: 1.5),
                                      ),
                                    ))
                                .toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ 나트륨 팁
                    if (sodiumTip.isNotEmpty) ...[
                      const Text(
                        '💡 나트륨 줄이는 꿀팁!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          sodiumTip,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }
}

// ✅ 재료 UI 위젯
class IngredientRow extends StatelessWidget {
  final String left;
  final String right;

  const IngredientRow({required this.left, required this.right, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontSize: 15)),
          Text(right, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

// ✅ 영양성분 UI 위젯
class NutrientRow extends StatelessWidget {
  final String label;
  final String value;

  const NutrientRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
