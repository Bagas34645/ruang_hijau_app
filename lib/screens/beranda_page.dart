import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import 'events_page.dart';
import 'profile_page.dart';
import 'add_post_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<Map<String, dynamic>> posts = [];
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final res = await Api.fetchPosts();
      if (!mounted) return;

      print(
        'DEBUG: API response statusCode=${res['statusCode']}, body=${res['body']}',
      );

      if (res['statusCode'] == 200 && res['body'] != null) {
        final data = res['body'] as List<dynamic>;
        posts = data.map((e) {
          return {
            'id': e['id'],
            'username': 'User ${e['user_id'] ?? 'unknown'}',
            'imageUrl': e['image'] ?? 'https://picsum.photos/400/250',
            'caption': e['text'] ?? '',
            'likes': 0,
            'comments': 0,
            'isLiked': false,
          };
        }).toList();
        print('DEBUG: Loaded ${posts.length} posts');
      } else {
        print(
          'DEBUG: API call failed or returned no body. Status=${res['statusCode']}, Body=${res['body']}',
        );
        final errorMsg =
            'API Error: Status ${res['statusCode']}. Error: ${res['error'] ?? 'Unknown'}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        posts = [
          {
            "username": "Eco Station",
            "imageUrl": "https://picsum.photos/400/250",
            "caption": "Kami baru saja mengadakan kegiatan bersih taman!",
            "likes": 1265,
            "comments": 278,
            "isLiked": false,
          },
          {
            "username": "Nature Squad",
            "imageUrl": "https://picsum.photos/401/250",
            "caption": "Aksi tanam pohon bersama komunitas lokal 🌱",
            "likes": 980,
            "comments": 152,
            "isLiked": false,
          },
        ];
      }
    } catch (e) {
      print('DEBUG: Exception in _loadPosts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading posts: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF43A047)),
            )
          : RefreshIndicator(
              color: const Color(0xFF43A047),
              onRefresh: _loadPosts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommunitySection(),
                    const Divider(height: 1, thickness: 1),
                    ...List.generate(
                      posts.length,
                      (index) => _buildPostItem(index),
                    ),
                  ],
                ),
              ),
            ),
      const Padding(padding: EdgeInsets.all(8.0), child: EventsPage()),
      const Padding(padding: EdgeInsets.all(8.0), child: ProfilePage()),
    ];

    return Scaffold(
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF43A047),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostPage()),
                );
                if (res == true) _loadPosts();
              },
              child: const Icon(Icons.add_a_photo, color: Colors.white),
            )
          : null,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Color(0xFF43A047), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'RuangHijau',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF2E7D32),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF43A047),
        unselectedItemColor: const Color(0xFF9E9E9E),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Komunitas Anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF43A047).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 28,
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
    );
  }

  Widget _buildPostItem(int index) {
    var post = posts[index];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  post["username"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF757575)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Image.network(
            post["imageUrl"].toString().startsWith('http')
                ? post["imageUrl"]
                : '${Api.baseUrl}/uploads/${post["imageUrl"]}',
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              height: 300,
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            loadingBuilder: (context, child, progress) {
              return progress == null
                  ? child
                  : Container(
                      height: 300,
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF43A047),
                        ),
                      ),
                    );
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      post["isLiked"] = !post["isLiked"];
                      post["isLiked"] ? post["likes"]++ : post["likes"]--;
                    });
                  },
                  child: Icon(
                    post["isLiked"] ? Icons.favorite : Icons.favorite_border,
                    color: post["isLiked"]
                        ? const Color(0xFFE53935)
                        : const Color(0xFF424242),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${post["likes"]}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    await _showCommentsDialog(post['id']);
                  },
                  child: const Icon(
                    Icons.comment_outlined,
                    color: Color(0xFF424242),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${post["comments"]}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _showShareOption,
                  child: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFF424242),
                    size: 28,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF424242),
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post["caption"],
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCommentsDialog(int postId) async {
    final TextEditingController commentController = TextEditingController();
    List<Map<String, dynamic>> comments = [];
    bool loadingComments = true;
    String? errorMessage;
    int? userId;

    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      print('DEBUG: Got userId=$userId from SharedPreferences');
    } catch (e) {
      print('DEBUG: Error getting user_id: $e');
    }

    try {
      final res = await Api.fetchComments(postId);
      if (!mounted) return;

      print('DEBUG: fetchComments response statusCode=${res['statusCode']}');

      if (res['statusCode'] == 200 && res['body'] != null) {
        final data = res['body'] as List<dynamic>;
        comments = data.map((e) {
          return {
            'id': e['id'],
            'username': 'User ${e['user_id'] ?? "unknown"}',
            'text': e['text'] ?? '',
            'user_id': e['user_id'],
          };
        }).toList();
        print('DEBUG: Loaded ${comments.length} comments');
      } else {
        errorMessage = 'Gagal memuat komentar. Status: ${res['statusCode']}';
        print('DEBUG: $errorMessage');
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      print('DEBUG: Exception in fetchComments: $e');
    }

    loadingComments = false;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Komentar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMessage ?? 'Error',
                        style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  child: loadingComments
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF43A047),
                          ),
                        )
                      : comments.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada komentar'),
                        )
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (ctx, idx) {
                            final comment = comments[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comment['text'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFF43A047),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF43A047),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tulis komentar terlebih dahulu'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error: User ID tidak ditemukan. Silakan login ulang.',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          try {
                            print(
                              'DEBUG: Adding comment for postId=$postId, userId=$userId',
                            );
                            final res = await Api.addComment(postId, {
                              'post_id': postId,
                              'user_id': userId,
                              'text': commentController.text,
                            });

                            print(
                              'DEBUG: addComment response statusCode=${res['statusCode']}',
                            );

                            if (!mounted) return;

                            if (res['statusCode'] == 200 ||
                                res['statusCode'] == 201) {
                              try {
                                final newRes = await Api.fetchComments(postId);
                                if (newRes['statusCode'] == 200 &&
                                    newRes['body'] != null) {
                                  final data = newRes['body'] as List<dynamic>;
                                  setState(() {
                                    comments = data.map((e) {
                                      return {
                                        'id': e['id'],
                                        'username':
                                            'User ${e['user_id'] ?? "unknown"}',
                                        'text': e['text'] ?? '',
                                        'user_id': e['user_id'],
                                      };
                                    }).toList();
                                    errorMessage = null;
                                  });
                                  commentController.clear();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Komentar berhasil ditambahkan!',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                print('DEBUG: Error re-fetching comments: $e');
                                setState(() {
                                  errorMessage =
                                      'Komentar ditambahkan tapi gagal memuat ulang: $e';
                                });
                              }
                            } else {
                              setState(() {
                                errorMessage =
                                    'Gagal menambah komentar. Status: ${res['statusCode']}';
                              });
                              print('DEBUG: Add comment failed: $errorMessage');
                            }
                          } catch (e) {
                            print('DEBUG: Exception in addComment: $e');
                            setState(() {
                              errorMessage = 'Error: $e';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF43A047)),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOption() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share'),
        content: const Text("Fitur share akan ditambahkan ke depannya 😊"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF43A047))),
          ),
        ],
      ),
    );
  }
}
