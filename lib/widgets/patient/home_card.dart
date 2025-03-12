// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

InkWell HomeCard(BuildContext context, {
  required int id,
  required bool isActive,
  required String title,
  required String imageUrl,
  required VoidCallback onClick,
}) {
  return InkWell(
    onTap: () {
      onClick();
    },
    borderRadius: BorderRadius.circular(20.0),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      decoration: BoxDecoration(
        color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.0),
        //boxShadow: [BoxShadow(blurRadius: 5.0, spreadRadius: 1.0, offset: const Offset(-2.0, 2.0), color: Colors.grey[400]!)],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(title, style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                SizedBox(width: 10.0),
                Image.asset(imageUrl, scale: id == 3 ? 3.5 : 4.0),
              ],
            ),
          ),
          isActive ? Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
              child: Image.asset('assets/icons/ripple.gif', color: HomeCareTheme.primaryColor, scale: 10.0),
            ),
          ) : Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.02),
              child: const CircleAvatar(radius: 5.5, backgroundColor: HomeCareTheme.redColor),
            ),
          ),
        ],
      ),
    ),
  );
}
