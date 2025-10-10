//사용자가 냉장고에 등록한 모든 재료 확인
//홈화면에서 "내 전체 재료 보기"시 확인 가능
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 모델
class AllFood {
  final int id;
  final String name;
  final String type;
  final int quantity;
  final String expDate;

  AllFood({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.expDate,
  });

  factory AllFood.fromJson(Map<String, dynamic> json) {
    return AllFood(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'],
      expDate: json['expDate'],
    );
  }
}

class AllScreen extends StatefulWidget {
  final String jwtToken;
  const AllScreen({super.key, required this.jwtToken});

  @override
  State<AllScreen> createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  int currentPage = 0;
  late Future<List<AllFood>> _futureFoods;

  @override
  void initState() {
    super.initState();
    _futureFoods = fetchAllFoods();
  }

  Future<List<AllFood>> fetchAllFoods() async {
    final baseUrl = dotenv.env['API_URL']!;
    final response = await http.get(
      Uri.parse('$baseUrl/api/mainPage'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = json.decode(decoded);
      final foods = (data['allFoods'] as List)
          .map((e) => AllFood.fromJson(e))
          .toList();
      return foods;
    } else {
      throw Exception('Failed to load allFoods');
    }
  }

  @override
  Widget build(BuildContext context) {
    const int itemsPerPage = 15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<AllFood>>(
          future: _futureFoods,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('등록된 재료가 없어요'));
            }

            final foods = snapshot.data!;
            final int totalPages = (foods.length / itemsPerPage).ceil();
            final int startIndex = currentPage * itemsPerPage;
            final int endIndex = (startIndex + itemsPerPage).clamp(0, foods.length);
            final List<AllFood> currentItems = foods.sublist(startIndex, endIndex);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  // 표 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            '재료',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '개수',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '유통기한',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 표 본문
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(), // 스크롤 제거
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 4, child: Text(item.name)),
                              Expanded(flex: 2, child: Text('${item.quantity}개')),
                              Expanded(flex: 3, child: Text(item.expDate)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 페이지네이션 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                      Text(
                        '${currentPage + 1} / $totalPages',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages - 1
                            ? () => setState(() => currentPage++)
                            : null,
                      ),
                    ],
                  ),

                  // 하단 버튼
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '돌아가기 ▼',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }
}
