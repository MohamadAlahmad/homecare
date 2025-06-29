/*
// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/view/supporter/add_patient_by_supporter_screen.dart';
import 'package:homecare/mvc/view/supporter/main_screen_supporter.dart';
import 'package:homecare/widgets/buttons.dart';

Widget HomeCareHeader(BuildContext context, {
  required String title,
  required Widget image,
  Widget? listOfPatients,
  required VoidCallback onImagePressed,
  required VoidCallback onBellClicked,
  VoidCallback? onLogout,
  bool? supporter = false,
}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0, top: 25.0),
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: HomeCareTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: supporter! ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  onImagePressed();
                },
                child: Row(
                  children: [
                    image,
                    const SizedBox(width: 10.0),
                    Text(title.length > 30 ? title.substring(0, 30) : title, style: const TextStyle(fontSize: 16.0, color: Colors.white)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  onBellClicked();
                },
                icon: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(child: Image.asset('assets/icons/notification.png', color: Colors.white, scale: 2.5)),
                ),
              ),
              if(supporter) IconButton(
                onPressed: () {
                  onLogout!();
                },
                icon: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(child: Image.asset('assets/icons/logout.png', color: Colors.white, scale: 2.5)),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white, thickness: 0.5),
          if(!supporter) const Text('إدارة المرضى الخاصين', style: TextStyle(color: Colors.white, fontSize: 14.0)),
          if(!supporter) SizedBox(
            height: 65.0, //MediaQuery.of(context).size.height * 0.09
            child: listOfPatients,
          ),
          if(supporter) Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: CustomButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPatientBySupporterScreen())).then((_) {
                  // Reload the screen after adding a patient
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreenSupporter()),
                  );
                });
              },
              title: Text('إضافة مريض', style: TextStyle(color: HomeCareTheme.primaryColor,fontWeight: FontWeight.bold, fontSize: 18.0)),
              width: HomeCareSize.width(context) * 0.7,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}*/
