//나만의 레시피 String으로 작성해 추가//
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:my_fridge_app__/widgets/bottom_nav.dart';

class RecipeAddScreen extends StatefulWidget {
  final String jwtToken;

  const RecipeAddScreen({super.key, required this.jwtToken});

  @override
  State<RecipeAddScreen> createState() => _RecipeAddScreenState();
}

class _RecipeAddScreenState extends State<RecipeAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortDescController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // 🔹 재료 리스트 (ingredientId + amount)
  final List<Map<String, dynamic>> _ingredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add({
          "ingredientId": 0, // 실제 앱에서는 DB에서 가져와야 함
          "amount": text
        });
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _submitRecipe() async {
    if (_nameController.text.isEmpty || _shortDescController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("레시피 이름과 한줄소개를 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? base64Image;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final body = {
        "name": _nameController.text,
        "shortDescription": _shortDescController.text,
        "imageUrl": base64Image ?? "",
        // 🔹 Map 리스트를 JSON 문자열로 변환
        "ingredients": jsonEncode(_ingredients),
        "cookingSteps": _stepsController.text,
      };

      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.post(
        Uri.parse('$baseUrl/api/my-recipes'),
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        Navigator.pop(context, data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("레시피 등록 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("레시피 등록 중 오류 발생: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 14))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(title: const Text("레시피 추가")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("레시피 이름",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController, hintText: "예: 감자조림"),
            const SizedBox(height: 16),

            const Text("한줄소개",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _shortDescController,
              hintText: "예: 간단하게 만들 수 있는 감자조림!",
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            const Text("사진 추가",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? _buildButton("+ 사진 추가하기")
                  : Image.file(_imageFile!, height: 150),
            ),
            const SizedBox(height: 16),

            const Text("재료 추가",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ingredientController,
                    hintText: "예: 200g 감자",
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addIngredient, child: const Text("추가")),
              ],
            ),
            if (_ingredients.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _ingredients.length,
                  (index) => Chip(
                    label: Text(_ingredients[index]["amount"]),
                    onDeleted: () => _removeIngredient(index),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            const Text("요리법 작성",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _stepsController,
              hintText: "예: 감자를 깍둑썰기해서 볶아주세요...",
              maxLines: 6,
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRecipe,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("등록하기"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: widget.jwtToken),
    );
  }
}
