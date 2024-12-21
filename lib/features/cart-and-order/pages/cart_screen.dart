import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
  String paymentMethodValue = 'SELECT';
  final notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureCart = fetchCartItems(context);
  }

  Future<CartResponse> fetchCartItems(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response = await request.get('${AppConfig.apiUrl}/order/api/mobile_cart/');

    if (response is Map<String, dynamic>) {
      return CartResponse.fromJson(response);
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<void> clearCart(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    final response = await request.get('${AppConfig.apiUrl}/order/api/cart/clear/');

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

  Future<void> orderNow(BuildContext context, String paymentMethod, String notes) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final request = authProvider.cookieRequest;

    request.headers['Content-Type'] = 'application/json';

    final body = jsonEncode({
      "notes": notes,
      "payment_method": paymentMethod,
      "final_price": 0 
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFFFF7ED),
      drawer: const LeftDrawer(),
      body: FutureBuilder<CartResponse>(
        future: _futureCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final cart = snapshot.data!;
          final items = cart.items;
          final total = cart.total;
          final restaurant = cart.restaurant;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.orange.shade700,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Restaurant:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant != null ? restaurant.name : '-',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Total:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              'Rp $total',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Items',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await clearCart(context);
                        },
                        child: const Text(
                          'Clear Cart',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (items.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          'assets/images/no_order.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your cart is empty.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final foodId = item.id;
                      final name = item.name;
                      final price = item.price;
                      final quantity = item.quantity;

                      return CartFoodCard(
                        foodId: foodId,
                        name: name,
                        price: price,
                        quantity: quantity,
                        onUpdate: () {
                          setState(() {
                            _futureCart = fetchCartItems(context);
                          });
                        },
                        onRemove: () {
                          setState(() {
                            _futureCart = fetchCartItems(context);
                          });
                        },
                      );
                    },
                  ),

                const SizedBox(height: 32),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payment, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Checkout',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Icon(Icons.payment, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Payment Method',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'SELECT', child: Text('Select Payment Method')),
                                  DropdownMenuItem(value: 'CASH', child: Text('Cash on Delivery')),
                                  DropdownMenuItem(value: 'CREDIT', child: Text('Credit Card')),
                                  DropdownMenuItem(value: 'PAYPAL', child: Text('PayPal')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      paymentMethodValue = value;
                                    });
                                  }
                                },
                                value: paymentMethodValue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: items.isEmpty || paymentMethodValue == 'SELECT'
                                ? null
                                : () async {
                                    final notes = notesController.text.trim();
                                    await orderNow(context, paymentMethodValue, notes);
                                  },
                            icon: const Icon(
                              Icons.shopping_cart_checkout,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Order Now',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 5,
                              shadowColor: Colors.orange.shade200,
                            ).copyWith(
                              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) return Colors.orange.shade800;
                                  return null; 
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
