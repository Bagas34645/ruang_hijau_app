import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  static String get baseUrl => AppConfig.baseUrl;

  // List untuk menyimpan notifikasi yang di-fetch
  static List<NotificationModel> _notifications = [];

  // Fetch all notifications untuk user
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      // Fetch dari API
      if (userId != null && userId.isNotEmpty) {
        try {
          final url = Uri.parse('$baseUrl/api/notifications?user_id=$userId');
          final response = await http
              .get(url, headers: {'Content-Type': 'application/json'})
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            _notifications = data
                .map((item) => NotificationModel.fromJson(item))
                .toList();
            return _notifications;
          }
        } catch (e) {
          print('Error fetching from API: $e');
        }
      }

      // Return empty list jika error atau user_id null
      return [];
    } catch (e) {
      print('Error in getNotifications: $e');
      return [];
    }
  }

  // Mark notification sebagai read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      // Update data locally
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      // Try to update via API
      if (userId != null && userId.isNotEmpty) {
        try {
          final url = Uri.parse(
            '$baseUrl/api/notifications/$notificationId/read',
          );
          final response = await http
              .put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'user_id': userId}),
              )
              .timeout(const Duration(seconds: 10));

          return response.statusCode == 200;
        } catch (e) {
          print('Error marking notification as read via API: $e');
          return true;
        }
      }
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark semua notifikasi sebagai read
  static Future<bool> markAllAsRead() async {
    try {
      // Update all data locally
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null && userId.isNotEmpty) {
        try {
          final url = Uri.parse('$baseUrl/api/notifications/read-all');
          final response = await http
              .put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'user_id': userId}),
              )
              .timeout(const Duration(seconds: 10));

          return response.statusCode == 200;
        } catch (e) {
          print('Error marking all as read via API: $e');
          return true;
        }
      }
      return true;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      // Remove from data locally
      _notifications.removeWhere((n) => n.id == notificationId);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null && userId.isNotEmpty) {
        try {
          final url = Uri.parse('$baseUrl/api/notifications/$notificationId');
          final response = await http
              .delete(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'user_id': userId}),
              )
              .timeout(const Duration(seconds: 10));

          return response.statusCode == 200;
        } catch (e) {
          print('Error deleting notification via API: $e');
          return true;
        }
      }
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    try {
      // Get from data
      final unreadCount = _notifications.where((n) => !n.read).length;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null && userId.isNotEmpty) {
        try {
          final url = Uri.parse(
            '$baseUrl/api/notifications/unread-count?user_id=$userId',
          );
          final response = await http
              .get(url, headers: {'Content-Type': 'application/json'})
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return data['unread_count'] ?? unreadCount;
          }
        } catch (e) {
          print('Error fetching unread count from API: $e');
        }
      }
      return unreadCount;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  static void closeNotificationStream() {
    // Cleanup if needed
  }
}
