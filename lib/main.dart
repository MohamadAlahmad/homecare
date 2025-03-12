import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/api/firebase_api.dart';
import 'package:homecare/firebase_options.dart';
import 'package:homecare/main_app.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

/*class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsController().init();
  //HttpOverrides.global = MyHttpOverrides();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  await FirebaseApi().firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Initialize all supported locales for date formatting
  await initializeDateFormatting();

  runApp(const MyApp());
}
