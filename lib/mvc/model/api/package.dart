class Package {
  int id;
  int sessionsNumber;
  int timePeriod;
  int visitDurationInHours;
  String name;
  String description;
  num price;
  String image;
  bool isActive;

  Package({
    required this.id,
    required this.sessionsNumber,
    required this.timePeriod,
    required this.visitDurationInHours,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isActive,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      sessionsNumber: json['sessionsNumber'] ?? 0,
      timePeriod: json['timePeriod'] ?? 0,
      visitDurationInHours: json['visitDurationInHours'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionsNumber': sessionsNumber,
      'timePeriod': timePeriod,
      'visitDurationInHours': visitDurationInHours,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'isActive': isActive,
    };
  }
}