import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:intl/intl.dart';

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
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final request = authProvider.cookieRequest;

      final response = await request
          .get('${AppConfig.apiUrl}/promo/mobile_delete_promo/${promo.id}/');

      if (!context.mounted) return;

      if (response["status"] == "success") {
        _showSnackBar(context, 'Promo deleted successfully', isError: false);
        refreshPromoCallback?.call();
      } else {
        _showSnackBar(context, 'Failed to delete promo', isError: true);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Failed to delete promo', isError: true);
    }
  }

  Future<void> _tagPromo(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final request = authProvider.cookieRequest;

      final response = await request
          .get('${AppConfig.apiUrl}/promo/tag_promo/?promo_id=$promoId');

      if (!context.mounted) return;

      if (response['status'] == 'success') {
        _showSnackBar(context, 'Promo tagged successfully!', isError: false);
        GoRouter.of(context).go('/cart');
        refreshPromoCallback?.call();
      } else {
        _showSnackBar(
          context,
          response['message'] ?? 'An error occurred',
          isError: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'An error occurred while tagging the promo',
        isError: true,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  String formattedValue(String promoType, int promoValue) {
    final formatter = NumberFormat("#,###", "id_ID");
    if (promoType == 'Fixed Price') {
      return 'Rp ${formatter.format(promoValue)}';
    } else if (promoType == 'Percentage') {
      return '$promoValue%';
    }
    return promoValue.toString();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildPromoIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Icon(
        promo.type == "Percentage"
            ? Icons.percent
            : promo.type == "Currency"
                ? Icons.payments
                : Icons.local_offer,
        color: Colors.orange[700],
        size: 24,
      ),
    );
  }

  Widget _buildRestaurantChips() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...promo.restaurants.take(3).map((restaurant) => Chip(
              label: Text(
                restaurant.trim(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: Colors.orange[300],
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
        if (promo.restaurants.length > 3)
          Chip(
            label: Text(
              "+ ${promo.restaurants.length - 3} more",
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isRestaurantOwner) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: Colors.blue[600],
            tooltip: 'Edit Promo',
            onPressed: () async {
              final result = await context.push('/promo/edit', extra: promo);
              if (result == true) {
                refreshPromoCallback?.call();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            color: Colors.red[600],
            tooltip: 'Delete Promo',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      );
    } else if (use) {
      return IconButton(
        icon: const Icon(Icons.add_circle, size: 28),
        color: Colors.orange[700],
        tooltip: 'Use Promo',
        onPressed: () => _tagPromo(context),
      );
    }
    return const SizedBox.shrink();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promo'),
        content: const Text('Are you sure you want to delete this promo?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.shade100),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/promo/${promo.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPromoIcon(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${formattedValue(promo.type, promo.value)} off",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                          ),
                        ),
                        _buildActionButtons(context),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Valid until ${_formatDate(promo.expiryDate)}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Code: ${promo.promoCode}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildRestaurantChips(),
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

class OtherPromoCard extends PromoCard {
  const OtherPromoCard({
    super.key,
    required super.promo,
    super.refreshPromoCallback,
  }) : super(
          isRestaurantOwner: false,
          use: false,
        );
}
