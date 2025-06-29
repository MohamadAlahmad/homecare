import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/package.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/view/patient/home_patient.dart';
import 'package:homecare/mvc/view/patient/main_services/package_booking_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/home_care_page.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/patient/home_card.dart';
import 'package:homecare/widgets/patient/package_card.dart';
import 'package:homecare/widgets/patient_brief_card.dart';
import 'package:homecare/widgets/profile_image_widget.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class MainScreenPatient extends StatefulWidget {
  const MainScreenPatient({super.key});

  @override
  State<MainScreenPatient> createState() => _MainScreenPatientState();
}

class _MainScreenPatientState extends State<MainScreenPatient> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  List<Patient> listOfPatients = [];
  late Future<List<Package>> futurePackages;
  bool empty = false;

  @override
  void initState() {
    debugPrint('HOME : Is Session terminated ? Answer : ${SharedPrefsController().sessionTerminated()}');
    getPatients();
    futurePackages = getPackages();
    if(sharedPrefsController.isSubUser()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if(mounted) {
          setState(() {});
        }
      });
    }
    super.initState();
  }

  getPatients() async {
    var patients = await ConnectionController.getPatients(
      token: sharedPrefsController.getToken(),
    );

    if(mounted) {
      setState(() {
        listOfPatients = patients;
        empty = listOfPatients.isEmpty;
      });
    }
  }

  Future<List<Package>> getPackages() async {
    return await ConnectionController.getPackages(
      token: sharedPrefsController.getToken(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return sharedPrefsController.sessionTerminated() ? ReLoginWidget(context) : HomeCarePage(
      title: '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}',
      image: ProfileImageWidget(
        sharedPrefsController: sharedPrefsController,
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width * 0.15,
      ),
      onImagePressed: () {
        pagePatientController.animateToPage(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
        );
      },
      listOfPatients: empty && listOfPatients.isEmpty
          ? MessageWidget(text: 'لا يوجد مرضى', small: true, color: Colors.white) : listOfPatients.isEmpty
          ? HCCPI() : ListView.builder(
        itemCount: listOfPatients.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return PatientBriefCard(
            context,
            name: '${listOfPatients[index].firstName} ${listOfPatients[index].lastName}',
            address: listOfPatients[index].locationDetails.isEmpty ? '(العنوان فارغ)' : listOfPatients[index].locationDetails,
            onPressed: () {
              HomeCareStyle.showHomeCareDialog(
                context,
                title: 'الانتقال إلى حساب مريض',
                content: 'أنت على وشك الانتقال إلى حساب المريض ${listOfPatients[index].firstName} ${listOfPatients[index].lastName} !',
                onOk: () async {
                  var result = await ConnectionController.switchAccount(
                    token: sharedPrefsController.getToken(),
                    patientId: listOfPatients[index].id,
                  );
                  Navigator.of(context).pop();
                  if (result == 'true') {
                    sharedPrefsController.saveUserType(type: 2);
                    if (context.mounted) {
                      sharedPrefsController.setIsSubUser(value: true);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePatient()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  } else {
                    HomeCareStyle.showSnackBar(
                      context,
                      content: 'فشل تحويل الحساب ، حاول لاحقاً',
                      icon: CupertinoIcons.exclamationmark_triangle_fill,
                    );
                    debugPrint('<<< FAILED >>>');
                  }
                },
                width: HomeCareSize.width(context),
              );
            },
          );
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('خدماتنا', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                textDirection: TextDirection.rtl,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
              height: Platform.isIOS ? MediaQuery.of(context).size.height * 0.52 : MediaQuery.of(context).size.height > 700.0 ? MediaQuery.of(context).size.height * 0.45 : MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: GridView.count(
                padding: EdgeInsets.zero,
                childAspectRatio: Platform.isIOS ? 1.5 : 1.7,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                physics: const BouncingScrollPhysics(),
                crossAxisCount: 2,
                children: List.generate(Globals.listOfServices.length, (index) =>
                    HomeCard(
                        context,
                        id: Globals.listOfServices[index].id,
                        isActive: Globals.listOfServices[index].isActive,
                        title: Globals.listOfServices[index].name,
                        imageUrl: Globals.listOfServices[index].image,
                        onClick: () {
                          if(Globals.listOfServices[index].isActive) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Globals.listOfServices[index].page));
                          } else {
                            HomeCareStyle.showHomeCareDialog(
                              context,
                              title: Globals.listOfServices[index].name,
                              content: 'عزيزي المستخدم، نعمل حاليًا على تفعيل خدمة "${Globals.listOfServices[index].name}" لضمان أفضل رعاية طبية لك. ستكون الخدمة متاحة قريبًا، ونقدّر تفهّمك ودعمك!',
                              onOk: () {},
                              oneButton: true,
                              width: HomeCareSize.width(context),
                              onCancelColor: HomeCareTheme.primaryColor,
                            );
                          }
                        }
                    ),
                ),
              ),
            ),
            Center(
              child: RegisterButton(
                context,
                color: HomeCareTheme.primaryColor,
                title: const Text('طلب مستعجَل', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  HomeCareStyle.showHomeCareDialog(
                    context,
                    title: 'طلب مستعجَل',
                    content: 'عزيزي المستخدم، نعمل حاليًا على تفعيل خدمة الطلب المستعجل لضمان أفضل رعاية طبية لك. ستكون الخدمة متاحة قريبًا، ونقدّر تفهّمك ودعمك!',
                    onOk: () {},
                    oneButton: true,
                    width: HomeCareSize.width(context),
                    onCancelColor: HomeCareTheme.primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('الباقات', style: TextStyle(fontSize: 16.0, color: Colors.black),
                textDirection: TextDirection.rtl,
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 200.0,
                child: buildPackages(),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget buildPackages() {
    return FutureBuilder<List<Package>>(
      future: futurePackages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return HCCPI(color: HomeCareTheme.primaryColor);
        } else if (snapshot.hasError) {
          return MessageWidget(text: 'حدث خطأ أثناء الاتصال', errorOrWarning: true);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return MessageWidget(text: 'لا توجد باقات');
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
            itemCount: snapshot.data!.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var packageItem = snapshot.data![index];
              return PackageCard(
                image: '',
                title: packageItem.name,
                price: packageItem.price,
                description: packageItem.description,
                onSelect: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PackageBookingScreen(package: packageItem)));
                },
              );
            },
          );
        }
      },
    );
  }
}

