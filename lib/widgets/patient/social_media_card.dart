import 'package:flutter/material.dart';

Material SocialMediaCard({
  required String iconUrl,
  required VoidCallback onTap,
  required String title,
}) {
  return Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
      side: BorderSide(width: 0.5, color: Colors.grey),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(25.0),
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 50.0,
        child: Row(
          spacing: 10.0,
          children: [
            Image.asset(iconUrl, scale: 2.0),
            const VerticalDivider(),
            Text(title, style: TextStyle(fontSize: 20.0, color: Colors.black)),
          ],
        ),
      ),
    ),
  );
}