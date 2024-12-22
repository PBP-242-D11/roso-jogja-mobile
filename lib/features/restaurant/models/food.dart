class Food {
  String id;
  String name;
  String description;
  String price;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
      };
}
