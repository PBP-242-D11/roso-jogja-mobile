import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class PromoCard extends StatelessWidget {
  final PromoElement promo;
  final VoidCallback? refreshPromoCallback;
  final bool isRestaurantOwner;
  final bool use;
  final String? promoId;

  const PromoCard({
    super.key,
    required this.promo,
    required this.isRestaurantOwner,
    required this.use,
    this.promoId,
    this.refreshPromoCallback,
  });

  Future<void> _deletePromo(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
          '${AppConfig.apiUrl}/promo/mobile_delete_promo/${promo.id}/');

      if (context.mounted) {
        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Promo deleted successfully'),
            backgroundColor: Colors.green,
          ));

          refreshPromoCallback?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete promo'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to delete promo'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
  String formattedValue(String promoType, int promoValue) {
    if (promoType == 'Fixed Price') {
      return 'Rp ${promoValue.toString()}';  // Add 'Rp' for Fixed Price
    } else if (promoType == 'Percentage') {
      return '${promoValue.toString()}%';  // Add '%' for Percentage
    } else {
      return promoValue.toString();  // Just the value if type is unknown
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/promo/${promo.id}'), // INI HARUS DIBIKIN DI PROMO_ROUTES
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Replace square image with a dynamic icon based on promo.type
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        promo.type == "Percentage"
                            ? Icons.percent
                            : promo.type == "Currency"
                                ? Icons.attach_money
                                : Icons.money, // Default to a generic money icon
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Promo value and type
                          Text(
                            "${formattedValue(promo.type, promo.value)} off",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Expiry date
                          Text(
                            "Expiry Date: ${promo.expiryDate.toString()}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Promo code
                          Text(
                            "Promo Code: ${promo.promoCode.toString()}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Restaurants
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              // Render up to 3 restaurants as chips
                              ...promo.restaurants.take(3).map((category) => Chip(
                                    label: Text(
                                      category.trim(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey[400],
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  )),
                              // Add a "+ X more" chip if there are more restaurants
                              if (promo.restaurants.length > 3)
                                Chip(
                                  label: Text(
                                    "+ ${promo.restaurants.length - 3} more",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.grey[400],
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isRestaurantOwner)
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      onPressed: () async {
                        bool? result = await context.push('/promo/edit', 
                            extra: promo);
                        if (result != null && result == true) {
                          refreshPromoCallback?.call();
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
                            title: const Text('Delete Promo'),
                            content: const Text(
                                'Are you sure you want to delete this promo?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context.pop();
                                  _deletePromo(context);
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
              if (use)
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 25),
                  color: Colors.orange,
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    final request = authProvider.cookieRequest;
                    
                    try {
                      final response = await request.get('${AppConfig.apiUrl}/promo/tag_promo/?promo_id=${promoId}');

                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promo tagged successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/cart');
                        refreshPromoCallback?.call();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'An error occurred'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('An error occurred while tagging the promo'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }
}

class OtherPromoCard extends StatelessWidget {
  final PromoElement promo;
  final VoidCallback? refreshPromoCallback;

  const OtherPromoCard(
      {super.key,
      required this.promo,
      this.refreshPromoCallback});

  String formattedValue(String promoType, int promoValue) {
    if (promoType == 'Fixed Price') {
      return 'Rp ${promoValue.toString()}';  // Add 'Rp' for Fixed Price
    } else if (promoType == 'Percentage') {
      return '${promoValue.toString()}%';  // Add '%' for Percentage
    } else {
      return promoValue.toString();  // Just the value if type is unknown
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/promo/${promo.id}'), 
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        promo.type == "Percentage"
                            ? Icons.percent
                            : promo.type == "Currency"
                                ? Icons.attach_money
                                : Icons.money,
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Promo value and type
                          Text(
                            "${formattedValue(promo.type, promo.value)} off",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Expiry date
                          Text(
                            "Expiry Date: ${promo.expiryDate.toString()}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Promo code
                          Text(
                            "Promo Code: ${promo.promoCode.toString()}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Restaurants
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              // Render up to 3 restaurants as chips
                              ...promo.restaurants.take(3).map((category) => Chip(
                                    label: Text(
                                      category.trim(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey[400],
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  )),
                              // Add a "+ X more" chip if there are more restaurants
                              if (promo.restaurants.length > 3)
                                Chip(
                                  label: Text(
                                    "+ ${promo.restaurants.length - 3} more",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.grey[400],
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}