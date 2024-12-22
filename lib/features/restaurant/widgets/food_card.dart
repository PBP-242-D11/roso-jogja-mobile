// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/cart-and-order/models/cart_response.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/food.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback? refreshRestaurantDetailsCallback;
  final bool isRestaurantOwner;
  final String restaurantId;

  const FoodCard({
    super.key,
    required this.food,
    required this.isRestaurantOwner,
    required this.restaurantId,
    this.refreshRestaurantDetailsCallback,
  });

  Future<void> _deleteFood(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
        '${AppConfig.apiUrl}/restaurant/api/restaurants/$restaurantId/delete_food/${food.id}/',
      );

      if (context.mounted) {
        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food item deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          refreshRestaurantDetailsCallback?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete food item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete food item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> addToCart(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

      final cartResponse = await request.get('${AppConfig.apiUrl}/order/api/mobile_cart/');

      if (cartResponse == null || cartResponse.isEmpty) {
        throw Exception('Failed to fetch cart details.');
      }

      if (cartResponse is! Map<String, dynamic>) {
        throw Exception('Invalid cart response format.');
      }

      final CartResponse currentCart = CartResponse.fromJson(cartResponse);
      final String? currentRestaurantId = currentCart.restaurant?.id;

      if (currentRestaurantId == null || currentRestaurantId == restaurantId) {
        await _proceedToAddToCart(context, request);
      } else {
        bool? shouldReplace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace Cart'),
            content: const Text(
              'Your cart contains items from another restaurant. Do you want to replace the cart with items from this restaurant?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Replace',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

        if (shouldReplace == true) {
          final clearResponse = await request.get('${AppConfig.apiUrl}/order/api/cart/clear/');

          if (clearResponse['message'] == 'Successfully cleared the cart') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cart has been cleared. Adding new item.'),
                backgroundColor: Colors.green,
              ),
            );

            await _proceedToAddToCart(context, request);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(clearResponse['message'] ?? 'Failed to clear the cart.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
  }

  Future<void> _proceedToAddToCart(BuildContext context, CookieRequest request) async {
      final response = await request.get(
        '${AppConfig.apiUrl}/order/api/cart/add/${food.id}/?quantity=1',
      );

      if (response['message'] == 'Food added successfully' ||
          response['message'] == 'Item quantity updated successfully') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food item added to cart successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to add food item to cart'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Food Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Food Price
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Rp ${food.price}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
              ),
            ),
            // Edit and Delete Buttons for Restaurant Owner
            if (isRestaurantOwner)
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.blue,
                    onPressed: () async {
                      // Navigate to food update screen
                      bool? result = await context.push(
                        '/restaurant/$restaurantId/update_food',
                        extra: food,
                      );

                      // Refresh if update was successful
                      if (result != null && result == true) {
                        refreshRestaurantDetailsCallback?.call();
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
                          title: const Text('Delete Food Item'),
                          content: const Text(
                            'Are you sure you want to delete this food item?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.pop();
                                _deleteFood(context);
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
            
            if (!isRestaurantOwner)
              Padding(
                padding: const EdgeInsets.only(left: 8.0), 
                child: SizedBox(
                  width: 36,
                  height: 36, 
                  child: ElevatedButton(
                    onPressed: () async {
                      await addToCart(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero, 
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
