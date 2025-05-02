// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/health_record_brief.dart';
import 'package:homecare/mvc/view/patient/profile_pages/health_record_details.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/health_record_card.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class HealthRecordPatientScreen extends StatefulWidget {
  const HealthRecordPatientScreen({super.key});

  @override
  State<HealthRecordPatientScreen> createState() => _HealthRecordPatientScreenState();
}

class _HealthRecordPatientScreenState extends State<HealthRecordPatientScreen> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  // Pagination variables for health records
  int healthRecordsPage = 1;
  bool hasMoreHealthRecords = true;
  bool isLoadingMoreHealthRecords = false;
  bool isInitialLoadingHealthRecords = true; // Track initial loading state
  final List<HealthRecordBrief> healthRecords = [];
  final ScrollController healthRecordsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getHealthRecords(); // Fetch initial health records

    // Add scroll listener for pagination
    healthRecordsScrollController.addListener(onHealthRecordsScroll);
  }

  @override
  void dispose() {
    healthRecordsScrollController.dispose();
    super.dispose();
  }

  // Fetch health records with pagination
  Future<void> getHealthRecords() async {
    var newRecords = await ConnectionController.getOwnHealthRecords(
      token: sharedPrefsController.getToken(),
      pageNumber: healthRecordsPage,
    );
    if (mounted) {
      setState(() {
        healthRecords.addAll(newRecords);
        hasMoreHealthRecords = newRecords.isNotEmpty;
        isInitialLoadingHealthRecords = false;
      });
    }
  }

  // Scroll listener for health records
  void onHealthRecordsScroll() {
    if (healthRecordsScrollController.position.pixels == healthRecordsScrollController.position.maxScrollExtent) {
      if (hasMoreHealthRecords && !isLoadingMoreHealthRecords) {
        _loadMoreHealthRecords();
      }
    }
  }

  // Load more health records
  Future<void> _loadMoreHealthRecords() async {
    if (mounted) {
      setState(() => isLoadingMoreHealthRecords = true);
    }
    healthRecordsPage++;
    await getHealthRecords();
    if (mounted) {
      setState(() => isLoadingMoreHealthRecords = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              HeaderWidget(context, title: 'السجل الصحي'),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: buildHealthRecords(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHealthRecords() {
    if (isInitialLoadingHealthRecords) {
      return Center(child: HCCPI(color: HomeCareTheme.primaryColor));
    }
    if (sharedPrefsController.sessionTerminated()) {
      return ReLoginWidget(context);
    }
    if (healthRecords.isEmpty) {
      return MessageWidget(text: 'السجل الصحي فارغ !');
    }

    return ListView.builder(
      controller: healthRecordsScrollController,
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
      itemCount: healthRecords.length + (hasMoreHealthRecords ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == healthRecords.length) {
          if (hasMoreHealthRecords && healthRecords.length > 10) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HCCPI(color: HomeCareTheme.primaryColor),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }

        var caseItem = healthRecords[index];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: HealthRecordBriefCard(
            context,
            medicalServiceName: caseItem.medicalServiceName,
            nurseName: caseItem.nurseName,
            visitDate: caseItem.visitDate,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthRecordDetailsScreen(sessionId: caseItem.id),
                ),
              ).then((_) {
                setState(() {
                  healthRecords.clear();
                  healthRecordsPage = 1;
                  isInitialLoadingHealthRecords = true;
                  getHealthRecords();
                });
              });
            },
          ),
        );
      },
    );
  }
}