// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare/core/theme/themes.dart';

Padding PhoneTextField(
    BuildContext context, {
      required TextEditingController controller,
      required String hintText,
      required double fontSize,
      required Color hintColor,
      Color? fillColor,
      String? Function(String? textValue)? validator,
      double? letterSpacing,
      double? padding,
    }) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0),
    child: TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: Colors.black,
      style: const TextStyle(fontSize: 20.0, letterSpacing: 1.0),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1.0, color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1.0, color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.only(left: padding ?? 5.0),
        fillColor: fillColor,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: fontSize),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.phone_android_rounded, color: HomeCareTheme.primaryColor, size: 30.0),
              ),
              //const VerticalDivider(color: Colors.grey, thickness: 1.0),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  '+963',
                  style: TextStyle(color: Colors.grey[700], fontSize: 20.0, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

