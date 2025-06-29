import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/health_record_model.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_item_card.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/dashed_border.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/patient/details_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';
import 'package:homecare/widgets/vital_sign_card.dart';

class HealthRecordDetailsScreen extends StatefulWidget {
  final int sessionId;
  const HealthRecordDetailsScreen({super.key, required this.sessionId});

  @override
  State<HealthRecordDetailsScreen> createState() => _HealthRecordDetailsScreenState();
}

class _HealthRecordDetailsScreenState extends State<HealthRecordDetailsScreen> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  late Future<HealthRecordModel?> futureHealthRecord;
  ScrollController scrollController = ScrollController();

  Future<HealthRecordModel?> getHealthRecordDetails({required int id}) async {
    return await ConnectionController.getSessionById(
      token: sharedPrefsController.getToken(),
      sessionId: id,
    );
  }

  @override
  void initState() {
    futureHealthRecord = getHealthRecordDetails(id: widget.sessionId);
    super.initState();
  }

  num finalLabServicePrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(context, title: 'تفاصيل الطلب'),
            Container(
              padding: EdgeInsets.only(top: 60.0, left: 10.0, right: 10.0, bottom: 10.0),
              child: buildHealthRecordDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHealthRecordDetails() {
    return FutureBuilder<HealthRecordModel?>(
      future: futureHealthRecord,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return HCCPI(color: HomeCareTheme.primaryColor);
        } else if (snapshot.hasError) {
          return MessageWidget(text: 'حدث خطأ أثناء جلب البيانات', errorOrWarning: true);
        } else if(sharedPrefsController.sessionTerminated()) {
          return ReLoginWidget(context);
        } else if (!snapshot.hasData) {
          return MessageWidget(text: 'البيانات فارغة');
        } else {
          var healthRecord = snapshot.data!;
          for(int i = 0; i < healthRecord.labTests.length; i++) {
            finalLabServicePrice += healthRecord.labTests[i].price;
          }
          var semiFinal = healthRecord.visitDurationInHours != 0
              ? healthRecord.visitCase!.basicServicePrice! * healthRecord.visitDurationInHours
              :healthRecord.visitCase!.finalPrice!;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailsCardExtended(
                    visitDateTime: healthRecord.visitDate,
                    city: healthRecord.geocodedAddress!.governorateDto.name,
                    region: healthRecord.geocodedAddress!.regionDto.name,
                    details: healthRecord.geocodedAddress!.details,
                    hours: healthRecord.visitDurationInHours.toString(),
                  ),
                  if(healthRecord.labTests.isEmpty) VitalSignCard(
                    context,
                    title: 'ضغط الدم',
                    controller: TextEditingController(text: healthRecord.visitCase!.bloodPressureFirstValue.toString()),
                    controller2: TextEditingController(text: healthRecord.visitCase!.bloodPressureSecondValue.toString()),
                    enabled: false,
                    forBloodPressure: true,
                    forHealthRecord: true,
                  ),
                  if(healthRecord.labTests.isEmpty) VitalSignCard(
                    context,
                    title: 'سكر الدم',
                    controller: TextEditingController(text: healthRecord.visitCase!.bloodSugar.toString()),
                    enabled: false,
                    forHealthRecord: true,
                  ),
                  if(healthRecord.labTests.isEmpty) VitalSignCard(
                    context,
                    title: 'نبضات القلب',
                    controller: TextEditingController(text: healthRecord.visitCase!.heartRate.toString()),
                    enabled: false,
                    forHealthRecord: true,
                  ),
                  if(healthRecord.labTests.isEmpty) VitalSignCard(
                    context,
                    title: 'الأكسجة',
                    controller: TextEditingController(text: healthRecord.visitCase!.oxygenation.toString()),
                    enabled: false,
                    forHealthRecord: true,
                  ),
                  if(healthRecord.labTests.isEmpty) Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MenuText('وصف الحالة :'),
                  ),
                  if(healthRecord.labTests.isEmpty) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CustomTextField(
                      context,
                      controller: TextEditingController(text: healthRecord.visitCase!.notes),
                      fontSize: 14.0,
                      maxLines: 1,
                      fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                      enabled: false,
                    ),
                  ),
                  if(healthRecord.labTests.isNotEmpty) const SizedBox(height: 10.0),
                  if(healthRecord.labTests.isNotEmpty) MenuText('التحاليل المخبرية:'),
                  if(healthRecord.labTests.isNotEmpty) SizedBox(
                    height: 180.0,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: scrollController,
                      child: ListView.builder(
                        itemCount: healthRecord.labTests.length,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: scrollController,
                        itemBuilder: (context, i) {
                          var labTest = healthRecord.labTests[i];
                          return CustomItemCard(
                            id: labTest.id,
                            title: labTest.name,
                            value: labTest.price,
                            isSelected: false,
                            forLabTest: true,
                            imagePath: 'assets/icons/labTest.png',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if(healthRecord.lab != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MenuText('المخبر الذي تم اختياره:'),
                        const Spacer(),
                        SizedBox(
                          height: 165.0,
                          child: CustomItemCard(
                            id: healthRecord.lab!.id,
                            title: healthRecord.lab!.name,
                            value: healthRecord.lab!.rate!,
                            isSelected: false,
                            forLabTest: false,
                            imagePath: 'assets/icons/lab.png',
                          ),
                        ),
                      ],
                    ),
                    Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: MenuText('سعر الخدمة :   '),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CustomTextField(
                            context,
                            controller: TextEditingController(text: '${healthRecord.visitCase!.basicServicePrice!} ل.س'),
                            fontSize: 14.0,
                            maxLines: 1,
                            fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                            enabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (healthRecord.visitCase!.basicServicePrice! != healthRecord.visitCase!.finalPrice!)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0),
                        Divider(indent: 25.0, endIndent: 25.0),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0),
                          child: MenuText('خدمات إضافية :'),
                        ),
                        if (healthRecord.visitCase!.additionalFeesDescription != null && healthRecord.visitCase!.additionalFeesDescription!.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: MenuText('الوصف :'),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(healthRecord.visitCase!.additionalFeesDescription!, style: TextStyle(fontSize: 14.0, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        if (healthRecord.visitCase!.additionalFeesPrice != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: MenuText('السعر :'),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text('${healthRecord.visitCase!.additionalFeesPrice} ل.س', style: TextStyle(fontSize: 14.0, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: MenuText('السعر النهائي :'),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CustomTextField(
                            context,
                            controller: TextEditingController(
                              text: healthRecord.visitDurationInHours != 0
                                  ? '${semiFinal + healthRecord.visitCase!.additionalFeesPrice! + finalLabServicePrice} ل.س'
                                  : '${healthRecord.visitCase!.finalPrice! + finalLabServicePrice} ل.س',
                            ),
                            fontSize: 14.0,
                            maxLines: 1,
                            fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                            enabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),
                  if(healthRecord.labTests.isNotEmpty) SizedBox(
                    height: 100.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: DashedBorder(
                        child: Center(
                          child: !healthRecord.attachmentsAdded
                              ? Text('لم يتم تحميل صورة نتيجة التحليل بعد', style: TextStyle(fontSize: 14.0, color: Colors.grey[600]))
                              : Text('تم تحميل الصورة'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          );
        }
      },
    );
  }

}