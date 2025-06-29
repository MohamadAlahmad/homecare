import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/backup_connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/view/patient/profile_pages/health_record_details.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/finished_screen_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  int value = 0;
  late PageController pageController;

  int pageNumber = 1;
  bool hasMoreRecords = true;
  bool isLoadingMore = false;

  final List<Case> activityRecord = [];

  bool isInitialLoadingFinished = true;

  final ScrollController scrollController = ScrollController();

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: value);

    getActivitiesRecords();

    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> getActivitiesRecords() async {
    var newCases = await ConnectionController.getFinishedCases(
      token: sharedPrefsController.getToken(),
      pageNumber: pageNumber,
    );
    if (mounted) {
      setState(() {
        activityRecord.addAll(newCases);
        hasMoreRecords = newCases.isNotEmpty;
        isInitialLoadingFinished = false;
      });
    }
  }

  void onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasMoreRecords && !isLoadingMore) {
        _loadMoreRecords();
      }
    }
  }

  Future<void> _loadMoreRecords() async {
    if (mounted) {
      setState(() => isLoadingMore = true);
    }
    pageNumber++;
    await getActivitiesRecords();
    if (mounted) {
      setState(() => isLoadingMore = false);
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
              HeaderWidget(context, title: 'سجل النشاطات'),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: buildActivitiesRecords(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActivitiesRecords() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        color: HomeCareTheme.primaryColorBold,
        backgroundColor: Colors.white,
        onRefresh: () async {
          setState(() {
            activityRecord.clear();
            pageNumber = 1;
            isInitialLoadingFinished = true;
            getActivitiesRecords();
          });
        },
        child: isInitialLoadingFinished
            ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
            : sharedPrefsController.sessionTerminated()
            ? ReLoginWidget(context)
            : sharedPrefsController.getMustFillInfo()
            ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الحالات', errorOrWarning: true)
            : activityRecord.isEmpty
            ? ListView(
          padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.3, 10.0, 10.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [MessageWidget(text: 'لا توجد حالات منتهية لعرض نشاطاتها')],
        )
            : ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
          itemCount: activityRecord.length + (hasMoreRecords ? 1 : 0),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == activityRecord.length) {
              if (activityRecord.length <= 10) {
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

            var caseItem = activityRecord[index];
            return GeneralCaseCard(
              context,
              medicalServiceName: caseItem.medicalServiceName,
              patientName: caseItem.patientName,
              visitDate: caseItem.visitDate,
              address: '${caseItem.geocodedAddress!.governorateDto.name} ${caseItem.geocodedAddress!.regionDto.name} ${caseItem.geocodedAddress!.details}',
              isSpecial: caseItem.specialized,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HealthRecordDetailsScreen(sessionId: caseItem.id)));
              },
              isForNurseActivityRecord: true,
            );
          },
        ),
      ),
    );
  }

}
