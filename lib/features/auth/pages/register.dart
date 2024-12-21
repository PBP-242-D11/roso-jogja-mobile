import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  List<String> roles = ['Customer', 'Restaurant Owner'];
  String? selectedRole;

  dynamic _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Moderate quality to balance performance and size
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = kIsWeb ? pickedFile : File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create an Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Profile Picture Upload
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _profileImage != null
                                ? kIsWeb
                                    ? NetworkImage(_profileImage.path)
                                    : FileImage(_profileImage) as ImageProvider
                                : null,
                            child: _profileImage == null
                                ? const Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
                          if (_profileImage != null)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    size: 20, color: Colors.blueAccent),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Fields
                  _buildInputField(
                      _usernameController, 'Username', Icons.person),
                  const SizedBox(height: 12),
                  _buildInputField(
                      _phoneNumberController, 'Phone Number', Icons.phone,
                      inputType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildInputField(_addressController, 'Address', Icons.home),
                  const SizedBox(height: 12),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Role', Icons.work_outline),
                    value: selectedRole,
                    hint: const Text('Select Role'),
                    onChanged: (String? newValue) {
                      setState(() => selectedRole = newValue);
                    },
                    items: roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Password Fields
                  _buildInputField(_passwordController, 'Password', Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 12),
                  _buildInputField(_confirmPasswordController,
                      'Confirm Password', Icons.lock_outline,
                      isPassword: true),
                  const SizedBox(height: 24),

                  // Register Button
                  ElevatedButton(
                    onPressed: () => _registerUser(context, authProvider),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      decoration: _inputDecoration(label, icon),
    );
  }

  void _registerUser(BuildContext context, AuthProvider authProvider) async {
    // Validate inputs
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a profile picture'),
        ),
      );
      return;
    }

    // Prepare data for registration
    String username = _usernameController.text;
    String password1 = _passwordController.text;
    String password2 = _confirmPasswordController.text;
    String phoneNumber = _phoneNumberController.text;
    String address = _addressController.text;

    // Convert image to base64
    String? base64Image;
    if (_profileImage != null) {
      List<int> imageBytes;
      if (kIsWeb) {
        // For web, use the XFile to read bytes
        imageBytes = await _profileImage.readAsBytes();
      } else {
        // For mobile, use File
        imageBytes = await _profileImage.readAsBytes();
      }
      base64Image = base64Encode(imageBytes);
    }

    // Send registration request
    final response = await authProvider.cookieRequest.postJson(
      '${AppConfig.apiUrl}/mobile_register/',
      jsonEncode({
        "username": username,
        "password1": password1,
        "password2": password2,
        "phone_number": phoneNumber,
        "address": address,
        "role": selectedRole,
        "profile_picture": base64Image,
      }),
    );

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered!'),
          ),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to register!'),
          ),
        );
      }
    }
  }
}
