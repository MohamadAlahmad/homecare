// ignore_for_file: non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

Widget PatientBriefCard(BuildContext context, {required String name, required String address, required VoidCallback onPressed}) {
  return InkWell(
    onTap: () {
      onPressed();
    },
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.43,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: HomeCareTheme.primaryColorLight,
              border: Border.all(width: 1.0, color: Colors.white),
            ),
            child: Row(
              children: [
                Container(
                  height: 50.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: HomeCareTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Image.asset('assets/images/person1_temp.png'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 10.0, bottom: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(name, maxLines: 1, minFontSize: 10.0, maxFontSize: 14.0, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 14.0)),
                        AutoSizeText(address, maxLines: 1, minFontSize: 8.0, maxFontSize: 12.0, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 12.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}