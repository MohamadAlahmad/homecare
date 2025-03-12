import 'package:flutter/material.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/view/register/privacy_policy_screen.dart';
import 'package:homecare/widgets/buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
                },
                child: const Text('سياسة الخصوصية والاستخدام', style: TextStyle(decoration: TextDecoration.underline, fontSize: 16.0, color: Colors.blue)),
              ),
              const Spacer(),
              RegisterButton(
                context,
                title: const Text('الموافقة وتسجيل الدخول', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  GlobalPageController.registerController.nextPage(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}