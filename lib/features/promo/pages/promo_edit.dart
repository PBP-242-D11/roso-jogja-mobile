import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/features/promo/models/promo_model.dart';

class EditPromoPage extends StatefulWidget {
  final PromoElement promo;

  const EditPromoPage({super.key, required this.promo});

  @override
  State<EditPromoPage> createState() => _EditPromoPageState();
}

class _EditPromoPageState extends State<EditPromoPage> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _value;
  late String _minPayment;
  late List<String> _selectedRestaurants;
  late String? _promoCode;
  late String _expiryDate;
  late String _maxUsage;
  late bool _shownToPublic;

  late List<dynamic> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _type = widget.promo.type;
    _value = widget.promo.value.toString();
    _minPayment = widget.promo.minPayment.toString();
    _selectedRestaurants = widget.promo.restaurants;
    _promoCode = widget.promo.promoCode;
    _expiryDate = widget.promo.expiryDate.toString().substring(0, 10);
    _maxUsage = widget.promo.maxUsage.toString();
    _shownToPublic = widget.promo.shownToPublic;
    fetchRestaurants();
  }

  Future<List<dynamic>> fetchRestaurants() async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response =
          await request.get('${AppConfig.apiUrl}/promo/owned_resto/');
      if (response == null || response.isEmpty) {
        throw Exception("Empty response from the server");
      }
      setState(() {
        _restaurants = response["restos"] as List<dynamic>? ?? [];
        // Initialize _selectedRestaurants with all restaurant IDs
        _selectedRestaurants = _restaurants
            .map((restaurant) => restaurant['id'] as String)
            .toList();
      });
      return _restaurants;
    } catch (e) {
      throw Exception("Error fetching restaurants: $e");
    }
  }

  Future<bool> isPromoCodeUnique(String promoCode) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response = await request.get(
        '${AppConfig.apiUrl}/promo/check_promo_code/$promoCode/?promo_id=${widget.promo.id}');
    return response['exists'] != true;
  }

  void _submitForm(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRestaurants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one restaurant')),
        );
        return;
      }
      if (_selectedRestaurants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one restaurant')),
        );
        return;
      }

      _formKey.currentState!.save();

      if ((_promoCode == null || _promoCode!.isEmpty)) {
        if (!_shownToPublic) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a promo code if not public')),
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
        '${AppConfig.apiUrl}/promo/mobile_edit_promo/${widget.promo.id}/',
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
            const SnackBar(content: Text('Promo updated successfully.')),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update promo.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Promo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Promo Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Percentage', child: Text('Percentage')),
                    DropdownMenuItem(
                        value: 'Fixed Price', child: Text('Fixed Price')),
                  ],
                  onChanged: (value) => setState(() => _type = value!),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a promo type'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _value,
                  decoration: const InputDecoration(labelText: 'Promo Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the promo value'
                      : null,
                  onSaved: (value) => _value = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _minPayment,
                  decoration:
                      const InputDecoration(labelText: 'Minimum Payment'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the minimum payment'
                      : null,
                  onSaved: (value) => _minPayment = value!,
                ),
                const SizedBox(height: 16),
                const Text('Select Restaurants:'),
                _restaurants.isEmpty
                    ? const Text('Loading restaurants...')
                    : Column(
                        children: _restaurants.map((restaurant) {
                          final id = restaurant['id'];
                          return CheckboxListTile(
                            title: Text(restaurant['name']),
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
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _promoCode,
                  decoration:
                      const InputDecoration(labelText: 'Promo Code (Optional)'),
                  onSaved: (value) => _promoCode = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _expiryDate,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                  validator: (value) => DateTime.tryParse(value!) == null
                      ? 'Enter a valid date (YYYY-MM-DD)'
                      : null,
                  onSaved: (value) => _expiryDate = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _maxUsage,
                  decoration: const InputDecoration(
                      labelText:
                          'Max Usage (negative value for unlimited usage)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => int.tryParse(value!) == null
                      ? 'Enter a valid number'
                      : null,
                  onSaved: (value) => _maxUsage = value!,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Show to Public'),
                  value: _shownToPublic,
                  onChanged: (value) => setState(() => _shownToPublic = value),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _submitForm(context.read<AuthProvider>()),
                  child: const Text('Update Promo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
