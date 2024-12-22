import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:go_router/go_router.dart';

class CreateRestaurantPage extends StatefulWidget {
  const CreateRestaurantPage({super.key});

  @override
  State<CreateRestaurantPage> createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  String _restaurantName = '';
  String _restaurantAddress = '';
  String _restaurantCategories = '';
  String _restaurantDescription = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Restaurant'),
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
                    // Call the API to create the restaurant
                    final response = await authProvider.cookieRequest.post(
                        '${AppConfig.apiUrl}/restaurant/api/restaurants/create/',
                        {
                          'name': _restaurantName,
                          'address': _restaurantAddress,
                          'categories': _restaurantCategories,
                          'description': _restaurantDescription,
                        });

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Restaurant created successfully."),
                        ));
                        context.pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Failed to create restaurant. Please try again.")));
                      }
                    }
                  }
                },
                child: const Text('Create Restaurant'),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
