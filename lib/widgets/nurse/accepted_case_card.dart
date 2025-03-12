// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:intl/intl.dart';

Widget AcceptedCaseCard(
    BuildContext context, {
      required int id,
      required String medicalServiceName,
      required String patientName,
      required String visitDate,
      required String? address,
      String? patientPhoneNumber,
      required VoidCallback onCancel,
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
                    Text(medicalServiceName.length > 22 ?  '${medicalServiceName.substring(0, 19)}...' : medicalServiceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                    const SizedBox(height: 5.0),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12.0,
                          backgroundImage: AssetImage('assets/images/person.png'),
                        ),
                        const SizedBox(width: 5.0),
                        Text(patientName.length > 40 ? '${patientName.substring(0, 40)}..' : patientName, style: TextStyle(fontSize: 12.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icons/location_nurse.png', scale: 3.0, color: HomeCareTheme.primaryColorBoldExtra),
                const SizedBox(width: 3.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(address!.isEmpty ? '(لا يوجد عنوان)' : address,
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Image.asset('assets/icons/calendar_nurse.png', scale: 3.0, color: HomeCareTheme.primaryColorBoldExtra),
                const SizedBox(width: 3.0),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(formattedDate,
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 25.0),
                Image.asset('assets/icons/clock_nurse.png', scale: 3.0, color: HomeCareTheme.primaryColorBoldExtra),
                const SizedBox(width: 3.0),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(formattedTime,
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 140.0,
                    child: IconButton(
                      onPressed: () {
                        onCancel();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(
                            color: HomeCareTheme.primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      icon: Text('إلغاء الطلب', style: TextStyle(color: HomeCareTheme.primaryColorBold, fontSize: 14.0)),
                    ),
                  ),
                  SizedBox(
                    width: 140.0,
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
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 1.0),
                    margin: const EdgeInsets.only(left: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.grey[200],
                    ),
                    width: 80.0,
                    child: Center(child: Text(patientPhoneNumber!.length > 9 ? '0${patientPhoneNumber.substring(0, 9)}' : '0$patientPhoneNumber', style: TextStyle(color: Colors.grey, fontSize: 12.0))),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '0$patientPhoneNumber'));
                      Fluttertoast.showToast(
                        msg: "تم نسخ رقم الهاتف إلى الحافظة",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    child: Icon(Icons.copy_rounded, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/*IconButton(
                onPressed: () {},
                icon: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: HomeCareTheme.primaryColor,
                  child: Icon(Icons.location_history, color: Colors.white, size: 20.0),
                ),
              ),*/