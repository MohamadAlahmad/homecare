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
  });

  factory PreviousCase.fromJson(Map<String, dynamic> json) {
    final bioMarkers = json['bioMarkers'] as List;
    return PreviousCase(
      bloodPressureFirstValue: bioMarkers[0]['value'],
      bloodPressureSecondValue: bioMarkers[1]['value'],
      bloodSugar: bioMarkers[2]['value'],
      heartRate: bioMarkers[3]['value'],
      oxygenation: bioMarkers[4]['value'],
      notes: json['notes'],
      basicServicePrice: json['basicServicePrice'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      additionalFeesDescription: json['additionalFees']['description'] ?? '',
      additionalFeesPrice: json['additionalFees']['price'] ?? 0,
    );
  }
}
