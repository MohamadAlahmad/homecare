import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:intl/intl.dart';

DetailsCard({
  required String visitDateTime,
  required String details,
  required String hours,
  required List<String> selectedLabTest,
  required String labName,
  String? nurseName,
  String? caseDescription,
  String? city,
  String? region,
  String? fileName,
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
        // Date and Time Row
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

        // Address Section
        Row(
          children: [
            Image.asset('assets/icons/send.png', scale: 2.5),
            const SizedBox(width: 5.0),
            Text('العنوان', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 5.0),

        // If city and region are provided (custom address)
        if (city != null && city.isNotEmpty && region != null && region.isNotEmpty) ...[
          Text('- المدينة    :  $city', style: TextStyle(fontSize: 14.0, color: Colors.black)),
          const SizedBox(height: 5.0),
          Text('- المنطقة  :  $region', style: TextStyle(fontSize: 14.0, color: Colors.black)),
          const SizedBox(height: 5.0),
          if (details.isNotEmpty)
            Text('- التفاصيل :  $details', style: TextStyle(fontSize: 14.0, color: Colors.black)),
        ] else ...[
          // Default address
          Text(details.isEmpty ? 'عنوانك الحالي في التطبيق' : details),
        ],

        // Nurse Name (if selected)
        if (nurseName != null && nurseName.isNotEmpty) ...[
          Divider(),
          Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF094f57), size: 20.0),
              const SizedBox(width: 5.0),
              Text('الممرض/ة', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 5.0),
          Text(nurseName, style: TextStyle(fontSize: 14.0, color: Colors.black)),
        ],

        // Lab Tests (if any selected)
        if (selectedLabTest.isNotEmpty) ...[
          Divider(),
          Row(
            children: [
              Image.asset('assets/services/6_6.png', scale: 8.0, color: Color(0xFF094f57)),
              const SizedBox(width: 5.0),
              Text('التحاليل المخبرية', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 5.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              for (int i = 0; i < selectedLabTest.length; i++)
                Text(
                  i == selectedLabTest.length - 1 ? '${selectedLabTest[i]}' : '${selectedLabTest[i]} - ',
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
            ],
          ),
        ],

        // Lab Name (if selected)
        if (labName.isNotEmpty) ...[
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
            style: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ],

        // Case Description (if provided)
        if (caseDescription != null && caseDescription.isNotEmpty) ...[
          Divider(),
          Row(
            children: [
              Icon(Icons.description_outlined, color: Color(0xFF094f57), size: 20.0),
              const SizedBox(width: 5.0),
              Text('شرح الحالة', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 5.0),
          Text(
            caseDescription,
            style: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ],

        // File Name (if uploaded)
        if (fileName != null && fileName.isNotEmpty) ...[
          Divider(),
          Row(
            children: [
              Icon(Icons.attach_file, color: Color(0xFF094f57), size: 20.0),
              const SizedBox(width: 5.0),
              Text('المرفق', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file, color: HomeCareTheme.primaryColor, size: 16.0),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    fileName,
                    style: TextStyle(fontSize: 13.0, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
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