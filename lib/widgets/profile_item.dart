// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
Widget ProfileItem(BuildContext context, {
  required VoidCallback onTap,
  required String title,
  required String iconUrl,
}) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      //margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onTap();
            },
            icon: Image.asset('assets/icons/forward.png', scale: 2.0),
          ),
          const Spacer(),
          Text(title),
          const SizedBox(width: 10.0),
          Image.asset(iconUrl, scale: iconUrl == 'assets/icons/insurance.png' ? 2.5 : 2.0, color: HomeCareTheme.primaryColorBoldExtra),
        ],
      ),
    ),
  );
}