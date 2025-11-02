import 'package:equatable/equatable.dart';

/// Notification Model
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
    this.actionUrl,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? avatarUrl,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'avatarUrl': avatarUrl,
      'actionUrl': actionUrl,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: _parseNotificationType(json['type'] as String?),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.general;
    try {
      return NotificationType.values.byName(type);
    } catch (e) {
      // Try case-insensitive match
      try {
        return NotificationType.values.firstWhere(
          (t) => t.name.toLowerCase() == type.toLowerCase(),
        );
      } catch (e) {
        return NotificationType.general;
      }
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        timestamp,
        isRead,
        avatarUrl,
        actionUrl,
        data,
      ];
}

/// Notification Type
enum NotificationType {
  general,
  message,
  application,
  interview,
  jobMatch,
  jobAlert,
  profileView,
  cvParsed,
  success,
  warning,
  error,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.message:
        return 'Message';
      case NotificationType.application:
        return 'Application';
      case NotificationType.interview:
        return 'Interview';
      case NotificationType.jobMatch:
        return 'Job Match';
      case NotificationType.jobAlert:
        return 'Job Alert';
      case NotificationType.profileView:
        return 'Profile View';
      case NotificationType.cvParsed:
        return 'CV Parsed';
      case NotificationType.success:
        return 'Success';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.error:
        return 'Error';
      case NotificationType.system:
        return 'System';
    }
  }
}

/// Notification Group
class NotificationGroup {
  final String label;
  final List<NotificationModel> notifications;

  const NotificationGroup({
    required this.label,
    required this.notifications,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}
