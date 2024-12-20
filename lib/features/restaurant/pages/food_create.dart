import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:go_router/go_router.dart';

class CreateFoodPage extends StatefulWidget {
  final String restaurantId;

  const CreateFoodPage({super.key, required this.restaurantId});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  String _foodName = '';
  String _foodDescription = '';
  String _foodPrice = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter the food name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the food name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _foodName = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter the food price',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the food price';
                    }
                    // Regex to match whole numbers or numbers ending with .00
                    final priceRegex = RegExp(r'^\d+(\.\d{2})?$');
                    if (!priceRegex.hasMatch(value)) {
                      return 'Please enter a valid price (e.g., 10000 or 10000.00)';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Ensure the value is formatted consistently
                    _foodPrice = value!.contains('.')
                        ? double.parse(value).toStringAsFixed(2)
                        : value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter the food description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the food description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _foodDescription = value!;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Call the API to create the food item
                      final response = await authProvider.cookieRequest.post(
                          '${AppConfig.apiUrl}/restaurant/api/restaurants/${widget.restaurantId}/create_food/',
                          {
                            'restaurant': widget.restaurantId.toString(),
                            'name': _foodName,
                            'price': _foodPrice,
                            'description': _foodDescription,
                          });

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Food item created successfully."),
                          ));
                          context.pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response['message'] ??
                                "Failed to create food item. Please try again."),
                          ));
                        }
                      }
                    }
                  },
                  child: const Text('Create Food Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
