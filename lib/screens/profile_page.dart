import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> userPosts = [];
  int? userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user');
    userId = prefs.getInt('user_id');
    if (json != null) {
      setState(() => user = jsonDecode(json) as Map<String, dynamic>);
    }
    await _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    try {
      final res = await Api.fetchPosts();
      if (!mounted) return;
      print('DEBUG ProfilePage: API response statusCode=${res['statusCode']}');
      if (res['statusCode'] == 200 && res['body'] != null && userId != null) {
        final data = res['body'] as List<dynamic>;
        final filtered = data.where((e) => e['user_id'] == userId).toList();
        userPosts = filtered.map((e) {
          return {
            'id': e['id'],
            'imageUrl': e['image'] ?? 'https://picsum.photos/300/300',
            'caption': e['text'] ?? '',
          };
        }).toList();
        print('DEBUG ProfilePage: Loaded ${userPosts.length} user posts');
      } else {
        print(
          'DEBUG ProfilePage: API call failed. Status=${res['statusCode']}, Error=${res['error'] ?? 'Unknown'}',
        );
        userPosts = [];
      }
    } catch (e) {
      print('DEBUG ProfilePage: Exception in _loadUserPosts: $e');
      userPosts = [];
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          user?['name'] ?? 'Profile',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserPosts,
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green[200],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['name'] ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?['email'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        userPosts.length.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Text(
                                        'Posts',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    children: [
                                      const Text(
                                        '0',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Text(
                                        'Followers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    children: [
                                      const Text(
                                        '0',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Text(
                                        'Following',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            // Posts grid
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (userPosts.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Belum ada post')),
              )
            else
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = userPosts[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Post Detail'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  post['imageUrl'].toString().startsWith('http')
                                      ? post['imageUrl']
                                      : '${Api.baseUrl}/uploads/${post['imageUrl']}',
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(Icons.broken_image),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post['caption'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
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
                    },
                    child: Container(
                      color: Colors.grey[200],
                      child: Image.network(
                        post['imageUrl'].toString().startsWith('http')
                            ? post['imageUrl']
                            : '${Api.baseUrl}/uploads/${post['imageUrl']}',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }, childCount: userPosts.length),
              ),
          ],
        ),
      ),
    );
  }
}
