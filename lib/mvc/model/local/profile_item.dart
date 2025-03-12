import 'package:flutter/material.dart';

class ProfileItem {
  String title;
  String iconUrl;
  Widget page;

  ProfileItem({
    required this.title,
    required this.iconUrl,
    required this.page,
  });
}