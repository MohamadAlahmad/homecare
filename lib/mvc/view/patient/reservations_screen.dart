// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/reservation.dart';
import 'package:homecare/mvc/view/patient/reservation_details.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/patient/reservation_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final SharedPrefsController sharedPrefsController = SharedPrefsController();
  final ScrollController scrollController = ScrollController();

  List<Reservation> reservations = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isInitialLoading = true;
  bool hasMoreData = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialReservations();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialReservations() async {
    try {
      setState(() => isInitialLoading = true);
      final initialReservations = await _fetchReservations(page: 1);
      setState(() {
        reservations = initialReservations;
        hasMoreData = initialReservations.isNotEmpty;
        isInitialLoading = false;
      });
    } catch (e) {
      if(mounted) {
        setState(() {
          isError = true;
          isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreReservations() async {
    if (isLoading || !hasMoreData) return;

    try {
      setState(() => isLoading = true);
      final newReservations = await _fetchReservations(page: currentPage + 1);

      setState(() {
        if (newReservations.isNotEmpty) {
          reservations.addAll(newReservations);
          currentPage++;
        }
        hasMoreData = newReservations.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<List<Reservation>> _fetchReservations({required int page}) async {
    return await ConnectionController.getOwnReservations(
      token: sharedPrefsController.getToken(),
      pageNumber: page,
    );
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMoreData) {
      _loadMoreReservations();
    }
  }

  Future<void> _refreshReservations() async {
    setState(() {
      currentPage = 1;
      hasMoreData = true;
    });
    await _loadInitialReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                10.0,
                Platform.isIOS ? 10.0 : 20.0,
                10.0,
                Platform.isIOS ? 5.0 : 10.0,
              ),
              child: Text(
                'حجوزاتي',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isInitialLoading) {
      return Center(child: HCCPI(color: HomeCareTheme.primaryColor));
    }

    if (sharedPrefsController.sessionTerminated()) {
      return ReLoginWidget(context);
    }

    if (isError) {
      return MessageWidget(text: 'حدث خطأ أثناء جلب البيانات', errorOrWarning: true);
    }

    if (reservations.isEmpty) {
      String errorMessage = sharedPrefsController.getMSG();
      return Center(child: MessageWidget(text: errorMessage, medium: true));
    }

    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: _refreshReservations,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: reservations.length + (hasMoreData ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index >= reservations.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: isLoading
                    ? HCCPI(color: HomeCareTheme.primaryColor)
                    : const SizedBox.shrink(),
              ),
            );
          }

          final reservation = reservations[index];
          return ReservationCard(
            context,
            id: reservation.id,
            medicalServiceName: reservation.medicalServiceName,
            patientName: reservation.patientName,
            nurseName: reservation.nurseName,
            visitDate: reservation.visitDate,
            address: '${reservation.geocodedAddress?.governorateDto.name ?? ''} '
                '${reservation.geocodedAddress?.regionDto.name ?? ''} '
                '${reservation.geocodedAddress?.details ?? ''}',
            onCancel: () => _showCancelDialog(reservation),
            onPressed: () => _navigateToDetails(reservation),
          );
        },
      ),
    );
  }

  void _showCancelDialog(Reservation reservation) {
    HomeCareStyle.showHomeCareDialog(
      context,
      title: 'إلغاء الطلب',
      content: 'هل أنت متأكد ؟',
      onOk: () async {
        final result = await ConnectionController.cancelCaseByPatient(
          token: sharedPrefsController.getToken(),
          caseId: reservation.id,
        );

        Navigator.of(context).pop();

        if (sharedPrefsController.sessionTerminated()) {
          HomeCareStyle.showReLoginDialog(context);
        } else if (result) {
          HomeCareStyle.showSnackBar(
            context,
            success: true,
            content: 'تم إلغاء الطلب بنجاح',
            icon: Icons.check_circle,
          );
          await _refreshReservations();
        } else {
          HomeCareStyle.showSnackBar(
            context,
            content: sharedPrefsController.getMSG(),
            icon: Icons.info_outline,
          );
        }
      },
      onOkColor: HomeCareTheme.redColor,
      onCancelColor: HomeCareTheme.primaryColor,
    );
  }

  void _navigateToDetails(Reservation reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsScreen(sessionId: reservation.id),
      ),
    );
  }
}