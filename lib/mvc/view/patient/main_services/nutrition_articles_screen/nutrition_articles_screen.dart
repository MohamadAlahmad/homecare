import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/medical_service.dart';
import 'package:homecare/mvc/view/patient/main_services/booking_screen.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/patient/custom_bottom_sheet.dart';
import 'package:homecare/widgets/patient/service_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class NutritionArticlesScreen extends StatefulWidget {
  const NutritionArticlesScreen({super.key});

  @override
  State<NutritionArticlesScreen> createState() => _NutritionArticlesScreenState();
}

class _NutritionArticlesScreenState extends State<NutritionArticlesScreen> {

  List<MedicalService> listOfServices = [];
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  getServices() async {
    String token = sharedPrefsController.getToken();
    listOfServices = await ConnectionController.getServices(token: token, medicalServiceTypeId: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200.0,
            child: Image.asset(
              'assets/images/nutrition.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: HomeCareSize.height(context) * 0.25),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            width: HomeCareSize.width(context),
            decoration: BoxDecoration(
              color: HomeCareTheme.containerColor2,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Text('المقالات', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getServices(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return HCCPI(color: HomeCareTheme.primaryColor);
                      } else if(sharedPrefsController.sessionTerminated()) {
                        sharedPrefsController.terminateSession(true);
                        return ReLoginWidget(context);
                      } else if(snapshot.hasError) {
                        return Center(child: Text('Error'));
                      } else {
                        return buildUI(services: listOfServices);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: Platform.isIOS ? HomeCareSize.height(context) * 0.05 : HomeCareSize.height(context) * 0.03,
            right: 5.0,
            child: HeaderWidget(context, title: 'مقالات التغذية الصحية', color: Colors.white, iconColor: Colors.white),
          ),
        ],
      ),
    );
  }


  buildUI({required List<MedicalService> services}) {
    return services.isEmpty ? MessageWidget(text: 'لا توجد مقالات') : ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: services.length,
      itemBuilder: (context, i) {
        return ServiceCard(
          //context,
          title: services[i].name,
          description: services[i].description,
          imageUrl: services[i].imageUrl,
          price: services[i].price,
          isNutrition: true,
          onClick: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (context) {
                return ServiceModal(
                  title: services[i].name,
                  description: services[i].description,
                  preConditions: services[i].serviceConditions,
                  price: services[i].price,
                  imagePath: services[i].imageUrl,
                  isNutrition: true,
                  category: 'مقالات التغذية',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingScreen(
                        serviceId: services[i].id,
                        price: services[i].price,
                        isNursingService: true,
                      )),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }


}
