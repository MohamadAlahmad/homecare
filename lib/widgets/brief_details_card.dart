// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

Widget BriefDetailsCard({
  String? serviceName,
  required String patientName,
  required String nurseName,
  required DateTime date,
  required String location,
  int? visitDurationInHours,
  String? caseDescription,
}) {
  final formattedDate =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  return Container(
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (serviceName != null)
          Row(
            children: [
              Image.asset('assets/icons/category.png', scale: 2.7, color: Colors.grey),
              const SizedBox(width: 10.0),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('اسم الخدمة     : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    serviceName,
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        Row(
          children: [
            Image.asset('assets/icons/person1.png', scale: 2.5, color: Colors.grey),
            const SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('اسم المريض   : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  patientName,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Image.asset('assets/icons/person2.png', scale: 2.5),
            const SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('اسم الممرض  : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  nurseName,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Image.asset('assets/icons/calendar_grey.png', scale: 2.5),
            const SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('التاريخ الحالي   : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(formattedDate, style: const TextStyle(fontSize: 14.0, color: Colors.black)),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/icons/location_grey.png', scale: 2.5),
            const SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('العنوان الحالي : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),

        // ── Case description ──────────────────────────────────────────────
        if (caseDescription != null && caseDescription.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, color: Colors.grey, size: 20.0),
              const SizedBox(width: 10.0),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('وصف الحالة    : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    caseDescription,
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

        if (visitDurationInHours != null && visitDurationInHours != 0)
          Row(
            children: [
              const Icon(Icons.numbers, color: Colors.grey, size: 20.0),
              const SizedBox(width: 10.0),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('ساعات الزيارة : ', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    visitDurationInHours.toString(),
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}