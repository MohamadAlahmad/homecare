import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare/core/theme/themes.dart';

class CodeTextField extends StatefulWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final TextEditingController controller4;

  const CodeTextField({
    super.key,
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.controller4,
  });

  @override
  State<CodeTextField> createState() => _CodeTextFieldState();
}

class _CodeTextFieldState extends State<CodeTextField> {
  final FocusNode field1FocusNode = FocusNode();
  final FocusNode field2FocusNode = FocusNode();
  final FocusNode field3FocusNode = FocusNode();
  final FocusNode field4FocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildCodeField(widget.controller1, field1FocusNode, field2FocusNode),
          buildCodeField(widget.controller2, field2FocusNode, field3FocusNode),
          buildCodeField(widget.controller3, field3FocusNode, field4FocusNode),
          buildCodeField(widget.controller4, field4FocusNode, null),
        ],
      ),
    );
  }

  // Reusable method for each text field
  Widget buildCodeField(TextEditingController controller, FocusNode currentFocusNode, FocusNode? nextFocusNode) {
    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: TextField(
        controller: controller,
        focusNode: currentFocusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        cursorColor: Colors.black,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.0, color: HomeCareTheme.primaryColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 0.0, color: HomeCareTheme.primaryColor.withValues(alpha: 0.05)),
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
          fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
          filled: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to the next field if the current field is not empty
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          }/* else {
            // Move to the previous field if the current field is empty
            if (currentFocusNode == field2FocusNode) {
              FocusScope.of(context).requestFocus(field1FocusNode);
            } else if (currentFocusNode == field3FocusNode) {
              FocusScope.of(context).requestFocus(field2FocusNode);
            } else if (currentFocusNode == field4FocusNode) {
              FocusScope.of(context).requestFocus(field3FocusNode);
            }
          }*/
        },
      ),
    );
  }
}

