import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/features/review/pages/add_review.dart';

class Review {
  final int id;
  final String user;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      user: json['user'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

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
    // Accessing context before any await is safe
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response = await request.get(
      '${AppConfig.apiUrl}/review/json_reviews/$restaurantId/',
    );

    // Check if the widget is still mounted after the asynchronous operation
    if (!mounted) return [];

    if (response['reviews'] != null) {
      return List<Review>.from(
        response['reviews'].map((json) => Review.fromJson(json)),
      );
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> _deleteReview(BuildContext context, int reviewId) async {
    // Accessing context before any await is safe
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
        '${AppConfig.apiUrl}/review/api/delete_review_mobile/$reviewId/',
      );

      // Check if the widget is still mounted after the asynchronous operation
      if (!context.mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review successfully deleted!'),
            backgroundColor: Colors.green,
          ),
        );

        widget.refreshRestaurantDetailsCallback?.call();

        // Ensure the widget is still mounted before calling setState
        if (context.mounted) {
          setState(() {
            _reviewsFuture = fetchReviews(widget.restaurantId);
          });
        }
      } else if (response["success"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not authorized to delete this review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Check if the widget is still mounted before showing the SnackBar
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete review'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildStars(int rating) {
    const int maxStars = 5;
    return Row(
      children: List.generate(maxStars, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
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
          refreshRestaurantDetailsCallback: widget.refreshRestaurantDetailsCallback,
        ),
      ),
    ).then((_) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _reviewsFuture = fetchReviews(widget.restaurantId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isCustomer = authProvider.user != null && authProvider.user!.role == "C";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCustomer)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _goToAddReviewPage,
                child: const Text('Add Review'),
              ),
            ),
          ),

        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'There are no reviews yet.',
                style: TextStyle(fontSize: 18, color: Color(0xFFA8A8A8)),
              );
            } else {
              final reviews = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.user,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            buildStars(review.rating),

                            if (isCustomer)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
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
                        const SizedBox(height: 10),
                        Text(
                          review.comment,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Posted on: ${review.createdAt.toLocal()}'.split('.')[0],
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
            }
          },
        ),
      ],
    );
  }
}
