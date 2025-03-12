import 'package:homecare/mvc/model/api/case.dart';

class Reservation {
  int id;
  int sessionStatus;
  int visitDurationInHours;
  String nurseName;
  String patientName;
  String medicalServiceName;
  String visitDate;
  GeocodedAddress? geocodedAddress;

  Reservation({
    required this.id,
    required this.sessionStatus,
    required this.visitDurationInHours,
    required this.nurseName,
    required this.patientName,
    required this.medicalServiceName,
    required this.visitDate,
    required this.geocodedAddress,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      sessionStatus: json['sessionStatus'] ?? 0,
      visitDurationInHours: json['visitDurationInHours'] ?? 0,
      nurseName: json['nurseName'] ?? '',
      patientName: json['patientName'] ?? '',
      medicalServiceName: json['medicalServiceName'] ?? '',
      visitDate: json['visitDate'] ?? '',
      geocodedAddress: json['geocodedAddress'] != null
          ? GeocodedAddress.fromJson(json['geocodedAddress'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionStatus': sessionStatus,
      'visitDurationInHours': visitDurationInHours,
      'nurseName': nurseName,
      'patientName': patientName,
      'medicalServiceName': medicalServiceName,
      'visitDate': visitDate,
      'geocodedAddress': geocodedAddress?.toJson(),
    };
  }
}