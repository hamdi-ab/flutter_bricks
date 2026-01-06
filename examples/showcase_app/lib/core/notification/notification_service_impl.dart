import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_payload.dart';
import 'notification_permission_status.dart';
import 'notification_service.dart';

/// Notification service implementation using Firebase Messaging and Local Notifications
class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl({
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseMessaging? firebaseMessaging,
    this.defaultChannelId = 'default_channel',
    this.defaultChannelName = 'Default',
    this.defaultChannelDescription = 'Default notification channel',
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;
  final String defaultChannelId;
  final String defaultChannelName;
  final String defaultChannelDescription;

  final _notificationTapController =
      StreamController<NotificationPayload>.broadcast();
  final _foregroundNotificationController =
      StreamController<NotificationPayload>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          defaultChannelId,
          defaultChannelName,
          description: defaultChannelDescription,
          importance: Importance.high,
        ),
      );
    }

    // Setup Firebase Messaging handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app launched from notification)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _tokenRefreshController.add(token);
    });
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    // Request Firebase permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Also request local notification permission on iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // On Android 13+, request local notification permission
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return _mapAuthorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<void> showNotification(NotificationPayload payload) async {
    final androidDetails = AndroidNotificationDetails(
      payload.channelId ?? defaultChannelId,
      defaultChannelName,
      channelDescription: defaultChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      groupKey: payload.groupKey,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      payload.id,
      payload.title,
      payload.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: _encodePayload(payload.data),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  @override
  Future<String?> getFcmToken() async {
    return _firebaseMessaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<NotificationPayload> get onNotificationTap =>
      _notificationTapController.stream;

  @override
  Stream<NotificationPayload> get onForegroundNotification =>
      _foregroundNotificationController.stream;

  @override
  void dispose() {
    _notificationTapController.close();
    _foregroundNotificationController.close();
    _tokenRefreshController.close();
  }

  // Private helpers

  void _handleNotificationTap(NotificationResponse response) {
    final data = _decodePayload(response.payload);
    final payload = NotificationPayload(id: response.id ?? 0, data: data);
    _notificationTapController.add(payload);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final payload = NotificationPayload.fromFcm(message.toMap());
    _foregroundNotificationController.add(payload);

    // Optionally show local notification for foreground messages
    if (message.notification != null) {
      showNotification(payload);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final payload = NotificationPayload.fromFcm(message.toMap());
    _notificationTapController.add(payload);
  }

  NotificationPermissionStatus _mapAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
    }
  }

  String _encodePayload(Map<String, dynamic> data) {
    // Simple encoding: key1=value1;key2=value2
    return data.entries.map((e) => '${e.key}=${e.value}').join(';');
  }

  Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return {};
    final map = <String, dynamic>{};
    for (final pair in payload.split(';')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}
