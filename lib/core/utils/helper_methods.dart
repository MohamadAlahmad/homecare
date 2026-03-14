// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';

class HomeCareHelperClass {

  static SharedPrefsController sharedPrefsController = SharedPrefsController();

  static void showMobileCountries(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25.0),
          height: MediaQuery.of(context).size.height * 0.2,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  leading: GlobalCountries.countriesPhone[0].flag,
                  title: Text(GlobalCountries.countriesPhone[0].name),
                  trailing: Text(
                    GlobalCountries.countriesPhone[0].dialCode,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String?> showOptionsMenu(BuildContext context) {
    return showMenu<String>(
      context: context,
      color: Colors.white,
      position: RelativeRect.fromLTRB(
          0.0,
          MediaQuery.of(context).size.height * 0.12,
          40.0,
          100
      ),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: HomeCareTheme.secondaryColorBold.withValues(alpha: 0.2)),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'التسجيل كـ مريض',
          height: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ مريض',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: HomeCareTheme.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.personal_injury_rounded,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Custom divider with padding
        PopupMenuItem<String>(
          enabled: false,
          height: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300], // Use your theme color if preferred
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'التسجيل كـ ممرّض',
          height: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ ممرّض',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: HomeCareTheme.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.medical_services_rounded,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Second custom divider with padding
        PopupMenuItem<String>(
          enabled: false,
          height: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Same padding as above
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300], // Match the first divider
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'التسجيل كـ داعم',
          height: 48,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ داعم',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: HomeCareTheme.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.handshake_rounded,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /*static Future<String?> showOptionsMenu(BuildContext context) {
    return showCupertinoModalPopup<String>(
      context: context,
      semanticsDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'خيارات التسجيل',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: HomeCareTheme.blackColor,
            fontFamily: 'Tajawal',
          ),
        ),
        message: Text(
          'اختر نوع الحساب الذي تريد إنشاءه',
          style: TextStyle(
            fontSize: 14,
            color: HomeCareTheme.blackColor.withOpacity(0.7),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'التسجيل كـ مريض'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ مريض',
                  style: TextStyle(
                    fontSize: 16,
                    color: HomeCareTheme.primaryColorBold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.personal_injury,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'التسجيل كـ ممرّض'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ ممرّض',
                  style: TextStyle(
                    fontSize: 16,
                    color: HomeCareTheme.primaryColorBold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.medical_services,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'التسجيل كـ داعم'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'التسجيل كـ داعم',
                  style: TextStyle(
                    fontSize: 16,
                    color: HomeCareTheme.primaryColorBold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.volunteer_activism,
                  color: HomeCareTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HomeCareTheme.redColor,
            ),
          ),
        ),
      ),
    );
  }*/

  static logoutMethod(BuildContext context) {
    HomeCareStyle.showHomeCareDialog(
      context,
      title: 'تسجيل الخروج',
      onOkTitle: 'نعم',
      content: 'هل تريد تسجيل الخروج فعلاً من حسابك في التطبيق ؟',
      onOk: () async {
        try {
          var result = await ConnectionController.logout(token: sharedPrefsController.getToken());

          if (result) {
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
        } catch (e) {
          Navigator.pop(context);
          HomeCareStyle.showSnackBar(
            context,
            content: 'لا يوجد اتصال بالإنترنت',
            icon: CupertinoIcons.wifi_exclamationmark,
          );
        }
      },
      onOkColor: HomeCareTheme.redColor,
      onCancelColor: HomeCareTheme.primaryColor,
      iconColor: Colors.red,
    );
  }

  static checkVersion(BuildContext context) async {
    var checkVersionObject = await ConnectionController.checkVersion(token: sharedPrefsController.getToken());
    if(checkVersionObject.latestVersion != Globals.appVersion) {
      HomeCareStyle.showVersionDialog(context, downloadUrl: checkVersionObject.downloadUrl);
    }
  }

}