//xxxxxxx필요없는 페이지xxxxxxxx//
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:my_fridge_app__/screen/my_r/r_add_screen.dart';

class RIngredientScreen extends StatefulWidget {
  final String jwtToken;

  const RIngredientScreen({super.key, required this.jwtToken});

  @override
  State<RIngredientScreen> createState() => _RIngredientScreenState();
}

class _RIngredientScreenState extends State<RIngredientScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  // 재료 검색
  Future<void> _searchIngredients(String query) async {
    if (query.isEmpty) {
      await _fetchAllIngredients();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final baseUrl = dotenv.env['API_URL']!; 
      
      final response = await http.get( 
        Uri.parse('$baseUrl/api/ingredients/search?name=$encodedQuery'),
        headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() => _searchResults = []);
      }
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 전체 재료 불러오기
  Future<void> _fetchAllIngredients() async {
    setState(() => _isLoading = true);

    try {
      final baseUrl = dotenv.env['API_URL']!; 

      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients'), headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() => _searchResults = []);
      }
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllIngredients(); // 초기 화면에서 전체 재료 불러오기
  }

  // 재료 추가 팝업
  void _showAddPopup(Map<String, dynamic> ingredient) {
    int count = 1;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: ingredient['name'],
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const TextSpan(
                          text: '를 추가할까요?',
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pop(context, {
                                  'id': ingredient['id'],
                                  'name': ingredient['name'],
                                  'count': count,
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('넣기'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    ).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
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
              const Text(
                '당신의 레시피에는\n무엇이 들어가나요?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '재료를 검색하세요',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _searchIngredients(value),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final ingredient = _searchResults[index];
                          return ListTile(
                            title: Text(ingredient['name']),
                            onTap: () => _showAddPopup(ingredient),
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
