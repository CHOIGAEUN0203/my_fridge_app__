// ✅ CategoryBar.dart
import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final Map<String, dynamic> percentages;

  const CategoryBar({super.key, required this.percentages});

  @override
  Widget build(BuildContext context) {
    // 백엔드에서 받은 데이터를 기반으로 categories 생성
    final categories = percentages.entries.map((entry) {
      return {
        'label': entry.key, // 백엔드에서 받은 실제 카테고리 이름
        'color': _getColorForCategory(entry.key),
        'ratio': (entry.value ?? 0).toDouble(),
      };
    }).toList();

    // ✅ 비율(ratio) 기준 내림차순 정렬
    categories.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));

    final totalRatio =
        categories.fold<double>(0, (sum, item) => sum + (item['ratio'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 색상 그래프 바
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: totalRatio == 0
                ? [
                    Expanded(
                      child: Container(
                        height: 20,
                        color: Colors.grey.shade200,
                      ),
                    )
                  ]
                : categories
                    .map(
                      (item) => Expanded(
                        flex: ((item['ratio'] as double) * 100).toInt(),
                        child: Container(
                          height: 20,
                          color: item['color'],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // ✅ 범례 (왼쪽부터 내림차순으로)
        Wrap(
          spacing: 12,
          children: categories
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item['color'],
                      ),
                    ),
                    Text(
                      "${item['label']} (${item['ratio']}%)",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
              .toList(),
        )
      ],
    );
  }

  // ✅ 카테고리 이름에 따른 색상 자동 지정
  Color _getColorForCategory(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('육')) return const Color(0xFFE57373); // 육류
    if (lower.contains('과일')) return const Color(0xFFFFF176); // 노란색 - 과일
    if (lower.contains('채소') || lower.contains('야채')) return const Color(0xFF81C784); // 초록색 - 채소/야채
    if (lower.contains('수산') || lower.contains('해산')) return const Color(0xFF64B5F6); // 수산물
    return const Color(0xFF9E9E9E); // 기타
  }
}
