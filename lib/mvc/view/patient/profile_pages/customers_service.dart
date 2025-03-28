import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/header_widget.dart';

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
        padding: const EdgeInsets.only(top: 25.0),
        child: Stack(
          children: [
            HeaderWidget(context, title: 'خدمة العملاء'),
          ],
        ),
      ),
    );
  }
}
