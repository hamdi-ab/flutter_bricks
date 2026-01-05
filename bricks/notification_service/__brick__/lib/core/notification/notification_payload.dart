/// Represents a notification payload
class NotificationPayload {
  const NotificationPayload({
    required this.id,
    this.title,
    this.body,
    this.data = const {},
    this.imageUrl,
    this.channelId,
    this.groupKey,
  });

  /// Unique notification ID
  final int id;

  /// Notification title
  final String? title;

  /// Notification body text
  final String? body;

  /// Custom data payload for routing
  final Map<String, dynamic> data;

  /// Optional image URL for rich notifications
  final String? imageUrl;

  /// Android notification channel ID
  final String? channelId;

  /// Group key for notification stacking
  final String? groupKey;

  /// Create from FCM message data
  factory NotificationPayload.fromFcm(Map<String, dynamic> message) {
    final notification = message['notification'] as Map<String, dynamic>?;
    final data = message['data'] as Map<String, dynamic>? ?? {};

    return NotificationPayload(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification?['title'] as String?,
      body: notification?['body'] as String?,
      data: data,
      imageUrl: notification?['image'] as String?,
    );
  }

  /// Get a route from the payload data
  String? get route => data['route'] as String?;

  /// Get route arguments from the payload data
  Map<String, dynamic>? get routeArgs {
    final args = data['args'];
    if (args is Map<String, dynamic>) return args;
    return null;
  }
}
