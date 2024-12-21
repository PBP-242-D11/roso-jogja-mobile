import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/cart-and-order/models/order_response.dart';

class OrderDetailPage extends StatelessWidget {
  final FlutterOrder order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = Colors.orange.shade700;
    final headingColor = Colors.grey.shade800;
    final cardColor = Colors.white;
    final shadowColor = Colors.black.withOpacity(0.05);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Detail',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFFFF7ED),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.restaurant,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ordered on:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.createdAt,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
                        const SizedBox(height: 12),
                        Text(
                          'Total:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${order.totalPrice}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
              

                ],
              ),
              
            ),


            const SizedBox(height: 32),

            _buildSectionTitle('Order Information', headingColor),
            const SizedBox(height: 16),

            _buildInfoCard(
              context: context,
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              value: order.notes.isEmpty ? '-' : order.notes,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context: context,
              icon: Icons.credit_card,
              label: 'Payment Method',
              value: order.paymentMethod,
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context: context,
              icon: Icons.discount_outlined,
              label: 'Discount',
              value: 'Rp ${order.promoCut}',
              backgroundColor: cardColor,
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Food Items', headingColor),
            const SizedBox(height: 16),
            if (order.orderItems.isEmpty)
              Center(
                child: Text('No food items found.', style: TextStyle(color: Colors.grey[600])),
              )
            else
              Column(
                children: order.orderItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.foodName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.brown[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rp ${item.priceAtOrder} x ${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color? headingColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade600,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}