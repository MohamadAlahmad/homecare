// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/notification_model.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/notification_card.dart';
import 'package:homecare/widgets/re_login_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  int value = 0;
  late PageController pageController;

  // Pagination variable
  int notificationPage = 1;
  bool hasMoreNotifications = true;
  bool isLoadingMoreNotifications = false;

  // Lists to store case
  final List<NotificationModel> notifications = [];

  // Track initial loading state
  bool isInitialLoadingNotifications = true;

  // Scroll controller
  final ScrollController notificationsScrollController = ScrollController();

  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: value);

    // Initialize future
    getNotifications();

    // Add scroll listener
    notificationsScrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    notificationsScrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  // Fetch initial data
  Future<void> getNotifications() async {
    var newCases = await ConnectionController.getNotifications(
      token: sharedPrefsController.getToken(),
      pageNumber: notificationPage,
    );
    if (mounted) {
      setState(() {
        notifications.addAll(newCases);
        hasMoreNotifications = newCases.isNotEmpty;
        isInitialLoadingNotifications = false; // Initial loading is done
      });
    }
  }

  // Scroll listener
  void onScroll() {
    if (notificationsScrollController.position.pixels ==
        notificationsScrollController.position.maxScrollExtent) {
      if (hasMoreNotifications && !isLoadingMoreNotifications) {
        _loadMoreFinishedCases();
      }
    }
  }

  // Load more data
  Future<void> _loadMoreFinishedCases() async {
    if (mounted) {
      setState(() => isLoadingMoreNotifications = true);
    }
    notificationPage++;
    await getNotifications();
    if (mounted) {
      setState(() => isLoadingMoreNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: Platform.isIOS ? 75.0 : 25.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: buildNotifications(),
            ),
            HeaderWidget(context, title: 'الإشعارات'),
          ],
        ),
      ),
    );
  }

  Widget buildNotifications() {
    return RefreshIndicator(
      color: HomeCareTheme.primaryColorBold,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          notifications.clear();
          notificationPage = 1;
          isInitialLoadingNotifications = true; // Show loading indicator
          getNotifications(); // Refresh data
        });
      },
      child: isInitialLoadingNotifications
          ? Center(child: HCCPI(color: HomeCareTheme.primaryColor))
          : sharedPrefsController.sessionTerminated()
          ? ReLoginWidget(context)
          : sharedPrefsController.getMustFillInfo()
          ? MessageWidget(text: 'يجب إكمال البيانات حتى يتم استقبال الإشعارات', mustFillInfo: true)
          : notifications.isEmpty
          ? ListView(
        padding: EdgeInsets.fromLTRB(10.0, HomeCareSize.height(context) * 0.3, 10.0, 10.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [MessageWidget(text: 'لا توجد إشعارات')],
      ) : ListView.builder(
        controller: notificationsScrollController,
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        itemCount: notifications.length + (hasMoreNotifications ? 1 : 0),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            if (notifications.length <= 10) {
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

          var notificationItem = notifications[index];
          return NotificationCard(
            context,
            title: notificationItem.title,
            body: notificationItem.body,
          );
        },
      ),
    );
  }

}
