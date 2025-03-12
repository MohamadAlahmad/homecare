class City {
  int id;
  String name;

  City({
    required this.id,
    required this.name,
  });

  @override
  String toString() => name; // Return the city's name

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}