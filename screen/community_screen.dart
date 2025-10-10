//커뮤니티(미완)
import 'package:flutter/material.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityScreen extends StatelessWidget {
  final String jwtToken;
  const CommunityScreen({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> posts = [
      {
        'title': '두유 들깨 칼국수',
        'description': '"고소함이 폭발하는 건강 칼국수~"',
        'author': '햇애미박씨',
        'date': '2025.09.20',
      },
      {
        'title': '간장마요 김밥볼',
        'description': '"김밥 만들기 귀찮고, 그냥 비벼서 뭉쳐봤어요!"',
        'author': '공주귀요미',
        'date': '2025.09.20',
      },
      {
        'title': '고추참치 짬뽕',
        'description': '"저렴한 간단 짬뽕 만들어봄~"',
        'author': 'gaeun_CHOI',
        'date': '2025.09.20',
      },
      {
        'title': '된장 버터 스테이크',
        'description': '"된장+쯔유로 만든 풍미 느껴지는 소스"',
        'author': '햇애미박씨',
        'date': '2025.09.20',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '~~~에 오신걸 환영합니다!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 검색창
              TextField(
                decoration: InputDecoration(
                  hintText: '게시글 제목 검색',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 작성하기 버튼
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('글 작성하기'),
                ),
              ),
              const SizedBox(height: 10),

              // 게시물 리스트
              Expanded(
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // 음식 사진 (빈 사각형)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 글 정보
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post['description']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${post['author']} | ${post['date']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(jwtToken: jwtToken),
    );
  }
}
