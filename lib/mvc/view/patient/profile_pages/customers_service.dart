import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/patient/social_media_card.dart';

class CustomersService extends StatefulWidget {
  const CustomersService({super.key});
  @override
  State<CustomersService> createState() => _CustomersServiceState();
}

class _CustomersServiceState extends State<CustomersService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: Platform.isIOS ? 60.0 : 0.0),
        child: Column(
          children: [
            HeaderWidget(context, title: 'خدمة العملاء'),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 5.0,
                children: [
                  SocialMediaCard(
                    iconUrl: 'assets/icons/facebook.png',
                    onTap: () {
                      HomeCareStyle.launchURL(url: 'https://www.facebook.com/share/16UQpEV34y/');
                    },
                    title: 'Facebook',
                  ),
                  const Divider(indent: 10.0, endIndent: 10.0),
                  SocialMediaCard(
                    iconUrl: 'assets/icons/youtube.png',
                    onTap: () {
                      HomeCareStyle.launchURL(url: 'https://youtube.com/@alb_app?si=lELmQMOke78FtPP3');
                    },
                    title: 'YouTube',
                  ),
                  const Divider(indent: 10.0, endIndent: 10.0),
                  SocialMediaCard(
                    iconUrl: 'assets/icons/whatsapp.png',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '+963940642036'));
                      Fluttertoast.showToast(
                        msg: "تم نسخ رقم الهاتف 036 642 940 963+ إلى الحافظة",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    title: 'WhatsApp',
                  ),
                  const SizedBox(height: 50.0),
                  Image.asset('assets/images/ALB.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
