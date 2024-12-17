import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShoppingCartPage(),
    );
  }
}

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: const Color(0xFFFF7043),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Shopping Cart',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 24),

              // Cart items container (mock static content)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order List',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7043), // Button color
                            ),
                            child: const Text('Clear Cart'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mock Cart Items
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3, // Example 3 items
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.shopping_cart, color: Color(0xFF333333)),
                            title: Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Rp 100.000', style: TextStyle(color: Color(0xFFFF7043))),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFF7043)),
                                ),
                                const Text('1'),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF7043)),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Details Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Price
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp 300.000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF7043))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Promo Section (Hidden for now)
                      // Note: This part can be conditionally displayed later
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Promo Cutoff:', style: TextStyle(fontSize: 18)),
                              Text('Rp 50.000', style: TextStyle(fontSize: 18, color: Color(0xFFFF7043))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Final Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Rp 250.000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF7043))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Payment and Notes Section
                      const Text('Restaurant:', style: TextStyle(fontSize: 16)),
                      const Text('- Your Restaurant Name Here', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Payment Method Dropdown
                      DropdownButton<String>(
                        isExpanded: true,
                        value: 'SELECT',
                        onChanged: (newValue) {},
                        items: <String>['SELECT', 'Cash on Delivery', 'Credit Card', 'PayPal']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Notes Section
                      const TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes:',
                          border: OutlineInputBorder(),
                          hintText: 'Write additional notes here...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Order Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}