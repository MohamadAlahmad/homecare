// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/view/common/notifications_screen.dart';
import 'package:homecare/mvc/view/supporter/add_patient_by_supporter_screen.dart';
import 'package:homecare/mvc/view/supporter/main_screen_supporter.dart';
import 'package:homecare/widgets/buttons.dart';

class HomeCarePage extends StatefulWidget {
  final String title;
  final Widget image;
  final Widget? listOfPatients;
  final VoidCallback onImagePressed;
  //final VoidCallback onBellClicked;
  final VoidCallback? onLogout;
  final bool? supporter;
  final Widget body;

  const HomeCarePage({
    super.key,
    this.listOfPatients,
    this.onLogout,
    this.supporter = false,
    required this.body,
    required this.title,
    required this.image,
    required this.onImagePressed,
    //required this.onBellClicked,
  });

  @override
  State<HomeCarePage> createState() => _HomeCarePageState();
}

class _HomeCarePageState extends State<HomeCarePage> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: expanded
              ? MediaQuery.of(context).size.height > 700.0
              ? MediaQuery.of(context).size.height * 0.28
              : MediaQuery.of(context).size.height * 0.33
              : MediaQuery.of(context).size.height > 700.0
              ? MediaQuery.of(context).size.height * 0.2
              : MediaQuery.of(context).size.height * 0.23,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
                bottom: 5.0,
                top: 35.0,
              ),
              decoration: BoxDecoration(
                color: HomeCareTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  widget.supporter! ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onImagePressed();
                          },
                          child: Row(
                            children: [
                              widget.image,
                              const SizedBox(width: 10.0),
                              Text(
                                widget.title.length > 30
                                    ? widget.title.substring(0, 30)
                                    : widget.title,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsScreen(),
                              ),
                            );
                          },
                          icon: Container(
                            height: 35.0,
                            width: 35.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/notification.png',
                                color: Colors.white,
                                scale: 2.5,
                              ),
                            ),
                          ),
                        ),
                        if (widget.supporter!)
                          IconButton(
                            onPressed: () {
                              widget.onLogout!();
                            },
                            icon: Container(
                              height: 35.0,
                              width: 35.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Image.asset('assets/icons/logout.png', color: Colors.white, scale: 2.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white, thickness: 0.5),
                    if (!widget.supporter!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إدارة المرضى الخاصين',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            icon: AnimatedRotation(
                              turns: expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 500),
                              child: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!widget.supporter! && expanded)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: expanded ? 1.0 : 0.0,
                        child: SizedBox(
                          height: 65.0,
                          child: widget.listOfPatients,
                        ),
                      ),
                    if (widget.supporter!)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: CustomButton(
                          onPressed: () async {
                            String result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (context) =>
                                    AddPatientBySupporterScreen())).then((result) {
                              if(result == 'complete-info') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddPatientBySupporterScreen(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreenSupporter(),
                                  ),
                                );
                              }
                              // Reload the screen after adding a patient
                              return result;
                            });
                          },
                          title: Text(
                            'إضافة مريض',
                            style: TextStyle(
                              color: HomeCareTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.7,
                          backgroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: MediaQuery.of(context).size.height > 700.0 ? 10 : 11,
          child: widget.body,
        ),
      ],
    );
  }
}
