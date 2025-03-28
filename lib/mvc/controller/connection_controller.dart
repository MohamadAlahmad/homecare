import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/utils/api.dart';
import 'package:homecare/core/utils/http_helper.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/health_record_brief.dart';
import 'package:homecare/mvc/model/api/health_record_model.dart';
import 'package:homecare/mvc/model/api/medical_service.dart';
import 'package:homecare/mvc/model/api/notification_model.dart';
import 'package:homecare/mvc/model/api/nurse.dart';
import 'package:homecare/mvc/model/api/package.dart';
import 'package:homecare/mvc/model/api/patient.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/model/api/reservation.dart';

class ConnectionController {

  static final SharedPrefsController prefsController = SharedPrefsController();

  static Future<String> register({
    required String dialCode,
    required String phoneNumber,
    required int userType,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.sendCode);
    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        return 'success';
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<String> verifyFirstCode({
    required String dialCode,
    required String phoneNumber,
    required int userType,
    required String code,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.verifyFirstCode);
    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'code': code,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        if (userType == 2) {
          prefsController.saveToken(token: response['body']['data']['token']);
          registerFCMToken(
            token: prefsController.getToken(),
            fcmToken: prefsController.getUserFCMToken(),
          );
          return response['body']['data']['eneteredBasicInfo'] ? 'success home' : 'success info';
        } else {
          return response['body']['data']['eneteredBasicInfo'] ? 'success code 2' : 'success info';
        }
      },
      onUnauthorizedAdditional: null,
      onGone: () => 'expired',
      responseBody: response['body'],
    );
  }

  static Future<String> verifySecondCode({
    required String dialCode,
    required String phoneNumber,
    required int userType,
    required String code,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.verifySecondCode);
    var body = jsonEncode({
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'code': code,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        prefsController.saveToken(token: response['body']['data']['token']);
        registerFCMToken(
          token: prefsController.getToken(),
          fcmToken: prefsController.getUserFCMToken(),
        );
        return 'true';
      },
      onUnauthorizedAdditional: null,
      onGone: () => 'expired',
      responseBody: response['body'],
    );
  }

  static Future<bool> sendPersonalInfo({
    required String firstName,
    required String lastName,
    required String dialCode,
    required String phoneNumber,
    required int userType,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.enterPersonalInfo);
    var body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'userType': userType,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        return true;
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<String> hasEnteredPersonalInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.hasEnteredPersonalInfo);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        return response['body']['data']['hasEnteredBasicPersonalInfo'].toString();
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<String> getPatientSignUpStatus({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getPatientSignUpStatus);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        prefsController.saveMSG(message: response['body']['message']);
        return response['body']['data']['hasEnteredBasicPersonalInfo'].toString();
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        return true;
      },
      onUnauthorizedAdditional: () => false,
      // لابد من كتابتها (الـ onBadRequest) منشان يتحقق الشرط بالـ HttpHelper ويفوت علي بلوك الـ 400
      // وهكذا بالنسبة لباقي التوابع ...
      onBadRequest: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getPatientProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getPatientProfileInfo);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        prefsController.saveFirstName(firstName: result['data']['firstName'] ?? '');
        prefsController.saveLastName(lastName: result['data']['lastName'] ?? '');
        prefsController.saveGender(gender: result['data']['gender']);
        String fullPhone = result['data']['phoneNumber'];
        prefsController.saveMobileNumber(mobile: fullPhone);
        String fullAltPhone = result['data']['alternativePhoneNumber'].toString();
        String altPhone = fullAltPhone != 'null' ? fullAltPhone.substring(3) : '';
        prefsController.saveAltMobileNumber(altMobile: altPhone);
        prefsController.saveBirthDate(date: result['data']['dateOfBirth']?.toString() ?? '');
        if (result['data']['geocodedAddress'] != null) {
          prefsController.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
          prefsController.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
          prefsController.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
        }
        if (result['data']['geographicCoordinates'] != null) {
          prefsController.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
          prefsController.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
        }
        return;
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        return 'true';
      },
      onUnauthorizedAdditional: () => 'false',
      onBadRequest: () {
        debugPrint("Bad request: ${response['body']['message']}");
        return 'false';
      },
      onPreconditionRequired: () {
        return 'enter-info';
      },
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> requestAccountManagement({
    required String patientDialCode,
    required String patientPhoneNumber,
    required String patientName,
    required String token,
  }) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.requestAccountManagement);
    var body = jsonEncode({
      'patientPhoneNumber': patientPhoneNumber,
      'patientDialCode': patientDialCode,
      'patientName': patientName,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        return true;
      },
      onPreconditionRequired: () {
        debugPrint('428 Status Code !!');
        return false;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<Patient>> getPatients({required String token}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}/api/Patients/ViewMyPatients');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Patient> patients = (result['data'] as List<dynamic>?)?.map((item) {
          return Patient.fromJson(item);
        }).toList() ?? [];
        return patients;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getCities() async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getCities);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}),
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        List data = response['body']['data'];
        List<City> cities = data.map((item) => City.fromJson(item)).toList();
        CitiesController citiesController = Get.find();
        citiesController.saveCities(cities);
        debugPrint(' 200 OK ---------- Get Cities');
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getRegions1() async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getRegions}1');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}),
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        List data = response['body']['data'];
        List<Region> regions = data.map((item) => Region.fromJson(item)).toList();
        RegionsController regionsController = Get.find();
        regionsController.saveRegions1(regions);
        debugPrint(' 200 OK ---------- Get Regions 1');
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getRegions2() async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getRegions}2');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}),
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        List data = response['body']['data'];
        List<Region> regions = data.map((item) => Region.fromJson(item)).toList();
        RegionsController regionsController = Get.find();
        regionsController.saveRegions2(regions);
        debugPrint(' 200 OK ---------- Update Regions 2');
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<MedicalService>> getServices({required String token, required int medicalServiceTypeId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.getMedicalServices}')
        .replace(queryParameters: {'medicalServiceTypeId': medicalServiceTypeId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<MedicalService> services = (result['items'] as List).map((item) {
          return MedicalService.fromJson(item);
        }).toList();
        for (var x in services) {
          debugPrint(x.name);
        }
        return services;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
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
      'geographicCoordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'geocodedAddress': {
        'regionId': regionId.toString(),
        'details': details,
      },
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        //debugPrint(response['body']);
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onBadRequest: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getNurseProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getNurseProfileInfo);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        SharedPrefsController controller = prefsController;
        controller.saveFirstName(firstName: result['data']['firstName']);
        controller.saveLastName(lastName: result['data']['lastName']);
        controller.saveGender(gender: result['data']['gender']);
        controller.saveRate(rate: result['data']['rate']);
        String fullPhone = result['data']['phoneNumber'];
        controller.saveMobileNumber(mobile: fullPhone);
        String fullAltPhone = result['data']['alternativePhoneNumber'].toString();
        String altPhone = fullAltPhone != 'null' ? fullAltPhone.substring(3) : '';
        controller.saveAltMobileNumber(altMobile: altPhone);
        controller.saveBirthDate(date: result['data']['dateOfBirth'] != null ? result['data']['dateOfBirth'].toString() : '');
        if (result['data']['geocodedAddress'] != null) {
          controller.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
          controller.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
          controller.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
        }
        if (result['data']['geographicCoordinates'] != null) {
          controller.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
          controller.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
        }
        debugPrint(' 200 OK ---------- Update Nurse Info');
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<Nurse>> getNurses({required String token, required bool onlyMales}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.viewNurses}');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: onlyMales ? jsonEncode({"gender": 1}) : jsonEncode({}),
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Nurse> nurses = (result['data'] as List).map((item) {
          return Nurse.fromJson(item);
        }).toList();
        return nurses;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint("HTTP Status Code: ${response['statusCode']}");
        //debugPrint(response['body']);
        return 'true';
      },
      onPreconditionRequired: () {
        return 'enter-info';
      },
      onUnauthorizedAdditional: () => 'false',
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint("HTTP Status Code: ${response['statusCode']}");
        //debugPrint(response['body']);
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> acceptCase({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.acceptCase}')
        .replace(queryParameters: {'caseId': caseId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Accepted Successfully !!');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> cancelCase({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.cancelCase}')
        .replace(queryParameters: {'caseId': caseId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Cancelled Successfully !!');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onBadRequest: () => false,

      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> cancelCaseByPatient({required String token, required int caseId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.cancelCaseByPatient}')
        .replace(queryParameters: {'caseId': caseId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Cancelled Successfully !!');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onBadRequest: () {
        debugPrint("Bad request: ${response['body']['message']}");
        return false;
      },
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<Case>> getPendingCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.pendingCases);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      },
      onUnauthorizedAdditional: () => [],
      onPreconditionRequired: () {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      },
      onGone: () => [],
      responseBody: response['body'],
    );
  }

  static Future<List<Case>> getFinishedCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.finishedCases);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      },
      onUnauthorizedAdditional: () => [],
      onPreconditionRequired: () {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      },
      onGone: () => [],
      responseBody: response['body'],
    );
  }

  static Future<List<Case>> getCancelledCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.cancelledCases);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      },
      onUnauthorizedAdditional: () => [],
      onPreconditionRequired: () {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      },
      onGone: () => [],
      responseBody: response['body'],
    );
  }

  static Future<List<Case>> getAcceptedCases({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.acceptedCases);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Case> cases = (result['data']['items'] as List).map((item) {
          return Case.fromJson(item);
        }).toList();
        return cases;
      },
      onUnauthorizedAdditional: () => [],
      onPreconditionRequired: () {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      },
      onGone: () => [],
      responseBody: response['body'],
    );
  }

  static Future<List<Reservation>> getOwnReservations({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.ownReservations);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Reservation> reservations = (result['data']['items'] as List).map((item) {
          return Reservation.fromJson(item);
        }).toList();
        String message = result['message'] ?? 'Error';
        prefsController.saveMSG(message: reservations.isEmpty ? 'لا توجد حجوزات' : message);
        return reservations;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<void> getSupporterProfileInfo({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getSupporterProfileInfo);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        SharedPrefsController controller = prefsController;
        controller.saveFirstName(firstName: result['data']['firstName']);
        controller.saveLastName(lastName: result['data']['lastName']);
        controller.saveOccupation(occupation: result['data']['occupation'] ?? '');
        controller.saveGender(gender: result['data']['gender'] ?? 1);
        String fullPhone = result['data']['phoneNumber'] ?? '';
        controller.saveMobileNumber(mobile: fullPhone);
        String fullAltPhone = result['data']['alternativePhoneNumber'] != null ? result['data']['alternativePhoneNumber'].toString() : '';
        String altPhone = fullAltPhone.isNotEmpty ? fullAltPhone.substring(3) : '';
        controller.saveAltMobileNumber(altMobile: altPhone);
        controller.saveBirthDate(date: result['data']['dateOfBirth'] != null ? result['data']['dateOfBirth'].toString() : '');
        if (result['data']['geocodedAddress'] != null) {
          controller.saveAddressDetails(details: result['data']['geocodedAddress']['details'].toString());
          controller.saveCityId(cityId: result['data']['geocodedAddress']['governorateDto']['id']);
          controller.saveRegionId(regionId: result['data']['geocodedAddress']['regionDto']['id']);
        }
        if (result['data']['geographicCoordinates'] != null) {
          controller.saveLatitude(latitude: result['data']['geographicCoordinates']['latitude']);
          controller.saveLongitude(longitude: result['data']['geographicCoordinates']['longitude']);
        }
        debugPrint(' 200 OK ---------- Update User Info');
      },
      onUnauthorizedAdditional: null,
      onGone: null,
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        //debugPrint(response['body']);
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onBadRequest: () => false,
      onGone: null,
      responseBody: response['body'],
    );
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

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        //debugPrint(response['body']);
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onBadRequest: () {
        debugPrint("Bad request: ${response['body']['message']}");
        return false;
      },
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<Patient>> viewPendingPatients({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}/api/Patients/ViewPendingPatients');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        if (result['data'] != null && result['data']['items'] != null) {
          List<Patient> patients = (result['data']['items'] as List).map((item) {
            return Patient.fromJson(item);
          }).toList();
          return patients;
        } else {
          debugPrint('Error: "items" key is missing in the API response');
          return [];
        }
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
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
      "basicServicePrice": basicServicePrice,
      "additionalFees": {
        "description": descriptionAdditional,
        "price": priceAdditional
      },
      "finalPrice": basicServicePrice + priceAdditional,
    });

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Success Fill Form');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<HealthRecordBrief>> getOwnHealthRecords({required String token, int pageNumber = 1}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.ownHealthRecords);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<HealthRecordBrief> records = (result['data']['items'] as List).map((item) {
          return HealthRecordBrief.fromJson(item);
        }).toList();
        return records;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<Package>> getPackages({required String token}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.packages}');

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<Package> packages = (result['data'] as List<dynamic>?)?.map((item) {
          return Package.fromJson(item);
        }).toList() ?? [];
        return packages;
      },
      onUnauthorizedAdditional: () => [],
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<HealthRecordModel?> getSessionById({required String token, required int sessionId}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getSessionById)
        .replace(queryParameters: {'sessionId': sessionId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        return HealthRecordModel.fromJson(result['data']);
      },
      onUnauthorizedAdditional: () => null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> deletePatientBySupporter({required String token, required int id}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.deletePatientBySupporter}')
        .replace(queryParameters: {'id': id.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Deleted Successfully !!');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<PreviousCase?> getPreviousCase({required String token, required int patientId}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getLastSession)
        .replace(queryParameters: {'patientId': patientId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
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
      },
      onUnauthorizedAdditional: () => null,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<String> switchAccount({required String token, required int patientId}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.switchUser}')
        .replace(queryParameters: {'patientId': patientId.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        prefsController.saveMainUserToken(token: prefsController.getToken());
        prefsController.saveMainUserType(type: prefsController.getUserType());
        prefsController.saveToken(token: result['data']['token']);
        prefsController.saveUserType(type: 2);
        return 'true';
      },
      onUnauthorizedAdditional: () => 'expired',
      onGone: () => 'false',
      responseBody: response['body'],
    );
  }

  static Future<bool> registerFCMToken({required String token, required String fcmToken}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.registerFCMToken);
    var body = jsonEncode({'token': fcmToken});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('✅✅✅ Success Register FCM Token');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<bool> logout({required String token}) async {
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.logout);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

  static Future<List<NotificationModel>> getNotifications({required String token, int pageNumber = 1}) async {
    debugPrint('TOKEN NOW :=> $token');
    Uri url = Uri.parse(HomeCareApi.baseUrl + HomeCareApi.getNotifications);

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'POST',
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
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        var result = response['body'];
        List<NotificationModel> notifications = (result['data']['items'] as List).map((item) {
          return NotificationModel.fromJson(item);
        }).toList();
        return notifications;
      },
      onUnauthorizedAdditional: () => [],
      onPreconditionRequired: () {
        prefsController.terminateSession(false);
        prefsController.setMustFillInfo(flag: true);
        return [];
      },
      onGone: () => [],
      responseBody: response['body'],
    );
  }

  static Future<bool> deletePatient({required String token, required int id}) async {
    Uri url = Uri.parse('${HomeCareApi.baseUrl}${HomeCareApi.deletePatient}')
        .replace(queryParameters: {'patientId': id.toString()});

    var response = await HttpHelper.httpRequest(
      url: url,
      method: 'DELETE',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return await HttpHelper.handleResponse(
      statusCode: response['statusCode'],
      onSuccess: () {
        debugPrint('Deleted Successfully !!');
        return true;
      },
      onUnauthorizedAdditional: () => false,
      onGone: null,
      responseBody: response['body'],
    );
  }

}
