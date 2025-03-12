// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

/*
SizedBox RegisterButton(BuildContext context, {required VoidCallback onPressed, required Widget title}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: 40.0,
    child: ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: HomeCareTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      child: title,
    ),
  );
}
*/

SizedBox RegisterButton(BuildContext context, {required VoidCallback onPressed, Color? color = HomeCareTheme.primaryColor, required Widget title}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    height: 50.0,
    child: MaterialButton(
      onPressed: () {
        onPressed();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: color,
      textColor: Colors.white,
      /*style: ElevatedButton.styleFrom(
        backgroundColor: HomeCareTheme.primaryColor,
        foregroundColor: Colors.white,
      ),*/
      child: title,
    ),
  );
}


SizedBox CustomButton({
  required VoidCallback onPressed,
  required Widget title,
  required double width,
  Color? backgroundColor = HomeCareTheme.redColor,
  double? height = 40.0,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: MaterialButton(
      onPressed: () {
        onPressed();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: backgroundColor,
      child: title,
    ),
  );
}

IconButton CustomBackButton({required VoidCallback onBack, Color? color = Colors.black}) {
  return IconButton(
    onPressed: () {
      onBack();
    },
    icon: Image.asset('assets/icons/back.png', scale: 2.5, color: color),
  );
}