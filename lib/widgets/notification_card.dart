// ignore_for_file: non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

Widget NotificationCard(BuildContext context, {required String title, required String body}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Container(
            //width: MediaQuery.of(context).size.width * 0.43,
            padding: EdgeInsets.all(5.0),
            /*decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: HomeCareTheme.primaryColorLight,
                  border: Border.all(width: 1.0, color: Colors.white),
                ),*/
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: HomeCareTheme.secondaryColor, blurRadius: 5.0)],
                  ),
                  child: CircleAvatar(backgroundImage: AssetImage('assets/appIcon/icon.png')),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 10.0, bottom: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, /*maxLines: 1, overflow: TextOverflow.ellipsis,*/ style: TextStyle(color: HomeCareTheme.primaryColorBoldExtra, fontSize: 16.0, fontWeight: FontWeight.bold)),
                        Text(body, /*maxLines: 1, overflow: TextOverflow.ellipsis,*/ style: TextStyle(color: Colors.black, fontSize: 14.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    ),
  );
}