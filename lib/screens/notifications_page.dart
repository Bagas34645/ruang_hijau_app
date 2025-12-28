import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'type': 'like',
      'username': 'Eco Station',
      'message': 'menyukai postingan Anda',
      'time': '5 menit yang lalu',
      'read': false,
      'avatar': 'https://picsum.photos/200',
    },
    {
      'id': 2,
      'type': 'comment',
      'username': 'Nature Squad',
      'message': 'mengomentari postingan Anda: "Kegiatan yang sangat bagus!"',
      'time': '15 menit yang lalu',
      'read': false,
      'avatar': 'https://picsum.photos/201',
    },
    {
      'id': 3,
      'type': 'follow',
      'username': 'Green Warrior',
      'message': 'mulai mengikuti Anda',
      'time': '1 jam yang lalu',
      'read': true,
      'avatar': 'https://picsum.photos/202',
    },
    {
      'id': 4,
      'type': 'event',
      'username': 'Sistem',
      'message': 'Event "Tanam Pohon Bersama" akan dimulai besok',
      'time': '2 jam yang lalu',
      'read': true,
      'avatar': null,
    },
    {
      'id': 5,
      'type': 'like',
      'username': 'Clean Earth',
      'message': 'menyukai postingan Anda',
      'time': '3 jam yang lalu',
      'read': true,
      'avatar': 'https://picsum.photos/203',
    },
  ];

  void _markAsRead(int id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['read'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tandai Semua',
                style: TextStyle(
                  color: Color(0xFF43A047),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Notifikasi Anda akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () => _markAsRead(notification['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['read'] ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification['read']
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF43A047).withOpacity(0.3),
            width: notification['read'] ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: notification['username'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              TextSpan(
                                text: ' ${notification['message']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!notification['read'])
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A047),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> notification) {
    final type = notification['type'];
    
    if (notification['avatar'] == null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getTypeColor(type).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getTypeIcon(type),
          color: _getTypeColor(type),
          size: 24,
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getTypeColor(type).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ClipOval(
            child: Image.network(
              notification['avatar'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF43A047),
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getTypeColor(type),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getTypeIcon(type),
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'like':
        return const Color(0xFFE53935);
      case 'comment':
        return const Color(0xFF43A047);
      case 'follow':
        return const Color(0xFF1E88E5);
      case 'event':
        return const Color(0xFFFB8C00);
      default:
        return const Color(0xFF43A047);
    }
  }
}