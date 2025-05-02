import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if(SharedPrefsController().getLoggedValue()) {
      if(SharedPrefsController().getUserType() == 2) {
        return const RouteSettings(name: '/home_patient');
      } else if(SharedPrefsController().getUserType() == 3) {
        return const RouteSettings(name: '/home_nurse');
      } else if(SharedPrefsController().getUserType() == 4) {
        return const RouteSettings(name: '/home_supporter');
      }
    } /*else if(SharedPrefsController().reachToInfoPage()) {
      debugPrint('----------------- Here 3');
      return const RouteSettings(name: '/info');
    }*/
    debugPrint('Logged ---------- ${SharedPrefsController().getLoggedValue()}');
    //debugPrint('1st code -------- ${SharedPrefsController().amIWaitingCode()}');
    debugPrint('2nd code -------- ${SharedPrefsController().amIWaitingSecondCode()}');
    return null;
  }

}