import 'package:flutter/material.dart';

Padding MenuText(title) => Padding(
  padding: const EdgeInsets.only(right: 10.0),
  child: Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal)),
);