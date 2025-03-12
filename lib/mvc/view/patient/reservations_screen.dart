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
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  late Future<List<Reservation>> reservationsFuture;

  // Pagination variables
  int currentPage = 1;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  List<Reservation> reservations = [];

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    reservationsFuture = getReservations();
    scrollController.addListener(scrollListener); // Add scroll listener
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Fetch reservations with pagination
  Future<List<Reservation>> getReservations({int pageNumber = 1}) async {
    return await ConnectionController.getOwnReservations(
      token: sharedPrefsController.getToken(),
      pageNumber: pageNumber,
    );
  }

  // Scroll listener to detect end of list
  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (hasMoreData && !isLoadingMore) {
        _loadMoreReservations();
      }
    }
  }

  // Load more reservations
  Future<void> _loadMoreReservations() async {
    setState(() {
      isLoadingMore = true;
    });

    currentPage++;
    var newReservations = await getReservations(pageNumber: currentPage);

    setState(() {
      reservations.addAll(newReservations);
      hasMoreData = newReservations.isNotEmpty; // Check if more data is available
      isLoadingMore = false;
    });
  }

  // Refresh reservations
  Future<void> _refreshReservations() async {
    setState(() {
      reservations.clear(); // Clear the current list
      currentPage = 1; // Reset pagination
      hasMoreData = true; // Reset hasMoreData flag
      reservationsFuture = getReservations(); // Re-fetch data
    });
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
              child: FutureBuilder(
                future: reservationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return HCCPI(color: HomeCareTheme.primaryColor);
                  } else if (sharedPrefsController.sessionTerminated()) {
                    return ReLoginWidget(context);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    String errorMessage = sharedPrefsController.getMSG();
                    return Center(child: MessageWidget(text: errorMessage, medium: true));
                  } else {
                    reservations = snapshot.data ?? [];
                    return buildOwnReservations();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOwnReservations() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: _refreshReservations, // Call the refresh method
      child: ListView.builder(
        controller: scrollController, // Attach the ScrollController
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: reservations.length + (hasMoreData ? 1 : 0), // Add 1 for loading indicator
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == reservations.length) {
            if (reservations.length == 1) {
              return Center();
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HCCPI(color: HomeCareTheme.primaryColor),
                ),
              );
            }
          }

          var caseItem = reservations[index];
          return ReservationCard(
            context,
            id: caseItem.id,
            medicalServiceName: caseItem.medicalServiceName,
            patientName: caseItem.nurseName,
            visitDate: caseItem.visitDate,
            address: '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}',
            onCancel: () {
              bool isLoading = false;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          title: isLoading ? Center(child: HCCPI(color: HomeCareTheme.primaryColor)) : Text('إلغاء الطلب'),
                          content: isLoading ? SizedBox.shrink() : Text('هل أنت متأكد ؟'),
                          actions: <Widget>[
                            if (!isLoading)
                              SizedBox(
                                width: 120.0,
                                child: IconButton(
                                  onPressed: () async {
                                    setStateDialog(() => isLoading = true);

                                    var result = await ConnectionController.cancelCaseByPatient(
                                      token: sharedPrefsController.getToken(),
                                      caseId: caseItem.id,
                                    );
                                    Navigator.of(dialogContext).pop();
                                    if (sharedPrefsController.sessionTerminated()) {
                                      HomeCareStyle.showReLoginDialog(context);
                                    } else if(result) {
                                      HomeCareStyle.showSnackBar(
                                        context,
                                        success: true,
                                        content: 'تم إلغاء الطلب بنجاح',
                                        icon: Icons.check_circle,
                                      );
                                      /// ✅ Refresh the reservations list
                                      setState(() {
                                        reservationsFuture = getReservations();
                                      });
                                    } else {
                                      HomeCareStyle.showSnackBar(
                                        context,
                                        content: sharedPrefsController.getMSG(),
                                        icon: Icons.info_outline,
                                      );
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                                  ),
                                  icon: Text('إلغاء الطلب', style: TextStyle(color: Colors.red, fontSize: 14.0)),
                                ),
                              ),
                            if (!isLoading)
                              SizedBox(
                                width: 100.0,
                                child: IconButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  style: IconButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                                  ),
                                  icon: Text('تراجع', style: TextStyle(color: HomeCareTheme.primaryColorBold, fontSize: 14.0)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            onPressed: () {
              debugPrint(caseItem.id.toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationDetailsScreen(sessionId: caseItem.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}