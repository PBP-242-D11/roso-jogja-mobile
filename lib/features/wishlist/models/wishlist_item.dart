import 'dart:convert';
import 'package:http/http.dart' as http;

class WishlistItem {
  final int id;
  final String menuItem;
  final DateTime addedAt;

  WishlistItem(
      {required this.id, required this.menuItem, required this.addedAt});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      menuItem: json['menu_item'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  static Future<List<WishlistItem>> fetchWishlist(
      String baseUrl, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wishlist/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => WishlistItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  static Future<void> addWishlistItem(
      String baseUrl, String token, int menuItemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wishlist/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'menu_item': menuItemId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add item to wishlist');
    }
  }

  static Future<void> deleteWishlistItem(
      String baseUrl, String token, int itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/wishlist/$itemId/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item from wishlist');
    }
  }
}
