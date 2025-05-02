//ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/view/patient/profile_pages/health_record_details.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/finished_screen_card.dart';
import 'package:homecare/widgets/nurse/pending_case_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class NurseReservationsScreen extends StatefulWidget {
  const NurseReservationsScreen({super.key});

  @override
  State<NurseReservationsScreen> createState() =>
      _NurseReservationsScreenState();
}

class _NurseReservationsScreenState extends State<NurseReservationsScreen> {
  int value = 0;
  late PageController pageController;

  // Pagination variables for each tab
  int pendingPage = 1;
  int finishedPage = 1;
  int cancelledPage = 1;
  bool hasMorePending = true;
  bool hasMoreFinished = true;
  bool hasMoreCancelled = true;
  bool isLoadingMorePending = false;
  bool isLoadingMoreFinished = false;
  bool isLoadingMoreCancelled = false;

  // Lists to store cases for each tab
  final List<Case> pendingCases = [];
  final List<Case> finishedCases = [];
  final List<Case> cancelledCases = [];

  // Track initial loading state for each tab
  bool isInitialLoadingPending = true;
  bool isInitialLoadingFinished = true;
  bool isInitialLoadingCancelled = true;

  // Scroll controllers for each tab
  final ScrollController pendingScrollController = ScrollController();
  final ScrollController finishedScrollController = ScrollController();
  final ScrollController cancelledScrollController = ScrollController();

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: value);

    // Initialize futures
    getPendingCases();
    getFinishedCases();
    getCancelledCases();

    // Add scroll listeners
    pendingScrollController.addListener(onPendingScroll);
    finishedScrollController.addListener(onFinishedScroll);
    cancelledScrollController.addListener(_onCancelledScroll);
  }

  @override
  void dispose() {
    pendingScrollController.dispose();
    finishedScrollController.dispose();
    cancelledScrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  // Fetch initial data for each tab
  Future<void> getPendingCases() async {
    var newCases = await ConnectionController.getPendingCases(
      token: sharedPrefsController.getToken(),
      pageNumber: pendingPage,
    );
    if (mounted) {
      setState(() {
        pendingCases.addAll(newCases);
        hasMorePending = newCases.isNotEmpty;
        isInitialLoadingPending = false;
      });
    }
  }

  Future<void> getFinishedCases() async {
    var newCases = await ConnectionController.getFinishedCases(
      token: sharedPrefsController.getToken(),
      pageNumber: finishedPage,
    );
    if (mounted) {
      setState(() {
        finishedCases.addAll(newCases);
        hasMoreFinished = newCases.isNotEmpty;
        isInitialLoadingFinished = false;
      });
    }
  }

  Future<void> getCancelledCases() async {
    var newCases = await ConnectionController.getCancelledCases(
      token: sharedPrefsController.getToken(),
      pageNumber: cancelledPage,
    );
    if (mounted) {
      setState(() {
        cancelledCases.addAll(newCases);
        hasMoreCancelled = newCases.isNotEmpty;
        isInitialLoadingCancelled = false;
      });
    }
  }

  // Scroll listeners for each tab
  void onPendingScroll() {
    if (pendingScrollController.position.pixels ==
        pendingScrollController.position.maxScrollExtent) {
      if (hasMorePending && !isLoadingMorePending) {
        _loadMorePendingCases();
      }
    }
  }

  void onFinishedScroll() {
    if (finishedScrollController.position.pixels ==
        finishedScrollController.position.maxScrollExtent) {
      if (hasMoreFinished && !isLoadingMoreFinished) {
        _loadMoreFinishedCases();
      }
    }
  }

  void _onCancelledScroll() {
    if (cancelledScrollController.position.pixels ==
        cancelledScrollController.position.maxScrollExtent) {
      if (hasMoreCancelled && !isLoadingMoreCancelled) {
        _loadMoreCancelledCases();
      }
    }
  }

  // Load more data for each tab
  Future<void> _loadMorePendingCases() async {
    if (mounted) {
      setState(() => isLoadingMorePending = true);
    }
    pendingPage++;
    await getPendingCases();
    if (mounted) {
      setState(() => isLoadingMorePending = false);
    }
  }

  Future<void> _loadMoreFinishedCases() async {
    if (mounted) {
      setState(() => isLoadingMoreFinished = true);
    }
    finishedPage++;
    await getFinishedCases();
    if (mounted) {
      setState(() => isLoadingMoreFinished = false);
    }
  }

  Future<void> _loadMoreCancelledCases() async {
    if (mounted) {
      setState(() => isLoadingMoreCancelled = true);
    }
    cancelledPage++;
    await getCancelledCases();
    if (mounted) {
      setState(() => isLoadingMoreCancelled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: Platform.isIOS ? 75.0 : 25.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
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
                    'الحجوزات',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    AnimatedToggleSwitch<int>.size(
                      textDirection: TextDirection.rtl,
                      current: value,
                      values: const [0, 1, 2],
                      iconOpacity: 1.0,
                      indicatorSize: const Size.fromWidth(100),
                      iconBuilder: (i) => textBuilder(i, value),
                      borderWidth: 4.0,
                      iconAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        borderColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      styleBuilder: (i) =>
                          ToggleStyle(indicatorColor: colorBuilder(i)),
                      onChanged: (i) {
                        if ((i - value).abs() == 1) {
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
                        } else {
                          pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        setState(() => value = i);
                      },
                    ),
                    SizedBox(
                      height: HomeCareSize.height(context) * 0.77,
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() => value = index);
                        },
                        children: [
                          buildPendingCases(),
                          buildFinishedCases(),
                          buildCancelledCases(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPendingCases() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          pendingCases.clear();
          pendingPage = 1;
          isInitialLoadingPending = true;
          getPendingCases();
        });
      },
      child: isInitialLoadingPending
          ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
          : sharedPrefsController.sessionTerminated()
          ? ReLoginWidget(context)
          : sharedPrefsController.getMustFillInfo()
          ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الحالات', mustFillInfo: true)
          : pendingCases.isEmpty && !isLoadingMorePending
          ? ListView(
        padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.3, 10.0, 10.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [MessageWidget(text: 'لا توجد حالات قادمة')],
      ) : ListView.builder(
        controller: pendingScrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: pendingCases.length + (hasMorePending ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == pendingCases.length) {
            if (pendingCases.length <= 10) {
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

          var caseItem = pendingCases[index];
          return PendingCaseCard(
            context,
            medicalServiceName: caseItem.medicalServiceName,
            patientName: caseItem.patientName,
            visitDate: caseItem.visitDate,
            address: '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}',
            isSpecial: caseItem.specialized,
            onAccept: () {
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
                          title: isLoading
                              ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
                              : Text('قبول الطلب'),
                          content: Text('هل أنت متأكد ؟'),
                          actions: <Widget>[
                            SizedBox(
                              width: 120.0,
                              child: IconButton(
                                onPressed: isLoading ? null : () async {
                                  setStateDialog(() => isLoading = true);

                                  var result = await ConnectionController.acceptCase(
                                    token: sharedPrefsController.getToken(),
                                    caseId: caseItem.id,
                                  );
                                  Navigator.of(dialogContext).pop();
                                  if (sharedPrefsController.sessionTerminated()) {
                                    HomeCareStyle.showReLoginDialog(context);
                                  } else if (result) {
                                    HomeCareStyle.showSnackBar(
                                      context,
                                      success: true,
                                      content: 'تم قبول الطلب بنجاح',
                                      icon: Icons.check_circle,
                                    );

                                    /// ✅ Refresh the UI in the main screen
                                    if (mounted) {
                                      setState(() {
                                        pendingCases.clear();
                                        pendingPage = 1;
                                        isInitialLoadingPending = true;
                                        getPendingCases(); // Fetch new data
                                      });
                                    }
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
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                ),
                                icon: Text(
                                  'قبول الطلب',
                                  style: TextStyle(color: Colors.green, fontSize: 14.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100.0,
                              child: IconButton(
                                onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                                style: IconButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                ),
                                icon: Text(
                                  'تراجع',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14.0,
                                  ),
                                ),
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

          );
        },
      ),
    );
  }

  Widget buildFinishedCases() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          finishedCases.clear();
          finishedPage = 1;
          isInitialLoadingFinished = true;
          getFinishedCases();
        });
      },
      child: isInitialLoadingFinished
          ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
          : sharedPrefsController.sessionTerminated()
          ? ReLoginWidget(context)
          : sharedPrefsController.getMustFillInfo()
          ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الحالات', mustFillInfo: true)
          : finishedCases.isEmpty
          ? ListView(
        padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.3, 10.0, 10.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [MessageWidget(text: 'لا توجد حالات منتهية')],
      )
          : ListView.builder(
        controller: finishedScrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: finishedCases.length + (hasMoreFinished ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == finishedCases.length) {
            if (finishedCases.length <= 10) {
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

          var caseItem = finishedCases[index];
          return FinishedScreenCard(
            context,
            medicalServiceName: caseItem.medicalServiceName,
            patientName: caseItem.patientName,
            visitDate: caseItem.visitDate,
            address: '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}',
            isSpecial: caseItem.specialized,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HealthRecordDetailsScreen(sessionId: caseItem.id)));
            },
          );
        },
      ),
    );
  }

  Widget buildCancelledCases() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          cancelledCases.clear();
          cancelledPage = 1;
          isInitialLoadingCancelled = true;
          getCancelledCases();
        });
      },
      child: isInitialLoadingCancelled
          ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
          : sharedPrefsController.sessionTerminated()
          ? ReLoginWidget(context)
          : sharedPrefsController.getMustFillInfo()
          ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الحالات', mustFillInfo: true)
          : cancelledCases.isEmpty
          ? ListView(
        padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.3, 10.0, 10.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [MessageWidget(text: 'لا توجد حالات ملغاة')],
      )
          : ListView.builder(
        controller: cancelledScrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: cancelledCases.length + (hasMoreCancelled ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == cancelledCases.length) {
            if (cancelledCases.length <= 10) {
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

          var caseItem = cancelledCases[index];
          return FinishedScreenCard(
            context,
            medicalServiceName: caseItem.medicalServiceName,
            patientName: caseItem.patientName,
            visitDate: caseItem.visitDate,
            address: '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}',
            isSpecial: caseItem.specialized,
            onPressed: () {},
          );
        },
      ),
    );
  }

}