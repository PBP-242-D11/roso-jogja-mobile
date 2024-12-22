import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class CreatePromoPage extends StatefulWidget {
  const CreatePromoPage({super.key});

  @override
  State<CreatePromoPage> createState() => _CreatePromoPageState();
}

class _CreatePromoPageState extends State<CreatePromoPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _type = 'Percentage'; // Default value
  String _value = '';
  String _minPayment = '';
  final List<String> _selectedRestaurants = [];
  String? _promoCode;
  String _expiryDate = '';
  String _maxUsage = '';
  bool _shownToPublic = false;

  // Fetch restaurants from API
  Future<List<dynamic>> fetchRestaurants() async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response =
          await request.get('${AppConfig.apiUrl}/promo/owned_resto/');
      if (response == null || response.isEmpty) {
        throw Exception("Empty response from the server");
      }
      // Extract and return restaurant data
      return response["restos"] as List<dynamic>? ?? [];
    } catch (e) {
      throw Exception("Error fetching restaurants: $e");
    }
  }

  Future<bool> isPromoCodeUnique(String promoCode) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;
    final response = await request
        .get('${AppConfig.apiUrl}/promo/check_promo_code/$promoCode/');

    if (response['exists'] == true) {
      return false; // Promo code already exists
    }
    return true; // Promo code is unique
  }

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Promo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promo Type Dropdown
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Promo Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Percentage',
                      child: Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'Fixed Price',
                      child: Text('Fixed Price'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a promo type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Promo Value
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Promo Value',
                    hintText: 'Enter the promo value',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the promo value';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _value = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Minimum Payment
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Minimum Payment',
                    hintText: 'Enter the minimum payment',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the minimum payment';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _minPayment = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Restaurant Checklist
                const Text('Select Restaurants:',
                    style: TextStyle(fontSize: 16)),
                FutureBuilder<List<dynamic>>(
                  future: fetchRestaurants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Loading restaurants...'),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No restaurants available.'),
                      );
                    }

                    final restaurants = snapshot.data!;
                    return Column(
                      children: restaurants.map((restaurant) {
                        final id = restaurant['id'];
                        final name = restaurant['name'];
                        return CheckboxListTile(
                          title: Text(name),
                          value: _selectedRestaurants.contains(id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedRestaurants.add(id);
                              } else {
                                _selectedRestaurants.remove(id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Promo Code
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Promo Code (Optional)',
                    hintText: 'Enter the promo code',
                  ),
                  onSaved: (value) {
                    _promoCode = value?.trim();
                  },
                ),
                const SizedBox(height: 16),

                // Expiry Date
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'YYYY-MM-DD',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the expiry date';
                    }
                    final expiry = DateTime.tryParse(value);
                    if (expiry == null || expiry.isBefore(DateTime.now())) {
                      return 'Expiry date must be a valid date in the future';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _expiryDate = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Max Usage
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Max Usage (-1 for unlimited usage)',
                    hintText: 'Enter the maximum usage',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the maximum usage';
                    }
                    final maxUsage = int.tryParse(value);
                    if (maxUsage == null || maxUsage < -1) {
                      return 'Max usage cannot be less than -1';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _maxUsage = value!;
                  },
                ),
                const SizedBox(height: 16),

                // Shown to Public
                SwitchListTile(
                  title: const Text('Show to Public'),
                  value: _shownToPublic,
                  onChanged: (value) {
                    setState(() {
                      _shownToPublic = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedRestaurants.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Select at least one restaurant')),
                        );
                        return;
                      }

                      _formKey.currentState!.save();

                      if ((_promoCode == null || _promoCode!.isEmpty)) {
                        if (!_shownToPublic) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Enter a promo code if not public')),
                          );
                          return;
                        }
                      }

                      // Validate promo code uniqueness
                      if (_promoCode != null && _promoCode != "") {
                        bool isUnique = await isPromoCodeUnique(_promoCode!);
                        if (!isUnique) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Promo code already exists. Please enter a different one.')),
                          );
                          return;
                        }
                      }

                      final response = await authProvider.cookieRequest.post(
                        '${AppConfig.apiUrl}/promo/mobile_add_promo/',
                        {
                          'type': _type,
                          'value': _value,
                          'min_payment': _minPayment,
                          'restaurants': _selectedRestaurants.join(','),
                          'promo_code': _promoCode,
                          'expiry_date': _expiryDate,
                          'max_usage': _maxUsage,
                          'shown_to_public': _shownToPublic.toString(),
                        },
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Promo created successfully.')),
                          );
                          context.pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to create promo.')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Create Promo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
