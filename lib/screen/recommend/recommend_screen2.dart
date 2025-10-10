// 레시피 상세 확인
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecommendScreen2 extends StatefulWidget {
  final String jwtToken;
  final String recipeId; // 레시피 ID

  const RecommendScreen2({
    super.key,
    required this.jwtToken,
    required this.recipeId,
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

 Future<Map<String, dynamic>> fetchRecipeDetails() async {
  final baseUrl = dotenv.env['API_URL']!;
  final url = Uri.parse("$baseUrl/api/recipes/details/${widget.recipeId}");

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer ${widget.jwtToken}',
      'Content-Type': 'application/json',
    },
  );
  print("*^_^* RecommendScreen2에서 전달받은 recipeId: ${widget.recipeId}"); 

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    // 혹시 전체가 리스트인지 확인
    if (decoded is List) {
      return {"data": decoded};
    }

    // 기본적으로 Map이면 그대로 반환
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception("예상치 못한 응답 구조: ${decoded.runtimeType}");
  } else {
    throw Exception('레시피 정보를 불러오는 데 실패했습니다.');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // 🔹 백엔드 응답에 맞춰 파싱
              final allIngredients =
                  (data['allIngredients'] as String? ?? '').split(',').map((e) {
                final parts = e.trim().split('|');
                return {
                  'name': parts.length > 0 ? parts[0].trim() : '',
                  'amount': parts.length > 1 ? parts[1].trim() : ''
                };
              }).toList();

              final cookingSteps = (data['cookingSteps'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList();

              final nutrition =
                  Map<String, dynamic>.from(data['nutrition'] ?? {});

              final sodiumTip = data['sodiumTip']?.toString() ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 (응답에 title이 없으면 recipeId 보여줌)
                    Text(
                      '추천 레시피',
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

                    // 재료
                    const Text(
                      '이 요리를 위해 필요한 재료들이에요',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: allIngredients
                            .map((ing) => IngredientRow(
                                  left: ing['name'] ?? '',
                                  right: ing['amount'] ?? '',
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 영양 성분
                    const Text(
                      '영양성분은 이렇게 구성됐어요',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // 칼로리 원형 표시
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
                                (nutrition['kcal']?.toString() ?? '0'),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                              const Text(
                                'Kcal',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // 나머지 영양소 리스트
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: nutrition.entries
                                .where((e) => e.key != 'kcal')
                                .map((e) => NutrientRow(
                                    label: e.key,
                                    value: e.value.toString()))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 조리법
                    const Text(
                      '이제 조리법을 알려드릴게요',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      cookingSteps.length,
                      (index) => RecipeStep(
                          number: index + 1, text: cookingSteps[index]),
                    ),
                    const SizedBox(height: 28),

                    // 나트륨 팁
                    if (sodiumTip.isNotEmpty) ...[
                      const Text(
                        '💡 나트륨 줄이는 꿀팁!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sodiumTip,
                        style: const TextStyle(fontSize: 15, height: 1.5),
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

// 재료 위젯
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

// 영양 성분 위젯
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
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

// 조리법 위젯
class RecipeStep extends StatelessWidget {
  final int number;
  final String text;

  const RecipeStep({required this.number, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$number. $text',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
