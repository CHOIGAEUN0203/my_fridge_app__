import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String jwtToken;
  final int recipeId;

  const CommunityDetailScreen({
    super.key,
    required this.jwtToken,
    required this.recipeId,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _recipe;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.get(
        Uri.parse("$baseUrl/api/community/recipes/${widget.recipeId}"),
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // 재료 처리
        var ingredients = data['ingredients'];
        if (ingredients is String) {
          try {
            final decoded = jsonDecode(ingredients);
            ingredients = decoded is List ? decoded : [];
          } catch (_) {
            ingredients = [];
          }
        } else if (ingredients == null) {
          ingredients = [];
        }

        // likeCount, recipeId 안정화
        data['likeCount'] = data['likeCount'] is int
            ? data['likeCount']
            : int.tryParse(data['likeCount']?.toString() ?? '0') ?? 0;
        data['id'] = data['id'] is int
            ? data['id']
            : int.tryParse(data['id']?.toString() ?? '0') ?? 0;
        data['ingredients'] = ingredients;

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

  Future<void> _toggleLike() async {
    if (_recipe == null) return;

    final wasLiked = _isLiked;

    // UI 즉시 업데이트
    setState(() {
      _isLiked = !_isLiked;
      final current = _recipe!['likeCount'] ?? 0;
      _recipe!['likeCount'] = current + (_isLiked ? 1 : -1);
    });

    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.post(
        Uri.parse("$baseUrl/api/community/recipes/${widget.recipeId}/like"),
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // 실패 시 롤백
        setState(() {
          _isLiked = wasLiked;
          final current = _recipe!['likeCount'] ?? 0;
          _recipe!['likeCount'] = current + (_isLiked ? 1 : -1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("좋아요 요청 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // 에러 발생 시 롤백
      setState(() {
        _isLiked = wasLiked;
        final current = _recipe!['likeCount'] ?? 0;
        _recipe!['likeCount'] = current + (_isLiked ? 1 : -1);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("좋아요 중 오류 발생: $e")),
      );
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
    final ingredients = recipe["ingredients"] as List<dynamic>? ?? [];
    final postedDate = recipe["postedDate"]?.toString() ?? "";
    final userNickname = recipe["userNickname"] ?? "익명";

    return Column(
      children: [
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
                "커뮤니티 게시글",
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
                Text(
                  recipe["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe["shortDescription"] ?? "",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  "작성자: $userNickname",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      postedDate.contains('T')
                          ? "등록일: ${postedDate.split('T').first}"
                          : "등록일: $postedDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${recipe['likeCount'] ?? 0}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "이 요리를 위해 필요한 재료들이에요",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ingredients.isEmpty
                      ? const Text("등록된 재료 정보가 없습니다.")
                      : Column(
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
                  "요리 순서",
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
                    recipe["cookingSteps"] ?? "",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
