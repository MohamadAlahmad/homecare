// Class for patient added by patient
class Patient {
  int id;
  String firstName;
  String lastName;
  String locationDetails;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.locationDetails,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      locationDetails: json['geocodedAddress'] != null ? json['geocodedAddress']['details'] : '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'locationDetails': locationDetails,
    };
  }
}