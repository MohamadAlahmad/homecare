import 'package:flutter/material.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/local/main_service.dart';
import 'package:homecare/mvc/model/local/country.dart';
import 'package:homecare/mvc/model/local/profile_item.dart';
import 'package:homecare/mvc/view/nurse/account_management_pages/account_details_page.dart';
import 'package:homecare/mvc/view/nurse/account_management_pages/activity_log_screen.dart';
import 'package:homecare/mvc/view/nurse/account_management_pages/my_points_screen.dart';
import 'package:homecare/mvc/view/patient/main_services/care_services/care_services_screen.dart';
import 'package:homecare/mvc/view/patient/main_services/labs_services/labs_services_screen.dart';
import 'package:homecare/mvc/view/patient/main_services/nursing_services/nursing_services_screen.dart';
import 'package:homecare/mvc/view/patient/main_services/nutrition_articles_screen/nutrition_articles_screen.dart';
import 'package:homecare/mvc/view/patient/profile_pages/customers_service.dart';
import 'package:homecare/mvc/view/patient/profile_pages/health_record_patient_screen.dart';
import 'package:homecare/mvc/view/patient/profile_pages/my_profile_screen.dart';
import 'package:homecare/mvc/view/common/patients_management_screen.dart';
import 'package:homecare/mvc/view/register/privacy_policy_screen.dart';

class GlobalPageController {
  static PageController registerController = PageController(initialPage: SharedPrefsController().reachToInfoPage() ? 3 :SharedPrefsController().amIWaitingSecondCode() ? 4 : 0);
}

class GlobalCountries {
  static List<Country> countriesPhone = [
    //Country(name: 'سوريا', flag: Image.asset('assets/images/sy.png', scale: 2.5), dialCode: '+963', code: 'sy', maxNumber: 9),
    //Country(name: 'UAE', flag: Image.asset('assets/images/uae.png', scale: 2.5), dialCode: '971', code: 'ue', maxNumber: 9),
  ];
}

class Globals {
  static int adminUserType = 1;
  static int patientUserType = 2;
  static int nurseUserTpe = 3;
  static int supporterUserType = 4;
  static String appVersion = '1.0.0';

  static List<MainService> listOfServices = [
    MainService(
      id: 1,
      name: 'خدمة الرعاية',
      isActive: true,
      image: 'assets/services/1_1.png',
      page: const CareServicesScreen(),
    ),
    MainService(
      id: 2,
      name: 'خدمة التمريض',
      isActive: true,
      image: 'assets/services/2_2.png',
      page: const NursingServicesScreen(),
    ),
    MainService(
      id: 4,
      name: 'التغذية الصحية',
      isActive: true,
      image: 'assets/services/3_3.png',
      page: const NutritionArticlesScreen(),
    ),
    MainService(
      id: 6,
      name: 'خدمات المخبر',
      isActive: true,
      image: 'assets/services/6_6.png',
      page: const LabsServicesScreen(),
    ),
    MainService(
      id: 3,
      name: 'علاج فيزيائي',
      isActive: false,
      image: 'assets/services/4_4.png',
      page: const Center(),
    ),
    MainService(
      id: 5,
      name: 'زيارة طبيب',
      isActive: false,
      image: 'assets/services/5_5.png',
      page: const Center(),
    ),
  ];

  static List<ProfileItem> listOfPatientProfileItems = [
    ProfileItem(
      title: 'تعديل المعلومات الشخصية',
      iconUrl: 'assets/icons/user.png',
      page: const MyProfileScreen(
        youDidNotEnterYourInfo: false,
        forBookingThroughPackage: false,
      ),
    ),
    /*ProfileItem(
      title: 'الموقع',
      iconUrl: 'assets/icons/location.png',
      page: const Center(),
    ),*/
    ProfileItem(
      title: 'السجل الصحي',
      iconUrl: 'assets/icons/document.png',
      page: const HealthRecordPatientScreen(),
    ),
    ProfileItem(
      title: 'المرضى الخاصين بي',
      iconUrl: 'assets/icons/users.png',
      page: PatientsManagementScreen(),
    ),
    ProfileItem(
      title: 'خدمة العملاء',
      iconUrl: 'assets/icons/support.png',
      page: CustomersService(),
    ),
    ProfileItem(
      title: 'سياسة الخصوصية والاستخدام',
      iconUrl: 'assets/icons/insurance.png',
      page: PrivacyPolicyScreen(),
    ),
  ];

  static List<ProfileItem> listOfNurseProfileItems = [
    ProfileItem(
      title: 'تعديل المعلومات الشخصية',
      iconUrl: 'assets/icons/user.png',
      page: const NurseAccountDetailsPage(),
    ),
    ProfileItem(
      title: 'سجل النشاطات',
      iconUrl: 'assets/icons/document.png',
      page: const ActivityLogScreen(),
    ),
    /*ProfileItem(
      title: 'نقاطي',
      iconUrl: 'assets/icons/star.png',
      page: const MyPointsScreen(),
    ),*/
    ProfileItem(
      title: 'تقييمي',
      iconUrl: 'assets/icons/star.png',
      page: PointsScreen(
        stars: SharedPrefsController().getRate(),
        //points: SharedPrefsController().getPoints(),
      ),
    ),
    ProfileItem(
      title: 'إدارة المرضى',
      iconUrl: 'assets/icons/category.png',
      page: PatientsManagementScreen(),
    ),
    ProfileItem(
      title: 'سياسة الخصوصية والاستخدام',
      iconUrl: 'assets/icons/insurance.png',
      page: PrivacyPolicyScreen(),
    ),
  ];

}

class HomeCareSize {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
}


Color colorBuilder(int value) => switch (value) {
  0 => Colors.lightBlueAccent,
  1 => Colors.green,
  _ => Colors.red,
};
Widget textBuilder(int toggleValue, int currentValue) {
  // Determine if the current toggleValue is selected.
  final isSelected = toggleValue == currentValue;
  return Container(
    height: 30.0,
    width: 70.0,
    decoration: BoxDecoration(
      // Use a constant border color based on toggleValue.
      border: Border.all(
        color: isSelected ? Colors.transparent : colorBuilder(toggleValue),
      ),
      borderRadius: BorderRadius.circular(8.0),
      color: isSelected ? colorBuilder(toggleValue) : Colors.transparent, // Fill with color if selected.
    ),
    child: Center(
      child: Text(
        textByValue(toggleValue),
        style: TextStyle(
          fontSize: 14.0,
          color: isSelected ? Colors.white : Colors.black, // White for selected, black for unselected.
        ),
      ),
    ),
  );
}
String textByValue(int? value) => switch (value) {
  0 => 'القادمة',
  1 => 'المنتهية',
  _ => 'الملغاة',
};
