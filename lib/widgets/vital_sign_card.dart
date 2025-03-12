// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/widgets/custom_text_field.dart';

Widget VitalSignCard(BuildContext context, {
  required String title,
  required TextEditingController controller,
  TextEditingController? controller2,
  //required String previousResult,
  bool? forBloodPressure = false,
  bool? forHealthRecord = false,
  required bool enabled,
  String? Function(String? textValue)? validator,
}) {
  return Container(
    height: 90.0,
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    margin: EdgeInsets.only(bottom: forHealthRecord! ? 5.0 :15.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16.0, color: Colors.black)),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: CustomTextField(
                        context,
                        enabled: enabled,
                        vital: true,
                        controller: controller,
                        fontSize: 14.0,
                        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                        validator: validator,
                      ),
                    ),
                  ),
                  if(forBloodPressure!) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('/', style: TextStyle(fontSize: 24.0, color: Colors.black)),
                  ),
                  if(forBloodPressure) Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: CustomTextField(
                        context,
                        enabled: enabled,
                        vital: true,
                        controller: controller2!,
                        fontSize: 14.0,
                        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                        validator: validator,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(),
        ),
      ],
    ),
  );
}