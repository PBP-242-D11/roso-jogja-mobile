import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class PromoDetailPage extends StatefulWidget {
  final String promoId;

  const PromoDetailPage({super.key, required this.promoId});

  @override
  State<PromoDetailPage> createState() => _PromoDetailPageState();
}

class _PromoDetailPageState extends State<PromoDetailPage> {
  Future<PromoElement> fetchPromoDetail(
      CookieRequest request, String restaurantId) async {
    final response = await request
        .get('${AppConfig.apiUrl}/promo/mobile_promo_details/$restaurantId/');
    return PromoElement.fromJson(response);
  }

  String formattedValue(String promoType, int promoValue) {
    if (promoType == 'Fixed Price') {
      return 'Rp ${promoValue.toString()}'; // Add 'Rp' for Fixed Price
    } else if (promoType == 'Percentage') {
      return '${promoValue.toString()}%'; // Add '%' for Percentage
    } else {
      return promoValue.toString(); // Just the value if type is unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Detail'),
      ),
      body: FutureBuilder<PromoElement>(
        future: fetchPromoDetail(authProvider.cookieRequest, widget.promoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Promo not found"));
          } else {
            PromoElement promo = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promo Name
                  Text(
                    "${formattedValue(promo.type, promo.value)} off",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Promo Payment
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Minimum Payment: ${promo.minPayment.toString()}",
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

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Expiry Date: ${promo.expiryDate.toString()}",
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
                  Row(
                    children: [
                      const Icon(Icons.key, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Promo Code: ${promo.promoCode.toString()}",
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

                  // Restaurants
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: promo.restaurants
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
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
