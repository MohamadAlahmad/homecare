// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/core/utils/helper_methods.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/phone_textfield.dart';
import 'package:homecare/widgets/progress_indicator.dart';
import 'package:homecare/widgets/buttons.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {

  final SharedPrefsController prefsController = SharedPrefsController();
  TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? option = '';
  int userType = Globals.patientUserType;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: Platform.isIOS ? HomeCareSize.height(context) * 0.05 : HomeCareSize.height(context) * 0.01, bottom: MediaQuery.of(context).size.height * 0.03),
              child: Form(
                key: formKey,
                child: Stack(
                  children: [
                    if(option!.isNotEmpty) Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: HomeCareSize.height(context) * 0.05),
                        child: Text('سيتم ${option!}', style: TextStyle(fontSize: 14.0, color: Colors.blueGrey)),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Image.asset('assets/images/ALB.png', scale: 2.0),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: HomeCareTheme.secondaryColor,
                              child: IconButton(
                                onPressed: () async {
                                  String? result = await HomeCareHelperClass.showOptionsMenu(context);
                                  if(result != null) {
                                    setState(() {
                                      if(result == 'التسجيل كـ مريض') {
                                        option = '';
                                        userType = Globals.patientUserType;
                                      } else {
                                        if(result == 'التسجيل كـ ممرّض') {
                                          userType = Globals.nurseUserTpe;
                                        } else if(result == 'التسجيل كـ داعم') {
                                          userType = Globals.supporterUserType;
                                        }
                                        option = result;
                                      }
                                    });
                                  }
                                },
                                icon: Icon(CupertinoIcons.ellipsis_vertical, color: HomeCareTheme.primaryColor),
                              ),
                            ),
                            Row(
                              children: [
                                Text('تسجيل الدخول', style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.bold)),
                                CustomBackButton(
                                  onBack: () {
                                    GlobalPageController.registerController.previousPage(
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                        Align(alignment: Alignment.centerRight, child: Text('رجاءً ، أدخل رقم الهاتف الخاص بك', style: TextStyle(fontSize: 14.0, color: Colors.black), textAlign: TextAlign.center)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        PhoneTextField(
                          context,
                          controller: phoneController,
                          hintText: '99999999',
                          fontSize: 20.0,
                          hintColor: Colors.grey,
                          fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الموبايل';
                            } else if (value.length != 9) {
                              return 'يجب أن يتكون الرقم من 9 أرقام بالضبط';
                            } else if (!value.startsWith('9')) {
                              return 'يجب أن يبدأ الرقم بـ 9';
                            }
                            return null; // No errors
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        RegisterButton(
                          context,
                          onPressed: loading ? () {} : pressMethod,
                          title: loading ? HCIndicator() : Text('متابعة', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pressMethod() async {
    debugPrint('Is Session terminated ? Answer : ${SharedPrefsController().sessionTerminated()}');
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      debugPrint('Number Phone :: ${phoneController.text}');
      debugPrint('User Type    :: $userType');

      try {
        var result = await ConnectionController.register(
          dialCode: '+963',
          phoneNumber: phoneController.text,
          userType: userType,
        );

        setState(() {
          loading = false; // Stop loading regardless of the result
        });

        if (result == 'success') {
          HomeCareStyle.showSnackBar(
            context,
            content: prefsController.getMSG(),
            icon: Icons.check_circle_outlined,
            success: true,
            duration: 2000,
          );
          //prefsController.saveIAmWaitingCode(flag: true);
          prefsController.saveMobileNumber(mobile: phoneController.text);
          prefsController.saveUserType(type: userType);
          GlobalPageController.registerController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else if (result == 'timeout') {
          HomeCareStyle.showSnackBar(
            context,
            content: 'انتهت مدة الطلب .. يرجى المحاولة مرة أخرى',
            icon: Icons.warning_amber_rounded,
          );
        } else {
          HomeCareStyle.showSnackBar(
            context,
            content: prefsController.getMSG(),
            icon: Icons.info_outline,
          );
        }
      } on TimeoutException {
        setState(() {
          loading = false;
        });
        HomeCareStyle.showSnackBar(
          context,
          content: prefsController.getMSG(),
          icon: Icons.warning_amber_rounded,
        );
      } catch (e) {
        setState(() {
          loading = false; // Stop loading on any other error
        });
        HomeCareStyle.showSnackBar(
          context,
          content: 'حدث خطأ غير متوقع .. الرجاء المحاولة لاحقاً',
          icon: Icons.info_outline,
        );
      }
    }
  }

}
