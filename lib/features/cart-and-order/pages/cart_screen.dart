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
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restaurant, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Restaurant:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant != null ? restaurant.name : '-',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              'Total:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              'Rp $total',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
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
                const SizedBox(height: 2),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFF7ED), // Background color
                    foregroundColor:
                        Colors.black87, // Text color for better contrast
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Smaller rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16), // Reduced padding
                    elevation: 2, // Lower elevation for a sleeker look
                    shadowColor: Colors.black
                        .withOpacity(0.05), // Shadow color directly defined
                  ),
                  onPressed: () {
                    if (restaurant == null || restaurant.id == null) {
                      // Show a SnackBar with a red background if restaurant or restaurant.id is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "You have to input something in your cart first!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Navigate to the route with the restaurant ID if not null
                      final String restaurantId = restaurant.id!;
                      context.go('/promo/use/$restaurantId/');
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 18, // Smaller icon size
                        color: Colors.orange, // Icon color
                      ),
                      const SizedBox(
                          width: 4), // Reduced space between icon and text
                      Builder(
                        builder: (context) {
                          final theme =
                              Theme.of(context); // Access the theme here
                          return Text(
                            'Find a Promo', // Shortened text for a smaller button
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600, // Bold text
                              fontSize: 16, // Smaller font size
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>>(
                  future: _promoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      if (data.containsKey('message') &&
                          data['status'] != 'success') {
                        return Center(
                          child: Text(
                            data['message'] ?? 'An error occurred',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      final promoCut = snapshot.data!['promo_cut'];
                      final finalPrice = snapshot.data!['final_price'];
                      if (promoCut == null || finalPrice == null) {
                        return const Center(
                          child: Text(
                            'No promo applied.',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Promo Cut:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '- Rp $promoCut',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Final Price:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                'Rp $finalPrice',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                            ],
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Promo'),
                                    content: const Text(
                                        'Are you sure you want to remove this promo?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _removePromo(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.delete_outline, // Delete icon
                                    size: 18, // Smaller icon size
                                    color: Colors.orange, // Icon color
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Reduced space between icon and text
                                  Builder(
                                    builder: (context) {
                                      final theme = Theme.of(
                                          context); // Access the theme here
                                      return Text(
                                        'Remove Promo', // Button label
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight:
                                              FontWeight.w600, // Bold text
                                          fontSize: 16, // Smaller font size
                                          color: Colors
                                              .black, // Text color matching the icon
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox(); // If no data or waiting
                  },
                ),
                const SizedBox(height: 2),
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
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
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
                                  DropdownMenuItem(
                                      value: 'SELECT',
                                      child: Text('Select Payment Method')),
                                  DropdownMenuItem(
                                      value: 'CASH',
                                      child: Text('Cash on Delivery')),
                                  DropdownMenuItem(
                                      value: 'CREDIT',
                                      child: Text('Credit Card')),
                                  DropdownMenuItem(
                                      value: 'PAYPAL', child: Text('PayPal')),
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
                            onPressed: items.isEmpty ||
                                    paymentMethodValue == 'SELECT'
                                ? null
                                : () async {
                                    final notes = notesController.text.trim();
                                    await orderNow(
                                        context, paymentMethodValue, notes);
                                  },
                            icon: const Icon(
                              Icons.shopping_cart_checkout,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Order Now',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 5,
                              shadowColor: Colors.orange.shade200,
                            ).copyWith(
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed))
                                    return Colors.orange.shade800;
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
