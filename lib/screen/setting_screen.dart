//사용자 설정 페이지. 지금까지 등록한 나만의 레시피 보기
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/my_r/r_add_screen.dart';
import 'package:my_fridge_app__/screen/post/post_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingScreen extends StatefulWidget {
  final String jwtToken;
  const SettingScreen({super.key, required this.jwtToken});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<Map<String, dynamic>> _myRecipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyRecipes();
  }

  // ✅ 서버에서 JWT로 내 레시피 가져오기
  Future<void> _fetchMyRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.get(
        Uri.parse('$baseUrl/api/mypage'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(utf8.decode(response.bodyBytes));

        final List<dynamic> recipes = json['myRecipes'] ?? [];

        setState(() {
          // id를 int 그대로 유지
          _myRecipes = recipes
              .map<Map<String, dynamic>>(
                (e) => {
                  'id': e['id'],
                  'title': e['name'] ?? '',
                  'subtitle': e['shortDescription'] ?? '',
                },
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '서버 오류: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '불러오기 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('< 마이 페이지', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // 상단 타이틀 + 레시피 추가 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '나만의 레시피',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeAddScreen(jwtToken: widget.jwtToken),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _myRecipes.insert(0, {
                            'id': result['id'], // int 그대로
                            'title': result['name'] ?? '',
                            'subtitle': result['shortDescription'] ?? '',
                          });
                        });
                      }
                    },
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('레시피 추가하기', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 레시피 리스트
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : _myRecipes.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text('아직 레시피가 추가되지 않았어요'),
                              )
                            : ListView.separated(
                                itemCount: _myRecipes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final recipe = _myRecipes[index];
                                  final recipeId = recipe['id'] as int?;
                                  if (recipeId == null) return const SizedBox.shrink();
                                  return _buildRecipeCard(
                                    id: recipeId,
                                    title: recipe['title'] ?? '',
                                    subtitle: recipe['subtitle'] ?? '',
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

  // 레시피 카드
  Widget _buildRecipeCard({
    required int id,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        // ✅ 실제 recipeId와 JWT를 PostDetailScreen으로 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              jwtToken: widget.jwtToken,
              recipeId: id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('레시피 보러가기 >',
                  style: TextStyle(fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
