class LabModel {
  int id;
  num? rate;
  String name;
  bool isSelected = false;

  LabModel({
    required this.id,
    required this.rate,
    required this.name,
  });

  factory LabModel.fromJson(Map<String, dynamic> json) {
    return LabModel(
      id: json['id'] ?? 0,
      rate: json['rate'] ?? 0,
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate': rate,
      'name': name,
    };
  }
}