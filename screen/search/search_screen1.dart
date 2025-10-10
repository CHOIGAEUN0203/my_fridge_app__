//음식 검색하면 해당 레시피 확인 가능(미완)
//페이지 연동 오류. 수정필요
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/screen/recommend/recommend_screen2.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';

// 1️⃣ Recipe 모델
class Recipe {
  final String id;
  final String title;

  Recipe({required this.id, required this.title});
}

class SearchScreen1 extends StatefulWidget {
  final String jwtToken;
  const SearchScreen1({super.key, required this.jwtToken});

  @override
  State<SearchScreen1> createState() => _SearchScreen1State();
}

class _SearchScreen1State extends State<SearchScreen1> {
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    setState(() => _isLoading = true);

    final baseUrl = dotenv.env['API_URL']!;
    final url = Uri.parse("$baseUrl/api/recipes/all");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded['recipes'] is List) {
          dataList = decoded['recipes'];
        }

        final recipes = dataList.map((r) {
          final map = r as Map<String, dynamic>;
          return Recipe(
            id: map['id']?.toString() ?? '',
            title: map['name'] ?? '제목 없음',
          );
        }).toList();

        if (!mounted) return;
        setState(() {
          _recipes = recipes;
          _filteredRecipes = recipes;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("에러 발생: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    final filtered = _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => _filteredRecipes = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '어떤 음식을 찾고있나요?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // 검색창
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "음식을 검색하세요",
                          border: InputBorder.none,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(thickness: 0.7),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecipes.isEmpty
                        ? const Center(child: Text("검색 결과가 없습니다."))
                        : ListView.builder(
                            itemCount: _filteredRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _filteredRecipes[index];
                              return ListTile(
                                title: Text(recipe.title),
                                onTap: () {
                                  print("📌 선택 레시피: ${recipe.title}, id: ${recipe.id}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecommendScreen2(
                                        jwtToken: widget.jwtToken,
                                        recipeId: recipe.id,
                                      ),
                                    ),
                                  );
                                },
                              );
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
}
