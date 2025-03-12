class MedicalService {
  int id;
  String name;
  String description;
  String serviceConditions;
  bool isActive;
  String image;
  num price;

  MedicalService({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceConditions,
    required this.isActive,
    required this.image,
    required this.price,
  });

factory MedicalService.fromJson(Map<String, dynamic> json) {
    return MedicalService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      serviceConditions: json['serviceConditions'] ?? '',
      isActive: json['isActive'] ?? false,
      image: json['image'] ?? '',
      price: json['price'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'serviceConditions': serviceConditions,
      'isActive': isActive,
      'image': image,
      'price': price,
    };
  }
}