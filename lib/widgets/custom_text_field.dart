// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare/core/theme/themes.dart';

Directionality CustomTextField(BuildContext context, {
  required TextEditingController controller,
  String? hintText,
  required double fontSize,
  Color? hintColor,
  Color? fillColor,
  bool? enabled = true,
  bool? vital = false,
  //String? hintText,
  String? Function(String? textValue)? validator,
  double? letterSpacing,
  double? padding,
  int? maxLines = 1,
}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0),
      child: TextFormField(
        maxLines: maxLines,
        enabled: enabled,
        controller: controller,
        validator: validator,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 16.0),
        cursorColor: Colors.black,
        keyboardType: vital! ? TextInputType.numberWithOptions(decimal: true) : null,
        inputFormatters: vital ? [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}$')),
          // Allows digits and at most one decimal point
        ] : null,
        /*keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],*/
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.2)),
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
          contentPadding: maxLines != 1 ? EdgeInsets.all(10.0) : EdgeInsets.only(right: padding ?? 10.0),
          fillColor: fillColor,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor, fontSize: fontSize),
        ),
      ),
    ),
  );
}

Widget CustomTextFieldWithLabel(BuildContext context, {
  required TextEditingController controller,
  //required String hintText,
  required double fontSize,
  required Color hintColor,
  required String hintText,
  bool? numeric = false,
  bool? enabled = true,
  bool? isDetails = false,
  double borderRadius = 10.0,
  String? Function(String? textValue)? validator,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10.0, top: 5.0),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        maxLines: isDetails! ? 1 : 1,
        minLines: isDetails ? 1 : 1,
        enabled: enabled,
        controller: controller,
        validator: validator,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 16.0),
        keyboardType: numeric! ? TextInputType.number : null,
        inputFormatters: numeric ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ] : [],
        decoration: InputDecoration(
          //labelText: hintText,
          //labelStyle: TextStyle(color: Colors.grey[600]),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HomeCareTheme.primaryColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBorder: OutlineInputBorder(
          borderSide: isDetails ? const BorderSide(width: 1.0, color: Colors.black) : BorderSide.none,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.0, color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.0, color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          contentPadding: isDetails ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0) :  const EdgeInsets.symmetric(horizontal: 10.0),
          fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor, fontSize: fontSize),
        ),
      ),
    ),
  );
}

Widget CustomMenuItem(BuildContext context, {
  required Widget child,
  required bool flag,
}) {
  return Container(
    height: 50.0,
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
    margin: EdgeInsets.only(bottom: flag ? 3.0 : 10.0, top: 5.0),
    decoration: BoxDecoration(
      color: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10.0),
      border: flag ? Border.all(color: Colors.red) : Border.all(width: 1.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.5)),
    ),
    child: child,
  );
}

Widget CustomNumberTextField(BuildContext context, {
  required TextEditingController controller,
  required String hintText,
  required double fontSize,
  required Color hintColor,
  String? Function(String? textValue)? validator,
  double? letterSpacing,
  double? padding
}) {
  return Container(
    //padding: const EdgeInsets.only(bottom: 10.0),
    margin: const EdgeInsets.only(bottom: 10.0, top: 5.0),
    child: TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 16.0, letterSpacing: 1.0),
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
        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: fontSize),
        prefixIcon: SizedBox(
          width: MediaQuery.of(context).size.width * 0.18,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text('+963', style: TextStyle(color: Colors.grey[700], fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                height: 25.0,
                child: VerticalDivider(color: Colors.grey),
              ),
            ],
          ),
        ),
        hintTextDirection: TextDirection.rtl,
      ),
    ),
  );
}