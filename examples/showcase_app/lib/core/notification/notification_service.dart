import 'notification_payload.dart';
import 'notification_permission_status.dart';

/// Abstract notification service interface
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permission
  Future<NotificationPermissionStatus> requestPermission();

  /// Get current permission status
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Show a local notification
  Future<void> showNotification(NotificationPayload payload);

  /// Cancel a specific notification
  Future<void> cancelNotification(int id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Get the FCM token for push notifications
  Future<String?> getFcmToken();

  /// Stream of FCM token refreshes
  Stream<String> get onTokenRefresh;

  /// Stream of notification taps (for routing)
  Stream<NotificationPayload> get onNotificationTap;

  /// Stream of foreground notifications
  Stream<NotificationPayload> get onForegroundNotification;

  /// Dispose resources
  void dispose();
}
