import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostDetailScreen extends StatefulWidget {
  final String jwtToken;
  final int recipeId;

  const PostDetailScreen({
    super.key,
    required this.jwtToken,
    required this.recipeId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _recipe;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.get(
        Uri.parse("$baseUrl/api/my-recipes/${widget.recipeId}"),
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // ✅ ingredients가 String이면 jsonDecode로 변환
        if (data['ingredients'] != null && data['ingredients'] is String) {
          try {
            data['ingredients'] = jsonDecode(data['ingredients']);
          } catch (e) {
            data['ingredients'] = [];
          }
        }

        setState(() {
          _recipe = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "서버 오류: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "불러오기 실패: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _recipe == null
                    ? const Center(child: Text("데이터 없음"))
                    : _buildContent(),
      ),
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }

  Widget _buildContent() {
    final recipe = _recipe!;

    // ✅ ingredients는 List<Map> 형태로 변환 후 사용
    List<dynamic> ingredients = [];
    if (recipe["ingredients"] != null && recipe["ingredients"] is List) {
      ingredients = recipe["ingredients"];
    }

    final String cookingSteps = recipe["cookingSteps"] ?? "";

    return Column(
      children: [
        // 상단 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                "게시글",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 음식 사진
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(16),
                    image: recipe["imageUrl"] != null &&
                            recipe["imageUrl"].toString().isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(recipe["imageUrl"]),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 제목 + 설명
                Text(
                  recipe["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recipe["shortDescription"] ?? "",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                const Text(
                  "이 요리를 위해 필요한 재료들이에요",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 재료 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < ingredients.length; i += 2)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${ingredients[i]['name'] ?? ''}  ${ingredients[i]['amount']?.toString() ?? ''}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (i + 1 < ingredients.length)
                              Expanded(
                                child: Text(
                                  "${ingredients[i + 1]['name'] ?? ''}  ${ingredients[i + 1]['amount']?.toString() ?? ''}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "나만의 레시피 요리법",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cookingSteps,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
