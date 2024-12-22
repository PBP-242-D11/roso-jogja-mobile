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
  String _type = 'Percentage';
  String _value = '';
  String _minPayment = '';
  final List<String> _selectedRestaurants = [];
  String? _promoCode;
  String _expiryDate = '';
  String _maxUsage = '';
  bool _shownToPublic = false;

  // Loading state
  bool _isLoading = false;

  // Fetch restaurants from API
  Future<List<dynamic>> fetchRestaurants(AuthProvider authProvider) async {
    try {
      final response = await authProvider.cookieRequest
          .get('${AppConfig.apiUrl}/promo/owned_resto/');
      if (response == null || response.isEmpty) {
        throw Exception("Empty response from the server");
      }
      return response["restos"] as List<dynamic>? ?? [];
    } catch (e) {
      throw Exception("Error fetching restaurants: $e");
    }
  }

  Future<bool> isPromoCodeUnique(
      AuthProvider authProvider, String promoCode) async {
    final response = await authProvider.cookieRequest
        .get('${AppConfig.apiUrl}/promo/check_promo_code/$promoCode/');
    return response['exists'] != true;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Promo'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Promo Type
                            Card(
                              elevation: 0,
                              color: Colors.grey[100],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: DropdownButtonFormField<String>(
                                  value: _type,
                                  decoration: const InputDecoration(
                                    labelText: 'Promo Type',
                                    border: InputBorder.none,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Percentage',
                                      child: Text('Percentage Discount'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Fixed Price',
                                      child: Text('Fixed Price Discount'),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _type = value!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Promo Value
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Promo Value',
                                hintText: _type == 'Percentage'
                                    ? 'Enter percentage'
                                    : 'Enter amount',
                                prefixIcon: Icon(_type == 'Percentage'
                                    ? Icons.percent
                                    : Icons.payments),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the promo value';
                                }
                                return null;
                              },
                              onSaved: (value) => _value = value!,
                            ),
                            const SizedBox(height: 16),

                            // Minimum Payment
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Minimum Payment',
                                hintText: 'Enter minimum payment amount',
                                prefixIcon: const Icon(Icons.payment),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the minimum payment';
                                }
                                return null;
                              },
                              onSaved: (value) => _minPayment = value!,
                            ),
                            const SizedBox(height: 24),

                            // Restaurant Selection
                            const Text(
                              'Available Restaurants',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<dynamic>>(
                              future: fetchRestaurants(authProvider),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Card(
                                    color: Colors.red[100],
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Error: ${snapshot.error}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No restaurants available'),
                                    ),
                                  );
                                }

                                return Card(
                                  elevation: 0,
                                  color: Colors.grey[100],
                                  child: Column(
                                    children: snapshot.data!.map((restaurant) {
                                      final id = restaurant['id'];
                                      final name = restaurant['name'];
                                      return CheckboxListTile(
                                        title: Text(name),
                                        value:
                                            _selectedRestaurants.contains(id),
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
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Promo Code
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Promo Code',
                                hintText: 'Optional for public promos',
                                prefixIcon: const Icon(Icons.code),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onSaved: (value) => _promoCode = value?.trim(),
                            ),
                            const SizedBox(height: 16),

                            // Expiry Date
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Expiry Date',
                                    hintText: 'Select expiry date',
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  controller:
                                      TextEditingController(text: _expiryDate),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an expiry date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Max Usage
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Maximum Usage',
                                hintText: 'Enter -1 for unlimited',
                                prefixIcon: const Icon(Icons.tag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                              onSaved: (value) => _maxUsage = value!,
                            ),
                            const SizedBox(height: 16),

                            // Public Switch
                            Card(
                              elevation: 0,
                              color: Colors.grey[100],
                              child: SwitchListTile(
                                title: const Text('Show to Public'),
                                subtitle: Text(
                                  _shownToPublic
                                      ? 'Promo will be visible to all users'
                                      : 'Promo will require a code',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                value: _shownToPublic,
                                onChanged: (value) =>
                                    setState(() => _shownToPublic = value),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _submitForm(authProvider),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create Promo',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRestaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one restaurant')),
      );
      return;
    }

    _formKey.currentState!.save();

    if (!_shownToPublic && (_promoCode == null || _promoCode!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Private promos require a promo code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_promoCode != null && _promoCode!.isNotEmpty) {
        bool isUnique = await isPromoCodeUnique(authProvider, _promoCode!);
        if (mounted && !isUnique) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promo code already exists')),
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

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promo created successfully')),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create promo')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
