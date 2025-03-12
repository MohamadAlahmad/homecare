import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/utils/api.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/health_record_brief.dart';
import 'package:homecare/mvc/model/api/health_record_model.dart';
import 'package:homecare/mvc/model/api/medical_service.dart';
import 'package:homecare/mvc/model/api/nurse.dart';
import 'package:homecare/mvc/model/api/package.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/model/api/reservation.dart';
import 'package:http/http.dart' as http;

class ConnectionController {

  static const int timeout = 60;
  static final SharedPrefsController prefsController = SharedPrefsController();

  static Future<String> register({required String dialCode, required String phoneNumber, required int userType}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.sendCode);

    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
    });

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        prefsController.saveMSG(message: result['message']);
        return 'success';
      } else {
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        return 'failed';
      }
    } on TimeoutException {
      debugPrint("Request timed out after $timeout seconds.");
      return 'timeout';
      // يمكن أن تُستخدم هذه الرسالة لإظهار رسالة للمستخدم حول انتهاء الوقت
    } on SocketException {
      debugPrint("No internet connection.");
      prefsController.saveMSG(message: "لا يوجد انترنت ، قم بالاتصال بالانترنت وحاول ثانيةً");
      return 'no_internet';
    } catch (e) {
      debugPrint("An error occurred: $e");
      return 'error';
      // يمكن أن تُستخدم هذه الرسالة لإظهار رسالة عامة عند حدوث خطأ غير متوقع
    }
  }

  static Future<String> verifyFirstCode({required String dialCode, required String phoneNumber, required int userType, required String code}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.verifyFirstCode);
    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'code': code,
    });
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));

    // Ensure the response is properly decoded as UTF-8
    var result = json.decode(utf8.decode(response.bodyBytes));

    prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      //debugPrint(response.body);
      if(userType == 2) {
        prefsController.saveToken(token: result['data']['token']);
        registerFCMToken(
          token: prefsController.getToken(),
          fcmToken: prefsController.getUserFCMToken(),
        );
        if(result['data']['eneteredBasicInfo'] == true) {
          return 'success home';
        } else {
          return 'success info';
        }
      } else {
        if(result['data']['eneteredBasicInfo'] == true) {
          return 'success code 2';
        } else {
          return 'success info';
        }
      }
    } else if(response.statusCode == 410) { // إذا انتهت الربع ساعة والتي المفروض الكود بعدها يصبح غير صالح
      return 'expired';
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
      return 'failed';
    }
  }

  static Future<String> verifySecondCode({required String dialCode, required String phoneNumber, required int userType, required String code}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.verifySecondCode);
    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'code': code,
    });
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));

    // Ensure the response is properly decoded as UTF-8
    var result = json.decode(utf8.decode(response.bodyBytes));

    prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      prefsController.saveToken(token: result['data']['token']);
      registerFCMToken(
        token: prefsController.getToken(),
        fcmToken: prefsController.getUserFCMToken(),
      );
      debugPrint(response.body);
      return 'true';
    } else if(response.statusCode == 410) { // إذا انتهت المدة للكود الثاني , والتي المفروض الكود بعدها يصبح غير صالح
      return 'expired';
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
      return 'false';
    }
  }

  static Future<bool> sendPersonalInfo({required String firstName, required String lastName, required String dialCode, required String phoneNumber, required int userType}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.enterPersonalInfo);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
    });
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    var result = json.decode(utf8.decode(response.bodyBytes));
    prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
      return false;
    }
  }

  static Future<String> hasEnteredPersonalInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.hasEnteredPersonalInfo);
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: timeout));

    debugPrint(response.bodyBytes.toString());
    var result = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      prefsController.saveMSG(message: result['message']);
      var value = result['data']['hasEnteredBasicPersonalInfo'];
      return value.toString();
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
      return 'failed';
    }
  }

  static Future<String> getPatientSignUpStatus({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getPatientSignUpStatus);
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: timeout));

    debugPrint(response.bodyBytes.toString());
    var result = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      prefsController.saveMSG(message: result['message']);
      var value = result['data']['hasEnteredBasicPersonalInfo'];
      return value.toString();
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
      return 'failed';
    }
  }

  static Future<bool> updatePatientPersonalInfo({
    required String firstName,
    required String lastName,
    required String token,
    required String dateOfBirth,
    required String dialCodeForAlternativePhoneNumber,
    required String alternativePhoneNumber,
    required int gender,
    required int? personalImageId,
    required double latitude,
    required double longitude,
    required int regionId,
    required String details,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.updatePatientPersonalInfo);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'dialCodeForAlternativePhoneNumber': dialCodeForAlternativePhoneNumber,
      'alternativePhoneNumber': alternativePhoneNumber,
      'gender': gender,
      'personalImageId': personalImageId,
      'geographicCoordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'geocodedAddress': {
        'regionId': regionId.toString(),
        'details': details,
      },
    });
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    var result = json.decode(utf8.decode(response.bodyBytes));
    //_prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      prefsController.saveMSG(message: result['message']);
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint("Error Message: ${result['message']}");
      return false;
    }
    /*} catch(e) {
      debugPrint('ERROR :::: $e');
      return false;
    }*/
  }

  static Future<void> getPatientProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getPatientProfileInfo);
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: timeout));
    SharedPrefsController controller = prefsController;

    if (response.statusCode == 200) {
      var result = json.decode(utf8.decode(response.bodyBytes));
      debugPrint('/START');
      debugPrint(result.toString());
      debugPrint('/End');
      controller.saveFirstName(firstName: result['data']['firstName'] ?? '');
      controller.saveLastName(lastName: result['data']['lastName'] ?? '');
      controller.saveGender(gender: result['data']['gender']);
      //TODO : save the region id here
      //controller.saveRegionId(regionId: result['data']['id']);
      String fullPhone = result['data']['phoneNumber'];
      //String phone = fullPhone.substring(3);
      controller.saveMobileNumber(mobile: fullPhone);
      String fullAltPhone = result['data']['alternativePhoneNumber'].toString();
      String altPhone = fullAltPhone != 'null' ? fullAltPhone.substring(3) : '';
      controller.saveAltMobileNumber(altMobile: altPhone);
      controller.saveBirthDate(date: result['data']['dateOfBirth'] != null ? result['data']['dateOfBirth'].toString() : '');
      if(result['data']['geocodedAddress'] != null) {
        controller.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
        controller.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
        controller.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
      }
      if(result['data']['geographicCoordinates'] != null) {
        controller.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
        controller.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
      }

      debugPrint('FULL NAME IN POST METHOD : ${prefsController.getFirstName()} ${prefsController.getLastName()}');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
    }
  }

  static Future<String> addPatient({
    required String firstName,
    required String lastName,
    required String token,
    required String dateOfBirth,
    required String dialCodeForAlternativePhoneNumber,
    required String alternativePhoneNumber,
    required String phoneNumber,
    required String dialCode,
    required int gender,
    required int? personalImageId,
    required double latitude,
    required double longitude,
    required int regionId,
    required String details,
    required String code,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.addPatient);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'dialCodeForAlternativePhoneNumber': dialCodeForAlternativePhoneNumber,
      'alternativePhoneNumber': alternativePhoneNumber,
      'gender': gender,
      'personalImageId': personalImageId,
      'geographicCoordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'geocodedAddress': {
        'regionId': regionId.toString(),
        'details': details,
      },
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'approvedManagementVerificationCode': code,
    });
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    var result = json.decode(utf8.decode(response.bodyBytes));
    //_prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return 'true';
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return 'false';
    } else if(response.statusCode == 428) {
      return 'enter-info';
    } else {
      prefsController.saveMSG(message: result['message'] ?? 'حدث خطأ أثناء الاتصال');
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(result.toString());
      return 'false';
    }
    /*} catch(e) {
      debugPrint('ERROR :::: $e');
      return false;
    }*/
  }

  static Future<bool> requestAccountManagement({required String patientDialCode, required String patientPhoneNumber, required String patientName, required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.requestAccountManagement);
    debugPrint('URL --> $url');
    var body = jsonEncode({
      'patientPhoneNumber': patientPhoneNumber,
      'patientDialCode': patientDialCode,
      'patientName': patientName,
    });

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        debugPrint('OK ---');
        return true;
      } else {
        debugPrint('Failed ---');
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        return false;
      }
    } on TimeoutException {
      debugPrint("Request timed out after $timeout seconds.");
      return false;
    } on SocketException {
      debugPrint("No internet connection");
      prefsController.saveMSG(message: "لا يوجد انترنت ، قم بالاتصال بالانترنت وحاول ثانيةً");
      return false;
    } catch (e) {
      debugPrint("An error occurred: $e");
      return false;
    }
  }

  static Future<List<Patient>> getPatients({required String token}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}/api/Patients/ViewMyPatients');

    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        List<Patient> patients = (result['data'] as List<dynamic>?)?.map((item) {
          return Patient.fromJson(item);
        }).toList() ?? [];

        return patients;
      } /*else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      }*/ else {
        debugPrint('Error - get Patients : ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<void> getCities() async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getCities);
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    var result = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      List data = result['data'];
      List<City> cities = data.map((item) => City.fromJson(item)).toList();
      CitiesController citiesController = Get.find();
      citiesController.saveCities(cities);
      debugPrint(' 200 OK ---------- Get Cities');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
    }
  }

  static Future<void> getRegions1() async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getRegions}1');
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    var result = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      List data = result['data'];
      List<Region> regions = data.map((item) => Region.fromJson(item)).toList();
      RegionsController regionsController = Get.find();
      regionsController.saveRegions1(regions);
      debugPrint(' 200 OK ---------- Get Regions 1');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
    }
  }

  static Future<void> getRegions2() async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getRegions}2');
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    var result = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      List data = result['data'];
      List<Region> regions = data.map((item) => Region.fromJson(item)).toList();
      RegionsController regionsController = Get.find();
      regionsController.saveRegions2(regions);
      debugPrint(' 200 OK ---------- Update Regions 2');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(utf8.decode(response.bodyBytes));
    }
  }

  static Future<List<MedicalService>> getServices({required String token, required int medicalServiceTypeId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getMedicalServices}')
        .replace(queryParameters: {'medicalServiceTypeId': medicalServiceTypeId.toString()});
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        List<MedicalService> services = (result['items'] as List).map((item) {
          return MedicalService.fromJson(item);
        }).toList();

        for (var x in services) {
          debugPrint(x.name);
        }
        return services;
      } else if(response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else {
        debugPrint('Error - Get Medical Services : ${response.statusCode}');
        debugPrint(response.body);
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<bool> updateNursePersonalInfo({
    required String firstName,
    required String lastName,
    required String token,
    required String dateOfBirth,
    required String dialCodeForAlternativePhoneNumber,
    required String alternativePhoneNumber,
    required int gender,
    required int? personalImageId,
    required String? attachmentIds,
    required double latitude,
    required double longitude,
    required int regionId,
    required String details,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.updateNursePersonalInfo);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'dialCodeForAlternativePhoneNumber': dialCodeForAlternativePhoneNumber,
      'alternativePhoneNumber': alternativePhoneNumber,
      'gender': gender,
      'personalImageId': personalImageId,
      //'attachmentIds': attachmentIds,
      'geographicCoordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'geocodedAddress': {
        'regionId': regionId.toString(),
        'details': details,
      },
    });
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    var result = json.decode(utf8.decode(response.bodyBytes));
    //_prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      prefsController.saveMSG(message: result['message']);
      //prefsController.saveMSG(message: result['message']);
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(response.body);
      debugPrint("Error Message: ${result['message']}");
      return false;
    }
    //} catch(e) {
    //  debugPrint('ERROR :::: $e');
    //  return false;
    //}
  }

  static Future<void> getNurseProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getNurseProfileInfo);
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: timeout));
    SharedPrefsController controller = prefsController;

    if (response.statusCode == 200) {
      var result = json.decode(utf8.decode(response.bodyBytes));
      debugPrint('/START --------------------------');
      debugPrint(result.toString());
      debugPrint('/End --------------------------');
      controller.saveFirstName(firstName: result['data']['firstName']);
      controller.saveLastName(lastName: result['data']['lastName']);
      controller.saveGender(gender: result['data']['gender']);
      //controller.savePoints(points: result['data']['points']);
      controller.saveRate(rate: result['data']['rate']);
      //TODO : save the region id here
      //controller.saveRegionId(regionId: result['data']['id']);
      String fullPhone = result['data']['phoneNumber'];
      //String phone = fullPhone.substring(3);
      controller.saveMobileNumber(mobile: fullPhone);
      String fullAltPhone = result['data']['alternativePhoneNumber'].toString();
      String altPhone = fullAltPhone != 'null' ? fullAltPhone.substring(3) : '';
      controller.saveAltMobileNumber(altMobile: altPhone);
      controller.saveBirthDate(date: result['data']['dateOfBirth'] != null ? result['data']['dateOfBirth'].toString() : '');
      if(result['data']['geocodedAddress'] != null) {
        controller.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
        controller.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
        controller.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
      }
      if(result['data']['geographicCoordinates'] != null) {
        controller.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
        controller.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
      }
      debugPrint('MOBILE ${prefsController.getMobileNumber()}');
      debugPrint(' 200 OK ---------- Update Nurse Info');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
    }
  }

  static Future<List<Nurse>> getNurses({required String token, required bool onlyMales}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.viewNurses}');
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: onlyMales ? jsonEncode({
          "gender": 1
        }) : jsonEncode({}),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Nurse> nurses = (result['data'] as List).map((item) {
          return Nurse.fromJson(item);
        }).toList();
        return nurses;
      } else if(response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else {
        debugPrint('Reached Here 4');
        debugPrint('Error: ${response.statusCode}');
        debugPrint(response.body);
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<String> bookService({
    required int serviceId,
    required int nurseId,
    required List<String> visitsDates,
    required int? visitDurationInHours,
    required String token,
    int? regionId,
    String? details,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.bookService);
    var body = jsonEncode({
      'serviceId': serviceId,
      if (nurseId != -1) 'nurseId': nurseId,
      'visitsDates': visitsDates,
      'visitDurationInHours': visitDurationInHours,
      if (regionId != null && details != null)
        'geocodedAddress': {
          'regionId': regionId.toString(),
          'details': details,
        }
    });

    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));

    var result = response.bodyBytes.isNotEmpty ? json.decode(utf8.decode(response.bodyBytes)) : '';
    if (response.statusCode == 200) {
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(response.body);
      return 'true';
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return 'false';
    } else if(response.statusCode == 428) {
      return 'enter-info';
    } else {
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(response.body);
      debugPrint("Error Message Is: ${result['message']}");
      prefsController.saveMSG(message: result['message']);
      return 'false';
    }
    /*} catch (e) {
      debugPrint('Error: $e');
      return false;
    }*/
  }

  static Future<bool> bookServiceThroughPackage({
    required int packageId,
    required int nurseId,
    required String firstVisitsDate,
    required String token,
    int? regionId,
    String? details,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.bookServiceThroughPackage);
    var body = jsonEncode({
      'packageId': packageId,
      if (nurseId != -1) 'nurseId': nurseId,
      'firstVisitsDate': firstVisitsDate,
      if (regionId != null && details != null)
        'geocodedAddress': {
          'regionId': regionId.toString(),
          'details': details,
        }
    });

    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));

    var result = response.bodyBytes.isNotEmpty ? json.decode(utf8.decode(response.bodyBytes)) : '';
    if (response.statusCode == 200) {
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(response.body);
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint(response.body);
      debugPrint("Error Message: ${result['message']}");
      prefsController.saveMSG(message: result['message']);
      return false;
    }
    /*} catch (e) {
      debugPrint('Error: $e');
      return false;
    }*/
  }

  static Future<bool> acceptCase({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.acceptCase}')
        .replace(queryParameters: {'caseId': caseId.toString()});
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    if (response.statusCode == 200) {
      debugPrint('Accepted Successfully !!');
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      debugPrint('Error: ${response.statusCode}');
      debugPrint(response.body);
      return false;
    }
    /*} catch (e) {
      debugPrint('Exception: $e');
      return false;
    }*/
  }

  static Future<bool> cancelCase({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.cancelCase}')
        .replace(queryParameters: {'caseId': caseId.toString()});
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    if (response.statusCode == 200) {
      debugPrint('Cancelled Successfully !!');
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      var result = json.decode(utf8.decode(response.bodyBytes));
      prefsController.saveMSG(message: result['message']);
      debugPrint('Error: ${response.statusCode}');
      debugPrint(response.body);
      return false;
    }
    /*} catch (e) {
      debugPrint('Exception: $e');
      return false;
    }*/
  }

  static Future<bool> cancelCaseByPatient({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.cancelCaseByPatient}')
        .replace(queryParameters: {'caseId': caseId.toString()});
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: timeout));

    if (response.statusCode == 200) {
      debugPrint('Cancelled Successfully !!');
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      var result = json.decode(utf8.decode(response.bodyBytes));
      prefsController.saveMSG(message: result['message']);
      debugPrint('Error: ${response.statusCode}');
      debugPrint(response.body);
      return false;
    }
    /*} catch (e) {
      debugPrint('Exception: $e');
      return false;
    }*/
  }

  static Future<List<Case>> getPendingCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.pendingCases);
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10,
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else if (response.statusCode == 428) {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<List<Case>> getFinishedCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.finishedCases);
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10,
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else if (response.statusCode == 428) {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<List<Case>> getCancelledCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.cancelledCases);
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10,
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else if (response.statusCode == 428) {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      } else {
        debugPrint('Error - Cancelled page : ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<List<Case>> getAcceptedCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.acceptedCases);
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10,
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else if (response.statusCode == 428) {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      } else {
        prefsController.terminateSession(false);
        debugPrint('Error - Accepted Cases : ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<List<Reservation>> getOwnReservations({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.ownReservations);
    debugPrint('Get Own Reservations');
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10,
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        List<Reservation> reservations = (result['data']['items'] as List).map((item) {
          return Reservation.fromJson(item);
        }).toList();
        String message = result['message'] ?? 'Error';
        prefsController.saveMSG(message: reservations.isEmpty ? 'لا توجد حجوزات' : message);
        return reservations;
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else {
        var errorResponse = json.decode(utf8.decode(response.bodyBytes));
        String errorMessage = errorResponse['message'] ?? 'Error';
        prefsController.saveMSG(message: errorMessage);
        debugPrint('Error In Get Reservations : ${response.statusCode}');
        debugPrint(utf8.decode(response.bodyBytes));
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<void> getSupporterProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getSupporterProfileInfo);
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: timeout));
    SharedPrefsController controller = prefsController;

    if (response.statusCode == 200) {
      var result = json.decode(utf8.decode(response.bodyBytes));
      controller.saveFirstName(firstName: result['data']['firstName']);
      controller.saveLastName(lastName: result['data']['lastName']);
      controller.saveOccupation(occupation: result['data']['occupation'] ?? '');
      controller.saveGender(gender: result['data']['gender'] ?? 1);
      //TODO : save the region id here
      //controller.saveRegionId(regionId: result['data']['id']);
      String fullPhone = result['data']['phoneNumber'] ?? '';
      //String phone = fullPhone.substring(3);
      controller.saveMobileNumber(mobile: fullPhone);
      String fullAltPhone = result['data']['alternativePhoneNumber'] != null ? result['data']['alternativePhoneNumber'].toString() : '';
      String altPhone = fullAltPhone.isNotEmpty ? fullAltPhone.substring(3) : '';
      controller.saveAltMobileNumber(altMobile: altPhone);
      controller.saveBirthDate(date: result['data']['dateOfBirth'] != null ? result['data']['dateOfBirth'].toString() : '');
      if(result['data']['geocodedAddress'] != null) {
        controller.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
        controller.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
        controller.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
      }
      if(result['data']['geographicCoordinates'] != null) {
        controller.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
        controller.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
      }
      debugPrint(' 200 OK ---------- Update User Info');
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
    }
  }

  static Future<bool> updateSupporterPersonalInfo({
    required String firstName,
    required String lastName,
    required String token,
    required String dateOfBirth,
    required String occupation,
    required int? personalImageId,
    required double latitude,
    required double longitude,
    required int regionId,
    required String details,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.updateSupporterPersonalInfo);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'occupation': occupation,
      'personalImageId': personalImageId,
      'geographicCoordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'geocodedAddress': {
        'regionId': regionId.toString(),
        'details': details,
      },
    });
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    //_prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      var result = json.decode(utf8.decode(response.bodyBytes));
      prefsController.saveMSG(message: result['message'] ?? 'حدث خطأ ما');
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint("HTTP Status Code: ${response.body}");
      //debugPrint("Error Message: ${result['message']}");
      return false;
    }
    /*} catch(e) {
      debugPrint('ERROR :::: $e');
      return false;
    }*/
  }

  static Future<bool> addPatientBySupporter({
    required String firstName,
    required String lastName,
    required String token,
    required String phoneNumber,
    required String dialCode,
    required int suggestedNurseId,
    required String operationType,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.addPatientBySupporter);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'suggestedNurseId': suggestedNurseId != -1 ? suggestedNurseId : null,
      'operationType': operationType,
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
    });
    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    var result = json.decode(utf8.decode(response.bodyBytes));
    //_prefsController.saveMSG(message: result['message']);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      prefsController.saveMSG(message: result['message']);
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint("Error Message: ${result['message']}");
      return false;
    }
    /*} catch(e) {
      debugPrint('ERROR :::: $e');
      return false;
    }*/
  }

  static Future<List<Patient>> viewPendingPatients({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}/api/Patients/ViewPendingPatients');
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "keywords": "",
          "isActive": true,
          "pageNumber": pageNumber,
          "pageSize": 10
        }),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        if(result['data'] != null && result['data']['items'] != null) {
          List<Patient> patients = (result['data']['items'] as List).map((item) {
            return Patient.fromJson(item);
          }).toList();
          return patients;
        } else {
          debugPrint('Error: "items" key is missing in the API response');
          return [];
        }
      } else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      } else {
        debugPrint('Error - Get Pending Patients: ${response.statusCode}');
        debugPrint('Response Body: ${utf8.decode(response.bodyBytes)}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<bool> fillSessionForm({
    required String bioMarker1Value,
    required String bioMarker2Value,
    required String bioMarker3Value,
    required String bioMarker4Value,
    required String bioMarker5Value,
    required String notes,
    required num basicServicePrice,
    required String descriptionAdditional,
    required num priceAdditional,
    required int sessionId,
    required String token,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.fillSessionForm)
        .replace(queryParameters: {'sessionId': sessionId.toString()});

    var body = jsonEncode({
      "bioMarkers": [
        {"bioMarkerType": 1, "value": num.parse(bioMarker1Value)},
        {"bioMarkerType": 2, "value": num.parse(bioMarker2Value)},
        {"bioMarkerType": 3, "value": num.parse(bioMarker3Value)},
        {"bioMarkerType": 4, "value": num.parse(bioMarker4Value)},
        {"bioMarkerType": 5, "value": num.parse(bioMarker5Value)},
      ],
      "notes": notes,
      //"attachmentIds": [1],
      "basicServicePrice": basicServicePrice,
      "additionalFees": {
        "description": descriptionAdditional,
        "price": priceAdditional
      },
      "finalPrice": basicServicePrice + priceAdditional,
    });

    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));

    if (response.statusCode == 200) {
      debugPrint('Success Fill Form');
      return true;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return false;
    } else {
      var result = json.decode(utf8.decode(response.bodyBytes));
      prefsController.saveMSG(message: result['message']);
      debugPrint('Error: ${response.statusCode}');
      debugPrint('Response: ${utf8.decode(response.bodyBytes)}');
      return false;
    }
    /*} catch (e) {
      debugPrint('Exception: $e');
      return false;
    }*/
  }

  static Future<List<HealthRecordBrief>> getOwnHealthRecords({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.ownHealthRecords);
    debugPrint('url here: ${url.toString()}');

    //try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "keywords": "",
        "isActive": true,
        "pageNumber": pageNumber,
        "pageSize": 10,
      }),
    ).timeout(const Duration(seconds: timeout));

    if (response.statusCode == 200) {
      var result = json.decode(utf8.decode(response.bodyBytes));
      List<HealthRecordBrief> records = (result['data']['items'] as List).map((item) {
        return HealthRecordBrief.fromJson(item);
      }).toList();
      return records;
    } else if(response.statusCode == 401) {
      prefsController.terminateSession(true);
      return [];
    } else {
      debugPrint('Error: ${response.statusCode}');
      debugPrint(utf8.decode(response.bodyBytes));
      return [];
    }
    /*} catch (e) {
      debugPrint('Exception: $e');
      return [];
    }*/
  }

  static Future<List<Package>> getPackages({required String token}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.packages}');
    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        //body: jsonEncode({}),
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        List<Package> packages = (result['data'] as List<dynamic>?)?.map((item) {
          return Package.fromJson(item);
        }).toList() ?? [];

        return packages;
      } /*else if (response.statusCode == 401) {
        prefsController.terminateSession(true);
        return [];
      }*/ else {
        debugPrint('Error - Get Packages : ${response.statusCode}');
        debugPrint(response.body);
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return [];
    }
  }

  static Future<HealthRecordModel?> getSessionById({required String token, required int sessionId}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getSessionById)
        .replace(queryParameters: {'sessionId': sessionId.toString()});
    debugPrint('URL: ${url.toString()}');
    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        return HealthRecordModel.fromJson(result['data']);
      } else if(response.statusCode == 401) {
        prefsController.terminateSession(true);
        return null;
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return null;
    }
  }

  static Future<bool> deletePatientBySupporter({required String token, required int id}) async {
    try {
      Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.deletePatientBySupporter}')
          .replace(queryParameters: {'id': id.toString()});
      debugPrint('Full URL : $url');

      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        debugPrint('Deleted Successfully !!');
        return true;
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return false;
    }
  }

  static Future<PreviousCase?> getPreviousCase({required String token, required int patientId}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getLastSession)
        .replace(queryParameters: {'patientId': patientId.toString()});

    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        if (result['data'] != null) {
          final sessionDetails = result['data']['sesssionDetails'];
          if (sessionDetails != null) {
            return PreviousCase.fromJson(sessionDetails);
          } else {
            debugPrint('Session details not found');
            return null;
          }
        } else {
          prefsController.saveMSG(message: 'لا يوجد بيانات');
          debugPrint('Data is empty or null');
          return null;
        }
      } else if(response.statusCode == 401) {
        prefsController.terminateSession(true);
        return null;
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      prefsController.saveMSG(message: 'حدثت مشكلة أثناء الاتصال');
      return null;
    }
  }

  static Future<String> switchAccount({required String token, required int patientId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.switchUser}')
        .replace(queryParameters: {'patientId': patientId.toString()});
    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        //save the previous
        prefsController.saveMainUserToken(token: prefsController.getToken());
        prefsController.saveMainUserType(type: prefsController.getUserType());

        //set the new
        prefsController.saveToken(token: result['data']['token']);
        prefsController.saveUserType(type: 2);

        return 'true';
      } else if(response.statusCode == 401) {
        prefsController.terminateSession(true);
        prefsController.saveMSG(message: 'حدث خطأ ما');
        return 'expired';
      } else {
        prefsController.saveMSG(message: 'حدث خطأ ما');
        debugPrint('Error - Switch Account : ${response.statusCode}');
        debugPrint(response.body);
        return 'false';
      }
    } catch (e) {
      prefsController.saveMSG(message: 'حدث خطأ ما');
      debugPrint('Exception: $e');
      return 'false';
    }
  }

  static Future<bool> registerFCMToken({required String token, required String fcmToken}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.registerFCMToken);
    var body = jsonEncode({
      'token': fcmToken,
    });
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    ).timeout(const Duration(seconds: timeout));
    if (response.statusCode == 200) {
      debugPrint('✅✅✅ Success Register FCM Token');
      return true;
    } else {
      debugPrint('❌❌❌ Failed Register FCM Token');
      debugPrint(response.statusCode.toString());
      return false;
    }
  }

  static Future<bool> logout({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.logout);
    try {
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        return false;
      }
    } on TimeoutException {
      debugPrint("Request timed out after $timeout seconds.");
      return false;
    } on SocketException {
      debugPrint("No internet connection.");
      return false;
    } catch (e) {
      debugPrint("An error occurred: $e");
      return false;
    }
  }

}
