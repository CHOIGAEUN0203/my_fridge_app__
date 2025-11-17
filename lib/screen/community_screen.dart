import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_fridge_app__/widgets/bottom_nav.dart';
import 'community_detail_screen.dart'; // ✅ 상세페이지 import

class CommunityScreen extends StatefulWidget {
  final String jwtToken;
  const CommunityScreen({super.key, required this.jwtToken});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _posts = [];
  List<dynamic> _filteredPosts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCommunityPosts();
  }

  Future<void> _fetchCommunityPosts() async {
    try {
      final baseUrl = dotenv.env['API_URL']!;
      final response = await http.get(
        Uri.parse("$baseUrl/api/community/recipes"),
        headers: {
          "Authorization": "Bearer ${widget.jwtToken}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _posts = data;
          _filteredPosts = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "서버 오류: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "불러오기 실패: $e";
        _isLoading = false;
      });
    }
  }

  void _filterPosts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredPosts = _posts);
      return;
    }

    setState(() {
      _filteredPosts = _posts
          .where((post) =>
              (post['recipeName'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (post['shortDescription'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🍳 커뮤니티에 오신걸 환영합니다!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 🔍 검색창
              TextField(
                controller: _searchController,
                onChanged: _filterPosts,
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

              // 📄 게시글 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : _filteredPosts.isEmpty
                            ? const Center(
                                child: Text("아직 공유된 레시피가 없습니다."),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchCommunityPosts,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: _filteredPosts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final post = _filteredPosts[index];
                                    final recipeId = post['id'];
                                    final recipeName =
                                        post['recipeName'] ?? "제목 없음";
                                    final description =
                                        post['shortDescription'] ?? "";
                                    final author =
                                        post['userNickname'] ?? "익명";
                                    final date = post['postedDate'] != null
                                        ? post['postedDate']
                                            .toString()
                                            .substring(0, 10)
                                        : "날짜 없음";
                                    final likeCount = post['likeCount'] ?? 0;
                                    final imageUrl = post['imageUrl'];

                                    // 🧭 상세페이지 이동
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CommunityDetailScreen(
                                              jwtToken: widget.jwtToken,
                                              recipeId: recipeId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            // 🖼️ 레시피 이미지
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: const Color(0xFFE0E0E0),
                                                image: imageUrl != null &&
                                                        imageUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                            imageUrl),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: imageUrl == null ||
                                                      imageUrl.isEmpty
                                                  ? const Icon(
                                                      Icons.fastfood,
                                                      color: Colors.white70,
                                                      size: 40,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),

                                            // 📋 게시글 정보
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      recipeName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      description,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "$author | $date",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.favorite,
                                                              size: 14,
                                                              color: Colors.red,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              "$likeCount",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
