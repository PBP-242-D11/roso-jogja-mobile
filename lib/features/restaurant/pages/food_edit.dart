import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import '../models/food.dart';

class EditFoodPage extends StatefulWidget {
  final Food food;
  final String restaurantId;

  const EditFoodPage(
      {super.key, required this.food, required this.restaurantId});

  @override
  State<EditFoodPage> createState() => _EditFoodPageState();
}

class _EditFoodPageState extends State<EditFoodPage> {
  final _formKey = GlobalKey<FormState>();
  late String _foodName;
  late String _foodDescription;
  late String _foodPrice;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with the passed food's data
    _foodName = widget.food.name;
    _foodDescription = widget.food.description;
    _foodPrice = widget.food.price.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _foodName,
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
                  initialValue: _foodPrice,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter the food price',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  initialValue: _foodDescription,
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

                      try {
                        // Call the API to update the food item
                        final response = await authProvider.cookieRequest.post(
                          '${AppConfig.apiUrl}/restaurant/api/restaurants/${widget.restaurantId}/update_food/${widget.food.id}/',
                          {
                            'name': _foodName,
                            'price': _foodPrice,
                            'description': _foodDescription,
                          },
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Food item updated successfully."),
                            ));
                            context.pop(true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(response['message'] ??
                                  "Failed to update food item. Please try again."),
                            ));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error updating food item: $e"),
                          ));
                        }
                      }
                    }
                  },
                  child: const Text('Update Food Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
