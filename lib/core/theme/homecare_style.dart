import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/re_login_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCareStyle {

  static void showSnackBar(BuildContext context, {required String content, bool? success = false, Color foregroundColor = Colors.white, required IconData icon, int duration = 3000}) {
    if (!context.mounted) return; // Check if the context is still mounted
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: AutoSizeText(content, style: TextStyle(color: foregroundColor, fontSize: 14.0), textAlign: TextAlign.center)),
            Icon(icon, color: Colors.white),
          ],
        ),
        backgroundColor: success! ? Colors.green.withValues(alpha: 0.9) : HomeCareTheme.primaryColor.withValues(alpha: 0.9),
        duration: Duration(milliseconds: duration),
      ));
  }

  static void showHomeCareDialog(BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onOk,
    String onOkTitle = 'تأكيد',
    String onCancelTitle = 'تراجع',
    Color onOkColor = HomeCareTheme.primaryColorBoldExtra,
    Color onCancelColor = HomeCareTheme.redColor,
    bool? oneButton = false,
    double? width,
    Image? icon,
    Color iconColor = HomeCareTheme.primaryColor,
  }) {
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20.0),
          child: Container(
            width: width ?? MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20.0),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isLoading
                          ? Center(child: HCCPI(color: onOkColor))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 30.0,
                                child: icon ?? Image.asset('assets/icons/info.png', color: iconColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 30.0),
                            ],
                          ),
                      isLoading ? SizedBox.shrink() : const Divider(),
                      isLoading ? SizedBox.shrink() : const SizedBox(height: 20),
                      isLoading ? SizedBox.shrink() : Text(content, style: TextStyle(fontSize: 16.0)),
                      isLoading ? SizedBox.shrink() : const SizedBox(height: 20),
                      if (!isLoading)
                        Row(
                          children: [
                            if(!oneButton!) SizedBox(
                              width: 120.0,
                              child: IconButton(
                                onPressed: () async {
                                  setStateDialog(() => isLoading = true);
                                  onOk();
                                },
                                style: IconButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: onOkColor.withValues(alpha: 0.1),
                                ),
                                icon: Text(onOkTitle, style: TextStyle(color: onOkColor, fontSize: 14.0, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 100.0,
                              child: IconButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                style: IconButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: onCancelColor.withValues(alpha: 0.1),
                                ),
                                icon: Text(onCancelTitle, style: TextStyle(color: onCancelColor, fontSize: 14.0)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: HCCPI(color: Colors.white, size: 30.0),
        );
      },
    );
  }

  static void showInfoRequiredDialog(BuildContext context, {
    required String title,
    required String buttonTitle,
    required String content,
    Color? buttonColor = Colors.green,
    Color? backButtonColor = HomeCareTheme.primaryColor,
    Color? backButtonTextColor = HomeCareTheme.primaryColorBold,
    required VoidCallback onYesPressed,
    bool? oneButton = false,
    VoidCallback? onNoPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              if(!oneButton!) SizedBox(
                width: 120.0,
                child: IconButton(
                  onPressed: () {
                    onYesPressed();
                  },
                  style: IconButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: buttonColor!.withValues(alpha: 0.1),
                  ),
                  icon: Text(buttonTitle, style: TextStyle(color: buttonColor, fontSize: 14.0)),
                ),
              ),
              SizedBox(
                width: 100.0,
                child: IconButton(
                  onPressed: () {
                    if (onNoPressed != null) {
                      onNoPressed();
                    }
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: backButtonColor!.withValues(alpha: 0.1),
                  ),
                  icon: Text('تراجع', style: TextStyle(color: backButtonTextColor, fontSize: 14.0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showReLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              width: HomeCareSize.width(context),
              height: 350.0,
              child: ReLoginWidget(context),
            ),
          ),
        );
      },
    );
  }

  static void showVersionDialog(BuildContext context, {required String downloadUrl}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              width: HomeCareSize.width(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.system_update, size: 100.0, color: HomeCareTheme.primaryColor),
                  const SizedBox(height: 10.0),
                  Text('تتوفر نسخة جديدة من التطبيق', style: TextStyle(fontSize: 20.0, color: Colors.grey[700]), textAlign: TextAlign.center),
                  const SizedBox(height: 10.0),
                  Text('''اضغط فوق زر "التنزيل" لتحديث النسخة''', style: TextStyle(fontSize: 20.0, color: Colors.grey[700]), textAlign: TextAlign.center),
                  const SizedBox(height: 10.0),
                  CustomButton(
                    onPressed: () {
                      launchURL(url: downloadUrl);
                    },
                    title: Text('التنزيل', style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold)),
                    width: 120.0,
                    backgroundColor: HomeCareTheme.primaryColor,

                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  static Future<void> launchURL({required String url}) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }
}