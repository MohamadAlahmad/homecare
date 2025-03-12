import 'package:flutter/material.dart';

logoutItem({required VoidCallback logoutMethod}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            logoutMethod();
          },
          icon: Image.asset('assets/icons/logout.png', scale: 2.0),
        ),
        const Spacer(),
        Text('تسجيل الخروج'),
      ],
    ),
  );
}