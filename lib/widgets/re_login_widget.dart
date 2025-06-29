// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/buttons.dart';

Widget ReLoginWidget(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.refresh_circled, size: 100.0, color: Colors.grey),
        const SizedBox(height: 10.0),
        Text('لقد تم الدخول لحسابك من جهاز آخر', style: TextStyle(fontSize: 20.0, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 10.0),
        Text('يرجى إعادة تسجيل الدخول', style: TextStyle(fontSize: 20.0, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 10.0),
        CustomButton(
          onPressed: () {
            SharedPrefsController().terminateSession(false);
            SharedPrefsController().clearData();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/', (Route<dynamic> route) => false,
            );
          },
          title: Text('إعادة الدخول', style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
          width: 120.0,
          backgroundColor: HomeCareTheme.primaryColor,

        ),
      ],
    ),
  );
}