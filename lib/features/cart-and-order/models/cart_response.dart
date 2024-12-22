// file: cart_response.dart
import 'dart:convert';

class CartResponse {
  final String total;
  final Restaurant? restaurant;
  final List<CartItemResponse> items;

  CartResponse({
    required this.total,
    required this.restaurant,
    required this.items,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      total: (json["total"]) ?? "0.0",
      restaurant: json["restaurant"] != null
          ? Restaurant.fromJson(json["restaurant"])
          : null,
      items: json["items"] == null
          ? []
          : (json["items"] as List)
              .map((item) => CartItemResponse.fromJson(item))
              .toList(),
    );
  }

  factory CartResponse.fromRawJson(String str) =>
      CartResponse.fromJson(json.decode(str));
}

class Restaurant {
  final String name;
  final String? id;

  Restaurant({
    required this.name,
    this.id,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json["name"]?.toString() ?? "",
      id: json["id"]?.toString() ?? "",
    );
  }
}

class CartItemResponse {
  final String id; 
  final String name;
  final String price;
  final int quantity;

  CartItemResponse({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      price: (json["price"]) ?? 0,
      quantity: json["quantity"],
    );
  }
}
