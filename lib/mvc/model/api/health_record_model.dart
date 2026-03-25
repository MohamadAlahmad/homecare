import 'package:homecare/mvc/model/api/lab_model.dart';
import 'package:homecare/mvc/model/api/lab_test_model.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/mvc/model/api/case.dart';

class HealthRecordModel {
  int id;
  int sessionStatus;
  int visitDurationInHours;
  String nurseName;
  String patientName;
  String medicalServiceName;
  String medicalServiceTypeName;
  DateTime visitDate;
  String? caseDescription;
  GeocodedAddress? geocodedAddress;
  PreviousCase? visitCase;
  LabModel? lab;
  List<LabTestModel> labTests;
  List<PatientAttachment> patientAttachments;
  bool attachmentsAdded;
  bool isDeleted;

  HealthRecordModel({
    required this.id,
    required this.sessionStatus,
    required this.visitDurationInHours,
    required this.nurseName,
    required this.patientName,
    required this.medicalServiceName,
    required this.medicalServiceTypeName,
    required this.visitDate,
    this.caseDescription,
    required this.geocodedAddress,
    required this.visitCase,
    this.lab,
    this.labTests = const [],
    this.patientAttachments = const [],
    required this.attachmentsAdded,
    required this.isDeleted,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] ?? 0,
      sessionStatus: json['sessionStatus'] ?? 0,
      visitDurationInHours: json['visitDurationInHours'] ?? 0,
      nurseName: json['nurseName'] ?? '',
      patientName: json['patientName'] ?? '',
      medicalServiceName: json['medicalServiceName'] ?? '',
      medicalServiceTypeName: json['medicalServiceTypeName'] ?? '',
      visitDate: DateTime.tryParse(json['visitDate'] ?? '') ?? DateTime.now(),
      caseDescription: json['caseDescription'] ?? '',
      geocodedAddress: json['geocodedAddress'] != null
          ? GeocodedAddress.fromJson(json['geocodedAddress'])
          : null,
      visitCase: json['sesssionDetails'] != null
          ? PreviousCase.fromJson(json['sesssionDetails'], json['visitDate'])
          : null,
      lab: json['lab'] != null ? LabModel.fromJson(json['lab']) : null,
      labTests: (json['labTests'] as List?)
          ?.map((e) => LabTestModel.fromJson(e))
          .toList() ??
          [],
      patientAttachments: (json['patientAttachments'] as List?)
          ?.map((e) => PatientAttachment.fromJson(e))
          .toList() ??
          [],
      attachmentsAdded: json['attachmentsAdded'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
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
      'medicalServiceTypeName': medicalServiceTypeName,
      'visitDate': visitDate.toIso8601String(),
      'caseDescription': caseDescription,
      'geocodedAddress': geocodedAddress?.toJson(),
      'lab': lab?.toJson(),
      'labTests': labTests.map((e) => e.toJson()).toList(),
      'patientAttachments': patientAttachments.map((e) => e.toJson()).toList(),
      'attachmentsAdded': attachmentsAdded,
      'isDeleted': isDeleted,
    };
  }
}

// ── PatientAttachment ────────────────────────────────────────────────────────

class PatientAttachment {
  final String url;
  final int id;

  const PatientAttachment({required this.url, required this.id});

  factory PatientAttachment.fromJson(Map<String, dynamic> json) {
    return PatientAttachment(
      url: json['url'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'id': id};
}