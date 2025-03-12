import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';

class HomeCareHelperClass {

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
                    //setState(() {
                      //selectedMobileIndex = 0;
                      //selectedMobileDialCode = GlobalCountries.countriesPhone[0].dialCode;
                      //print('Selected PHONE Code IS ::: $selectedPhoneDialCode');
                    //});
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
      color: HomeCareTheme.secondaryColor,
      position: RelativeRect.fromLTRB(0.0, MediaQuery.of(context).size.height * 0.12, 40.0, 100),
      elevation: 10.0,
      items: [
        const PopupMenuItem<String>(
          value: 'التسجيل كـ مريض',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('التسجيل كـ مريض', style: TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'التسجيل كـ ممرّض',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('التسجيل كـ ممرّض', style: TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'التسجيل كـ داعم',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('التسجيل كـ داعم', style: TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
      ],
    );
  }

}