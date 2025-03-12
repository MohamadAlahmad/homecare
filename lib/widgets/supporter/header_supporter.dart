// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

Widget SupporterHeader(BuildContext context, {required String title, required Widget image, required VoidCallback onAddPatient, required VoidCallback onImagePressed}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      padding: const EdgeInsets.all(5.0),
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: HomeCareTheme.containerColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              image,
              const SizedBox(width: 10.0),
              Text(title),
              const Spacer(),
              IconButton(
                onPressed: () {
                  onImagePressed();
                },
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.notifications_none, color: HomeCareTheme.primaryColor, size: 30.0),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10.0),
          IconButton(
            onPressed: () {
              onAddPatient();
            },
            icon: SizedBox(
              height: 50.0, //MediaQuery.of(context).size.height * 0.09
              child: Image.asset('assets/icons/add_patient_icon.png'),
            ),
          ),
          const Text('إضافة مريض', style: TextStyle(fontSize: 16.0)),
        ],
      ),
    ),
  );
}