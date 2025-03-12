// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:intl/intl.dart';

Widget HealthRecordBriefCard(BuildContext context, {
  required String medicalServiceName,
  required String nurseName,
  required String visitDate,
  required VoidCallback onPressed,
}) {
  // Parse the visitDate string to DateTime
  DateTime parsedDate = DateTime.parse(visitDate);

  // Format the date (e.g., "30-01-2025")
  String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

  // Format the time (e.g., "01:30 م" for Arabic or "01:30 PM" for English)
  String formattedTime = DateFormat('hh:mm a', 'en').format(parsedDate); // Change 'ar' to your desired locale if needed

  return Container(
    height: 165.0,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(bottom: 10.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      //mainAxisSize: MainAxisSize.min,
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
                Text(medicalServiceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12.0,
                      backgroundImage: AssetImage('assets/images/person.png'),
                    ),
                    const SizedBox(width: 5.0),
                    Text('${SharedPrefsController().getFirstName()} ${SharedPrefsController().getLastName()}', style: TextStyle(fontSize: 12.0)),
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
            Icon(Icons.medical_services_outlined, color: HomeCareTheme.primaryColorBoldExtra, size: 20.0),
            const SizedBox(width: 3.0),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(nurseName,
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/icons/calendar_nurse.png', scale: 3.0, color: HomeCareTheme.primaryColorBoldExtra),
            const SizedBox(width: 3.0),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(formattedDate,
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/icons/clock_nurse.png', scale: 3.0, color: HomeCareTheme.primaryColorBoldExtra),
            const SizedBox(width: 3.0),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(formattedTime,
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
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
              icon: Text('تفاصيل الطلب', style: TextStyle(color: HomeCareTheme.primaryColorBold, fontSize: 14.0)),
            ),
          ),
        ),
      ],
    ),
  );
}