import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class HttpHelper {
  static const int timeout = 30;
  static final SharedPrefsController prefsController = SharedPrefsController();

  static Future<T> handleResponse<T>({
    required int statusCode,
    required T Function() onSuccess,
    T Function()? onUnauthorizedAdditional,
    T Function()? onGone,
    T Function()? onParamNotFound,
    T Function()? onBadRequest,
    T Function()? onPreconditionRequired,
    required Map<String, dynamic> responseBody,
  }) async {
    if (statusCode == 200) {
      return onSuccess();
    } else if (statusCode == 401) {
      prefsController.terminateSession(true);
      if (onUnauthorizedAdditional != null) {
        return onUnauthorizedAdditional();
      }
      throw Exception('Unauthorized access');
    } else if (statusCode == 410 && onGone != null) {
      return onGone();
    } else if (statusCode == 404 && onParamNotFound != null) {
      String message = responseBody['message'] ?? 'أحد الحقول مطلوبة';
      prefsController.saveMSG(message: message);
      return onParamNotFound();
    } else if (statusCode == 400 && onBadRequest != null) {
      // Save the message for 400 status code
      String message = responseBody['message'] ?? 'Bad Request';
      prefsController.saveMSG(message: message);
      return onBadRequest();
    } else if (statusCode == 428 && onPreconditionRequired != null) {
      // Save the message for 428 status code
      String message = responseBody['message'] ?? 'Precondition Required';
      prefsController.saveMSG(message: message);
      return onPreconditionRequired();
    } else {
      print('\x1B[33m<<<<<<<<<<  STATUS CODE  >>>>>>>>> : \x1B[34m$statusCode\x1B[0m');
      print('\x1B[33m<<<<<<<<<< RESPONSE BODY >>>>>>>>> : \x1B[34m$responseBody\x1B[0m');
      prefsController.saveMSG(message: 'حدث خطأ أثناء الاتصال .. الرجاء المحاولة لاحقاً');
      return Future.value(false as T);
    }
  }

  /*
  Red    \x1B[31m
  Green  \x1B[32m
  Yellow \x1B[33m
  Blue   \x1B[34m
  Magenta \x1B[35m
  Cyan   \x1B[36m
  White  \x1B[37m
  */

  static Future<Map<String, dynamic>> httpRequest({
    required Uri url,
    required String method,
    Map<String, String>? headers,
    String? body,
  }) async {
    try {
      final response = await (method == 'POST'
          ? http.post(url, headers: headers, body: body)
          : method == 'DELETE'
          ? http.delete(url, headers: headers)
          : http.get(url, headers: headers)).timeout(const Duration(seconds: timeout));

      // Print the status code
      debugPrint('Response Status Code: ${response.statusCode}');

      // Print the raw response body for debugging
      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('Response Body: $responseBody');

      // Attempt to parse the JSON response
      Map<String, dynamic> parsedBody;
      try {
        parsedBody = json.decode(responseBody);
      } catch (e) {
        // Handle JSON parsing errors
        debugPrint('Failed to parse JSON: $e');
        parsedBody = {};
      }
      return {
        'statusCode': response.statusCode,
        'body': parsedBody,
      };
    } on TimeoutException {
      debugPrint("Request timed out after $timeout seconds.");
      prefsController.saveMSG(message: "الوقت انتهى للطلب .. الرجاء المحاولة لاحقاً");
      throw Exception('Request timed out');
    } on SocketException {
      debugPrint("No internet connection.");
      prefsController.saveMSG(message: "لا يوجد انترنت ، قم بالاتصال بالانترنت وحاول ثانيةً");
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint("An error occurred: $e");
      throw Exception('An error occurred');
    }
  }
}
