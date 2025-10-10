import 'package:flutter/material.dart';

class IngredientsTable extends StatelessWidget {
  final List<Map<String, String>> ingredients;

  const IngredientsTable({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
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

        // 내용
        ingredients.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '등록된 재료가 없어요',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ingredients.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = ingredients[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Text(item['name']!)),
                        Expanded(flex: 2, child: Text(item['amount']!)),
                        Expanded(flex: 3, child: Text(item['expiry']!)),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}
