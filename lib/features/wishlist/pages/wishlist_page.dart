import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../wishlist/provider/wishlist_provider.dart';
import '../../restaurant/widgets/restaurant_card.dart';

class WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>().wishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Text(
                "No restaurants in wishlist.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final restaurant = wishlist[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  isRestaurantOwner: false, // Tidak relevan di wishlist
                  refreshRestaurantCallback: () {}, // Tidak perlu refresh
                );
              },
            ),
    );
  }
}
