// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/code_textfield.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/progress_indicator.dart';


class SecondCodeScreen extends StatefulWidget {
  const SecondCodeScreen({super.key});

  @override
  State<SecondCodeScreen> createState() => _SecondCodeScreenState();
}

class _SecondCodeScreenState extends State<SecondCodeScreen> {

  bool loading = false;
  final SharedPrefsController prefsController = SharedPrefsController();
  TextEditingController codeController1 = TextEditingController();
  TextEditingController codeController2 = TextEditingController();
  TextEditingController codeController3 = TextEditingController();
  TextEditingController codeController4 = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: MediaQuery.of(context).size.height * 0.05, bottom: MediaQuery.of(context).size.height * 0.03),
              child: Center(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /*Align(
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
                      ),*/
                      SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                      if(prefsController.getUserType() == 3) Text('أدخل رمز التأكيد الخاص كـ ممرض', style: TextStyle(fontSize: 16.0, color: Colors.black), textAlign: TextAlign.center),
                      if(prefsController.getUserType() == 4) Text('أدخل رمز التأكيد الخاص كـ داعم', style: TextStyle(fontSize: 16.0, color: Colors.black), textAlign: TextAlign.center),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Text('+963 ${formatPhoneNumber(prefsController.getMobileNumber())}', style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      CodeTextField(
                        controller1: codeController1,
                        controller2: codeController2,
                        controller3: codeController3,
                        controller4: codeController4,
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
            Positioned(
              left: 0,
              right: 0,
              child: Image.asset('assets/images/ALB.png', scale: 2.0),
            ),
          ],
        ),
      ),
    );
  }

  /*
  if(sharedPrefsController.getUserType() == 3) {
                            GlobalPageController.registerController.nextPage(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                            );
                            //Navigator.of(context).pushNamedAndRemoveUntil('/home_nurse', (Route<dynamic> route) => false);
                          } else if(sharedPrefsController.getUserType() == 4) {
                            //Navigator.of(context).pushNamedAndRemoveUntil('/home_supporter', (Route<dynamic> route) => false);
                          }
  */
  pressMethod () async {
    FocusScope.of(context).unfocus();
    if(codeController1.text.isNotEmpty && codeController2.text.isNotEmpty && codeController3.text.isNotEmpty && codeController4.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      String code = codeController1.text + codeController2.text + codeController3.text + codeController4.text;
      debugPrint('User Phone ::: ${prefsController.getMobileNumber()}');
      debugPrint('User Type  ::: ${prefsController.getUserType()}');
      var result = await ConnectionController.verifySecondCode(
        dialCode: '+963',
        phoneNumber: prefsController.getMobileNumber(),
        userType: prefsController.getUserType(),
        code: code,
      );
      setState(() {
        loading = false;
      });
      if(result == 'true') {
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.check_circle_outlined,
          success: true,
          duration: 2000,
        );
        prefsController.saveIAmWaitingSecondCode(flag: false);
        if(prefsController.getUserType() == 3) {
          //SharedPrefsController().setReachToInfoPage(flag: false);
          SharedPrefsController().saveLoggedValue(logged: true);
          Navigator.of(context).pushNamedAndRemoveUntil('/home_nurse', (Route<dynamic> route) => false);
        } else if(prefsController.getUserType() == 4) {
          debugPrint('Here --- Supporter , reach to info : false, logged : true, got to supporter home');
          SharedPrefsController().setReachToInfoPage(flag: false);
          SharedPrefsController().saveLoggedValue(logged: true);
          Navigator.of(context).pushNamedAndRemoveUntil('/home_supporter', (Route<dynamic> route) => false);
        }
      } else if(result == 'expired') {
        //prefsController.saveIAmWaitingCode(flag: false);
        FocusScope.of(context).unfocus();
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.info_outline,
        );
        /*GlobalPageController.registerController.previousPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );*/
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

}
