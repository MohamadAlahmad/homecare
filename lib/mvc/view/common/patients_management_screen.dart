//ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/view/common/add_patient_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/patient_added_by_nurse_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class PatientsManagementScreen extends StatelessWidget {
  PatientsManagementScreen({super.key});

  final SharedPrefsController sharedPrefsController = SharedPrefsController();

  Future<List<Patient>> getPatients() async {
    return await ConnectionController.getPatients(
      token: sharedPrefsController.getToken(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(
              context,
              title: sharedPrefsController.getUserType() == 2 ? 'المرضى الخاصين بي' : 'إدارة المرضى',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.only(top: 50.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder<List<Patient>>(
                      future: getPatients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return HCCPI(color: HomeCareTheme.primaryColorBold, size: 25.0);
                        } else if(sharedPrefsController.sessionTerminated()) {
                          return ReLoginWidget(context);
                        } else if (snapshot.hasError) {
                          return Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
                        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return MessageWidget(text: 'لا يوجد مرضى', small: false, color: HomeCareTheme.primaryColor);
                        } else if (snapshot.hasData) {
                          final listOfPatients = snapshot.data!;
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: listOfPatients.length,
                                  itemBuilder: (context, index) {
                                    final patient = listOfPatients[index];
                                    return PatientAddedByNurseOrPatientCard(
                                      context,
                                      imageUrl: '',
                                      name: '${patient.firstName} ${patient.lastName}',
                                      address: patient.locationDetails,
                                      onDelete: () async {
                                        // Handle patient deletion logic
                                        // Refresh the screen
                                        /*Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PatientsManagementScreen()),
                                        );*/
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 130.0),
                            ],
                          );
                        }
                        return const SizedBox(); // Fallback for unexpected states
                      },
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: sharedPrefsController.isSubUser() ? () {
                    HomeCareStyle.showSnackBar(context, content: 'لا يمكنك إضافة مريض من هذا الحساب', icon: CupertinoIcons.exclamationmark_shield_fill);
                  } : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
                    ).then((_) {
                      // Reload the screen after adding a patient
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PatientsManagementScreen()),
                      );
                    });
                  },
                  title: const Text(
                    'إضافة مريض',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  backgroundColor: HomeCareTheme.primaryColorBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
