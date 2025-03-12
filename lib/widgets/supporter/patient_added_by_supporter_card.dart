// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget PatientAddedBySupporterCard(BuildContext context, {required Widget image, required String name, required VoidCallback onDelete}) {
  return Container(
    height: 65.0,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(bottom: 10.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        image,
        Text(name),
        IconButton(
          onPressed: () {
            onDelete();
          },
          icon: const Icon(CupertinoIcons.delete, color: Colors.red),
          iconSize: 30.0,
        ),
      ],
    ),
  );
}