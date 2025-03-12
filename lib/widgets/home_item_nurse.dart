// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class HomeItemNurse extends StatefulWidget {
  const HomeItemNurse({super.key});

  @override
  State<HomeItemNurse> createState() => _HomeItemNurseState();
}

class _HomeItemNurseState extends State<HomeItemNurse> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: MediaQuery.of(context).size.height * 0.08, width: MediaQuery.of(context).size.width * 0.15, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 10.0),
              const Text('title'),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.notifications_none, color: HomeCareTheme.primaryColor, size: 30.0),
                ),
              ),
            ],
          ),
          const Divider(),
          const Text('إدارة المرضى الخاصين'),
        ],
      ),
    );
  }
}
