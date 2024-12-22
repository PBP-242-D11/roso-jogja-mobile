import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/features/review/pages/add_review.dart';
import 'package:roso_jogja_mobile/features/review/models/review_model.dart';

class ListReview extends StatefulWidget {
  final String restaurantId;
  final VoidCallback? refreshRestaurantDetailsCallback;

  const ListReview({
    super.key,
    required this.restaurantId,
    this.refreshRestaurantDetailsCallback,
  });

  @override
  State<ListReview> createState() => _ListReviewState();
}

class _ListReviewState extends State<ListReview> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews(widget.restaurantId);
  }

  Future<List<Review>> fetchReviews(String restaurantId) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final request = authProvider.cookieRequest;

      final response = await request.get(
        '${AppConfig.apiUrl}/review/json_reviews/$restaurantId/',
      );

      if (!mounted) return [];

      if (response['reviews'] != null) {
        return List<Review>.from(
          response['reviews'].map((json) => Review.fromJson(json)),
        );
      } else {
        throw Exception('No reviews data available');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<void> _deleteReview(BuildContext context, int reviewId) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
        '${AppConfig.apiUrl}/review/api/delete_review_mobile/$reviewId/',
      );

      if (!context.mounted) return;

      if (response["success"] == true) {
        _showSnackBar('Review successfully deleted!', Colors.green);
        widget.refreshRestaurantDetailsCallback?.call();

        if (mounted) {
          setState(() {
            _reviewsFuture = fetchReviews(widget.restaurantId);
          });
        }
      } else {
        _showSnackBar(
            'You are not authorized to delete this review', Colors.red);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar('Failed to delete review', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    const int maxStars = 5;
    return Row(
      children: List.generate(maxStars, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < rating ? Colors.amber : Colors.grey[400],
          size: 20,
        );
      }),
    );
  }

  void _goToAddReviewPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
          restaurantId: widget.restaurantId,
          refreshRestaurantDetailsCallback:
              widget.refreshRestaurantDetailsCallback,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _reviewsFuture = fetchReviews(widget.restaurantId);
        });
      }
    });
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _reviewsFuture = fetchReviews(widget.restaurantId);
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isCustomer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCustomer
                ? 'Be the first to review this restaurant!'
                : 'Waiting for customers to share their experience.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (isCustomer) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _goToAddReviewPage,
              icon: const Icon(Icons.add),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isCustomer =
        authProvider.user != null && authProvider.user!.role == "C";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCustomer)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _goToAddReviewPage,
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(isCustomer);
            }

            final reviews = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: Text(
                              review.user[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.user,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStars(review.rating),
                              ],
                            ),
                          ),
                          if (isCustomer)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red[400],
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Review'),
                                    content: const Text(
                                      'Are you sure you want to delete this review?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _deleteReview(context, review.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review.comment,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Posted on: ${review.createdAt.toLocal()}'
                            .split('.')[0],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
