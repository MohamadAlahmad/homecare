class PreviousCase {
  final String bloodPressureFirstValue;
  final String bloodPressureSecondValue;
  final String bloodSugar;
  final String heartRate;
  final String oxygenation;
  final String notes;
  num? basicServicePrice;
  num? finalPrice;
  String? additionalFeesDescription;
  num? additionalFeesPrice;
  DateTime visitDate;

  PreviousCase({
    required this.bloodPressureFirstValue,
    required this.bloodPressureSecondValue,
    required this.bloodSugar,
    required this.heartRate,
    required this.oxygenation,
    required this.notes,
    required this.basicServicePrice,
    required this.finalPrice,
    required this.additionalFeesDescription,
    required this.additionalFeesPrice,
    required this.visitDate,
  });

  factory PreviousCase.fromJson(Map<String, dynamic> json, String visitDate) {
    final bioMarkers = json['bioMarkers'] as List;
    return PreviousCase(
      bloodPressureFirstValue: bioMarkers.isNotEmpty ? bioMarkers[0]['value'] : '',
      bloodPressureSecondValue: bioMarkers.length > 1 ? bioMarkers[1]['value'] : '',
      bloodSugar: bioMarkers.length > 2 ? bioMarkers[2]['value'] : '',
      heartRate: bioMarkers.length > 3 ? bioMarkers[3]['value'] : '',
      oxygenation: bioMarkers.length > 4 ? bioMarkers[4]['value'] : '',
      notes: json['notes'] ?? '',
      basicServicePrice: json['basicServicePrice'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      additionalFeesDescription: json['additionalFees']?['description'] ?? '',
      additionalFeesPrice: json['additionalFees']?['price'] ?? 0,
      visitDate: DateTime.parse(visitDate),
    );
  }
}
