import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/patient/social_media_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomersService extends StatefulWidget {
  const CustomersService({super.key});

  @override
  State<CustomersService> createState() => _CustomersServiceState();
}

class _CustomersServiceState extends State<CustomersService> {

  final String whatsappNumber = '+963940642036';

  Future<void> openWhatsApp() async {
    // Remove the '+' and any spaces from the number for the WhatsApp URL
    final String cleanNumber = whatsappNumber.replaceAll('+', '').replaceAll(' ', '');

    // Create WhatsApp URL with pre-filled message
    final String message = 'مرحباً، أود الاستفسار عن التطبيق';
    final String encodedMessage = Uri.encodeComponent(message);

    // Try different WhatsApp URL schemes
    final List<String> whatsappUrls = [
      'whatsapp://send?phone=$cleanNumber&text=$encodedMessage', // WhatsApp app
      'https://wa.me/$cleanNumber?text=$encodedMessage', // WhatsApp web/fallback
    ];

    bool launched = false;

    for (String url in whatsappUrls) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) break;
      }
    }

    if (!launched) {
      // If WhatsApp couldn't be opened, show error message
      Fluttertoast.showToast(
        msg: "لا يمكن فتح واتساب. تأكد من تثبيت التطبيق",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: Platform.isIOS ? 60.0 : 0.0),
        child: Column(
          children: [
            HeaderWidget(context, title: 'خدمة العملاء'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    spacing: 15.0,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 10.0),

                      // WhatsApp Section with description
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                              HomeCareTheme.secondaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: HomeCareTheme.primaryColor.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 15.0,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    'يمكنك تقديم شكوى أو إبداء رأي عن التطبيق عن طريق مراسلتنا على واتساب',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.support_agent,
                                    color: HomeCareTheme.primaryColor,
                                    size: 30.0,
                                  ),
                                ),
                              ],
                            ),

                            SocialMediaCard(
                              iconUrl: 'assets/icons/whatsapp.png',
                              onTap: openWhatsApp,
                              title: 'WhatsApp',
                              isWhatsApp: true,
                            ),
                          ],
                        ),
                      ),

                      const Divider(indent: 10.0, endIndent: 10.0, height: 40.0),

                      // Social Media Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'تابعنا على مواقع التواصل الاجتماعي',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      const SizedBox(height: 5.0),

                      // Facebook
                      SocialMediaCard(
                        iconUrl: 'assets/icons/facebook.png',
                        onTap: () {
                          HomeCareStyle.launchURL(url: 'https://www.facebook.com/share/16UQpEV34y/');
                        },
                        title: 'Facebook',
                      ),

                      const Divider(indent: 10.0, endIndent: 10.0),

                      // YouTube
                      SocialMediaCard(
                        iconUrl: 'assets/icons/youtube.png',
                        onTap: () {
                          HomeCareStyle.launchURL(url: 'https://youtube.com/@alb_app?si=lELmQMOke78FtPP3');
                        },
                        title: 'YouTube',
                      ),

                      const SizedBox(height: 50.0),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/ALB.png',
                          height: 120.0,
                        ),
                      ),

                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}