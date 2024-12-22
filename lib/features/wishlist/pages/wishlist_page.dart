import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/restaurant/widgets/restaurant_card.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/pagination_metadata.dart';
import 'package:roso_jogja_mobile/features/restaurant/widgets/restaurant_card.dart';
import 'package:roso_jogja_mobile/features/restaurant/widgets/loading_indicator.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/widgets/left_drawer.dart';
import '../../auth/provider/auth_provider.dart';
import "package:go_router/go_router.dart";
import '../models/wishlist_item.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  Future<List<WishlistItem>> fetchWishlist() async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response =
        await request.get('${AppConfig.apiUrl}/wishlist/mobile_wishlist/');
    final wishlistItems = response['wishlist'];
    return (wishlistItems as List)
        .map((restaurant) => WishlistItem.fromJson(restaurant))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load wishlist: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          final List<WishlistItem> wishlist =
              snapshot.data as List<WishlistItem>;

          return ListView.builder(
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              return RestaurantCard(
                restaurant: wishlist[index] as Restaurant,
                isRestaurantOwner: false, // Wishlist tidak membedakan role
                refreshRestaurantCallback: () {
                  setState(() {}); // Refresh data
                },
              );
            },
          );
        },
      ),
    );
  }
}
