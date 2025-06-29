import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/health_record_model.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/patient/details_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final int sessionId;
  const ReservationDetailsScreen({super.key, required this.sessionId});

  @override
  State<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  late Future<HealthRecordModel?> futureReservation;

  Future<HealthRecordModel?> getReservationDetails({required int id}) async {
    return await ConnectionController.getSessionById(
      token: sharedPrefsController.getToken(),
      sessionId: id,
    );
  }

  @override
  void initState() {
    futureReservation = getReservationDetails(id: widget.sessionId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(context, title: 'تفاصيل الطلب'),
            Container(
              padding: EdgeInsets.only(top: 60.0, left: 10.0, right: 10.0, bottom: HomeCareSize.height(context) * 0.18),
              child: buildReservationDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReservationDetails() {
    return FutureBuilder<HealthRecordModel?>(
      future: futureReservation,
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
          var reservation = snapshot.data!;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: DetailsCardExtended(
              visitDateTime: reservation.visitDate,
              city: reservation.geocodedAddress!.governorateDto.name,
              region: reservation.geocodedAddress!.regionDto.name,
              details: reservation.geocodedAddress!.details,
              hours: reservation.visitDurationInHours.toString(),
            ),
          );
        }
      },
    );
  }

}