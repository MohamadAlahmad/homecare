// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

Widget PackageCard({
  required String image,
  required String title,
  required String description,
  required num price,
  required VoidCallback onSelect,
}) {
  return InkWell(
    onTap: () {
      onSelect();
    },
    child: Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      width: 200.0,
      height: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(image: AssetImage('assets/images/temp_image.png'), fit: BoxFit.fill),
            ),
          ),
          const SizedBox(height: 3.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(title, style: TextStyle(fontSize: 16.0, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(description, style: TextStyle(fontSize: 14.0, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Text('$price ل.س', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
            ],
          ),
        ],
      ),
    ),
  );
}
