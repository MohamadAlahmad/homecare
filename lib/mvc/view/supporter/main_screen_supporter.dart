// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/view/supporter/personal_profile_screen.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/home_care_page.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/patient_added_by_nurse_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class MainScreenSupporter extends StatefulWidget {
  const MainScreenSupporter({super.key});

  @override
  State<MainScreenSupporter> createState() => _MainScreenSupporterState();
}

class _MainScreenSupporterState extends State<MainScreenSupporter> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  // Pagination variables
  int patientsPage = 1;
  bool hasMorePatients = true;
  bool isLoadingMorePatients = false;
  bool isInitialLoadingPatients = true; // Track initial loading state
  final List<Patient> patients = [];
  final ScrollController patientsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getInfo();
    getPatients(); // Fetch initial patients

    // Add scroll listener for pagination
    patientsScrollController.addListener(onPatientsScroll);
  }

  @override
  void dispose() {
    patientsScrollController.dispose();
    super.dispose();
  }

  // Fetch patients with pagination
  Future<void> getPatients() async {
    var newPatients = await ConnectionController.viewPendingPatients(
      token: sharedPrefsController.getToken(),
      pageNumber: patientsPage,
    );
    if (mounted) {
      setState(() {
        patients.addAll(newPatients);
        hasMorePatients = newPatients.isNotEmpty;
        isInitialLoadingPatients = false; // Initial loading is done
      });
    }
  }

  // Scroll listener for patients
  void onPatientsScroll() {
    if (patientsScrollController.position.pixels == patientsScrollController.position.maxScrollExtent) {
      if (hasMorePatients && !isLoadingMorePatients) {
        _loadMorePatients();
      }
    }
  }

  // Load more patients
  Future<void> _loadMorePatients() async {
    if (mounted) {
      setState(() => isLoadingMorePatients = true);
    }
    patientsPage++;
    await getPatients();
    if (mounted) {
      setState(() => isLoadingMorePatients = false);
    }
  }

  void getInfo() {
    ConnectionController.getSupporterProfileInfo(
      token: sharedPrefsController.getToken(),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeCarePage(
        title: '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}',
        image: Container(
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width * 0.15,
          decoration: const BoxDecoration(
            color: HomeCareTheme.secondaryColor,
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage('assets/images/person1_temp.png'),),
          ),
        ),
        onImagePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonalProfileScreen()),
          );
        },
        onLogout: logoutMethod,
        supporter: true,
        body: sharedPrefsController.sessionTerminated()
            ? ReLoginWidget(context)
            : Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width,
                child: buildPatientsList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientsList() {
    if (isInitialLoadingPatients) {
      return Center(
        child: HCCPI(
          color: HomeCareTheme.primaryColorBold,
          size: 25.0,
        ),
      );
    }
    if (sharedPrefsController.sessionTerminated()) {
      return ReLoginWidget(context);
    }
    if (patients.isEmpty) {
      return MessageWidget(
        text: 'لا يوجد مرضى',
        small: false,
        color: HomeCareTheme.primaryColor,
      );
    }

    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          patients.clear();
          patientsPage = 1;
          isInitialLoadingPatients = true; // Show loading indicator
          getPatients(); // Refresh data
        });
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: patientsScrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: patients.length + (hasMorePatients ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == patients.length) {
                  if (hasMorePatients && patients.length > 10) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HCCPI(
                          color: HomeCareTheme.primaryColorBold,
                          size: 25.0,
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }

                final patient = patients[index];
                return PatientAddedByNurseOrPatientCard(
                  context,
                  imageUrl: '',
                  name: '${patient.firstName} ${patient.lastName}',
                  address: patient.locationDetails,
                  onDelete: () async {
                    HomeCareStyle.showCustomDialog(
                      context,
                      title: 'تأكيد الحذف',
                      buttonTitle: 'حذف',
                      content: 'هل أنت متأكد أنك تريد حذف المريض ؟',
                      onYesPressed: () async {
                        var result = await ConnectionController.deletePatientBySupporter(
                          token: sharedPrefsController.getToken(),
                          id: patient.id,
                        );
                        if (result) {
                          // Reload patients if deletion was successful
                          setState(() {
                            patients.clear(); // Clear current list
                            patientsPage = 1;
                            isInitialLoadingPatients = true; // Show loading indicator
                            getPatients(); // Refresh data
                          });
                          HomeCareStyle.showSnackBar(
                            context,
                            success: true,
                            content: 'تم الحذف بنجاح',
                            icon: Icons.check_circle,
                          );
                        } else {
                          HomeCareStyle.showSnackBar(
                            context,
                            content: sharedPrefsController.getMSG(),
                            icon: Icons.info_outline,
                          );
                        }
                      },
                      buttonColor: Colors.red,
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }

  logoutMethod() {
    HomeCareStyle.showCustomDialog2(
      context,
      title: 'تسجيل الخروج',
      buttonTitle: 'نعم',
      content: 'هل تريد تسجيل الخروج فعلاً من حسابك في التطبيق ؟',
      onYesPressed: () async {
        var result = await ConnectionController.logout(token: sharedPrefsController.getToken());
        if(result) {
          sharedPrefsController.clearData();
          GlobalPageController.registerController = PageController(initialPage: 0);
          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        } else {
          Navigator.pop(context);
          HomeCareStyle.showSnackBar(
            context,
            content: 'فشل تسجيل الخروج',
            icon: CupertinoIcons.exclamationmark_circle_fill,
          );
        }
      },
      buttonColor: Colors.red,
    );
  }

}