// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/api/firebase_api.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/code_textfield.dart';
import 'package:homecare/widgets/progress_indicator.dart';
import 'package:homecare/widgets/buttons.dart';

class FirstCodeScreen extends StatefulWidget {
  const FirstCodeScreen({super.key});

  @override
  State<FirstCodeScreen> createState() => _FirstCodeScreenState();
}

class _FirstCodeScreenState extends State<FirstCodeScreen> {

  final SharedPrefsController prefsController = SharedPrefsController();
  TextEditingController codeController1 = TextEditingController();
  TextEditingController codeController2 = TextEditingController();
  TextEditingController codeController3 = TextEditingController();
  TextEditingController codeController4 = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Timer? timer;
  int start = 120;
  bool isButtonDisabled = false;
  bool timerVisible = false;
  bool loading = false;

  void startTimer() {
    setState(() {
      start = 120;
      timerVisible = true;
      isButtonDisabled = true;
    });
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer timer) {
      if (start == 0) {
        setState(() {
          timerVisible = false;
          isButtonDisabled = false;
          timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> didChangeDependencies() async {
    await FirebaseApi().initNotifications();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: Platform.isIOS ? HomeCareSize.height(context) * 0.05 : HomeCareSize.height(context) * 0.01, bottom: Get.height * 0.03),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Image.asset('assets/images/ALB.png', scale: 2.0),
              ),
              SingleChildScrollView(
                child: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                        Text('أدخل رمز التأكيد المُرسَل إلى الرقم', style: TextStyle(fontSize: 16.0, color: Colors.black), textAlign: TextAlign.center),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Text('+963 ${formatPhoneNumber(prefsController.getMobileNumber())}', style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        SizedBox(height: Get.height * 0.03),
                        CodeTextField(
                          controller1: codeController1,
                          controller2: codeController2,
                          controller3: codeController3,
                          controller4: codeController4,
                        ),
                        //Divider(indent: Get.width * 0.1, endIndent: Get.width * 0.1),
                        //Text('الرجاء انتظار رمز التفعيل', style: TextStyle(fontSize: 14.0, color: Colors.black), textAlign: TextAlign.center),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: timerVisible,
                                child: Text(formatTime(start), style: TextStyle(color: HomeCareTheme.primaryColor, fontSize: 14.0)),
                              ),
                              TextButton(
                                onPressed: isButtonDisabled ? null : () async {
                                  startTimer();
                                  var result = await ConnectionController.register(
                                    dialCode: '+963',
                                    phoneNumber: prefsController.getMobileNumber(),
                                    userType: prefsController.getUserType(),
                                  );
                                  if(result == 'success' || result == 'success waiting') {
                                    HomeCareStyle.showSnackBar(
                                      context,
                                      content: 'تم إرسال الكود',
                                      icon: Icons.numbers,
                                    );
                                  }
                                },
                                child: Text('إعادة إرسال الكود', style: TextStyle(color: HomeCareTheme.primaryColor, fontSize: 14.0)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        RegisterButton(
                          context,
                          onPressed: loading ? () {} : pressMethod,
                          title: loading ? HCIndicator() : Text('تأكيد', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('تأكيد الرقم', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                    CustomBackButton(
                      onBack: () {
                        FocusScope.of(context).unfocus();
                        GlobalPageController.registerController.previousPage(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                        );

                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pressMethod() async {
    FocusScope.of(context).unfocus();
    if(codeController1.text.isNotEmpty && codeController2.text.isNotEmpty && codeController3.text.isNotEmpty && codeController4.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      String code = codeController1.text + codeController2.text + codeController3.text + codeController4.text;
      debugPrint('User Phone ::: ${prefsController.getMobileNumber()}');
      debugPrint('User Type  ::: ${prefsController.getUserType()}');
      var result = await ConnectionController.verifyFirstCode(
        dialCode: '+963',
        phoneNumber: prefsController.getMobileNumber(),
        userType: prefsController.getUserType(),
        code: code,
      );
      setState(() {
        loading = false;
      });
      debugPrint(result);
      if(result == 'success home') {
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.check_circle_outlined,
          success: true,
          duration: 2000,
        );
        prefsController.setReachToInfoPage(flag: false);
        prefsController.saveLoggedValue(logged: true);
        Navigator.of(context).pushNamedAndRemoveUntil('/home_patient', (Route<dynamic> route) => false);
      } else if(result == 'success info') {
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.check_circle_outlined,
          success: true,
          duration: 2000,
        );
        prefsController.setReachToInfoPage(flag: true);
        GlobalPageController.registerController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else if (result == 'success code 2') {
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.check_circle_outlined,
          success: true,
          duration: 2000,
        );
        prefsController.saveIAmWaitingSecondCode(flag: true);
        GlobalPageController.registerController.animateToPage(
          GlobalPageController.registerController.page!.toInt() + 2, // Skip next and go to the one after
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else if(result == 'expired') {
        //prefsController.saveIAmWaitingCode(flag: false);
        FocusScope.of(context).unfocus();
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.info_outline,
        );
        GlobalPageController.registerController.previousPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.info_outline,
        );
      }
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 9) return phoneNumber;
    return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6, 9)}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
