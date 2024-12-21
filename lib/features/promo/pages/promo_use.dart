import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_model.dart';


class UsePromo extends StatefulWidget {
  final String restoId;
  const UsePromo({super.key, required this.restoId});

  @override
  State<UsePromo> createState() => _UsePromoPageState();
}

class _UsePromoPageState extends State<UsePromo> {
  late Future<Map<String, dynamic>> futurePromos;
  final TextEditingController promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futurePromos = fetchPromo(widget.restoId); // Use widget.restoId here
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchPromo(String restaurantId) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    // Make the GET request
    final response = await request.get('${AppConfig.apiUrl}/promo/mobile_use_promo/$restaurantId/');

    if (response == null || response.isEmpty) {
      throw Exception("Empty response from the server");
    }

    // Check for error fields in the response map
    if (response.containsKey('error')) {
      final errorMessage = response['error'] as String;
      if (errorMessage.contains('Cart not found')) {
        throw Exception("Error: Cart not found");
      } else {
        throw Exception("Error: $errorMessage");
      }
    }

    // Process successful response
    final promos = response["promos"] as List<dynamic>? ?? [];
    final otherPromos = response["other_promos"] as List<dynamic>? ?? [];
    final message = response["message"] ?? 'No message available';

    return {
      'promos': promos,
      'other_promos': otherPromos,
      'message': message,
    };
  }


  Future<void> tagPromo(int promoId) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response = await request.post('${AppConfig.apiUrl}/promo/tag_promo/', {'promo_id': promoId.toString()});
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo tagged successfully!')),
      );
      context.go('/cart');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to tag promo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRestaurantOwner = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Promo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
      future: futurePromos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data;

          // Ensure data is not null and has the expected structure
          if (data == null || !data.containsKey('promos') || !data.containsKey('other_promos')) {
            return const Center(child: Text("Invalid data format received"));
          }

          // Extract the 'promos' and 'otherPromos' lists
          final promos = (data['promos'] as List<dynamic>? ?? [])
            .where((promo) => promo is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();

        final otherPromos = (data['other_promos'] as List<dynamic>? ?? [])
            .where((promo) => promo is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();

          if (promos.isEmpty && otherPromos.isEmpty) {
            return const Center(child: Text("No promos available"));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: promoCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Input your promo code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final promoCode = promoCodeController.text.trim();
                    if (promoCode.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a promo code')),
                      );
                      return;
                    }

                    try {
                      // Send the promo code to the backend
                      final authProvider = context.read<AuthProvider>();
                      final request = authProvider.cookieRequest;

                      final response = await request.get('${AppConfig.apiUrl}/promo/find_by_code/$promoCode/');

                      if (response == null || response.isEmpty || response['promo'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Promo code not found')),
                        );
                        return;
                      }

                      // Display promo details
                      final promoDetails = response['promo'];
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Promo Found'),
                          content: Text(
                            'Promo Code: ${promoDetails['promo_code']}\n'
                            'Discount: ${promoDetails['type'] == 'Percentage' ? '${promoDetails['value']}%' : 'Rp ${promoDetails['value']}'}',
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black, // Black box
                                    foregroundColor: Colors.white, // White text
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Back'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.orange, // Orange box
                                    foregroundColor: Colors.white, // White text
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  onPressed: () async {
                                    final authProvider = context.read<AuthProvider>();
                                    final request = authProvider.cookieRequest;

                                    try {
                                      // Send the request to tag the promo
                                      final response = await request.get('${AppConfig.apiUrl}/promo/tag_promo/?promo_id=${promoDetails['id']}');

                                      if (response['status'] == 'success') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Promo tagged successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // Redirect to /cart
                                        context.go('/cart');
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to tag promo'),
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
                                  child: const Text('Apply Promo'),
                                ),
                              ],
                            ),

                          ],
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Find Promo'),
                ),
              const SizedBox(height: 12),

              // Render the first list only if promos are available
              if (promos.isNotEmpty)
                const Text('Available Promos', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: promos.length,
                    itemBuilder: (context, index) {
                      final promo = promos[index];
                      return PromoCard(
                        promo: PromoElement.fromJson(promo),
                        isRestaurantOwner: isRestaurantOwner,
                        promoId: promo["id"],
                        use: true,
                        refreshPromoCallback: () {
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              // Display the "Other Promos" section if available promos exist
              if (otherPromos.isNotEmpty)
                const Text('Other Promos', style: TextStyle(fontWeight: FontWeight.bold)),
              // Render the second list only if otherPromos are available
              if (otherPromos.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: otherPromos.length,
                    itemBuilder: (context, index) {
                      final promo = otherPromos[index];
                      return OtherPromoCard(
                        promo: PromoElement.fromJson(promo),
                      );
                    },
                  ),
                ),
              // Default fallback if neither list is available
              if (promos.isEmpty && otherPromos.isEmpty)
                const Center(child: Text("No data available")),
            ],
          );


          } else {
            // Default fallback if none of the above conditions match
            return const Center(child: Text("No data available"));
          }
        }

      ),
    );
  }
  }
