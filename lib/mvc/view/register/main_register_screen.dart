// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/view/register/main_info_screen.dart';
import 'package:homecare/mvc/view/register/welcome_screen.dart';
import 'package:homecare/mvc/view/register/phone_number_screen.dart';
import 'package:homecare/mvc/view/register/first_code_screen.dart';
import 'package:homecare/mvc/view/register/second_code_screen.dart';

class MainRegisterScreen extends StatelessWidget {
  const MainRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: GlobalPageController.registerController,
      children: const [
        WelcomeScreen(), // index = 0
        PhoneNumberScreen(), // index = 1
        FirstCodeScreen(), // index = 2
        MainInfoScreen(),  // index = 3
        SecondCodeScreen(), // index = 4
      ],
    );
  }
}





