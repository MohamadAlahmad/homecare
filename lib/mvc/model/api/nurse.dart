// Class for patient added by patient
class Nurse {
  int id;
  num rate;
  String firstName;
  String lastName;
  String locationDetails;
  bool isSelected = false;

  Nurse({
    required this.id,
    required this.rate,
    required this.firstName,
    required this.lastName,
    required this.locationDetails,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'] ?? 0,
      rate: json['rate'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      locationDetails: json['geocodedAddress'] != null ? json['geocodedAddress']['details'] : '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate': rate,
      'firstName': firstName,
      'lastName': lastName,
      'locationDetails': locationDetails,
    };
  }
}