import 'package:flutter/material.dart';

class Country {
  String name;
  Widget flag;
  String dialCode;
  String code;
  int maxNumber;

  Country({required this.name, required this.flag, required this.dialCode, required this.code, required this.maxNumber});
}