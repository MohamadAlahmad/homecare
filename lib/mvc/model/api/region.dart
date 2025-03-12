class Region {
  int id;
  String name;

  Region({
    required this.id,
    required this.name,
  });

  @override
  String toString() => name; // Return the region's name

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
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