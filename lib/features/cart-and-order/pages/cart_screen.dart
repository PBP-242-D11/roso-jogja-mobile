import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/cart-and-order/models/cart_response.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:roso_jogja_mobile/features/cart-and-order/widgets/cart_food_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<CartResponse> _futureCart;
  late Future<Map<String, dynamic>> _promoFuture;
  String paymentMethodValue = 'SELECT';
  final notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureCart = fetchCartItems(context);
  }

  @override
  void initState() {
    super.initState();
    _promoFuture = fetchPromoApplied();
  }

  void _refreshPromo() {
    setState(() {
      _promoFuture = fetchPromoApplied();
    });
  }

  Future<CartResponse> fetchCartItems(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response =
        await request.get('${AppConfig.apiUrl}/order/api/mobile_cart/');

    if (response is Map<String, dynamic>) {
      return CartResponse.fromJson(response);
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<void> _removePromo(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response =
          await request.get('${AppConfig.apiUrl}/promo/remove_promo_usage/');

      if (context.mounted) {
        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Promo removed successfully'),
            backgroundColor: Colors.green,
          ));
          _refreshPromo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to remove promo'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to remove promo'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<Map<String, dynamic>> fetchPromoApplied() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response =
        await request.get('${AppConfig.apiUrl}/order/api/show_promo_applied/');
    return {
      'promo_cut': response["promo_cut"],
      'final_price': response["final_price"],
    };
  }

  Future<void> clearCart(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response =
        await request.get('${AppConfig.apiUrl}/order/api/cart/clear/');

    if (response['message'] == 'Successfully cleared the cart') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _futureCart = fetchCartItems(context);
      });
      setState(() {
        _promoFuture = fetchPromoApplied();
      });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to clear cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> orderNow(
      BuildContext context, String paymentMethod, String notes) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    request.headers['Content-Type'] = 'application/json';

    final body = jsonEncode(
        {"notes": notes, "payment_method": paymentMethod, "final_price": 0});

    final response = await request.post(
      '${AppConfig.apiUrl}/order/api/mobile_create_order/',
      body,
    );

    request.headers.remove('Content-Type');

    if (response['message'] == 'Order Created Successfully') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _futureCart = fetchCartItems(context);
      });
      notesController.clear();
      setState(() {
        paymentMethodValue = 'SELECT';
      });
      setState(() {
        _promoFuture = fetchPromoApplied();
      });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to place order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRestaurantHeader(String? restaurantName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 165, 0, 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ordering from',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      restaurantName ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(String restaurantId) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.local_offer_outlined, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Text(
                  'Promotional Offers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/promo/use/$restaurantId/'),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Find Available Promos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_order.png',
            width: 200,
            height: 200,
            opacity: const AlwaysStoppedAnimation<double>(0.8),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/restaurant'),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Restaurants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.orange.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'Any special requests for your order?',
                prefixIcon: const Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.orange.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.orange.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: paymentMethodValue,
              items: const [
                DropdownMenuItem(
                    value: 'SELECT', child: Text('Select Payment Method')),
                DropdownMenuItem(
                    value: 'CASH', child: Text('Cash on Delivery')),
                DropdownMenuItem(value: 'CREDIT', child: Text('Credit Card')),
                DropdownMenuItem(value: 'PAYPAL', child: Text('PayPal')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => paymentMethodValue = value);
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                  onPressed: paymentMethodValue == 'SELECT'
                      ? null
                      : () async {
                          final notes = notesController.text.trim();
                          await orderNow(context, paymentMethodValue, notes);
                        },
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.orange.shade200,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary(CartResponse cart) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate_outlined, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rp ${cart.total}',
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _promoFuture,
              builder: (context, promoSnapshot) {
                if (promoSnapshot.hasData &&
                    promoSnapshot.data!['promo_cut'] != null) {
                  final promoCut = promoSnapshot.data!['promo_cut'];
                  final finalPrice = promoSnapshot.data!['final_price'];
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Promo Discount:',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '- Rp $promoCut',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _removePromo(context),
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 18),
                        label: const Text(
                          'Remove Promo',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Final Total:',
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Rp $finalPrice',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFFFF7ED),
      drawer: const LeftDrawer(),
      body: FutureBuilder<CartResponse>(
        future: _futureCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final cart = snapshot.data!;
          final items = cart.items;
          final restaurant = cart.restaurant;

          if (items.isEmpty) {
            return _buildEmptyCart();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureCart = fetchCartItems(context);
                _promoFuture = fetchPromoApplied();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRestaurantHeader(restaurant?.name),
                  const SizedBox(height: 24),
                  if (restaurant != null) _buildPromoSection(restaurant.id!),
                  const SizedBox(height: 24),
                  _buildPricingSummary(cart), // Add the pricing summary here
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => clearCart(context),
                        icon: const Icon(Icons.remove_shopping_cart,
                            color: Colors.red, size: 20),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CartFoodCard(
                        foodId: item.id,
                        name: item.name,
                        price: item.price,
                        quantity: item.quantity,
                        onUpdate: () {
                          setState(() {
                            _futureCart = fetchCartItems(context);
                            _promoFuture = fetchPromoApplied();
                          });
                        },
                        onRemove: () {
                          setState(() {
                            _futureCart = fetchCartItems(context);
                            _promoFuture = fetchPromoApplied();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildCheckoutSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
