class LabTestModel {
  int id;
  num price;
  String name;
  bool isSelected = false;

  LabTestModel({
    required this.id,
    required this.price,
    required this.name,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      id: json['id'] ?? 0,
      price: json['price'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'name': name,
    };
  }
}
