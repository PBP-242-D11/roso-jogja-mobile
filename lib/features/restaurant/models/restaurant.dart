// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

List<Restaurant> restaurantFromJson(String str) =>
    List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));

String restaurantToJson(List<Restaurant> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Restaurant {
  String id;
  String name;
  String slug;
  String description;
  String address;
  String categories;
  int placeholderImage;

  Restaurant({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.address,
    required this.categories,
    required this.placeholderImage,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        address: json["address"],
        categories: json["categories"],
        placeholderImage: json["placeholder_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "address": address,
        "categories": categories,
        "placeholder_image": placeholderImage,
      };
}
