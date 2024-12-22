import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/widgets/promo_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';

class UsePromo extends StatefulWidget {
  final String restoId;
  const UsePromo({super.key, required this.restoId});

  @override
  State<UsePromo> createState() => _UsePromoPageState();
}

class _UsePromoPageState extends State<UsePromo> {
  late Future<Map<String, dynamic>> futurePromos;
  final TextEditingController promoCodeController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futurePromos = fetchPromo();
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchPromo() async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request
          .get('${AppConfig.apiUrl}/promo/mobile_use_promo/${widget.restoId}/');

      if (response == null || response.isEmpty) {
        throw Exception("Empty response from the server");
      }

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      return {
        'promos': response["promos"] as List<dynamic>? ?? [],
        'other_promos': response["other_promos"] as List<dynamic>? ?? [],
        'message': response["message"] ?? 'No message available',
      };
    } catch (e) {
      throw Exception("Failed to fetch promos: $e");
    }
  }

  Future<void> applyPromoCode(String promoCode) async {
    if (promoCode.isEmpty) {
      if (!mounted) return;
      _showSnackBar('Please enter a promo code', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final request = authProvider.cookieRequest;

      final response = await request
          .get('${AppConfig.apiUrl}/promo/find_by_code/$promoCode/');

      if (!mounted) return;

      if (response == null || response.isEmpty || response['promo'] == null) {
        _showSnackBar('Promo code not found', isError: true);
        return;
      }

      final promoDetails = response['promo'];
      if (!mounted) return;

      // Use showDialog with a BuildContext from a widget that is definitely mounted
      await showDialog(
        context: context,
        builder: (dialogContext) =>
            _buildPromoDialog(dialogContext, promoDetails),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> tagPromo(String promoId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final request = authProvider.cookieRequest;

      final response = await request
          .get('${AppConfig.apiUrl}/promo/tag_promo/?promo_id=$promoId');

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackBar('Promo tagged successfully!');
        // Use go_router's context-independent navigation
        if (!mounted) return;
        GoRouter.of(context).go('/cart');
      } else {
        _showSnackBar('Failed to tag promo', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('An error occurred while tagging the promo', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPromoDialog(
      BuildContext context, Map<String, dynamic> promoDetails) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Promo Found', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromoDetailRow('Code:', promoDetails['promo_code']),
          const SizedBox(height: 8),
          _buildPromoDetailRow(
            'Discount:',
            promoDetails['type'] == 'Percentage'
                ? '${promoDetails['value']}%'
                : 'Rp ${promoDetails['value']}',
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDialogButton(
              onPressed: () => Navigator.pop(context),
              label: 'Back',
              backgroundColor: Colors.black87,
            ),
            _buildDialogButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog first
                tagPromo(promoDetails['id']); // Then tag promo
              },
              label: 'Apply Promo',
              backgroundColor: Colors.orange[700]!,
            ),
          ],
        ),
      ],
    );
  }

  // Update the ElevatedButton in _buildPromoCodeInput():
  Widget _buildPromoCodeInput() {
    return Card(
      // ... rest of the card properties ...
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: promoCodeController,
              decoration: InputDecoration(
                labelText: 'Enter Promo Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => applyPromoCode(
                      promoCodeController.text.trim()), // Updated this line
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(isLoading ? 'Searching...' : 'Find Promo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildDialogButton({
    required VoidCallback onPressed,
    required String label,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildPromoSection(
      String title, List<Map<String, dynamic>> promos, bool isMainPromo) {
    if (promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: promos.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final promo = promos[index];
            return isMainPromo
                ? PromoCard(
                    promo: PromoElement.fromJson(promo),
                    isRestaurantOwner: false,
                    promoId: promo["id"],
                    use: true,
                    refreshPromoCallback: () => setState(() {}),
                  )
                : OtherPromoCard(
                    promo: PromoElement.fromJson(promo),
                  );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Promo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
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
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      futurePromos = fetchPromo();
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final data = snapshot.data!;
          final promos = List<Map<String, dynamic>>.from(data['promos'] ?? []);
          final otherPromos =
              List<Map<String, dynamic>>.from(data['other_promos'] ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoCodeInput(),
                _buildPromoSection('Available Promos', promos, true),
                _buildPromoSection('Other Promos', otherPromos, false),
                if (promos.isEmpty && otherPromos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No Promos Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for exciting offers!',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
