// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/lab_model.dart';
import 'package:homecare/mvc/model/api/lab_test_model.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/widgets/brief_details_card.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_item_card.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/fill_session_modal.dart';
import 'package:homecare/widgets/nurse/upload_button.dart';
import 'package:homecare/widgets/re_login_widget.dart';
import 'package:homecare/widgets/vital_sign_card.dart';
import 'package:screen_protector/screen_protector.dart';

class VisitDetailsNurseScreen extends StatefulWidget {
  final String serviceName;
  final String patientName;
  final int patientId;
  final num servicePrice;
  final String location;
  final int sessionId;
  final bool forLabService;
  final int visitDurationInHours;
  final List<LabTestModel> labTests;
  final LabModel? lab;

  const VisitDetailsNurseScreen({
    super.key,
    required this.serviceName,
    required this.patientName,
    required this.location,
    required this.sessionId,
    required this.patientId,
    required this.servicePrice,
    required this.forLabService,
    required this.labTests,
    required this.lab,
    required this.visitDurationInHours,
  });

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
  ScrollController scrollController = ScrollController();

  late Future<PreviousCase?> futurePreviousCase;

  Future<PreviousCase?> getPreviousCase() async {
    return await ConnectionController.getPreviousCase(
      token: sharedPrefsController.getToken(),
      patientId: widget.patientId,
    );
  }

  @override
  void initState() {
    pageController = PageController(initialPage: value);
    futurePreviousCase = getPreviousCase();
    disableScreenshot();
    calculateFinalLabPrice();
    super.initState();
  }

  calculateFinalLabPrice() {
    for(int i = 0; i < widget.labTests.length; i++) {
        finalLabPrice += widget.labTests[i].price;
    }
  }

  @override
  void dispose() {
    enableScreenshot();
    super.dispose();
  }

  void disableScreenshot() async {
    try {
      await ScreenProtector.protectDataLeakageOn();
      debugPrint('Screenshot disabled');
    } catch (e) {
      debugPrint('Error disabling screenshot: $e');
    }
  }

  void enableScreenshot() async {
    try {
      await ScreenProtector.protectDataLeakageOff();
      debugPrint('Screenshot enabled');
    } catch (e) {
      debugPrint('Error enabling screenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                values: widget.forLabService ? const [0] : const [0, 1],
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
                      widget.forLabService ? CurrentLabVisit() : CurrentVisit(),
                      if (!widget.forLabService) PreviousVisit(),
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

  String selectedFilePath = '';
  String fileName = '';
  int fileId = -1;
  bool fileLoadingState = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path!;
        fileName = result.files.single.name;
        fileLoadingState = true;
      });
      await uploadAttachment();
      setState(() {
        fileLoadingState = false;
      });
    }
  }

  Future<void> uploadAttachment() async {
    String? filePath = selectedFilePath;

    int result = await ConnectionController.uploadFile(
      folderName: 2,
      token: sharedPrefsController.getToken(),
      filePath: filePath,
    );

    if (result != -1) {
      Fluttertoast.showToast(
        msg: "تم تحميل الملف",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {
        fileId = result;
      });
      debugPrint('File ID : $result');
    } else {
      Fluttertoast.showToast(
        msg: "فشل تحميل الملف",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
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
                date: DateTime.now(),
                location: widget.location,
                visitDurationInHours: widget.visitDurationInHours,
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
                  return null;
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
                  return null;
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
                  return null;
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
                  return null;
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
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: MenuText('ملفات إضافية : (اختياري)'),
              ),
              UploadButton(
                onPressed: pickFile,
                filePath: selectedFilePath,
                fileName: fileName,
                loading: fileLoadingState,
                forFillSession: true,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: fileLoadingState ? () {} : () {
                    /*if(fileName.isEmpty) {
                      HomeCareStyle.showSnackBar(context, content: 'الملف مطلوب', icon: CupertinoIcons.exclamationmark_circle);
                    } else {*/
                    if(formKey.currentState!.validate()) {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SingleChildScrollView(
                              child: FillSessionModal(
                                title: 'تفاصيل الفاتورة',
                                price: widget.visitDurationInHours != 0 ? (widget.servicePrice * widget.visitDurationInHours) : widget.servicePrice,
                                additionalServiceNameCtrl: additionalServiceNameController,
                                additionalServicePriceCtrl: additionalServicePriceController,
                                onPressed: () async {
                                  HomeCareStyle.showLoadingDialog(context);
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
                                      attachmentIds: [fileId],
                                    );

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    if (sharedPrefsController.sessionTerminated()) {
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
                                    Navigator.pop(context);
                                    debugPrint('Error occurred: $e');
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
                    //}
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

  num finalLabPrice = 0;
  CurrentLabVisit() {
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
                date: DateTime.now(),
                location: widget.location,
              ),
              SizedBox(height: 25.0),
              MenuText('التحاليل المخبرية:'),
              SizedBox(
                height: 180.0,
                child: Scrollbar(
                  thumbVisibility: true,

                  controller: scrollController,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    children: [
                      for (var labTest in widget.labTests)
                        CustomItemCard(
                          id: labTest.id,
                          title: labTest.name,
                          value: labTest.price,
                          isSelected: false,
                          forLabTest: true,
                          imagePath: 'assets/icons/labTest.png',
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              if(widget.lab != null) Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuText('المخبر الذي تم اختياره:'),
                  const Spacer(),
                  SizedBox(
                    height: 165.0,
                    child: CustomItemCard(
                      id: widget.lab!.id,
                      title: widget.lab!.name,
                      value: widget.lab!.rate!,
                      isSelected: false,
                      forLabTest: false,
                      imagePath: 'assets/icons/lab.png',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SingleChildScrollView(
                              child: FillSessionModal(
                                title: 'تفاصيل الفاتورة',
                                price: widget.servicePrice + finalLabPrice,
                                additionalServiceNameCtrl: additionalServiceNameController,
                                additionalServicePriceCtrl: additionalServicePriceController,
                                onPressed: () async {
                                  HomeCareStyle.showLoadingDialog(context);
                                  try {
                                    var result = await ConnectionController.fillLabSessionForm(
                                      notes: caseDescription.text.isNotEmpty ? caseDescription.text : '',
                                      basicServicePrice: widget.servicePrice,
                                      descriptionAdditional: additionalServiceNameController.text.isNotEmpty ? additionalServiceNameController.text : '',
                                      priceAdditional: additionalServicePriceController.text.isNotEmpty
                                          ? num.tryParse(additionalServicePriceController.text) ?? 0
                                          : 0,
                                      token: sharedPrefsController.getToken(),
                                      sessionId: widget.sessionId,
                                      attachmentIds: [fileId],
                                    );

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    if (sharedPrefsController.sessionTerminated()) {
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
                                    Navigator.pop(context);
                                    debugPrint('Error occurred: $e');
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
            } else if (sharedPrefsController.sessionTerminated()) {
              return ReLoginWidget(context);
            } else if (snapshot.hasError) {
              return MessageWidget(text: 'حدث خطأ أثناء جلب البيانات', errorOrWarning: true);
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
                    date: snapshot.data!.visitDate,
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
    final isSelected = toggleValue == currentValue;
    return Container(
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.transparent : colorBuilder2(toggleValue),
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: isSelected ? colorBuilder2(toggleValue) : Colors.transparent,
      ),
      child: Center(
        child: Text(
          textByValue2(toggleValue),
          style: TextStyle(
            fontSize: 14.0,
            color: isSelected ? Colors.white : Colors.black,
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
