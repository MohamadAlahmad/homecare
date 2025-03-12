// ignore_for_file: non_constant_identifier_names, avoid_print


import 'package:get/get.dart';
//import 'package:image_picker/image_picker.dart';
///import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsController extends GetxController {
  static final SharedPrefsController initial = SharedPrefsController._internal();
  factory SharedPrefsController() {
    return initial;
  }
  SharedPrefsController._internal();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences prefs;
  // To saving Dark/Light Mode
  String _darkModeEnabled = 'false';

  init() async {
    prefs = await _prefs;
    //_imagePath = prefs.getString('profileImagePath');
  }
  SharedPreferences get getInstance => prefs;
  //****************************************************************************
  // Method to save mode, dark or light
  saveMode(String enableDarkMode) {
    _darkModeEnabled = enableDarkMode;
    prefs.setString('darkMode', _darkModeEnabled);
    print('WE SAVE NOW : DARK ? $_darkModeEnabled');
    update();
  }
  // Method to get mode , dark or light
  String getMode() {
    _darkModeEnabled = prefs.getString('darkMode') ?? 'false';
    print('CURRENT MODE : DARK ? $_darkModeEnabled');
    return _darkModeEnabled;
  }

  //****************************************************************************
  void saveLoggedValue({required bool logged}) {
    prefs.setBool('logged', logged);
    update();
  }
  bool getLoggedValue() {
    return prefs.getBool('logged') ?? false;
  }

  //****************************************************************************
  void saveMSG({required String message}) {
    prefs.setString('msg', message);
    update();
  }
  String getMSG() {
    return prefs.getString('msg') ?? '';
  }

  //****************************************************************************
  /*void saveIAmWaitingCode({required bool flag}) {
    prefs.setBool('IAmWaitingCode', flag);
    update();
  }
  bool amIWaitingCode() {
    return prefs.getBool('IAmWaitingCode') ?? false;
  }*/

  //****************************************************************************
  void saveIAmWaitingSecondCode({required bool flag}) {
    prefs.setBool('IAmWaitingSecondCode', flag);
    update();
  }
  bool amIWaitingSecondCode() {
    return prefs.getBool('IAmWaitingSecondCode') ?? false;
  }

  //****************************************************************************
  void setReachToInfoPage({required bool flag}) {
    prefs.setBool('reachToInfoPage', flag);
    update();
  }
  bool reachToInfoPage() {
    return prefs.getBool('reachToInfoPage') ?? false;
  }

  //****************************************************************************
  void setMustFillInfo({required bool flag}) {
    prefs.setBool('must_fill_info', flag);
    update();
  }
  bool getMustFillInfo() {
    return prefs.getBool('must_fill_info') ?? false;
  }

  //****************************************************************************
  void saveToken({required String token}) {
    prefs.setString('token', token);
    update();
  }
  String getToken() {
    return prefs.getString('token') ?? '';
  }

  //****************************************************************************
  // Save User FCM Token , either after login of after registration
  void saveUserFCMToken({String? fcmToken}) {
    if (fcmToken != null) {
      prefs.setString('user_fcm_token', fcmToken);
    }
    update();
  }

  // Method to get user fcm token
  String getUserFCMToken() {
    return prefs.getString('user_fcm_token') ?? '';
  }
  // Method to delete user fcm token
  void deleteUserFCMToken() {
    prefs.remove('user_fcm_token');
    print('Old FCM Token Deleted');
    update();
  }

  //****************************************************************************
  void saveMainUserToken({required String token}) {
    prefs.setString('main_token', token);
    update();
  }
  String getMainUserToken() {
    return prefs.getString('main_token') ?? '';
  }

  //****************************************************************************
  void saveMainUserType({required int type}) {
    prefs.setInt('main_type', type);
    update();
  }
  int getMainUserType() {
    return prefs.getInt('main_type') ?? -1;
  }

  //****************************************************************************
  void saveMobileNumber({required String mobile}) {
    prefs.setString('mobile', mobile);
    update();
  }
  String getMobileNumber() {
    return prefs.getString('mobile') ?? '';
  }

  //****************************************************************************
  void saveUserType({required int type}) {
    prefs.setInt('type', type);
    update();
  }
  int getUserType() {
    return prefs.getInt('type') ?? -1;
  }

  //****************************************************************************
  void setIsSubUser({required bool value}) {
    prefs.setBool('isSubUser', value);
    update();
  }
  bool isSubUser() {
    return prefs.getBool('isSubUser') ?? false;
  }

  //****************************************************************************
  void saveFullName({required String fullName}) {
    prefs.setString('fullName', fullName);
    update();
  }
  String getFullName() {
    return prefs.getString('fullName') ?? 'اسم المستخدم';
  }

  //****************************************************************************
  void saveFirstName({required String firstName}) {
    prefs.setString('firstName', firstName);
    update();
  }
  String getFirstName() {
    return prefs.getString('firstName') ?? '';
  }

  //****************************************************************************
  /*void savePoints({required int points}) {
    prefs.setInt('points', points);
    update();
  }
  int getPoints() {
    return prefs.getInt('points') ?? 0;
  }*/

  //****************************************************************************
  void saveRate({required int rate}) {
    prefs.setInt('rate', rate);
    update();
  }
  int getRate() {
    return prefs.getInt('rate') ?? 0;
  }

  //****************************************************************************
  void saveLastName({required String lastName}) {
    prefs.setString('lastName', lastName);
    update();
  }
  String getLastName() {
    return prefs.getString('lastName') ?? '';
  }

  //****************************************************************************
  // 1: => Male, 2: => Female
  void saveGender({required int gender}) {
    prefs.setInt('gender', gender);
    update();
  }
  int getGender() {
    return prefs.getInt('gender') ?? 1;
  }

  //****************************************************************************
  void saveAltMobileNumber({required String altMobile}) {
    prefs.setString('alt_mobile', altMobile);
    update();
  }
  String getAltMobileNumber() {
    return prefs.getString('alt_mobile') ?? '';
  }

  //****************************************************************************
  void saveBirthDate({required String date}) {
    prefs.setString('birth_date', date);
    update();
  }
  String getBirthDate() {
    return prefs.getString('birth_date') ?? '';
  }

  //****************************************************************************
  void saveAddressDetails({required String details}) {
    prefs.setString('address_details', details);
    update();
  }
  String getAddressDetails() {
    return prefs.getString('address_details') ?? '';
  }

  //****************************************************************************
  void saveLatitude({required double latitude}) {
    prefs.setDouble('latitude', latitude);
    update();
  }
  double getLatitude() {
    return prefs.getDouble('latitude') ?? 0.0;
  }

  //****************************************************************************
  void saveLongitude({required double longitude}) {
    prefs.setDouble('longitude', longitude);
    update();
  }
  double getLongitude() {
    return prefs.getDouble('longitude') ?? 0.0;
  }

  //****************************************************************************
  void saveOccupation({required String occupation}) {
    prefs.setString('occupation', occupation);
    update();
  }
  String getOccupation() {
    return prefs.getString('occupation') ?? '';
  }

  //****************************************************************************
  // Method to save if session terminated or not
  terminateSession(bool flag) {
    prefs.setBool('terminated', flag);
    update();
  }
  // Method to get if session terminated or not
  bool sessionTerminated() {
    return prefs.getBool('terminated') ?? false;
  }

  //****************************************************************************
  void saveCityId({required int cityId}) {
    prefs.setInt('city_id', cityId);
    update();
  }
  int getCityId() {
    return prefs.getInt('city_id') ?? 1;
  }

  //****************************************************************************
  void saveRegionId({required int regionId}) {
    prefs.setInt('region_id', regionId);
    update();
  }
  int getRegionId() {
    return prefs.getInt('region_id') ?? 0;
  }

  //****************************************************************************

  // Saving And Getting List Of Data To/From Shared Preferences
  Future<void> saveListOfInt({required String listKey, required List<int> list}) async {
    await prefs.setStringList(listKey, list.map((item) => item.toString()).toList());
  }
  Future<List<int>> getListOfInt({required String listKey}) async {
    final intList = prefs.getStringList(listKey);
    return intList?.map((item) => int.parse(item)).toList() ?? [];
  }
  Future<void> saveStringList({required String listKey, required List<String> list}) async {
    await prefs.setStringList(listKey, list);
  }
  Future<List<String>> getStringList({required String listKey}) async {
    return prefs.getStringList(listKey) ?? [];
  }

  clearData() async {
    await prefs.clear();
    update();
  }

}
