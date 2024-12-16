import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/food.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback? refreshRestaurantDetailsCallback;
  final bool isRestaurantOwner;

  const FoodCard(
      {super.key,
      required this.food,
      required this.isRestaurantOwner,
      this.refreshRestaurantDetailsCallback});

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
          ],
        ),
      ),
    );
  }
}
