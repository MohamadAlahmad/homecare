import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

PackageDetailsCard({required String name, required String details, required int numberOfSessions, required num price}) {

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
            Icon(Icons.content_paste, color: Colors.teal[900]),
            const SizedBox(width: 5.0),
            Text(name, style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 5.0),
        Text(details),
        Divider(),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.number_circle, color: Colors.teal[900]),
                    const SizedBox(width: 5.0),
                    Text('عدد الجلسات', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(numberOfSessions.toString()),
              ],
            ),
            const SizedBox(width: 50.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.money_dollar_circle, color: Colors.teal[900]),
                    const SizedBox(width: 5.0),
                    Text('السعر', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text('$price ل.س'),
              ],
            ),
            const Spacer(),
          ],
        ),
      ],
    ),
  );
}
