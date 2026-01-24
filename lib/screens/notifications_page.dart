import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationModel>> _notificationsFuture;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService.getNotifications();
  }

  @override
  void dispose() {
    NotificationService.closeNotificationStream();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notifications = await NotificationService.getNotifications();
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Error refreshing notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markAsRead(int id) async {
    final success = await NotificationService.markAsRead(id);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(read: true);
        }
      });
    }
  }

  void _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(read: true))
            .toList();
      });
    }
  }

  void _deleteNotification(int id) async {
    final success = await NotificationService.deleteNotification(id);
    if (success) {
      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationModel>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _notifications.isEmpty) {
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
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF43A047)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
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
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE53935),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat notifikasi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Update notifications dari snapshot
        if (snapshot.hasData && _notifications.isEmpty) {
          _notifications = snapshot.data ?? [];
        }

        final unreadCount = _notifications.where((n) => !n.read).length;

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
          body: _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  color: const Color(0xFF43A047),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_notifications[index].id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteNotification(_notifications[index].id);
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        child: _buildNotificationItem(_notifications[index]),
                      );
                    },
                  ),
                ),
        );
      },
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

  Widget _buildNotificationItem(NotificationModel notification) {
    return GestureDetector(
      onTap: () => _markAsRead(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.read
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF43A047).withOpacity(0.3),
            width: notification.read ? 1 : 2,
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
                                text: notification.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              TextSpan(
                                text: ' ${notification.message}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!notification.read)
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
                        notification.time,
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

  Widget _buildAvatar(NotificationModel notification) {
    final type = notification.type;

    if (notification.avatar == null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getTypeColor(type).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 24),
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
              notification.avatar!,
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
              child: Icon(_getTypeIcon(type), color: Colors.white, size: 12),
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
