import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/view/nurse/home_nurse.dart';
import 'package:homecare/mvc/view/patient/main_screen_patient.dart';
import 'package:homecare/mvc/view/patient/profile_patient_screen.dart';
import 'package:homecare/mvc/view/patient/reservations_screen.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

PageController pagePatientController = PageController(initialPage: selectedPIndex);
int selectedPIndex = 2;

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedPIndex = 2;
    });
    //pageController = PageController(initialPage: selectedIndex);
    getPatientDetails();
  }

  void getPatientDetails() {
    String token = sharedPrefsController.getToken();
    ConnectionController.getPatientProfileInfo(token: token);
    if(sharedPrefsController.isSubUser()) {
      if(mounted) {
        setState(() {});
      }
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedPIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        bool backNavigationAllowed = pagePatientController.page == 2;
        if (backNavigationAllowed) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        } else {
          pagePatientController.jumpToPage(2);
        }
      },
      child: Scaffold(
        floatingActionButton: sharedPrefsController.isSubUser() ? FloatingActionButton(
          onPressed: () {
            bool isLoading = false;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: isLoading
                            ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
                            : Text('الرجوع إلى الحساب'),
                        content: isLoading ? SizedBox.shrink() : Text('هل تريد الرجوع إلى حسابك الأساسي ؟'),
                        actions: <Widget>[
                          if (!isLoading)
                            SizedBox(
                              width: 120.0,
                              child: IconButton(
                                onPressed: () async {
                                  setStateDialog(() => isLoading = true);
                                  sharedPrefsController.setIsSubUser(value: false);
                                  String previousToken = sharedPrefsController.getMainUserToken();
                                  sharedPrefsController.saveToken(token: previousToken);
                                  if(sharedPrefsController.getMainUserType() == 2) {
                                    sharedPrefsController.saveUserType(type: 2);
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) =>
                                          HomePatient()),
                                          (Route<dynamic> route) => false,
                                    );
                                  } else {
                                    sharedPrefsController.saveUserType(type: 3);
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) =>
                                          HomeNurse()),
                                          (Route<dynamic> route) => false,
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                                ),
                                icon: Text('تأكيد', style: TextStyle(color: Colors.green, fontSize: 14.0)),
                              ),
                            ),
                          if (!isLoading)
                            SizedBox(
                              width: 100.0,
                              child: IconButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                style: IconButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                                ),
                                icon: Text('تراجع', style: TextStyle(color: Colors.red, fontSize: 14.0)),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          backgroundColor: HomeCareTheme.primaryColorBold,
          tooltip: 'الرجوع إلى حسابك',
          child: Icon(CupertinoIcons.refresh_circled, color: Colors.white, size: 30.0),
        ) : null,
        body: PageView(
          controller: pagePatientController,
          children: screens,
          onPageChanged: (index) {
            setState(() {
              selectedPIndex = index;
            });
          },
        ),
        bottomNavigationBar: SlidingClippedNavBar(
          backgroundColor: Colors.white,
          onButtonPressed: (index) {
            setState(() {
              selectedPIndex = index;
            });
            pagePatientController.animateToPage(selectedPIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          },
          iconSize: 30,
          activeColor: HomeCareTheme.primaryColor,
          inactiveColor: HomeCareTheme.secondaryColorBold,
          selectedIndex: selectedPIndex,
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
    const ProfilePatientScreen(),
    const ReservationsScreen(),
    const MainScreenPatient(),
  ];

}
