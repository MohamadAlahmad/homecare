// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/widgets/dashed_border.dart';

UploadButton({required VoidCallback onPressed}) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.all(10.0),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: SizedBox(
          height: 100.0,
          child: DashedBorder(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons/export.png', scale: 3.0),
                  Text('رفع صورة', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}