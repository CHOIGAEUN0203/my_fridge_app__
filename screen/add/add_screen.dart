// 냉장고에 재료 추가(검색) //
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/add/add_screen_custom1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddScreen extends StatefulWidget {
  final String jwtToken;
  const AddScreen({super.key, required this.jwtToken});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String? error;

  // 전체 재료 불러오기
  Future<void> fetchAllIngredients() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final baseUrl = dotenv.env['API_URL']!;
    final uri = Uri.parse('$baseUrl/api/ingredients');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          searchResults = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = '서버 오류: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '불러오기 실패: $e';
        isLoading = false;
      });
    }
  }

  // 검색 API 호출
  Future<void> searchIngredient(String query) async {
    if (query.isEmpty) {
      fetchAllIngredients();
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });
    final baseUrl = dotenv.env['API_URL']!;
    final uri = Uri.parse('$baseUrl/api/ingredients/search?name=$query');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          searchResults = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = '검색 실패: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '검색 실패: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("재료 추가")),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "재료를 검색하세요",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: searchIngredient,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : ListView.separated(
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          return ListTile(
                            title: Text(item['name'] ?? '-'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddScreenCustom1(
                                    jwtToken: widget.jwtToken,
                                    ingredientId: item['id'],
                                    ingredientName: item['name'],
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
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }
}
