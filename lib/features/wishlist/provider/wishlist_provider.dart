import 'package:flutter/material.dart';
import '../../restaurant/models/restaurant.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Restaurant> _wishlist = [];

  List<Restaurant> get wishlist => _wishlist;

  void addToWishlist(Restaurant restaurant) {
    if (!_wishlist.contains(restaurant)) {
      _wishlist.add(restaurant);
      notifyListeners();
    }
  }

  void removeFromWishlist(Restaurant restaurant) {
    _wishlist.remove(restaurant);
    notifyListeners();
  }

  bool isInWishlist(Restaurant restaurant) {
    return _wishlist
        .contains(restaurant); // Cek apakah restoran ada di wishlist
  }
}
