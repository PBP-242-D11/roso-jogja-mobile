import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

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
  _ListReviewState createState() => _ListReviewState();
}

class _ListReviewState extends State<ListReview> {
  late Future<List<Review>> _reviewsFuture;

  Future<List<Review>> fetchReviews(String restaurantId) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response = await request.get('${AppConfig.apiUrl}/review/json_reviews/$restaurantId/');

    if (response['reviews'] != null) {
      return List<Review>.from(
        response['reviews'].map((review) => Review.fromJson(review)),
      );
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> _deleteReview(BuildContext context, int reviewId) async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    try {
      final response = await request.get(
        '${AppConfig.apiUrl}/review/api/delete_review/$reviewId/',
      );

      if (context.mounted) {
        if (response["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh setelah berhasil menghapus review
          widget.refreshRestaurantDetailsCallback?.call();
          setState(() {
            _reviewsFuture = fetchReviews(widget.restaurantId);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus review'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menghapus review'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'There are no reviews yet.',
              style: TextStyle(fontSize: 18, color: Color(0xFFA8A8A8)),
            ),
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Review'),
                                content: const Text(
                                  'Are you sure you want to delete this review?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
