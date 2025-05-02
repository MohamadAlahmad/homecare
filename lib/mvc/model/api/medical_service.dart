class MedicalService {
  int id;
  String name;
  String description;
  String serviceConditions;
  bool isActive;
  String imageUrl; // Change this to imageUrl
  num price;

  MedicalService({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceConditions,
    required this.isActive,
    required this.imageUrl, // Change this to imageUrl
    required this.price,
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) {
    return MedicalService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      serviceConditions: json['serviceConditions'] ?? '',
      isActive: json['isActive'] ?? false,
      imageUrl: json['image']?['url'] ?? '', // Parse the nested 'url' field
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
      'image': {'url': imageUrl}, // Ensure the image field is a map
      'price': price,
    };
  }
}
