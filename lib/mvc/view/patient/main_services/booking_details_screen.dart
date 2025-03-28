//ignore_for_file: constant_identifier_names, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/view/patient/profile_pages/my_profile_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/patient/details_card.dart';
import 'package:homecare/widgets/progress_indicator.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int serviceId;
  final int nurseId;
  final List<String> visitsDates;
  final int? visitDurationInHours;
  final int? regionId;
  final String? details;
  final num totalPrice;
  const BookingDetailsScreen({super.key, required this.serviceId, required this.nurseId, required this.visitDurationInHours, required this.regionId, required this.details, required this.visitsDates, required this.totalPrice});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(context, title: 'تفاصيل الطلب'),
            Container(
              padding: EdgeInsets.only(top: 60.0, left: 10.0, right: 10.0, bottom: HomeCareSize.height(context) * 0.18),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.visitsDates.length,
                itemBuilder: (context, i) =>
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: DetailsCard(
                        visitDateTime: widget.visitsDates[i],
                        details: widget.details!,
                        hours: widget.visitDurationInHours.toString(),
                      ),
                    ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('data'),
                    ),
                    Container(
                      padding: EdgeInsets.all(15.0),
                      height: HomeCareSize.height(context) * 0.18,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الإجمالي',  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0)),
                              Text('${widget.totalPrice} ل.س', style: TextStyle(color: HomeCareTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.0)),
                            ],
                          ),
                          ValueListenableBuilder(
                            valueListenable: loading,
                            builder: (context, value, _) {
                              return CustomButton(
                                onPressed: () async {
                                  debugPrint('ServiceId  --> ${widget.serviceId}');
                                  debugPrint('nurseId    --> ${widget.nurseId}');
                                  debugPrint('hours      --> ${widget.visitDurationInHours}');
                                  debugPrint('regionId   --> ${widget.regionId}');
                                  debugPrint('details    --> ${widget.details}');
                                  for(int i = 0; i < widget.visitsDates.length; i++) {
                                    debugPrint('date[$i] --> ${widget.visitsDates[i]}');
                                  }
                                  String token = sharedPrefsController.getToken();
                                  loading.value = true;
                                  var result = await ConnectionController.bookService(
                                    serviceId: widget.serviceId,
                                    nurseId: widget.nurseId,
                                    visitsDates: widget.visitsDates,
                                    visitDurationInHours: widget.visitDurationInHours,
                                    token: token,
                                    regionId: widget.regionId == 0 ? null : widget.regionId,
                                    details: widget.details?.isEmpty ?? true ? null : widget.details,
                                  );
                                  loading.value = false;
                                  if(sharedPrefsController.sessionTerminated()) {
                                    HomeCareStyle.showReLoginDialog(context);
                                  } else if(result == 'true') {
                                    HomeCareStyle.showSnackBar(
                                      context,
                                      content: 'تم الحجز بنجاح',
                                      icon: Icons.check_circle,
                                      success: true,
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else if(result == 'enter-info') {
                                    HomeCareStyle.showInfoRequiredDialog(
                                      context,
                                      title: 'يجب عليك إدخال معلوماتك الشخصية أولاً',
                                      buttonTitle: 'نعم',
                                      content: 'هل تريد إدخال المعلومات الشخصية لإكمال الحجز ؟',
                                      onYesPressed: () async {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                            MyProfileScreen(youDidNotEnterYourInfo: true),
                                        ));
                                      },
                                    );
                                  } else if(result == 'false') {
                                    HomeCareStyle.showSnackBar(
                                      context,
                                      content: sharedPrefsController.getMSG(),
                                      icon: CupertinoIcons.exclamationmark_circle_fill,
                                    );
                                  }
                                },
                                title: value ? HCIndicator() : Text('حجز الخدمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                backgroundColor: HomeCareTheme.primaryColor,
                                width: HomeCareSize.width(context),
                                height: 55.0,
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ValueNotifier<bool> loading = ValueNotifier(false);
}