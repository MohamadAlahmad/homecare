// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/widgets/brief_details_card.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/fill_session_modal.dart';
import 'package:homecare/widgets/re_login_widget.dart';
import 'package:homecare/widgets/vital_sign_card.dart';

class VisitDetailsNurseScreen extends StatefulWidget {
  final String serviceName;
  final String patientName;
  final int patientId;
  final num servicePrice;
  final String location;
  final int sessionId;
  const VisitDetailsNurseScreen({super.key, required this.serviceName, required this.patientName, required this.location, required this.sessionId, required this.patientId, required this.servicePrice});

  @override
  State<VisitDetailsNurseScreen> createState() => _VisitDetailsNurseScreenState();
}

class _VisitDetailsNurseScreenState extends State<VisitDetailsNurseScreen> {

  int value = 0;
  late PageController pageController;
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  TextEditingController bloodPressureFirstCtrl = TextEditingController();
  TextEditingController bloodPressureSecondCtrl = TextEditingController();
  TextEditingController bloodSugarCtrl = TextEditingController();
  TextEditingController heartRateCtrl = TextEditingController();
  TextEditingController oxygenationCtrl = TextEditingController();
  TextEditingController caseDescription = TextEditingController();
  TextEditingController additionalServiceNameController = TextEditingController();
  TextEditingController additionalServicePriceController = TextEditingController();

  late Future<PreviousCase?> futurePreviousCase;

  DateTime now = DateTime.now();
  late String formattedDate;

  Future<PreviousCase?> getPreviousCase() async {
    return await ConnectionController.getPreviousCase(
      token: sharedPrefsController.getToken(),
      patientId: widget.patientId,
    );
  }

  @override
  void initState() {
    pageController = PageController(initialPage: value);
    formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    futurePreviousCase = getPreviousCase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              HeaderWidget(context, title: 'تفاصيل الزيارة'),
              AnimatedToggleSwitch<int>.size(
                textDirection: TextDirection.rtl,
                current: value,
                values: const [0, 1], // For two pages
                iconOpacity: 1.0,
                indicatorSize: const Size.fromWidth(150),
                iconBuilder: (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: textBuilder2(i, value),
                ),
                borderWidth: 4.0,
                iconAnimationType: AnimationType.onHover,
                style: ToggleStyle(
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                styleBuilder: (i) => ToggleStyle(indicatorColor: colorBuilder2(i)),
                onChanged: (i) {
                  if (i != value) {
                    if (i > value) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    setState(() => value = i);
                  }
                },
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() => value = index);
                    },
                    children: [
                      CurrentVisit(),
                      PreviousVisit(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  CurrentVisit() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BriefDetailsCard(
                serviceName: widget.serviceName,
                patientName: widget.patientName,
                nurseName: '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}',
                date: formattedDate,
                location: widget.location,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: MenuText('المعالم الحيوية :'),
              ),
              VitalSignCard(
                context,
                title: 'الضغط',
                controller: bloodPressureFirstCtrl,
                controller2: bloodPressureSecondCtrl,
                forBloodPressure: true,
                enabled: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  }
                  return null; // No errors
                },
              ),
              VitalSignCard(
                context,
                title: 'السكر',
                controller: bloodSugarCtrl,
                enabled: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  }
                  return null; // No errors
                },
              ),
              VitalSignCard(
                context,
                title: 'نبضات القلب',
                controller: heartRateCtrl,
                enabled: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  }
                  return null; // No errors
                },
              ),
              VitalSignCard(
                context,
                title: 'الأكسجة',
                controller: oxygenationCtrl,
                enabled: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  }
                  return null; // No errors
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: MenuText('وصف الحالة :'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CustomTextField(
                  context,
                  controller: caseDescription,
                  fontSize: 14.0,
                  maxLines: 1,
                  fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                  enabled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'حقل مطلوب';
                    }
                    return null; // No errors
                  },
                ),
              ),
              /*Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: MenuText('صور إضافية : لا يوجد حالياً'),
              ),*/
              /*Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('هنا'),
              ),*/
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: () {
                    if(formKey.currentState!.validate()) {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
                            ),
                            child: SingleChildScrollView(
                              child: FillSessionModal(
                                title: 'تفاصيل الفاتورة',
                                price: widget.servicePrice,
                                additionalServiceNameCtrl: additionalServiceNameController,
                                additionalServicePriceCtrl: additionalServicePriceController,
                                onPressed: () async {
                                  // Show the loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.transparent,
                                        title: HCCPI(color: Colors.white, size: 30.0),
                                      );
                                    },
                                  );
                                  // Try sending the request and handle any response
                                  try {
                                  var result = await ConnectionController.fillSessionForm(
                                    bioMarker1Value: bloodPressureFirstCtrl.text,
                                    bioMarker2Value: bloodPressureSecondCtrl.text,
                                    bioMarker3Value: bloodSugarCtrl.text,
                                    bioMarker4Value: heartRateCtrl.text,
                                    bioMarker5Value: oxygenationCtrl.text,
                                    notes: caseDescription.text.isNotEmpty ? caseDescription.text : '',
                                    basicServicePrice: widget.servicePrice,
                                    descriptionAdditional: additionalServiceNameController.text.isNotEmpty ? additionalServiceNameController.text : '',
                                    priceAdditional: additionalServicePriceController.text.isNotEmpty
                                        ? num.tryParse(additionalServicePriceController.text) ?? 0
                                        : 0,
                                    token: sharedPrefsController.getToken(),
                                    sessionId: widget.sessionId,
                                  );

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);

                                  if(sharedPrefsController.sessionTerminated()) {
                                    HomeCareStyle.showReLoginDialog(context);
                                  } else if (result) {
                                      HomeCareStyle.showSnackBar(
                                        context,
                                        success: true,
                                        content: 'تم تسجيل الانتهاء بنجاح',
                                        icon: Icons.check_circle,
                                      );
                                    } else {
                                      HomeCareStyle.showSnackBar(
                                        context,
                                        content: sharedPrefsController.getMSG(),
                                        icon: Icons.info_outline,
                                      );
                                    }
                                  } catch (e) {
                                    // Ensure the dialog is dismissed on error
                                    Navigator.pop(context);
                                    // Log or handle the error
                                    debugPrint('Error occurred: $e');
                                    // Show an error snackbar
                                    HomeCareStyle.showSnackBar(
                                      context,
                                      content: 'حدث خطأ أثناء إرسال البيانات. يرجى المحاولة مرة أخرى.',
                                      icon: Icons.error_outline,
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  title: const Text('استمرار', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                  backgroundColor: HomeCareTheme.primaryColorBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreviousVisit() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FutureBuilder<PreviousCase?>(
            future: futurePreviousCase,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: HCCPI(color: HomeCareTheme.primaryColor));
              } else if(sharedPrefsController.sessionTerminated()) {
                return ReLoginWidget(context);
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return MessageWidget(text: 'لا توجد زيارة سابقة');
              } else {
                var previousCase = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BriefDetailsCard(
                      serviceName: widget.patientName,
                      patientName: widget.patientName,
                      nurseName: '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}',
                      date: formattedDate,
                      location: widget.location,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: MenuText('المعالم الحيوية :'),
                    ),
                    VitalSignCard(
                      context,
                      title: 'الضغط',
                      controller: TextEditingController(text: previousCase.bloodPressureFirstValue),
                      controller2: TextEditingController(text: previousCase.bloodPressureSecondValue),
                      forBloodPressure: true,
                      enabled: false,
                    ),
                    VitalSignCard(
                      context,
                      title: 'السكر',
                      controller: TextEditingController(text: previousCase.bloodSugar),
                      enabled: false,
                    ),
                    VitalSignCard(
                      context,
                      title: 'نبضات القلب',
                      controller: TextEditingController(text: previousCase.heartRate),
                      enabled: false,
                    ),
                    VitalSignCard(
                      context,
                      title: 'الأكسجة',
                      controller: TextEditingController(text: previousCase.oxygenation),
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
                        controller: TextEditingController(text: previousCase.notes),
                        fontSize: 14.0,
                        maxLines: 5,
                        fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                        enabled: false,
                      ),
                    ),
                    /*Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: MenuText('صور إضافية : لا يوجد حالياً'),
                    ),*/
                    /*Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('هنا'),
                    ),*/
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CustomButton(
                        width: HomeCareSize.width(context),
                        height: 50.0,
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        title: const Text('رجوع', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                        backgroundColor: HomeCareTheme.primaryColorBold,
                      ),
                    ),
                  ],
                );
              }
            },
        ),
      ),
    );
  }

  Color colorBuilder2(int value) => switch (value) {
    0 => HomeCareTheme.primaryColor,
    1 => HomeCareTheme.primaryColor,
    _ => HomeCareTheme.primaryColor,
  };
  Widget textBuilder2(int toggleValue, int currentValue) {
    // Determine if the current toggleValue is selected.
    final isSelected = toggleValue == currentValue;
    return Container(
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
        // Use a constant border color based on toggleValue.
        border: Border.all(
          color: isSelected ? Colors.transparent : colorBuilder2(toggleValue),
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: isSelected ? colorBuilder2(toggleValue) : Colors.transparent, // Fill with color if selected.
      ),
      child: Center(
        child: Text(
          textByValue2(toggleValue),
          style: TextStyle(
            fontSize: 14.0,
            color: isSelected ? Colors.white : Colors.black, // White for selected, black for unselected.
          ),
        ),
      ),
    );
  }
  String textByValue2(int? value) => switch (value) {
    0 => 'الزيارة الحالية',
    1 => 'الزيارة السابقة',
    _ => '',
  };
}
