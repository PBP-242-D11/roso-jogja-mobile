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
  bool _isLoading = false;
  String? _error;

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
    _initializeFields();
    _fetchRestaurants();
  }

  void _initializeFields() {
    _type = widget.promo.type;
    _value = widget.promo.value.toString();
    _minPayment = widget.promo.minPayment.toString();
    _selectedRestaurants = List.from(widget.promo.restaurants);
    _promoCode = widget.promo.promoCode;
    _expiryDate = widget.promo.expiryDate.toString().substring(0, 10);
    _maxUsage = widget.promo.maxUsage.toString();
    _shownToPublic = widget.promo.shownToPublic;
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.cookieRequest
          .get('${AppConfig.apiUrl}/promo/owned_resto/');

      if (!mounted) return;

      if (response != null && response.isNotEmpty) {
        setState(() {
          _restaurants = response["restos"] as List<dynamic>? ?? [];
          final temp = _restaurants
              .where((restaurant) =>
                  _selectedRestaurants.contains(restaurant["name"]))
              .map((restaurant) => restaurant["id"].toString())
              .toList();
          _selectedRestaurants = temp;
          _error = null;
        });
      } else {
        setState(() => _error = "No restaurants found");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Failed to load restaurants");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_expiryDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _expiryDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<bool> _isPromoCodeUnique(String promoCode) async {
    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.cookieRequest.get(
        '${AppConfig.apiUrl}/promo/check_promo_code/$promoCode/?promo_id=${widget.promo.id}');
    return response['exists'] != true;
  }

  Future<void> _submitForm(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRestaurants.isEmpty) {
      _showErrorSnackBar('Please select at least one restaurant');
      return;
    }

    _formKey.currentState!.save();

    if (!_shownToPublic && (_promoCode == null || _promoCode!.isEmpty)) {
      _showErrorSnackBar('Private promos require a promo code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_promoCode != null && _promoCode!.isNotEmpty) {
        final isUnique = await _isPromoCodeUnique(_promoCode!);
        if (!isUnique && mounted) {
          _showErrorSnackBar('Promo code already exists');
          setState(() => _isLoading = false);
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

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSuccessSnackBar('Promo updated successfully');
        context.pop(true);
      } else {
        _showErrorSnackBar('Failed to update promo');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Promo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _restaurants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withAlpha(204),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBasicInfoCard(),
                          const SizedBox(height: 20),
                          _buildPromoSettingsCard(),
                          const SizedBox(height: 20),
                          _buildRestaurantsCard(),
                          const SizedBox(height: 24),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _type,
              decoration:
                  _buildInputDecoration('Promo Type', Icons.local_offer),
              items: const [
                DropdownMenuItem(
                    value: 'Percentage', child: Text('Percentage Discount')),
                DropdownMenuItem(
                    value: 'Fixed Price', child: Text('Fixed Price Discount')),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _value,
              decoration: _buildInputDecoration(
                'Promo Value',
                _type == 'Percentage' ? Icons.percent : Icons.payments,
                hint:
                    _type == 'Percentage' ? 'Enter percentage' : 'Enter amount',
              ),
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
                  _buildInputDecoration('Minimum Payment', Icons.payment),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter the minimum payment'
                  : null,
              onSaved: (value) => _minPayment = value!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSettingsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promo Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _promoCode,
              decoration: _buildInputDecoration(
                'Promo Code',
                Icons.code,
                hint: 'Optional for public promos',
              ),
              onSaved: (value) => _promoCode = value?.trim(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(text: _expiryDate),
                  decoration: _buildInputDecoration(
                      'Expiry Date', Icons.calendar_today),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an expiry date'
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _maxUsage,
              decoration: _buildInputDecoration(
                'Maximum Usage',
                Icons.repeat,
                hint: 'Enter -1 for unlimited',
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
            SwitchListTile(
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
              activeColor: Colors.orange[700],
              onChanged: (value) => setState(() => _shownToPublic = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applicable Restaurants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              ..._restaurants.map((restaurant) {
                final id = restaurant['id'];
                return CheckboxListTile(
                  title: Text(restaurant['name']),
                  subtitle: Text(
                    restaurant['address'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  value: _selectedRestaurants.contains(id),
                  activeColor: Colors.orange[700],
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
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed:
          _isLoading ? null : () => _submitForm(context.read<AuthProvider>()),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Update Promo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.orange[700]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange[700]!),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
