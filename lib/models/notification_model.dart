class NotificationModel {
  final int id;
  final String type;
  final String username;
  final String message;
  final String time;
  final bool read;
  final String? avatar;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.username,
    required this.message,
    required this.time,
    required this.read,
    this.avatar,
    required this.createdAt,
  });

  // Factory constructor untuk membuat NotificationModel dari JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type'] ?? 'notification',
      username: json['username'] ?? 'Unknown',
      message: json['message'] ?? '',
      time: json['time'] ?? 'baru saja',
      read: json['read'] == true || json['read'] == 1,
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'username': username,
      'message': message,
      'time': time,
      'read': read,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with untuk membuat copy dengan perubahan
  NotificationModel copyWith({
    int? id,
    String? type,
    String? username,
    String? message,
    String? time,
    bool? read,
    String? avatar,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      username: username ?? this.username,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
