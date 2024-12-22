import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';

class WishlistItem extends Restaurant {
  WishlistItem({
    required super.id,
    required super.slug,
    required super.name,
    required super.address,
    required super.categories,
    required super.description,
    required super.placeholderImage,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      description: json["description"],
      address: json["address"],
      categories: json["categories"],
      placeholderImage: json["placeholder_image"],
    );
  }
}
