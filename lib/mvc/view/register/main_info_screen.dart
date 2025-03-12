// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/progress_indicator.dart';

class MainInfoScreen extends StatefulWidget {
  const MainInfoScreen({super.key});

  @override
  State<MainInfoScreen> createState() => _MainInfoScreenState();
}

class _MainInfoScreenState extends State<MainInfoScreen> {
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Text('رجاءً ، أدخل الاسم الكامل', style: TextStyle(fontSize: 14.0, color: Colors.black), textDirection: TextDirection.rtl),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: CustomTextField(
                        context,
                        controller: firstNameTextController,
                        fontSize: 15.0,
                        hintText: 'الاسم الأول',
                        hintColor: Colors.grey,
                        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'حقل مطلوب';
                          }
                          return null; // No errors
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: CustomTextField(
                        context,
                        controller: lastNameTextController,
                        fontSize: 15.0,
                        hintText: 'الاسم الأخير',
                        hintColor: Colors.grey,
                        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'حقل مطلوب';
                          }
                          return null; // No errors
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: RegisterButton(
                        context,
                        title: loading ? HCIndicator() : const Text('حفظ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if(formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            var result = await ConnectionController.sendPersonalInfo(
                              firstName: firstNameTextController.text,
                              lastName: lastNameTextController.text,
                              dialCode: '+963',
                              phoneNumber: sharedPrefsController.getMobileNumber(),
                              userType: sharedPrefsController.getUserType(),
                            );
                            setState(() {
                              loading = false;
                            });
                            if(result) {
                              sharedPrefsController.setReachToInfoPage(flag: false);
                              //sharedPrefsController.saveLoggedValue(logged: true);
                              sharedPrefsController.saveFirstName(firstName: firstNameTextController.text);
                              sharedPrefsController.saveLastName(lastName: lastNameTextController.text);
                              HomeCareStyle.showSnackBar(
                                context,
                                content: sharedPrefsController.getMSG(),
                                icon: Icons.check_circle_outlined,
                                success: true,
                                duration: 2000,
                              );
                              if(sharedPrefsController.getUserType() == 2) {
                                sharedPrefsController.saveLoggedValue(logged: true);
                                Navigator.of(context).pushNamedAndRemoveUntil('/home_patient', (Route<dynamic> route) => false);
                              } else if(sharedPrefsController.getUserType() == 3 || sharedPrefsController.getUserType() == 4) {
                                sharedPrefsController.saveIAmWaitingSecondCode(flag: true);
                                GlobalPageController.registerController.nextPage(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else {
                              HomeCareStyle.showSnackBar(
                                context,
                                content: sharedPrefsController.getMSG(),
                                icon: CupertinoIcons.exclamationmark_circle_fill,
                                duration: 2000,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset('assets/images/ALB.png', scale: 2.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

