//ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/login_item.dart';
import 'package:homecare/widgets/profile_image_widget.dart';
import 'package:homecare/widgets/profile_item.dart';

class ProfilePatientScreen extends StatefulWidget {
  const ProfilePatientScreen({super.key});

  @override
  State<ProfilePatientScreen> createState() => _ProfilePatientScreenState();
}

class _ProfilePatientScreenState extends State<ProfilePatientScreen> {
  SharedPrefsController sharedPrefsController = SharedPrefsController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const Text('البروفايل', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25.0),
              ProfileImageWidget(
                sharedPrefsController: sharedPrefsController,
                height: 120.0,
                width: 120.0,
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}', style: TextStyle(fontSize: 18.0)),
              ),
              Container(
                //height: 400.0,
                height: 400.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                ),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Globals.listOfPatientProfileItems.length + 1,
                    itemBuilder: (context, i) {
                      if(i == Globals.listOfPatientProfileItems.length) {
                        return logoutItem(logoutMethod: logoutMethod);
                      } else {
                        return ProfileItem(
                          context,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Globals.listOfPatientProfileItems[i].page));
                          },
                          title: Globals.listOfPatientProfileItems[i].title,
                          iconUrl: Globals.listOfPatientProfileItems[i].iconUrl,
                        );
                      }
                    },
                  separatorBuilder: (context, i) => const Divider(indent: 10.0, endIndent: 10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logoutMethod() {
    HomeCareStyle.showCustomDialog2(
      context,
      title: 'تسجيل الخروج',
      buttonTitle: 'نعم',
      content: 'هل تريد تسجيل الخروج فعلاً من حسابك في التطبيق ؟',
      onYesPressed: () async {
        var result = await ConnectionController.logout(token: sharedPrefsController.getToken());
        if(result) {
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
      },
      buttonColor: Colors.red,
    );
  }

}
