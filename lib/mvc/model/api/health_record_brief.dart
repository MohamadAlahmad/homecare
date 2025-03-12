class HealthRecordBrief {
  int id;
  String nurseName;
  String medicalServiceName;
  String visitDate;

  HealthRecordBrief({
    required this.id,
    required this.nurseName,
    required this.medicalServiceName,
    required this.visitDate,
  });

  factory HealthRecordBrief.fromJson(Map<String, dynamic> json) {
    return HealthRecordBrief(
      id: json['id'] ?? 0,
      nurseName: json['nurseName'] ?? '',
      medicalServiceName: json['medicalServiceName'] ?? '',
      visitDate: json['visitDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nurseName': nurseName,
      'medicalServiceName': medicalServiceName,
      'visitDate': visitDate,
    };
  }
}