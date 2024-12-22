import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import "package:go_router/go_router.dart";

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
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select a rating before submitting your review.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cookieRequest = authProvider.cookieRequest;

    setState(() => _isLoading = true);

    try {
      final response = await cookieRequest.post(
        '${AppConfig.apiUrl}/review/api/add_review_mobile/${widget.restaurantId}/',
        {
          'rating': _rating.toString(),
          'comment': _reviewController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review added successfully!')),
        );

        widget.refreshRestaurantDetailsCallback?.call();

        context.pop();
      } else {
        final error = response['error'] ?? 'Failed to add review.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
          tooltip: 'Rate ${index + 1} stars',
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
                _buildStarRating(),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Review Text',
                    hintText: 'Write your review here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write a review';
                    }
                    if (value.trim().length > 500) {
                      return 'Review cannot exceed 500 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
