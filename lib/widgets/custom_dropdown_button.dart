import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class CustomDropdownWidget<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onItemSelected;
  final String hintText;
  //final bool enabled;
  final bool showMsg;
  final String Function(T) displayText;

  const CustomDropdownWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.hintText,
    required this.displayText,
    //required this.enabled,
    required this.showMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          border: Border.all(color: showMsg ? Colors.red : HomeCareTheme.primaryColor.withValues(alpha: 0.5), width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
          color: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        //margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: DropdownButtonFormField<T>(
          initialValue: selectedItem,
          hint: Center(
            child: Text(
              hintText,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          ),
          items: /*enabled ? */items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              alignment: Alignment.center,
              child: AutoSizeText(
                displayText(item),
                style: const TextStyle(
                  //fontSize: 14.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                minFontSize: 8.0,
                maxFontSize: 14.0,
              ),
            );
          }).toList()/* : null*/,
          onChanged: onItemSelected,
          icon: Image.asset('assets/icons/arrow_down.png', scale: 2.0),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            fontSize: 16,
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
