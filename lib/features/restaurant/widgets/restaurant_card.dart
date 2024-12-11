import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

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
        ),
      ),
    );
  }
}
