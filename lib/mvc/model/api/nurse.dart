// Class for patient added by patient
import 'package:homecare/core/utils/api.dart';

class Nurse {
  int id;
  num rate;
  String firstName;
  String lastName;
  String locationDetails;
  String personalImageUrl;
  bool isSelected = false;

  Nurse({
    required this.id,
    required this.rate,
    required this.firstName,
    required this.lastName,
    required this.locationDetails,
    required this.personalImageUrl,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'] ?? 0,
      rate: json['rate'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      locationDetails: json['geocodedAddress'] != null ? json['geocodedAddress']['details'] : '',
      personalImageUrl: json['personalImage'] != null
          ? '${HomeCareApi.baseUrl}/${json['personalImage']['url']}'
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate': rate,
      'firstName': firstName,
      'lastName': lastName,
      'locationDetails': locationDetails,
      'personalImageUrl': personalImageUrl,
    };
  }
}