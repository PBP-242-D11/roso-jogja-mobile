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
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  dynamic _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
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
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Picture
                        _buildProfilePicture(),
                        const SizedBox(height: 24),

                        // Input Fields
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneNumberController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.home_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Role Dropdown
                        _buildRoleDropdown(),
                        const SizedBox(height: 16),

                        // Password Fields
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        _buildRegisterButton(context, authProvider),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 100,
        ),
        const SizedBox(height: 16),
        Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join RosoJogja and start your culinary journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _profileImage != null
                ? kIsWeb
                    ? NetworkImage(_profileImage.path)
                    : FileImage(_profileImage) as ImageProvider
                : null,
            child: _profileImage == null
                ? Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.orange[700],
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !(isPasswordVisible ?? false),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.orange[700],
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ?? false
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.orange[700],
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        border: _outlineInputBorder(),
        enabledBorder: _outlineInputBorder(),
        focusedBorder: _outlineInputBorder(color: Colors.orange[700]!),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(
          Icons.work_outline,
          color: Colors.orange[700],
        ),
        border: _outlineInputBorder(),
        enabledBorder: _outlineInputBorder(),
        focusedBorder: _outlineInputBorder(color: Colors.orange[700]!),
      ),
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
    );
  }

  Widget _buildRegisterButton(BuildContext context, AuthProvider authProvider) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _registerUser(context, authProvider),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange[700],
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 5,
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text(
              'Register',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
    );
  }

  OutlineInputBorder _outlineInputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color ?? Colors.grey.shade300,
        width: 1.5,
      ),
    );
  }

  Future<void> _registerUser(
      BuildContext context, AuthProvider authProvider) async {
    if (!_validateInputs(context)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64
      String? base64Image;
      if (_profileImage != null) {
        List<int> imageBytes;
        if (kIsWeb) {
          imageBytes = await _profileImage.readAsBytes();
        } else {
          imageBytes = await _profileImage.readAsBytes();
        }
        base64Image = base64Encode(imageBytes);
      }

      // Send registration request
      final response = await authProvider.cookieRequest.postJson(
        '${AppConfig.apiUrl}/mobile_register/',
        jsonEncode({
          "username": _usernameController.text.trim(),
          "password1": _passwordController.text,
          "password2": _confirmPasswordController.text,
          "phone_number": _phoneNumberController.text.trim(),
          "address": _addressController.text.trim(),
          "role": selectedRole,
          "profile_picture": base64Image,
        }),
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          context.pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('Registration successful! Please login.'),
                backgroundColor: Colors.orange[700],
              ),
            );
        } else {
          _showErrorDialog(
              context, response['message'] ?? 'Registration failed!');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs(BuildContext context) {
    if (_profileImage == null) {
      _showErrorDialog(context, 'Please upload a profile picture');
      return false;
    }

    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _addressController.text.isEmpty ||
        selectedRole == null) {
      _showErrorDialog(context, 'Please fill in all fields');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange[700],
            ),
            child: const Text('OK'),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}