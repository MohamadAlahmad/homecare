import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/re_login_widget.dart';

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
        backgroundColor: success! ? Colors.green.withOpacity(0.9) : HomeCareTheme.primaryColor.withOpacity(0.9),
        duration: Duration(milliseconds: duration),
      ));
  }


  static void showCustomDialog(BuildContext context, {
    required String title,
    required String buttonTitle,
    required Widget content,
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
            content: content,
            actions: <Widget>[
              if(!oneButton!) SizedBox(
                width: 120.0,
                child: IconButton(
                  onPressed: () {
                    onYesPressed();
                    Navigator.of(context).pop();
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

  static void showCustomDialog2(BuildContext context, {
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
        bool loading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  if(!oneButton!) SizedBox(
                    width: 120.0,
                    height: 40.0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        onYesPressed();
                        //Navigator.of(context).pop();
                      },
                      style: IconButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: buttonColor!.withValues(alpha: 0.1),
                      ),
                      icon: loading ? HCCPI(color: buttonColor) : Text(buttonTitle, style: TextStyle(color: buttonColor, fontSize: 14.0)),
                    ),
                  ),
                  SizedBox(
                    width: 100.0,
                    height: 40.0,
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
          }
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


}