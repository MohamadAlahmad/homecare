import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Title   : ${message.notification?.title}');
  debugPrint('Body    : ${message.notification?.body}');
  debugPrint('Payload : ${message.data}');
  debugPrint('id : ${message.messageId}');
}

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  DateTime currentTime = DateTime.now();

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();

    try {
      final fcmToken = await firebaseMessaging.getToken();
      SharedPrefsController().saveUserFCMToken(fcmToken: fcmToken);
      debugPrint('FCM TOKEN : $fcmToken');
    } catch (e) {
      debugPrint("Error fetching token: $e");
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Title   : ${message.notification?.title}');
      debugPrint('Body    : ${message.notification?.body}');
      debugPrint('Payload : ${message.data}');

      if (message.notification?.title != null) {
        Get.snackbar(
          '',
          '',
          duration: const Duration(milliseconds: 3000),
          backgroundColor: HomeCareTheme.primaryColor,
          titleText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              message.notification?.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
          messageText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              message.notification?.body ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'لا يوجد عنوان', // Arabic for "No Title"
          '',
          duration: const Duration(seconds: 2),
          backgroundColor: HomeCareTheme.primaryColor,
          titleText: Directionality(  // 👈 Forces RTL Layout
            textDirection: TextDirection.rtl,
            child: const Text(
              'لا يوجد عنوان',
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
          messageText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              message.notification?.body ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Title   : ${message.notification?.title}');
      debugPrint('Body    : ${message.notification?.body}');
      debugPrint('Payload : ${message.data}');

      Get.snackbar(
        '',
        '',
        duration: const Duration(milliseconds: 1500),
        backgroundColor: HomeCareTheme.primaryColor,
        titleText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message.notification?.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message.notification?.body ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ),
      );
    });
  }
}

/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Title   : ${message.notification?.title}');
  debugPrint('Body    : ${message.notification?.body}');
  debugPrint('Payload : ${message.data}');
  debugPrint('id : ${message.messageId}');
}

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  DateTime currentTime = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();

    try {
      final fcmToken = await firebaseMessaging.getToken();
      SharedPrefsController().saveUserFCMToken(fcmToken: fcmToken);
      debugPrint('FCM TOKEN : $fcmToken');
    } catch (e) {
      debugPrint("Error fetching token: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Title   : ${message.notification?.title}');
      debugPrint('Body    : ${message.notification?.body}');
      debugPrint('Payload : ${message.data}');

      showHighPriorityNotification(
        title: message.notification?.title ?? 'لا يوجد عنوان',
        body: message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Title   : ${message.notification?.title}');
      debugPrint('Body    : ${message.notification?.body}');
      debugPrint('Payload : ${message.data}');

      showHighPriorityNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    });
  }

  Future<void> showHighPriorityNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/icon',
      fullScreenIntent: true, // This makes the notification a heads-up notification
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    // Handle notification tapped
  }
}

*/
