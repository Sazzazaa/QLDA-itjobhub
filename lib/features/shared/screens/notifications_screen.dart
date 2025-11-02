import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/notification_model.dart';
import 'package:itjobhub/services/notification_service.dart';
import 'package:itjobhub/features/shared/screens/notification_detail_screen.dart';

/// Notifications Screen
/// 
/// Displays all notifications grouped by date
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationGroup> _notificationGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🔔 NotificationsScreen: initState called');
    // Schedule load for after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔔 NotificationsScreen: PostFrameCallback - calling _loadNotifications');
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔔 NotificationsScreen: Loading notifications from API...');
      
      // Fetch all notifications from API
      final notifications = await _notificationService.getAllNotifications();
      print('🔔 NotificationsScreen: Received ${notifications.length} notifications from service');
      
      // Get grouped notifications
      final groups = _notificationService.getGroupedNotifications();
      print('🔔 NotificationsScreen: Grouped into ${groups.length} groups');
      
      if (mounted) {
        setState(() {
          _notificationGroups = groups;
          _isLoading = false;
        });
        print('✅ NotificationsScreen: UI updated with ${groups.length} notification groups');
      }
    } catch (e, stackTrace) {
      print('❌ NotificationsScreen: Failed to load notifications - $e');
      print('❌ StackTrace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    await _loadNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _notificationService.clearAllNotifications();
      await _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications cleared')),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read
    await _notificationService.markAsRead(notification.id);
    
    // Navigate to notification detail screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailScreen(
            notification: notification,
          ),
        ),
      );
    }
    
    // Reload notifications to update read status
    await _loadNotifications();
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    await _notificationService.deleteNotification(notification.id);
    await _loadNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _notificationGroups.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasNotifications && !_isLoading) ...[
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAll,
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasNotifications
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notificationGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final group = _notificationGroups[groupIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                              vertical: AppSizes.paddingM,
                            ),
                            color: AppColors.surface,
                            child: Text(
                              group.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          
                          // Group notifications
                          ...group.notifications.map((notification) {
                            return _NotificationTile(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                              onDelete: () => _deleteNotification(notification),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              'We\'ll notify you when something important happens',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification Tile Widget
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingL),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false; // We handle deletion in the callback
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? null : AppColors.primary.withValues(alpha: 0.05),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on notification type
              CircleAvatar(
                radius: 24,
                backgroundColor: _getTypeColor().withValues(alpha: 0.1),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: AppSizes.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead 
                            ? AppColors.textSecondary 
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.application:
        return Icons.description;
      case NotificationType.interview:
        return Icons.event;
      case NotificationType.jobMatch:
      case NotificationType.jobAlert:
        return Icons.work;
      case NotificationType.profileView:
        return Icons.person;
      case NotificationType.cvParsed:
        return Icons.document_scanner;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.system:
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.application:
        return Colors.purple;
      case NotificationType.interview:
        return Colors.orange;
      case NotificationType.jobMatch:
      case NotificationType.jobAlert:
        return Colors.green;
      case NotificationType.profileView:
        return Colors.teal;
      case NotificationType.cvParsed:
        return Colors.indigo;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.system:
      case NotificationType.general:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}
