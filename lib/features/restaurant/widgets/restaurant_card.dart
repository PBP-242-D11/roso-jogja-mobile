import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import '../models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onDelete;
  final bool isRestaurantOwner;

  const RestaurantCard(
      {super.key,
      required this.restaurant,
      required this.isRestaurantOwner,
      this.onDelete});

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

          onDelete?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete restaurant'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to delete restaurant'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: GestureDetector(
        onTap: () => context.go('/restaurant/${restaurant.id}'),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          title: Text(
            restaurant.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          subtitle: Text(
            restaurant.address,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          minVerticalPadding: 20,
          trailing: isRestaurantOwner
              ? IconButton(
                  icon: const Icon(Icons.delete),
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
                                      backgroundColor: Colors.red),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ));
                  },
                )
              : null,
        ),
      ),
    );
  }
}
