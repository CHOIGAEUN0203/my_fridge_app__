import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final Map<String, dynamic> percentages;

  const CategoryBar({super.key, required this.percentages});

  @override
  Widget build(BuildContext context) {
    // 서버에서 받은 percentages를 기반으로 categories 생성
    final categories = [
      {
        'label': '육류',
        'color': const Color(0xFFE57373),
        'ratio': (percentages['meat'] ?? 0).toDouble()
      },
      {
        'label': '과일/야채류',
        'color': const Color(0xFF81C784),
        'ratio': (percentages['fruitVeg'] ?? 0).toDouble()
      },
      {
        'label': '수산물',
        'color': const Color(0xFF64B5F6),
        'ratio': (percentages['seafood'] ?? 0).toDouble()
      },
      {
        'label': '기타',
        'color': const Color(0xFF9E9E9E),
        'ratio': (percentages['etc'] ?? 0).toDouble()
      },
    ];

    final totalRatio =
        categories.fold<double>(0, (sum, item) => sum + item['ratio']);

    return Column(
      children: [
        // 색상 그래프 바
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
        // 범례
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
                      item['label'],
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
}
