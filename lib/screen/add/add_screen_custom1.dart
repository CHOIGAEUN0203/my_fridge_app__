// o //
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/add/add_screen.dart';

class AddScreenCustom1 extends StatefulWidget {
  final String jwtToken;
  final int ingredientId;       // ✅ 추가
  final String ingredientName;  // ✅ 추가

  const AddScreenCustom1({
    super.key,
    required this.jwtToken,
    required this.ingredientId,
    required this.ingredientName,
  });

  @override
  State<AddScreenCustom1> createState() => _AddScreenCustom1State();
}

class _AddScreenCustom1State extends State<AddScreenCustom1> {
  int count = 1;
  bool isLoading = false; // ✅ 서버 요청 중 로딩 상태

  // 서버에 재료 추가
  Future<void> _addIngredient() async {
    setState(() => isLoading = true);

    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.post(
        Uri.parse('$baseUrl/api/refrigerator/add-ingredient'), // ✅ 실제 백엔드 URL로 변경
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': widget.ingredientId,
          'quantity': count,
        }),
      );

      if (response.statusCode == 200) {
        // 성공 시 화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(jwtToken: widget.jwtToken),
          ),
        );
      } else {
        // 실패 시 스낵바 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재료 추가 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '냉장고 재료를 등록해볼까요?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: '재료를 검색하세요',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('최근에 등록한 재료', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      // TODO: 직접 추가 기능
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF3366FF),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('직접 재료 추가하기', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.ingredientName,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const TextSpan(
                            text: '를 냉장고에 넣을까요?',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (count > 1) setState(() => count--);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$count', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () => setState(() => count++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddScreen(jwtToken: widget.jwtToken),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : _addIngredient, // ✅ 서버 연동
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('넣기'),
                        ),
                      ],
                    )
                  ],
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
