// ignore_for_file: non_constant_identifier_names


import 'package:flutter/material.dart';

class MainService {
  int id;
  String name;
  bool isActive;
  String image;
  Widget page;

  MainService({
    required this.id,
    required this.name,
    required this.isActive,
    required this.image,
    required this.page,
  });
}