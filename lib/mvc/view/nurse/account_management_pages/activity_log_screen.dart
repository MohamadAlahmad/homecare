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

  int finishedPage = 1;
  bool hasMoreFinished = true;
  bool isLoadingMoreFinished = false;

  final List<Case> finishedCases = [];

  bool isInitialLoadingFinished = true;

  final ScrollController finishedScrollController = ScrollController();

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: value);

    getFinishedCases();

    finishedScrollController.addListener(onFinishedScroll);
  }

  @override
  void dispose() {
    finishedScrollController.dispose();
    pageController.dispose();
    super.dispose();
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

  void onFinishedScroll() {
    if (finishedScrollController.position.pixels ==
        finishedScrollController.position.maxScrollExtent) {
      if (hasMoreFinished && !isLoadingMoreFinished) {
        _loadMoreFinishedCases();
      }
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
                child: buildFinishedCases(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFinishedCases() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
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
      ),
    );
  }

}
