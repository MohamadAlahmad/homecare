// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/widgets/buttons.dart';

Widget HeaderWidget(BuildContext context, {required String title, Color? color = Colors.black, Color? iconColor = Colors.black, bool? isDifferent = false, VoidCallback? onBack}) {
  return Align(
    alignment: Alignment.topRight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: color)),
        CustomBackButton(
          onBack: isDifferent! ? () {onBack!();} : () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          color: iconColor,
        ),
      ],
    ),
  );
}