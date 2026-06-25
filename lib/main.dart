import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/storage_service.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';
import 'firebase_options.dart';

void _log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

bool _isFcmTokenSyncInProgress = false;
String? _lastAttemptedFcmToken;

/// Background message handler - runs in isolate, must be top-level
/// IMPORTANT: Firebase must be re-initialized here because this runs in a separate context
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    _log('Background Firebase initialization warning: $e');
  }

  try {
    _log('Background message received: ${message.messageId}');
  } catch (e) {
    _log('Error processing background message: $e');
  }
}

Future<void> _sendFcmTokenToBackend(String token) async {
  if (_isFcmTokenSyncInProgress) {
    _log('FCM token sync skipped: sync already in progress');
    return;
  }

  if (_lastAttemptedFcmToken == token) {
    _log('FCM token sync skipped: same token already attempted');
    return;
  }

  _isFcmTokenSyncInProgress = true;
  _lastAttemptedFcmToken = token;

  try {
    final storage = StorageService();
    final String? authToken = await storage.getToken();
    final String? userId = await storage.getUserId();

    if (authToken == null || authToken.isEmpty) {
      _log('FCM token sync skipped: user is not logged in');
      return;
    }

    if (userId == null || userId.isEmpty) {
      _log('FCM token sync skipped: userId not found');
      return;
    }

    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final Response<dynamic> response = await dio.post(
      '/api/token/save',
      data: <String, dynamic>{'userId': userId, 'fcmToken': token},
      options: Options(
        headers: <String, dynamic>{
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      _log('token send success');
    } else {
      _log('FCM token API non-success response: $status');
    }
  } on DioException catch (e) {
    final int? status = e.response?.statusCode;
    final dynamic body = e.response?.data;
    _log('FCM token API failed (status: $status, body: $body)');
    _log('Error sending FCM token to backend: ${e.message}');
  } catch (e) {
    _log('Error sending FCM token to backend: $e');
  } finally {
    _isFcmTokenSyncInProgress = false;
  }
}

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  _log('Widgets binding initialized');

  await setupLocator();
  _log('Dependency injection initialized');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _log('Firebase initialized');
  } catch (e) {
    _log('Firebase initialization failed: $e');
    // REMOVED rethrow so the app can at least start and show the error!
  }

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _log('Background message handler registered');
  } catch (e) {
    _log('Failed to register background handler: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Container(
          color: Colors.red,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Text(
                'CRASH DETECTED:\n${details.exceptionAsString()}\n\n${details.stack}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(const MultiBranchCrmApp());

      // Keep native splash on-screen briefly for a smoother startup.
      Timer(const Duration(seconds: 2), FlutterNativeSplash.remove);

      // Do notification setup in background so native splash exits quickly.
      unawaited(_initializeMessaging());
    },
    (error, stackTrace) {
      _log('RunZonedGuarded Error: $error');
    },
  );
}

Future<void> _initializeMessaging() async {
  try {
    final NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    _log('Notification permission: ${settings.authorizationStatus}');
  } catch (e) {
    _log('Permission request failed: $e');
  }

  try {
    final String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _log('FCM token received');
      await _sendFcmTokenToBackend(token);
    } else {
      _log('FCM token is null');
    }
  } catch (e) {
    _log('Failed to get FCM token: $e');
  }

  try {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      _log('FCM token refreshed');
      await _sendFcmTokenToBackend(token);
    });
  } catch (e) {
    _log('Failed to set token refresh listener: $e');
  }

  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _log('Foreground message received: ${message.messageId}');
    });
  } catch (e) {
    _log('Failed to set foreground listener: $e');
  }

  try {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _log('Notification clicked: ${message.messageId}');
    });
  } catch (e) {
    _log('Failed to set click listener: $e');
  }

  try {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _log('App opened from notification: ${initialMessage.messageId}');
    }
  } catch (e) {
    _log('Failed to read initial notification message: $e');
  }
}
