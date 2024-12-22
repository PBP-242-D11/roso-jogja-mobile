import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import '../models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? refreshRestaurantCallback;
  final bool isRestaurantOwner;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isRestaurantOwner,
    this.refreshRestaurantCallback,
  });

  Future<void> _deleteRestaurant(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
          '${AppConfig.apiUrl}/restaurant/api/restaurants/delete/${restaurant.id}/');

      if (context.mounted) {
        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Restaurant deleted successfully'),
            backgroundColor: Colors.green,
          ));

          refreshRestaurantCallback?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete restaurant'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete restaurant'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user; // Ambil data user

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/restaurant/${restaurant.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder untuk gambar restoran
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/restaurant_placeholder_${restaurant.placeholderImage}.png'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: restaurant.categories
                          .split(',')
                          .map((category) => Chip(
                                label: Text(
                                  category.trim(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.grey[200],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Icon Love (Wishlist)
              IconButton(
                icon: Icon(
                   Icons.favorite
                  
                ),
                onPressed: () {
                  if (user == null) {
                    // Jika user belum login
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please login to manage your wishlist'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  };
                },
              ),
              if (isRestaurantOwner)
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      onPressed: () async {
                        bool? result = await context.push('/restaurant/update',
                            extra: restaurant);
                        if (result != null && result == true) {
                          refreshRestaurantCallback?.call();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Restaurant'),
                            content: const Text(
                                'Are you sure you want to delete this restaurant?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context.pop();
                                  _deleteRestaurant(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
