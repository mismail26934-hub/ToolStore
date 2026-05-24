import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tool_store_app/config/firebase_web_vapid.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/firebase_messaging_background.dart';
import 'package:tool_store_app/firebase_options.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/services/fcm_platform.dart';
import 'package:tool_store_app/view/var/var.dart';

/// FCM setup: init Firebase, permissions, token sync to backend (mobile + web).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String _androidChannelId = 'tool_store_alerts';
  static const String _androidChannelName = 'Tool Store Alerts';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;
  bool _initialized = false;
  String? _lastSyncedToken;

  bool get isReady => _initialized;

  FirebaseMessaging get _messagingOrThrow {
    final messaging = _messaging;
    if (messaging == null) {
      throw StateError(
        'PushNotificationService: Firebase belum diinisialisasi.',
      );
    }
    return messaging;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    if (!fcmSupported) return;
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'PushNotificationService: Firebase belum dikonfigurasi. '
        'Isi lib/firebase_options.dart dan file native (google-services / plist).',
      );
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      debugPrint(
        'PushNotificationService: Firebase.initializeApp timeout (15s).',
      );
      return;
    } catch (e, st) {
      debugPrint(
        'PushNotificationService: Firebase.initializeApp gagal: $e\n$st',
      );
      return;
    }

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    _messaging = FirebaseMessaging.instance;
    await _setupLocalNotifications();
    _listenForegroundMessages();

    _initialized = true;
  }

  Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Notifikasi Tool Monitoring',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      _showLocalNotification(
        title: notification.title ?? 'Tool Monitoring',
        body: notification.body ?? '',
      );
    });

    _messagingOrThrow.onTokenRefresh.listen((token) {
      unawaited(syncTokenWithBackend(forcedToken: token));
    });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      debugPrint('FCM (web foreground): $title — $body');
      return;
    }
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Requests permission, enables FCM auto-init, fetches token, posts to API.
  Future<void> syncTokenWithBackend({String? forcedToken}) async {
    if (!_initialized && DefaultFirebaseOptions.isConfigured) {
      await initialize();
    }
    if (!_initialized) return;

    final creds = await loadAuthCredentials();
    if (!creds.isAuthenticated) return;

    final granted = await _requestNotificationPermission();
    if (!granted) {
      debugPrint('PushNotificationService: izin notifikasi ditolak.');
      return;
    }

    if (!kIsWeb) {
      await _messagingOrThrow.setAutoInitEnabled(true);
    }

    final token = forcedToken ?? await _fetchFcmToken();
    if (token == null || token.isEmpty) return;
    if (forcedToken == null && token == _lastSyncedToken) return;

    try {
      await apiPost(ApiUrl.contFcmToken, {
        'param': paramSaveFcmToken,
        'fcm_token': token,
        'platform': fcmPlatformLabel,
      });
      _lastSyncedToken = token;
      debugPrint('PushNotificationService: FCM token terkirim ke backend.');
    } catch (e, st) {
      debugPrint('PushNotificationService: gagal kirim token: $e\n$st');
    }
  }

  Future<String?> _fetchFcmToken() async {
    if (kIsWeb) {
      return _messagingOrThrow.getToken(vapidKey: kFirebaseWebVapidKey);
    }
    return _messagingOrThrow.getToken();
  }

  Future<bool> _requestNotificationPermission() async {
    if (kIsWeb || fcmIsApplePlatform) {
      final settings = await _messagingOrThrow.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? true;
    }

    return true;
  }
}
