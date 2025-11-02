# Notification System 🔔

Complete notification system with Material 3 design, action buttons, and comprehensive demo.

## 🚀 Quick Start

### Run the Demo

```bash
flutter run -t lib/notifications_demo_main.dart
```

## 📦 What's Included

### 1. **NotificationModel** (`lib/models/notification_model.dart`)
Complete data model with:
- All notification types (12 types)
- JSON serialization
- Equatable for comparison
- Notification grouping support

### 2. **NotificationCardEnhanced** (`lib/widgets/common/notification_card_enhanced.dart`)
Enhanced notification card with:
- ✅ Swipe to dismiss
- ✅ Tap to view details
- ✅ Mark as read/unread
- ✅ Action buttons (primary & secondary)
- ✅ Popup menu (mark as read, delete)
- ✅ Unread indicator dot
- ✅ Timestamp with smart formatting
- ✅ Custom icons & colors per type
- ✅ Avatar or icon display

### 3. **NotificationsDemoScreen** (`lib/screens/demo/notifications_demo_screen.dart`)
Full-featured demo showing:
- Tab navigation (All, Unread, Read)
- Badge counts on tabs
- Mark all as read
- Swipe to delete
- Tap for detail view
- Context-specific action buttons
- Empty state handling

### 4. **EmptyNotifications** Widget
Beautiful empty state when no notifications

## 🎨 Notification Types

| Type | Icon | Color | Use Case |
|------|------|-------|----------|
| **general** | notifications | Primary | General notifications |
| **message** | message | Primary | Chat messages |
| **application** | work | Purple | Job applications |
| **interview** | event | Green | Interview invites |
| **jobMatch** | trending_up | Accent | Job matches |
| **jobAlert** | campaign | Accent | Job alerts |
| **profileView** | visibility | Blue | Profile views |
| **cvParsed** | description | Teal | CV parsing complete |
| **success** | check_circle | Green | Success messages |
| **warning** | warning | Orange | Warnings |
| **error** | error | Red | Errors |
| **system** | settings | Grey | System messages |

## 💡 Usage Examples

### Basic Notification

```dart path=null start=null
NotificationCardEnhanced(
  notification: NotificationModel(
    id: '1',
    title: 'New Job Match!',
    message: 'Flutter Developer at Google matches your profile',
    type: NotificationType.jobMatch,
    timestamp: DateTime.now(),
    isRead: false,
  ),
  onTap: () => print('Notification tapped'),
  onDismiss: () => print('Notification dismissed'),
)
```

### With Action Buttons

```dart path=null start=null
NotificationCardEnhanced(
  notification: notification,
  actions: [
    NotificationAction(
      label: 'View Job',
      icon: Icons.visibility,
      onPressed: () => navigateToJob(),
      isPrimary: true,
    ),
    NotificationAction(
      label: 'Save',
      icon: Icons.bookmark,
      onPressed: () => saveJob(),
    ),
  ],
)
```

### In a List

```dart path=null start=null
ListView.builder(
  itemCount: notifications.length,
  itemBuilder: (context, index) {
    return NotificationCardEnhanced(
      notification: notifications[index],
      onTap: () => handleTap(notifications[index]),
      onDismiss: () => deleteNotification(notifications[index].id),
      onMarkAsRead: () => markAsRead(notifications[index].id),
    );
  },
)
```

## 🎯 Features

### Notification Card Features

- [x] **Swipe to dismiss** - Swipe left to delete
- [x] **Tap to open** - View full details
- [x] **Unread indicator** - Blue dot for unread
- [x] **Smart timestamps** - "Just now", "5m ago", "2h ago", etc.
- [x] **Action buttons** - Context-specific actions
- [x] **Popup menu** - Mark as read, delete
- [x] **Type-based styling** - Different icons & colors
- [x] **Avatar support** - Show user/company avatar

### Demo Screen Features

- [x] **Tab navigation** - All / Unread / Read
- [x] **Badge counts** - Show unread count
- [x] **Mark all read** - Bulk action
- [x] **Filter support** - Via tabs
- [x] **Detail view** - Bottom sheet with full info
- [x] **Empty states** - When no notifications
- [x] **Responsive** - Works on all screen sizes

## 🔧 Integration with Main App

### Step 1: Add to your screen

```dart path=null start=null
import 'package:it_job_finder/widgets/common/notification_card_enhanced.dart';
import 'package:it_job_finder/models/notification_model.dart';

// In your widget
final notifications = await getNotifications(); // Your API call

ListView.builder(
  itemCount: notifications.length,
  itemBuilder: (context, index) {
    return NotificationCardEnhanced(
      notification: notifications[index],
      onTap: () => handleNotificationTap(notifications[index]),
      onDismiss: () => deleteNotification(notifications[index].id),
    );
  },
)
```

### Step 2: Handle Actions

```dart path=null start=null
void handleNotificationTap(NotificationModel notification) {
  // Mark as read
  markNotificationAsRead(notification.id);
  
  // Navigate based on type
  switch (notification.type) {
    case NotificationType.jobMatch:
      Navigator.pushNamed(context, '/job-details', 
        arguments: notification.data?['jobId']);
      break;
    case NotificationType.message:
      Navigator.pushNamed(context, '/chat',
        arguments: notification.data?['conversationId']);
      break;
    case NotificationType.interview:
      Navigator.pushNamed(context, '/interview-details',
        arguments: notification.data?['interviewId']);
      break;
    // ... handle other types
  }
}
```

### Step 3: Add Badge to App Bar

```dart path=null start=null
import 'package:it_job_finder/widgets/common/notification_card.dart';

AppBar(
  actions: [
    NotificationBadge(
      count: unreadCount,
      child: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(),
          ),
        ),
      ),
    ),
  ],
)
```

## 🔌 Backend Integration

### API Endpoints Needed

```
GET    /api/notifications         - List notifications
GET    /api/notifications/:id     - Get notification
PATCH  /api/notifications/:id/read  - Mark as read
DELETE /api/notifications/:id     - Delete notification
POST   /api/notifications/mark-all-read  - Mark all as read
```

### Example API Call

```dart path=null start=null
class NotificationService {
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/api/notifications');
    return (response.data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }
  
  Future<void> markAsRead(String id) async {
    await dio.patch('/api/notifications/$id/read');
  }
  
  Future<void> deleteNotification(String id) async {
    await dio.delete('/api/notifications/$id');
  }
}
```

## 📱 Push Notifications

To add Firebase push notifications:

1. **Setup Firebase** (already in pubspec.yaml)
2. **Request permissions**
3. **Handle notifications**

```dart path=null start=null
import 'package:firebase_messaging/firebase_messaging.dart';

// Request permission
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();

// Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show in-app notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.notification?.title ?? '')),
  );
  
  // Add to notification list
  addNotification(NotificationModel.fromPushNotification(message));
});

// Handle background/terminated messages
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navigate to relevant screen
  handleNotificationTap(NotificationModel.fromPushNotification(message));
});
```

## 🧪 Testing

### Run the Demo

```bash
flutter run -t lib/notifications_demo_main.dart
```

### Test Features

1. **Swipe left** - Delete notification
2. **Tap notification** - View details
3. **Tap menu (⋮)** - Mark as read or delete
4. **Switch tabs** - View all/unread/read
5. **Tap "Mark all read"** - Clear unread indicators
6. **Action buttons** - Test context-specific actions

## 🎨 Customization

### Change Colors

Edit `lib/core/constants/app_constants.dart`:

```dart path=null start=null
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF26C6DA);
  static const Color success = Color(0xFF4CAF50);
  // ...
}
```

### Add New Notification Type

1. Add to enum in `notification_model.dart`:
```dart path=null start=null
enum NotificationType {
  // ... existing types
  newType,
}
```

2. Add icon & color in `notification_card_enhanced.dart`:
```dart path=null start=null
IconData _getNotificationIcon(NotificationType type) {
  switch (type) {
    // ... existing cases
    case NotificationType.newType:
      return Icons.your_icon;
  }
}
```

### Customize Card Style

Override in `NotificationCardEnhanced`:
- Change padding, margins
- Modify colors and shapes
- Add animations
- Change typography

## 📊 State Management

For production, use Riverpod:

```dart path=null start=null
// Provider
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

// Notifier
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]);
  
  Future<void> loadNotifications() async {
    state = await NotificationService().getNotifications();
  }
  
  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification
    ];
  }
  
  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

// Usage in widget
final notifications = ref.watch(notificationsProvider);
```

## ✅ Checklist

- [x] Notification model with 12 types
- [x] Enhanced notification card
- [x] Swipe to dismiss
- [x] Action buttons
- [x] Popup menu
- [x] Unread indicators
- [x] Smart timestamps
- [x] Demo screen with tabs
- [x] Empty state
- [x] Detail view
- [x] Badge component
- [x] No analysis errors
- [x] Ready for integration

## 🎉 Status

**Notification System: COMPLETE** ✅

Ready for:
- Backend API integration
- Firebase push notifications
- State management with Riverpod
- Integration into main app

---

**Questions?** Check the demo or code comments!
