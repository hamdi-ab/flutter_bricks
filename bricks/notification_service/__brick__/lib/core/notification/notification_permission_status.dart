/// Notification permission status
enum NotificationPermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied
  denied,

  /// Permission hasn't been requested yet
  notDetermined,

  /// Permission is permanently denied (user must enable in settings)
  permanentlyDenied,
}

/// Extension methods for NotificationPermissionStatus
extension NotificationPermissionStatusX on NotificationPermissionStatus {
  /// Check if notifications are allowed
  bool get isGranted => this == NotificationPermissionStatus.granted;

  /// Check if permission can be requested
  bool get canRequest =>
      this == NotificationPermissionStatus.notDetermined ||
      this == NotificationPermissionStatus.denied;
}
