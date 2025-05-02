import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/view/register/privacy_policy_screen.dart';
import 'package:homecare/widgets/buttons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: MediaQuery.of(context).size.height * 0.2, bottom: MediaQuery.of(context).size.height * 0.03),
          child: Column(
            children: [
              Hero(
                tag: 'main_image',
                child: Image.asset('assets/images/ALB.png', scale: 2.0),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text('مرحباً بك في ALB', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
                    },
                    child: const Text('سياسة الخصوصية والاستخدام', style: TextStyle(decoration: TextDecoration.underline, fontSize: 14.0, color: Colors.blue)),
                  ),
                  Text('الموافقة على ', style: TextStyle(fontSize: 14.0, color: Colors.black)),
                  Checkbox(
                    value: agree,
                    activeColor: HomeCareTheme.primaryColor,
                    onChanged: (bool? newValue) {
                      setState(() {
                        agree = !agree;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              RegisterButton(
                context,
                title: const Text('متابعة', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: agree ? () {
                  GlobalPageController.registerController.nextPage(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                } : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}