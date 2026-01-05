# notification_service Brick

Enterprise-grade notification service with local notifications, Firebase Cloud Messaging (FCM), permissions, and navigation routing.

## Features

- **Local Notifications**: Show notifications when app is in foreground
- **FCM Integration**: Handle push notifications from Firebase
- **Permission Handling**: Request and check notification permissions
- **Event Streams**: React to notification taps, foreground messages, token refreshes
- **Navigation Router**: Deep link from notifications to specific screens
- **Android Channels**: Proper notification channel management

## Generated Files

| File | Description |
|------|-------------|
| `notification_payload.dart` | Notification data model with FCM parsing |
| `notification_permission_status.dart` | Permission status enum |
| `notification_service.dart` | Abstract service interface |
| `notification_service_impl.dart` | Full implementation with FCM + local |
| `notification_router.dart` | Helper for notification-based navigation |

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0
```

## Setup

### 1. Initialize Firebase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 2. Create and Initialize Service

```dart
final notificationService = NotificationServiceImpl();
await notificationService.initialize();
```

### 3. Request Permission

```dart
final status = await notificationService.requestPermission();
if (status.isGranted) {
  final token = await notificationService.getFcmToken();
  // Send token to your backend
}
```

### 4. Handle Notification Taps (Navigation)

```dart
notificationService.onNotificationTap.listen((payload) {
  final route = payload.route;
  if (route != null) {
    // Navigate using your router
    GoRouter.of(context).push(route, extra: payload.routeArgs);
  }
});
```

### 5. Handle Foreground Notifications

```dart
notificationService.onForegroundNotification.listen((payload) {
  // Show in-app snackbar or banner
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(payload.title ?? 'New notification')),
  );
});
```

### 6. Show Local Notification

```dart
await notificationService.showNotification(
  NotificationPayload(
    id: 1,
    title: 'Hello',
    body: 'This is a local notification',
    data: {'route': '/details', 'args': {'id': '123'}},
  ),
);
```

## FCM Payload Format

For notifications to support routing, send this structure from your backend:

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "route": "/chat/123",
    "args": "{\"userId\": \"abc\"}"
  }
}
```

## Background Message Handler

For handling messages when the app is terminated, add this top-level function:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
```
