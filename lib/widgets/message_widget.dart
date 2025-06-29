// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/view/nurse/home_nurse.dart';
import 'package:homecare/mvc/view/patient/home_patient.dart';
import 'package:homecare/widgets/buttons.dart';

Directionality MessageWidget({required String text, bool small = false, bool medium = false, Color? color = Colors.grey, bool errorOrWarning = false}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorOrWarning ? CupertinoIcons.info_circle_fill : CupertinoIcons.exclamationmark_bubble_fill, color: color, size: small ? 30.0 : medium ? 50.0 : 75.0),
          SizedBox(height: small ? 0.0 : 10.0),
          Text(text, style: TextStyle(fontSize: small ? 10.0 : medium ? 15.0 : 20.0, color: color), textAlign: TextAlign.center),
          SizedBox(height: small ? 0.0 : 50.0),
          /*if(mustFillInfo) CustomButton(
            onPressed: () {
              pageNurseController.animateToPage(0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad,
              );
            },
            title: Text('الذهاب لإكمال البيانات', style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
            width: 200.0,
            backgroundColor: HomeCareTheme.primaryColorLight,
          ),*/
        ],
      ),
    ),
  );
}