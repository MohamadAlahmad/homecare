// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

Widget PatientAddedByNurseOrPatientCard(BuildContext context, {
  required String imageUrl,
  required String name,
  required String address,
  required VoidCallback onDelete,
}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      height: 90.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Container(
            height: 70.0,
            width: 65.0,
            decoration: BoxDecoration(
              color: HomeCareTheme.secondaryColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5.0),
              Text(name, style: TextStyle(fontSize: 16.0, color: Colors.black)),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  Image.asset('assets/icons/location_fill.png', scale: 2.5, color: HomeCareTheme.primaryColorBoldExtra),
                  const SizedBox(width: 5.0),
                  Text(address.isEmpty ? '(العنوان فارغ)' : address, style: TextStyle(fontSize: 14.0, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onDelete,
            icon: Image.asset('assets/icons/trash.png', scale: 2.0),
          ),
        ],
      ),
    ),
  );
}