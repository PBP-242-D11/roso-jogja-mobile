// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';
import 'food.dart';

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
  List<Food>? foods;

  Restaurant({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.address,
    required this.categories,
    required this.placeholderImage,
    this.foods,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        address: json["address"],
        categories: json["categories"],
        placeholderImage: json["placeholder_image"],
        foods: json["foods"] != null
            ? List<Food>.from(json["foods"].map((x) => Food.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "address": address,
        "categories": categories,
        "placeholder_image": placeholderImage,
        "foods": foods != null
            ? List<dynamic>.from(foods!.map((x) => x.toJson()))
            : null,
      };
}
