import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import '../models/restaurant.dart';

class EditRestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const EditRestaurantPage({super.key, required this.restaurant});

  @override
  State<EditRestaurantPage> createState() => _EditRestaurantPageState();
}

class _EditRestaurantPageState extends State<EditRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  late String _restaurantName;
  late String _restaurantAddress;
  late String _restaurantCategories;
  late String _restaurantDescription;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with the passed restaurant's data
    _restaurantName = widget.restaurant.name;
    _restaurantAddress = widget.restaurant.address;
    _restaurantCategories = widget.restaurant.categories;
    _restaurantDescription = widget.restaurant.description;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _restaurantName,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter the restaurant name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the restaurant name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _restaurantName = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _restaurantAddress,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter the restaurant address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the restaurant address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _restaurantAddress = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _restaurantCategories,
                  decoration: const InputDecoration(
                    labelText: 'Categories',
                    hintText: 'Enter the restaurant categories',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the restaurant categories';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _restaurantCategories = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _restaurantDescription,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter the restaurant description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the restaurant description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _restaurantDescription = value!;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      try {
                        // Call the API to update the restaurant
                        final response = await authProvider.cookieRequest.post(
                          '${AppConfig.apiUrl}/restaurant/api/restaurants/update/${widget.restaurant.id}/',
                          {
                            'name': _restaurantName,
                            'address': _restaurantAddress,
                            'categories': _restaurantCategories,
                            'description': _restaurantDescription,
                          },
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Restaurant updated successfully."),
                            ));
                            context.pop(true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(response['message'] ??
                                  "Failed to update restaurant. Please try again."),
                            ));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error updating restaurant: $e"),
                          ));
                        }
                      }
                    }
                  },
                  child: const Text('Update Restaurant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
