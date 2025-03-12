// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/brief_details_card.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/vital_sign_card.dart';

class VisitDetailsPatientScreen extends StatefulWidget {
  const VisitDetailsPatientScreen({super.key});

  @override
  State<VisitDetailsPatientScreen> createState() => _VisitDetailsPatientScreenState();
}

class _VisitDetailsPatientScreenState extends State<VisitDetailsPatientScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              HeaderWidget(context, title: 'تفاصيل الزيارة'),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BriefDetailsCard(
                          patientName: 'patientName',
                          nurseName: 'nurseName',
                          date: 'date',
                          location: 'location',
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: MenuText('المعالم الحيوية :'),
                        ),
                        VitalSignCard(
                          context,
                          title: 'الضغط',
                          controller: TextEditingController(),
                          controller2: TextEditingController(),
                          forBloodPressure: true,
                          enabled: false,
                        ),
                        VitalSignCard(
                          context,
                          title: 'السكر',
                          controller: TextEditingController(),
                          enabled: false,
                        ),
                        VitalSignCard(
                          context,
                          title: 'نبضات القلب',
                          controller: TextEditingController(),
                          enabled: false,
                        ),
                        VitalSignCard(
                          context,
                          title: 'الأكسجة',
                          controller: TextEditingController(),
                          enabled: false,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: MenuText('وصف الحالة :'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: CustomTextField(
                            context,
                            controller: TextEditingController(),
                            fontSize: 14.0,
                            maxLines: 5,
                            fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                          child: MenuText('صور إضافية :'),
                        ),
                        Text('هنا'),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CustomButton(
                            width: HomeCareSize.width(context),
                            height: 50.0,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            title: const Text('رجوع', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                            backgroundColor: HomeCareTheme.primaryColorBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
