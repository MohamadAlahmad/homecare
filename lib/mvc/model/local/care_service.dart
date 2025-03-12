class SubService {
  int id;
  String name;
  String description;
  String image;
  String? price;

  SubService({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.price,
  });

}