import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    initializeData();
    Timer(const Duration(milliseconds: 3000), () {
      Get.offAllNamed('/main');
    });
    debugPrint('WAITING SECOND CODE : ${sharedPrefsController.amIWaitingSecondCode()}');
    super.initState();
  }

  initializeData() async {
    ConnectionController.getCities();
    ConnectionController.getRegions1();
    ConnectionController.getRegions2();
    if(sharedPrefsController.getLoggedValue()) {
      ConnectionController.registerFCMToken(
        token: sharedPrefsController.getToken(),
        fcmToken: sharedPrefsController.getUserFCMToken(),
      );
      if(sharedPrefsController.getUserType() == 2) {
        getPatientDetails();
      } else if(sharedPrefsController.getUserType() == 3) {
        getNurseDetails();
      } else if(sharedPrefsController.getUserType() == 4) {
        getSupporterDetails();
      }
    }
    debugPrint('Token = ${sharedPrefsController.getToken()}');
  }

  void getPatientDetails() {
    String token = sharedPrefsController.getToken();
    ConnectionController.getPatientProfileInfo(token: token);
  }
  void getNurseDetails() {
    String token = sharedPrefsController.getToken();
    ConnectionController.getNurseProfileInfo(token: token);
  }
  void getSupporterDetails() {
    String token = sharedPrefsController.getToken();
    ConnectionController.getSupporterProfileInfo(token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'main_image',
          child: Image.asset('assets/images/ALB.png', scale: 1.5),
        ),
      ),
    );
  }
}
