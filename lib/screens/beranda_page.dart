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

      // Debug logging
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
        // fallback sample posts when api fails
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
      // Home posts
      _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommunitySection(),
                    const Divider(),
                    ...List.generate(posts.length, (index) {
                      return _buildPostItem(index);
                    }),
                  ],
                ),
              ),
            ),

      // Events
      const Padding(padding: EdgeInsets.all(8.0), child: EventsPage()),

      // Profile
      const Padding(padding: EdgeInsets.all(8.0), child: ProfilePage()),
    ];

    return Scaffold(
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostPage()),
                );
                if (res == true) _loadPosts();
              },
              child: const Icon(Icons.add_a_photo),
            )
          : null,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'RuangHijau',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Community',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green[200],
                    child: const Icon(Icons.group, color: Colors.white),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.eco, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                post["username"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              post["imageUrl"].toString().startsWith('http')
                  ? post["imageUrl"]
                  : '${Api.baseUrl}/uploads/${post["imageUrl"]}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      );
              },
            ),
          ),

          const SizedBox(height: 8),

          Row(
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
                  color: post["isLiked"] ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Text('${post["likes"]}'),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: () async {
                  await _showCommentsDialog(post['id']);
                },
                child: const Icon(Icons.comment_outlined),
              ),
              const SizedBox(width: 6),
              Text('${post["comments"]}'),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: () {
                  _showShareOption();
                },
                child: const Icon(Icons.share_outlined),
              ),

              const Spacer(),
              const Icon(Icons.bookmark_border),
            ],
          ),

          const SizedBox(height: 6),

          Text(post["caption"], style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 8),
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

    // Get user_id from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      print('DEBUG: Got userId=$userId from SharedPreferences');
    } catch (e) {
      print('DEBUG: Error getting user_id: $e');
    }

    // Fetch comments
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
        title: const Text('Komentar'),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error message (if any)
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        errorMessage ?? 'Error',
                        style: TextStyle(color: Colors.red[900], fontSize: 12),
                      ),
                    ),
                  ),

                // Comments list
                Flexible(
                  child: loadingComments
                      ? const Center(child: CircularProgressIndicator())
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
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    comment['text'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                // Input komentar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                            // Re-fetch comments
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
                      child: const Text('Post'),
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
            child: const Text('Tutup'),
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
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
