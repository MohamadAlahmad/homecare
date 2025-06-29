import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/middleware/auth_middleware.dart';
import 'package:homecare/core/middleware/binding.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/view/register/main_info_screen.dart';
import 'package:homecare/mvc/view/nurse/home_nurse.dart';
import 'package:homecare/mvc/view/patient/home_patient.dart';
import 'package:homecare/mvc/view/register/main_register_screen.dart';
import 'package:homecare/mvc/view/splash_screen.dart';
import 'package:homecare/mvc/view/supporter/main_screen_supporter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Tajawal',
        primaryColor: HomeCareTheme.primaryColor,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: HomeCareTheme.primaryColor.withValues(alpha: 0.5),
          selectionHandleColor: HomeCareTheme.primaryColor,
        ),
      ),
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/main', page: () => const MainRegisterScreen(), middlewares: [AuthMiddleware()]),
        GetPage(name: '/info', page: () => const MainInfoScreen()),
        GetPage(name: '/home_nurse', page: () => const HomeNurse()),
        GetPage(name: '/home_patient', page: () => HomePatient()),
        GetPage(name: '/home_supporter', page: () => const MainScreenSupporter()),
      ],
      initialRoute: '/',
      initialBinding: Binding(),
    ) : SafeArea(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        theme: ThemeData(
          fontFamily: 'Tajawal',
          primaryColor: HomeCareTheme.primaryColor,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: HomeCareTheme.primaryColor.withValues(alpha: 0.5),
            selectionHandleColor: HomeCareTheme.primaryColor,
          ),
        ),
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(name: '/main', page: () => const MainRegisterScreen(), middlewares: [AuthMiddleware()]),
          GetPage(name: '/info', page: () => const MainInfoScreen()),
          GetPage(name: '/home_nurse', page: () => const HomeNurse()),
          GetPage(name: '/home_patient', page: () => HomePatient()),
          GetPage(name: '/home_supporter', page: () => const MainScreenSupporter()),
        ],
        initialRoute: '/',
        initialBinding: Binding(),
      ),
    );
  }
}