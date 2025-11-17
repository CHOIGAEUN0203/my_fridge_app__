// r1
// ai 기반 추천 음식 10개 띄움
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/recommend/recommend_screen2.dart';

// Recipe 모델
class Recipe {
  final String id;
  final String title;

  Recipe({required this.id, required this.title});
}

class RecommendScreen1 extends StatefulWidget {
  final String jwtToken;
  const RecommendScreen1({super.key, required this.jwtToken});

  @override
  State<RecommendScreen1> createState() => _RecommendScreen1State();
}

class _RecommendScreen1State extends State<RecommendScreen1> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = fetchRecommendedRecipes();
  }

Future<List<Recipe>> fetchRecommendedRecipes() async {
  final baseUrl = dotenv.env['API_URL']!;
  final url = Uri.parse("$baseUrl/api/recipes/recommend");
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer ${widget.jwtToken}',
      'Content-Type': 'application/json',
    },
  );


  if (response.statusCode == 200) {
    final safeBody = response.body.replaceAll('NaN', 'null');
    final decoded = json.decode(safeBody);

    // 리스트로 변환
    List<dynamic> dataList = [];
    if (decoded is List) {
      dataList = decoded;
    } else if (decoded is Map && decoded['recipes'] is List) {
      dataList = decoded['recipes'];
    }

    return dataList
        .map((r) {
          final map = r as Map<String, dynamic>;
          return Recipe(
            id: map['recipeId']?.toString() ?? '',
            title: map['recipeName'] ?? '제목 없음',
          );
        })
        .toList();
  } else {
    throw Exception('추천 레시피를 불러오는 데 실패했습니다.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'AI가 현재 재료로\n만들 수 있는 요리를 추천했어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              Expanded(
  child: FutureBuilder<List<Recipe>>(
    future: _recipesFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('오류 발생: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('추천 레시피가 없습니다.'));
      } else {
        final recipes = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: recipes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildRecipeButton(context, recipes[index]);
          },
        );
      }
    },
  ),
),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }

  Widget _buildRecipeButton(BuildContext context, Recipe recipe) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendScreen2(
                jwtToken: widget.jwtToken,
                recipeId: recipe.id, // ID 전달
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF9F9F9),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
