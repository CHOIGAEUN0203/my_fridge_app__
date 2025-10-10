import 'package:flutter/material.dart';

class ExpiringItems extends StatelessWidget {
  final List<dynamic> items; // HomeScreen에서 넘어오는 데이터

  const ExpiringItems({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4F7CFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.take(3).map((item) { // 최대 3개만 표시
          return Expanded(
            child: _buildItem(
              item.name,
              '${item.quantity}개',
              item.daysLeft == 0 ? 'D-DAY' : 'D-${item.daysLeft}',
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItem(String name, String amount, String dday) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          amount,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          dday,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
