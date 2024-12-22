import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class WishlistService {
  static final String baseUrl = '${AppConfig.apiUrl}/wishlist';

  static Future<List<dynamic>> getWishlist(CookieRequest cookieRequest) async {
    final url = baseUrl; // Menggunakan AppConfig untuk baseUrl
    print('Request URL: $url');
    final response = await cookieRequest.get(url);

    print('Response from getWishlist: $response');

    if (response.containsKey('status') && response['status'] == 200) {
      return response['data'];
    } else {
      throw Exception(response['error'] ?? 'Failed to load wishlist');
    }
  }

  static Future<void> addToWishlist(
      CookieRequest cookieRequest, String restaurantId) async {
    final url = baseUrl; // Menggunakan AppConfig untuk baseUrl
    print('Request URL: $url');
    print('Request Body: ${{'restaurant': restaurantId}}');

    final response =
        await cookieRequest.post(url, {'restaurant': restaurantId});

    print('Response from addToWishlist: $response');

    if (response.containsKey('status') && response['status'] == 201) {
      return;
    } else {
      throw Exception(response['error'] ?? 'Failed to add to wishlist');
    }
  }

  static Future<void> removeFromWishlist(
      CookieRequest cookieRequest, String restaurantId) async {
    final url =
        '$baseUrl/$restaurantId/'; // Menggunakan AppConfig untuk baseUrl
    print('Request URL: $url');
    print('Request Body: ${{'_method': 'DELETE'}}');

    final response = await cookieRequest.post(
      url,
      {'_method': 'DELETE'}, // Simulasi DELETE
    );

    print('Response from removeFromWishlist: $response');

    if (response.containsKey('status') && response['status'] == 204) {
      return;
    } else {
      throw Exception(response['error'] ?? 'Failed to remove from wishlist');
    }
  }
}
