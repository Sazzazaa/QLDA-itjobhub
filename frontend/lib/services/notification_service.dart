import 'package:itjobhub/models/notification_model.dart';
import 'package:itjobhub/services/api_client.dart';

/// Notification Service
/// 
/// Manages app notifications via API
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();
  
  // Cache for notifications
  final List<NotificationModel> _notifications = [];

  /// Get all notifications from API
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      print('🔔 NotificationService: Fetching notifications from API...');
      final response = await _apiClient.get('/notifications');
      
      _notifications.clear();
      _notifications.addAll(
        (response as List).map((json) => NotificationModel.fromJson(json)).toList(),
      );
      
      print('✅ NotificationService: Loaded ${_notifications.length} notifications');
      return List.from(_notifications);
    } catch (e) {
      print('❌ NotificationService: Failed to fetch notifications - $e');
      // Return cached notifications on error
      return List.from(_notifications);
    }
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get total unread count from API
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      return response['count'] as int;
    } catch (e) {
      print('❌ NotificationService: Failed to get unread count - $e');
      // Fallback to cached count
      return _notifications.where((n) => !n.isRead).length;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      print('🔔 NotificationService: Marking notification $notificationId as read...');
      await _apiClient.put('/notifications/$notificationId/read', {});

      // Update local cache
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
      
      print('✅ NotificationService: Notification marked as read');
    } catch (e) {
      print('❌ NotificationService: Failed to mark as read - $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      print('🔔 NotificationService: Marking all notifications as read...');
      await _apiClient.put('/notifications/mark-all-read', {});

      // Update local cache
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      
      print('✅ NotificationService: All notifications marked as read');
    } catch (e) {
      print('❌ NotificationService: Failed to mark all as read - $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🔔 NotificationService: Deleting notification $notificationId...');
      await _apiClient.delete('/notifications/$notificationId');

      // Remove from local cache
      _notifications.removeWhere((n) => n.id == notificationId);
      
      print('✅ NotificationService: Notification deleted');
    } catch (e) {
      print('❌ NotificationService: Failed to delete notification - $e');
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      print('🔔 NotificationService: Clearing all notifications...');
      await _apiClient.delete('/notifications');

      // Clear local cache
      _notifications.clear();
      
      print('✅ NotificationService: All notifications cleared');
    } catch (e) {
      print('❌ NotificationService: Failed to clear all notifications - $e');
      rethrow;
    }
  }

  /// Get grouped notifications (by date)
  List<NotificationGroup> getGroupedNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayNotifications = <NotificationModel>[];
    final yesterdayNotifications = <NotificationModel>[];
    final olderNotifications = <NotificationModel>[];

    final sortedNotifications = List.from(_notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final notification in sortedNotifications) {
      final notificationDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );

      if (notificationDate == today) {
        todayNotifications.add(notification);
      } else if (notificationDate == yesterday) {
        yesterdayNotifications.add(notification);
      } else {
        olderNotifications.add(notification);
      }
    }

    final groups = <NotificationGroup>[];
    
    if (todayNotifications.isNotEmpty) {
      groups.add(NotificationGroup(
        label: 'Today',
        notifications: todayNotifications,
      ));
    }
    
    if (yesterdayNotifications.isNotEmpty) {
      groups.add(NotificationGroup(
        label: 'Yesterday',
        notifications: yesterdayNotifications,
      ));
    }
    
    if (olderNotifications.isNotEmpty) {
      groups.add(NotificationGroup(
        label: 'Earlier',
        notifications: olderNotifications,
      ));
    }

    return groups;
  }

  /// Clear all data (for logout)
  void clear() {
    _notifications.clear();
  }
}
