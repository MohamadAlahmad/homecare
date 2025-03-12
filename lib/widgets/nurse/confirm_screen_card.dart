// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';

Widget ConfirmScreenCard(BuildContext context, {required String buttonTitle, required VoidCallback onPressed, bool? isSpecial = false}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      height: 165.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        //boxShadow: [BoxShadow(color: HomeCareTheme.secondaryColor.withValues(alpha: 0.5), blurRadius: 10.0, spreadRadius: 1.0)],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 55.0,
                    width: 55.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset('assets/images/temp_image.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('قياس ضغط', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            backgroundImage: AssetImage('assets/images/person.png'),
                          ),
                          const SizedBox(width: 5.0),
                          Text('غسان آدم', style: TextStyle(fontSize: 12.0)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/location_nurse.png', scale: 3.0),
                  const SizedBox(width: 3.0),
                  Expanded(flex: 3, child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text('المهاجرين', style: TextStyle(color: Colors.black, fontSize: 14.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
                  const SizedBox(width: 5.0),
                  Image.asset('assets/icons/calendar_nurse.png', scale: 3.0),
                  const SizedBox(width: 3.0),
                  Expanded(flex: 3, child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text('15-10-2024', style: TextStyle(color: Colors.black, fontSize: 14.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
                  const SizedBox(width: 5.0),
                  Image.asset('assets/icons/clock_nurse.png', scale: 3.0),
                  const SizedBox(width: 3.0),
                  Expanded(flex: 5, child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text('10:00 - 11:00 ص', style: TextStyle(color: Colors.black, fontSize: 14.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: HomeCareSize.width(context),
                  child: IconButton(
                    onPressed: () {
                      onPressed();
                    },
                    style: IconButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                    icon: Text(buttonTitle, style: TextStyle(color: HomeCareTheme.primaryColorBold, fontSize: 14.0)),
                  ),
                ),
              ),
            ],
          ),
          if(isSpecial!) Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text('طلب خاص بك', style: TextStyle(fontSize: 12.0, color: Colors.green)),
            ),
          ),
        ],
      ),
    ),
  );
}