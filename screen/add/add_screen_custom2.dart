// o //
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/add/add_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddScreenCustom2 extends StatefulWidget {
  final String jwtToken;
  final String ingredientName;
  const AddScreenCustom2({super.key, required this.jwtToken, required this.ingredientName});

  @override
  State<AddScreenCustom2> createState() => _AddScreenCustom2State();
}

class _AddScreenCustom2State extends State<AddScreenCustom2> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  int count = 1;

  Future<void> addCustomIngredient() async {
    final String name = nameController.text.trim();
    final String dateStr = dateController.text.trim();

    if (name.isEmpty || dateStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 유통기한을 입력해주세요.')),
      );
      return;
    }

    // expDate를 숫자로 변환 (단순히 일수로 가정)
    int expDate = 0;
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        // 오늘 기준으로 일수 계산 (단순 예시)
        final inputDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        final now = DateTime.now();
        expDate = inputDate.difference(now).inDays;
      }
    } catch (_) {
      expDate = 0;
    }

    // POST 요청
    final baseUrl = dotenv.env['API_URL']!;
    final uri = Uri.parse('$baseUrl/api/refrigerator/add-ingredient');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': 0, // 새로 추가하는 커스텀 재료는 id 0
          'quantity': count,
          'name': name,       // 커스텀 재료 이름
          'expDate': expDate, // 유통기한 일수
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재료 등록 완료')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddScreen(jwtToken: widget.jwtToken)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
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
              const Center(
                child: Text(
                  '< 사용자 지정 재료',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 30),
              const Text('재료명', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              const Text('개수', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Row(
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
              const Text('유통기한', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: '예) 2025.12.31',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addCustomIngredient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3366FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('등록하기', style: TextStyle(fontSize: 16)),
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
