import 'package:homecare/mvc/model/api/case.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/mvc/model/api/lab_model.dart';
import 'package:homecare/mvc/model/api/lab_test_model.dart';

class HealthRecordModel {
  int id;
  int sessionStatus;
  int visitDurationInHours;
  String nurseName;
  String patientName;
  String medicalServiceName;
  String visitDate;
  GeocodedAddress? geocodedAddress;
  PreviousCase? visitCase;
  LabModel? lab;
  List<LabTestModel> labTests;

  HealthRecordModel({
    required this.id,
    required this.sessionStatus,
    required this.visitDurationInHours,
    required this.nurseName,
    required this.patientName,
    required this.medicalServiceName,
    required this.visitDate,
    required this.geocodedAddress,
    required this.visitCase,
    this.lab,
    this.labTests = const [],
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
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
      visitCase: json['sesssionDetails'] != null
          ? PreviousCase.fromJson(json['sesssionDetails'], json['visitDate'])
          : null,
      lab: json['lab'] != null ? LabModel.fromJson(json['lab']) : null,
      labTests: (json['labTests'] as List?)
          ?.map((labTestJson) => LabTestModel.fromJson(labTestJson))
          .toList() ?? [],
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
      'lab': lab?.toJson(),
      'labTests': labTests.map((labTest) => labTest.toJson()).toList(),
    };
  }
}
