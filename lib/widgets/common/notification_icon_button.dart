import 'package:flutter/material.dart';
import 'package:itjobhub/services/notification_service.dart';
import 'package:itjobhub/features/shared/screens/notifications_screen.dart';

/// Notification Icon Button
/// 
/// Displays a notification bell icon with unread badge
class NotificationIconButton extends StatefulWidget {
  final Color? iconColor;
  
  const NotificationIconButton({super.key, this.iconColor});

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _updateUnreadCount();
  }

  Future<void> _updateUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('❌ NotificationIconButton: Failed to get unread count - $e');
      // Keep current count on error
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
    
    // Update badge count when returning from notifications screen
    await _updateUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Theme.of(context).iconTheme.color;
    
    return IconButton(
      icon: _unreadCount > 0
          ? Badge(
              label: Text('$_unreadCount'),
              child: Icon(Icons.notifications_outlined, color: iconColor),
            )
          : Icon(Icons.notifications_outlined, color: iconColor),
      onPressed: _openNotifications,
      tooltip: 'Notifications',
    );
  }
}
