import 'package:flutter/material.dart';
import '../services/api.dart';
import 'events_page.dart';
import 'profile_page.dart';
import 'add_post_page.dart';
import 'notifications_page.dart';
import 'campaign_page.dart';

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

      if (res['statusCode'] == 200 && res['body'] != null) {
        final data = res['body'] as List<dynamic>;
        posts = data.map((e) {
          return {
            'id': e['id'],
            'username': 'User ${e['user_id'] ?? 'unknown'}',
            'imageUrl': e['image'] != null
                ? 'http://127.0.0.1:5000/uploads/${e['image']}'
                : 'https://picsum.photos/400/250',
            'caption': e['text'] ?? '',
            'likes': 0,
            'comments': 0,
            'isLiked': false,
          };
        }).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading posts: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // HOME
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
                    const Divider(height: 1),
                    if (posts.isEmpty)
                      _buildEmptyState()
                    else
                      ...List.generate(posts.length, _buildPostItem),
                  ],
                ),
              ),
            ),

      // KAMPANYE (BARU - TERPISAH)
      const CampaignPage(),

      // EVENTS
      const Padding(padding: EdgeInsets.all(8), child: EventsPage()),

      // PROFILE
      const Padding(padding: EdgeInsets.all(8), child: ProfilePage()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // FLOATING BUTTON
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

      // APPBAR
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),

      // BODY
      body: pages[_currentIndex],

      // BOTTOM NAVBAR (UPDATED - 4 ITEMS)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF43A047),
        unselectedItemColor: const Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed, // Untuk 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Kampanye',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // =======================
  // UI SECTION
  // =======================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Postingan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama membagikan\nmomen hijau Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostPage()),
                );
                if (res == true) _loadPosts();
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Buat Postingan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(int index) {
    final post = posts[index];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF43A047),
              child: Icon(Icons.eco, color: Colors.white),
            ),
            title: Text(
              post['username'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.more_horiz, color: Color(0xFF757575)),
          ),
          Image.network(
            post['imageUrl'],
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 300,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF43A047),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(post['caption']),
          ),
        ],
      ),
    );
  }
}
