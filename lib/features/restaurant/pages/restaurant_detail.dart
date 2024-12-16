import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';
import 'package:roso_jogja_mobile/features/restaurant/widgets/food_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  Future<Restaurant> fetchRestaurantDetail(
      CookieRequest request, String restaurantId) async {
    final response = await request
        .get('${AppConfig.apiUrl}/restaurant/api/restaurants/$restaurantId/');
    return Restaurant.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isRestaurantOwner =
        authProvider.user != null && authProvider.user!.role == "R";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Detail'),
      ),
      body: FutureBuilder<Restaurant>(
        future: fetchRestaurantDetail(
            authProvider.cookieRequest, widget.restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Restaurant not found"));
          } else {
            Restaurant restaurant = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/restaurant_placeholder_${restaurant.placeholderImage}.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Restaurant Name
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Restaurant Address
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Restaurant Description
                  Text(
                    restaurant.description == ""
                        ? "No description given"
                        : restaurant.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Categories
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: restaurant.categories
                        .split(',')
                        .map((category) => Chip(
                              label: Text(
                                category.trim(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[200],
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Menu Section
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (isRestaurantOwner)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool? result = await context.push(
                              '/restaurant/${widget.restaurantId}/create');

                          if (result != null && result == true) {
                            setState(() {});
                          }
                        },
                        child: const Text('Add Food'),
                      ),
                    ),

                  if (restaurant.foods != null && restaurant.foods!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurant.foods!.length,
                      itemBuilder: (context, index) {
                        return FoodCard(
                            food: restaurant.foods![index],
                            isRestaurantOwner: isRestaurantOwner,
                            restaurantId: restaurant.id,
                            refreshRestaurantDetailsCallback: () {
                              setState(() {});
                            });
                      },
                    )
                  else
                    const Center(
                      child: Text(
                        'No menu available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
