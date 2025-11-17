import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/screen/recommend/recommend_screen2.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';

// ✅ Recipe 모델
class Recipe {
  final int id;
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
  bool _dataLoaded = false;

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

        if (decoded is! List) throw Exception("Unexpected format: not a List");

        if (decoded.isNotEmpty) {
          print("📦 서버 응답 샘플: ${decoded.first}");
        }

        final recipes = decoded.map<Recipe>((r) {
          final map = r as Map<String, dynamic>;
          final id = map['id'] ?? map['recipeId'] ?? 0;
          final title = map['name'] ?? map['title'] ?? '제목 없음';
          return Recipe(id: id, title: title);
        }).where((r) => r.id != 0).toList();

        if (!mounted) return;
        setState(() {
          _recipes = recipes;
          _isLoading = false;
          _dataLoaded = true;
        });

        print("✅ 총 ${_recipes.length}개의 레시피 불러옴");
      } else {
        print("❌ 서버 응답 코드: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("⚠️ 에러 발생: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (!_dataLoaded) return;
    if (query.isEmpty) {
      setState(() => _filteredRecipes = []);
      return;
    }

    final filtered = _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => _filteredRecipes = filtered);
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['API_URL']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "레시피 검색",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🍲 어떤 음식을 찾고 있나요?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 🔍 검색창
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "레시피 이름을 검색하세요",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 0.7),

              // 📋 검색 결과
              Expanded(
                child: !_dataLoaded
                    ? const Center(child: CircularProgressIndicator(color: Colors.grey))
                    : _filteredRecipes.isEmpty
                        ? const Center(
                            child: Text(
                              "검색어를 입력해주세요.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchAllRecipes,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredRecipes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final recipe = _filteredRecipes[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      recipe.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                    onTap: () {
                                      print("➡️ 선택한 레시피 ID: ${recipe.id}, 제목: ${recipe.title}");
                                      print("🍳 RecommendScreen2로 이동: $baseUrl/api/recipes/details-db/${recipe.id}");

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecommendScreen2(
                                            jwtToken: widget.jwtToken,
                                            recipeId: recipe.id.toString(),
                                            fromSearch: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
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
