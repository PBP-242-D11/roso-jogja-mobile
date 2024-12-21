import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class AddReviewPage extends StatefulWidget {
  final String restaurantId;
  final VoidCallback? refreshRestaurantDetailsCallback;

  const AddReviewPage({
    super.key,
    required this.restaurantId,
    this.refreshRestaurantDetailsCallback,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();

  int _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Accessing context before any await is safe
    final authProvider = context.read<AuthProvider>();
    final cookieRequest = authProvider.cookieRequest;
    // Ensure the user is logged in and the session cookie is stored in cookieRequest

    setState(() => _isLoading = true);

    try {
      // Call the add_review_mobile endpoint (CSRF-exempt) to avoid needing a CSRF token
      final response = await cookieRequest.post(
        '${AppConfig.apiUrl}/review/api/add_review_mobile/${widget.restaurantId}/',
        {
          // Fields as per backend requirements
          'rating': _rating.toString(),
          'comment': _reviewController.text,
        },
      );

      // Check if the widget is still mounted after the asynchronous operation
      if (!mounted) return;

      // Check the response from the backend
      // For example, in Django, you might return {"status": "success"}
      if (response['status'] == 'success') {
        // Successfully added the review
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil ditambahkan!')),
        );

        // Refresh restaurant details if needed
        widget.refreshRestaurantDetailsCallback?.call();

        // Navigate back to the previous page
        Navigator.pop(context);
      } else {
        // Failed to add review -> display error message
        final error = response['error'] ?? 'Gagal menambahkan review';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle connection errors or other exceptions
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menambahkan review'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Ensure the widget is still mounted before updating the state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStarRating() {
    const int maxStars = 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _rating > index ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Add Your Review',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Star Rating
                _buildStarRating(),
                const SizedBox(height: 12.0),

                // Review Text Field
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Review Text',
                    hintText: 'Write your review here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write a review';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Submit Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Submit Review'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
