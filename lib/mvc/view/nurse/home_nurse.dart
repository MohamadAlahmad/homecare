// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/helper_methods.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/view/nurse/profile_nurse_screen.dart';
import 'package:homecare/mvc/view/nurse/reservations/nurse_reservations_screen.dart';
import 'package:homecare/mvc/view/nurse/main_screen_nurse.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

PageController pageNurseController = PageController(initialPage: selectedNIndex);
int selectedNIndex = 2;

class HomeNurse extends StatefulWidget {
  const HomeNurse({super.key});

  @override
  State<HomeNurse> createState() => _HomeNurseState();
}

class _HomeNurseState extends State<HomeNurse> {

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedNIndex = 2;
    });
    getNurseDetails();
    checkVersion();
  }

  checkVersion() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      HomeCareHelperClass.checkVersion(context);
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedNIndex = index;
    });
  }

  void getNurseDetails() {
    String token = SharedPrefsController().getToken();
    ConnectionController.getNurseProfileInfo(token: token);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        bool backNavigationAllowed = pageNurseController.page == 2;
        if (backNavigationAllowed) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        } else {
          pageNurseController.jumpToPage(2);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: pageNurseController,
          children: screens,
          onPageChanged: (index) {
            setState(() {
              selectedNIndex = index;
            });
          },
        ),
        bottomNavigationBar: SlidingClippedNavBar(
          backgroundColor: Colors.white,
          onButtonPressed: (index) {
            setState(() {
              selectedNIndex = index;
            });
            pageNurseController.animateToPage(selectedNIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          },
          iconSize: 30,
          activeColor: HomeCareTheme.primaryColor,
          inactiveColor: HomeCareTheme.secondaryColorBold,
          selectedIndex: selectedNIndex,
          barItems: [
            BarItem(
              icon: CupertinoIcons.person_solid,
              title: 'حسابي',
            ),
            BarItem(
              icon: CupertinoIcons.calendar,
              title: 'الحجوزات',
            ),
            BarItem(
              icon: Icons.home_filled,
              title: 'الرئيسية',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> screens = [
    const ProfileNurseScreen(),
    const NurseReservationsScreen(),
    const MainScreenNurse(),
  ];

}
