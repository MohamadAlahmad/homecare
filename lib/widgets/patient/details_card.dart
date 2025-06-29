import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:intl/intl.dart';

DetailsCard({required String visitDateTime, required String details, required String hours, required List<String> selectedLabTest, required String labName}) {
  // Parse the visitDateTime string to a DateTime object
  final parsedDateTime = DateTime.parse(visitDateTime);

  // Format the date as "yyyy-MM-dd"
  final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDateTime);

  // Format the time as "HH:mm"
  final formattedTime = DateFormat('HH:mm').format(parsedDateTime);

  return Container(
    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    margin: EdgeInsets.only(bottom: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: HomeCareTheme.cardColor,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/calendar.png', scale: 2.5),
                    const SizedBox(width: 5.0),
                    Text('التاريخ', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(formattedDate),
              ],
            ),
            const SizedBox(width: 50.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/clock.png', scale: 2.5),
                    const SizedBox(width: 5.0),
                    Text('الوقت', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                hours != '0' ? Text('$formattedTime (+$hours سا)') : Text(formattedTime),
              ],
            ),
            const Spacer(),
          ],
        ),
        Divider(),
        Row(
          children: [
            Image.asset('assets/icons/send.png', scale: 2.5),
            const SizedBox(width: 5.0),
            Text('العنوان', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 5.0),
        Text(details.isEmpty ? 'عنوانك الحالي في التطبيق' : details),
        if(selectedLabTest.isNotEmpty) Divider(),
        if(selectedLabTest.isNotEmpty) Row(
          children: [
            Image.asset('assets/services/6_6.png', scale: 8.0, color: Color(0xFF094f57)),
            const SizedBox(width: 5.0),
            Text('التحاليل المخبرية', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        if(selectedLabTest.isNotEmpty) const SizedBox(height: 5.0),
        if(selectedLabTest.isNotEmpty)
          Wrap(
            spacing: 8.0, // Adjust the spacing between items
            runSpacing: 4.0, // Adjust the spacing between lines
            children: [
              for (int i = 0; i < selectedLabTest.length; i++)
                Text(
                  i == selectedLabTest.length -1 ? '${selectedLabTest[i]}\n' : '${selectedLabTest[i]} -\n',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        if(labName.isNotEmpty) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            Row(
              children: [
                Icon(Icons.biotech, color: Color(0xFF094f57)),
                const SizedBox(width: 5.0),
                Text('المخبر', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 5.0),
            Text(
              labName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    ),
  );
}


DetailsCardExtended({
  required String visitDateTime,
  required String city,
  required String region,
  required String details,
  required String hours,
}) {
  // Parse the visitDateTime string to a DateTime object
  final parsedDateTime = DateTime.parse(visitDateTime);

  // Format the date as "yyyy-MM-dd"
  final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDateTime);

  // Format the time as "HH:mm"
  final formattedTime = DateFormat('HH:mm').format(parsedDateTime);

  return Container(
    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    margin: EdgeInsets.only(bottom: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: HomeCareTheme.cardColor,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/calendar.png', scale: 2.5),
                    const SizedBox(width: 5.0),
                    Text('التاريخ', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(formattedDate, style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ],
            ),
            const SizedBox(width: 50.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/clock.png', scale: 2.5),
                    const SizedBox(width: 5.0),
                    Text('الوقت', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text('$formattedTime (+$hours سا)', style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ],
            ),
            const Spacer(),
          ],
        ),
        Divider(),
        Row(
          children: [
            Image.asset('assets/icons/send.png', scale: 2.5),
            const SizedBox(width: 5.0),
            Text('العنوان', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 10.0),
        Text('- المدينة    :  $city', style: TextStyle(fontSize: 14.0, color: Colors.black)),
        const SizedBox(height: 10.0),
        Text('- المنطقة  :  $region', style: TextStyle(fontSize: 14.0, color: Colors.black)),
        const SizedBox(height: 10.0),
        Text('- التفاصيل :  $details', style: TextStyle(fontSize: 14.0, color: Colors.black)),
      ],
    ),
  );
}