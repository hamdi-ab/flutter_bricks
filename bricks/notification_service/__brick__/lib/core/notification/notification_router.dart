import 'notification_payload.dart';
import 'notification_service.dart';

/// Helper class for routing based on notification taps
///
/// Usage:
/// ```dart
/// final router = NotificationRouter(notificationService);
/// router.onRoute.listen((routeInfo) {
///   // Navigate to routeInfo.route with routeInfo.args
///   context.push(routeInfo.route, extra: routeInfo.args);
/// });
/// ```
class NotificationRouter {
  NotificationRouter(this._notificationService) {
    _notificationService.onNotificationTap.listen(_handleNotification);
  }

  final NotificationService _notificationService;

  /// Handler function for navigation
  void Function(String route, Map<String, dynamic>? args)? onNavigate;

  void _handleNotification(NotificationPayload payload) {
    final route = payload.route;
    if (route != null && onNavigate != null) {
      onNavigate!(route, payload.routeArgs);
    }
  }

  void dispose() {
    onNavigate = null;
  }
}
