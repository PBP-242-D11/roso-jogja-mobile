import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/widgets/promo_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';

class PromoHome extends StatefulWidget {
  const PromoHome({super.key});

  @override
  State<PromoHome> createState() => _PromoHomePageState();
}

class _PromoHomePageState extends State<PromoHome> {
  late Future<Map<String, dynamic>> futurePromos;

  Future<Map<String, dynamic>> fetchPromo() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final request = authProvider.cookieRequest;

      final response =
          await request.get('${AppConfig.apiUrl}/promo/mobile_promo_home/');

      if (response == null) {
        throw Exception("No response from server");
      }

      final promos = response["promos"] as List<dynamic>? ?? [];
      final otherPromos = response["other_promos"] as List<dynamic>? ?? [];
      final message = response["message"]?.toString() ?? 'No message available';

      return {
        'promos': promos,
        'other_promos': otherPromos,
        'message': message,
      };
    } catch (e) {
      throw Exception("Failed to fetch promos: $e");
    }
  }

  Widget _buildRestaurantOwnerHeader() {
    return Container(
      width: double.infinity, // Ensure container takes full width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.orange[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make children stretch full width
        children: [
          const Text(
            'Restaurant Owner Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your restaurant\'s promotional offers',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              bool? result = await context.push('/promo/add');
              if (result == true) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create New Promo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      width: double.infinity, // Ensure container takes full width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.orange[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make children stretch full width
        children: [
          const Text(
            'Available Promotions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover the latest offers from your favorite restaurants',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isRestaurantOwner) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isRestaurantOwner ? 'No Active Promos' : 'No Promotions Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isRestaurantOwner
                  ? 'Start creating promotional offers for your restaurant!'
                  : 'Check back later for exciting offers and discounts!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (isRestaurantOwner) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                bool? result = await context.push('/promo/add');
                if (result == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Your First Promo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRestaurantOwner = user != null && user.role == "R";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRestaurantOwner ? 'Promo Management' : 'Available Promos',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchPromo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmptyState(isRestaurantOwner);
            }

            final data = snapshot.data!;
            final promos = (data['promos'] as List<dynamic>?)
                    ?.where((promo) => promo is Map<String, dynamic>)
                    .cast<Map<String, dynamic>>()
                    .toList() ??
                [];

            final otherPromos = (data['other_promos'] as List<dynamic>?)
                    ?.where((promo) => promo is Map<String, dynamic>)
                    .cast<Map<String, dynamic>>()
                    .toList() ??
                [];

            if (promos.isEmpty && otherPromos.isEmpty) {
              return _buildEmptyState(isRestaurantOwner);
            }

            return Column(
              children: [
                // Role-specific header
                if (isRestaurantOwner)
                  _buildRestaurantOwnerHeader()
                else
                  _buildCustomerHeader(),

                // Promos list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: promos.length + otherPromos.length,
                    itemBuilder: (context, index) {
                      final isPromo = index < promos.length;
                      final promo = isPromo
                          ? promos[index]
                          : otherPromos[index - promos.length];

                      if (!promo.containsKey('value') ||
                          !promo.containsKey('type')) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: isPromo
                            ? PromoCard(
                                promo: PromoElement.fromJson(promo),
                                isRestaurantOwner: isRestaurantOwner,
                                use: false,
                                refreshPromoCallback: () => setState(() {}),
                              )
                            : OtherPromoCard(
                                promo: PromoElement.fromJson(promo),
                              ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
