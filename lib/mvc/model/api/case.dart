import 'package:homecare/mvc/model/api/lab_model.dart';

class Case {
  int id;
  int patientId;
  String patientName;
  String medicalServiceName;
  String visitDate;
  GeocodedAddress? geocodedAddress;
  bool prioritized;
  bool specialized;
  num price;
  String? patientPhoneNumber;
  LabModel? lab;
  List<dynamic>? labTests;
  int visitDurationInHours;

  Case({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.medicalServiceName,
    required this.visitDate,
    required this.geocodedAddress,
    required this.prioritized,
    required this.specialized,
    required this.price,
    required this.patientPhoneNumber,
    required this.lab,
    required this.labTests,
    required this.visitDurationInHours,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      patientName: json['patientName'] ?? '',
      medicalServiceName: json['medicalServiceName'] ?? '',
      visitDate: json['visitDate'] ?? '',
      geocodedAddress: json['geocodedAddress'] != null
          ? GeocodedAddress.fromJson(json['geocodedAddress'])
          : null,
      prioritized: json['prioritized'] ?? false,
      specialized: json['specialized'] ?? false,
      price: json['price'] ?? 0,
      patientPhoneNumber: json['patientPhoneNumber'] ?? '(N/A)',
      lab: json['lab'] != null ? LabModel.fromJson(json['lab']) : null, // Parse lab field
      labTests: json['labTests'] ?? [],
      visitDurationInHours: json['visitDurationInHours'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'medicalServiceName': medicalServiceName,
      'visitDate': visitDate,
      'geocodedAddress': geocodedAddress?.toJson(),
      'prioritized': prioritized,
      'specialized': specialized,
      'price': price,
      'patientPhoneNumber': patientPhoneNumber,
      'lab': lab?.toJson(), // Serialize lab field
    };
  }
}

class GeocodedAddress {
  GovernorateDto governorateDto;
  RegionDto regionDto;
  String details;
  int id;

  GeocodedAddress({
    required this.governorateDto,
    required this.regionDto,
    required this.details,
    required this.id,
  });

  factory GeocodedAddress.fromJson(Map<String, dynamic> json) {
    return GeocodedAddress(
      governorateDto: GovernorateDto.fromJson(json['governorateDto']),
      regionDto: RegionDto.fromJson(json['regionDto']),
      details: json['details'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'governorateDto': governorateDto.toJson(),
      'regionDto': regionDto.toJson(),
      'details': details,
      'id': id,
    };
  }
}

class GovernorateDto {
  String name;
  int id;

  GovernorateDto({required this.name, required this.id});

  factory GovernorateDto.fromJson(Map<String, dynamic> json) {
    return GovernorateDto(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

class RegionDto {
  String name;
  int id;

  RegionDto({required this.name, required this.id});

  factory RegionDto.fromJson(Map<String, dynamic> json) {
    return RegionDto(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
