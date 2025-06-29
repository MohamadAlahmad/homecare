import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await _showNotification(
    title: message.notification?.title ?? 'لا يوجد عنوان',
    body: message.notification?.body ?? '',
  );
  debugPrint('Background FCM: ${message.notification?.title}');
}

class FirebaseApi {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();

    try {
      final fcmToken = await firebaseMessaging.getToken();
      if (fcmToken != null) {
        SharedPrefsController().saveUserFCMToken(fcmToken: fcmToken);
        debugPrint('FCM TOKEN: $fcmToken');
      }
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
    }

    await _initLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM: ${message.notification?.title}');
      _showNotification(
        title: message.notification?.title ?? 'لا يوجد عنوان',
        body: message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked: ${message.notification?.title}');
      _showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    });
  }
}

Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
  AndroidInitializationSettings('@drawable/icon');

  const DarwinInitializationSettings iosInitSettings =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification tapped: ${response.payload}');
    },
  );
}

Future<void> _showNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_priority_channel',
    'High Priority Notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@drawable/icon',
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
  );
}
