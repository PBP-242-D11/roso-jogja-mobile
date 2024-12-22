import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class CartFoodCard extends StatelessWidget {
  final String foodId;
  final String name;
  final String price;
  final int quantity;
  final VoidCallback onUpdate;
  final VoidCallback onRemove;

  const CartFoodCard({
    super.key,
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onUpdate,
    required this.onRemove,
  });

  Future<void> _updateQuantity(BuildContext context, int newQuantity) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response = await request.get(
      '${AppConfig.apiUrl}/order/api/cart/update/$foodId/?quantity=$newQuantity',
    );

    if (response['message'] == 'Item quantity updated successfully') {
      onUpdate();
    } else if (response['message'] == 'Item removed successfully') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from cart successfully'),
            backgroundColor: Colors.green,
          ),
        );
        onUpdate();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to update quantity'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response =
        await request.get('${AppConfig.apiUrl}/order/api/cart/remove/$foodId/');

    if (response['message'] == 'Item removed from cart') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart successfully'),
            backgroundColor: Colors.green,
          ),
        );
        onRemove();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to remove item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp $price',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (quantity >= 0) {
                    await _updateQuantity(context, quantity - 1);
                  }
                },
                icon: const Icon(Icons.remove_circle, color: Colors.red),
              ),
              Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  await _updateQuantity(context, quantity + 1);
                },
                icon: const Icon(Icons.add_circle, color: Colors.green),
              ),
              IconButton(
                onPressed: () async {
                  await _removeItem(context);
                },
                icon: const Icon(Icons.delete, color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }
}

