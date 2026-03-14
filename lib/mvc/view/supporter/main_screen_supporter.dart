// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/core/utils/helper_methods.dart';
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
        isInitialLoadingPatients = false;
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
        onLogout: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            HomeCareHelperClass.logoutMethod(context);
          });
        },
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
          isInitialLoadingPatients = true;
          getPatients();
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
                    HomeCareStyle.showHomeCareDialog(
                      context,
                      title: 'تأكيد الحذف',
                      content: 'هل أنت متأكد أنك تريد حذف المريض ؟',
                      onOk: () async {
                        var result = await ConnectionController.deletePatientBySupporter(
                          token: sharedPrefsController.getToken(),
                          id: patient.id,
                        );
                        if (result) {
                          // Reload patients if deletion was successful
                          setState(() {
                            patients.clear();
                            patientsPage = 1;
                            isInitialLoadingPatients = true;
                            getPatients();
                          });
                          HomeCareStyle.showSnackBar(
                            context,
                            success: true,
                            content: 'تم الحذف بنجاح',
                            icon: Icons.check_circle,
                          );
                          Navigator.pop(context);
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
                      width: HomeCareSize.width(context),
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

}