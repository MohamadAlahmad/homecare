//ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/view/nurse/home_nurse.dart';
import 'package:homecare/mvc/view/nurse/visit_details_nurse_screen.dart';
import 'package:homecare/mvc/view/patient/home_patient.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/home_care_page.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/accepted_case_card.dart';
import 'package:homecare/widgets/patient_brief_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class MainScreenNurse extends StatefulWidget {
  const MainScreenNurse({super.key});

  @override
  State<MainScreenNurse> createState() => _MainScreenNurseState();
}

class _MainScreenNurseState extends State<MainScreenNurse> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  List<Patient> listOfPatients = [];
  bool empty = false;

  // Pagination variables for accepted cases
  int acceptedPage = 1;
  bool hasMoreAccepted = true;
  bool isLoadingMoreAccepted = false;
  bool isInitialLoadingAccepted = true; // Track initial loading state
  final List<Case> acceptedCases = [];
  final ScrollController acceptedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPatients();
    getAcceptedCases(); // Fetch initial accepted cases
    debugPrint('Is Nurse Session Terminated ==> ${sharedPrefsController.sessionTerminated()}');

    // Add scroll listener for pagination
    acceptedScrollController.addListener(onAcceptedScroll);
  }

  @override
  void dispose() {
    acceptedScrollController.dispose();
    super.dispose();
  }

  // Fetch patients
  getPatients() async {
    var patients = await ConnectionController.getPatients(token: sharedPrefsController.getToken());
    if(mounted) {
      setState(() {
        listOfPatients = patients;
        if (listOfPatients.isEmpty) {
          empty = true;
        }
      });
    }
  }

  // Fetch accepted cases with pagination
  Future<void> getAcceptedCases() async {
    var newCases = await ConnectionController.getAcceptedCases(
      token: sharedPrefsController.getToken(),
      pageNumber: acceptedPage,
    );
    if (mounted) {
      setState(() {
        acceptedCases.addAll(newCases);
        hasMoreAccepted = newCases.isNotEmpty;
        isInitialLoadingAccepted = false; // Initial loading is done
      });
    }
  }

  // Scroll listener for accepted cases
  void onAcceptedScroll() {
    if (acceptedScrollController.position.pixels == acceptedScrollController.position.maxScrollExtent) {
      if (hasMoreAccepted && !isLoadingMoreAccepted) {
        _loadMoreAcceptedCases();
      }
    }
  }

  // Load more accepted cases
  Future<void> _loadMoreAcceptedCases() async {
    if (mounted) {
      setState(() => isLoadingMoreAccepted = true);
    }
    acceptedPage++;
    await getAcceptedCases();
    if (mounted) {
      setState(() => isLoadingMoreAccepted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeCarePage(
      title: '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}',
      image: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width * 0.15,
        decoration: const BoxDecoration(
          color: HomeCareTheme.secondaryColor,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/nurse_temp.png'),
          ),
        ),
      ),
      onImagePressed: () {
        pageNurseController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
        );
      },
      listOfPatients: empty && listOfPatients.isEmpty
          ? MessageWidget(text: 'لا يوجد مرضى', small: true, color: Colors.white)
          : listOfPatients.isEmpty
          ? HCCPI()
          : ListView.builder(
        itemCount: listOfPatients.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return PatientBriefCard(
            context,
            name: '${listOfPatients[index].firstName} ${listOfPatients[index].lastName}',
            address: listOfPatients[index].locationDetails.isEmpty
                ? '(العنوان فارغ)'
                : listOfPatients[index].locationDetails,
            onPressed: () {
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
                              : Text('الانتقال إلى حساب المريض'),
                          content: isLoading ? SizedBox.shrink() : Text('أنت على وشك فتح التطبيق كحساب مريض !'),
                          actions: <Widget>[
                            if (!isLoading)
                              SizedBox(
                                width: 120.0,
                                child: IconButton(
                                  onPressed: () async {
                                    setStateDialog(() => isLoading = true);
                                    var result = await ConnectionController.switchAccount(
                                      token: sharedPrefsController.getToken(),
                                      patientId: listOfPatients[index].id,
                                    );
                                    Navigator.of(dialogContext).pop();
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
                                      debugPrint('ERROR __________________________');
                                      HomeCareStyle.showSnackBar(
                                        context,
                                        content: 'فشل تحويل الحساب ، حاول لاحقاً',
                                        icon: CupertinoIcons.exclamationmark_triangle_fill,
                                      );
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                                  ),
                                  icon: Text('تأكيد', style: TextStyle(color: Colors.green, fontSize: 14.0)),
                                ),
                              ),
                            if (!isLoading)
                              SizedBox(
                                width: 100.0,
                                child: IconButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  style: IconButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                                  ),
                                  icon: Text('تراجع', style: TextStyle(color: Colors.red, fontSize: 14.0)),
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, Platform.isIOS ? 10.0 : 20.0, 10.0, Platform.isIOS ? 5.0 : 10.0),
              child: Text(
                'الحالات الجارية',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
              ),
            ),
            Expanded(
              child: buildAcceptedCases(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAcceptedCases() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          acceptedCases.clear(); // Clear current list of cases
          acceptedPage = 1;
          isInitialLoadingAccepted = true; // Show loading indicator
          getAcceptedCases(); // Refresh data
        });
      },
      child: isInitialLoadingAccepted
          ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
          : sharedPrefsController.sessionTerminated()
          ? ReLoginWidget(context)
          : sharedPrefsController.getMustFillInfo()
          ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الحالات', mustFillInfo: true)
          : acceptedCases.isEmpty
          ? ListView(
        padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.2, 10.0, 10.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          MessageWidget(text: 'لا توجد حالات مقبولة'),
        ],
      ) : ListView.builder(
        controller: acceptedScrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: acceptedCases.length + (hasMoreAccepted ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == acceptedCases.length) {
            if (hasMoreAccepted && acceptedCases.length > 10) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HCCPI(color: HomeCareTheme.primaryColor),
                ),
              );
            } else {
              return SizedBox.shrink(); // No spinner if no more data
            }
          }

          var caseItem = acceptedCases[index];
          return AcceptedCaseCard(
            context,
            id: caseItem.id,
            medicalServiceName: caseItem.medicalServiceName,
            patientName: caseItem.patientName,
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
                          title: isLoading
                              ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
                              : Text('إلغاء الطلب'),
                          content: isLoading ? SizedBox.shrink() : Text('هل أنت متأكد ؟'),
                          actions: <Widget>[
                            if (!isLoading)
                              SizedBox(
                                width: 120.0,
                                child: IconButton(
                                  onPressed: () async {
                                    setStateDialog(() => isLoading = true);
                                    var result = await ConnectionController.cancelCase(
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
                                        content: 'تم إلغاء الطلب بنجاح',
                                        icon: Icons.check_circle,
                                      );

                                      setState(() {
                                        acceptedCases.clear(); // Clear current list
                                        acceptedPage = 1;
                                        isInitialLoadingAccepted = true; // Show loading indicator
                                        getAcceptedCases(); // Refresh data
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitDetailsNurseScreen(
                    patientId: caseItem.patientId,
                    servicePrice: caseItem.price,
                    serviceName: caseItem.medicalServiceName,
                    patientName: caseItem.patientName,
                    location: caseItem.geocodedAddress!.details.isNotEmpty
                        ? '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}'
                        : '(العنوان فارغ)',
                    sessionId: caseItem.id,
                  ),
                ),
              ).then((_) {
                setState(() {
                  acceptedCases.clear(); // Clear current list
                  acceptedPage = 1;
                  isInitialLoadingAccepted = true; // Show loading indicator
                  getAcceptedCases(); // Refresh data
                });
              });
            },
            patientPhoneNumber: caseItem.patientPhoneNumber!,
          );
        },
      ),
    );
  }

}