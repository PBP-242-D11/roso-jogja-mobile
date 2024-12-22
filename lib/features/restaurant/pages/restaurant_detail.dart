import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';
import 'package:roso_jogja_mobile/features/restaurant/widgets/food_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/review/widgets/list_review.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewsSectionKey = GlobalKey();

  Future<Restaurant> fetchRestaurantDetail(
      CookieRequest request, String restaurantId) async {
    try {
      final response = await request
          .get('${AppConfig.apiUrl}/restaurant/api/restaurants/$restaurantId/');
      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load restaurant details: $e');
    }
  }

  void _scrollToReviews() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _reviewsSectionKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
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

  Widget _buildHeader(Restaurant restaurant) {
    return Stack(
      children: [
        // Hero Image
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Image.asset(
            'assets/images/restaurant_placeholder_${restaurant.placeholderImage}.png',
            fit: BoxFit.cover,
          ),
        ),
        // Gradient Overlay
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Restaurant Info
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant.address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(Restaurant restaurant) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: restaurant.categories
            .split(',')
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    category.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.orange[700],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDescription(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.description.isEmpty
                    ? "No description available"
                    : restaurant.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _scrollToReviews,
          icon: const Icon(Icons.comment),
          label: const Text("See Reviews"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
      Restaurant restaurant, bool isRestaurantOwner, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRestaurantOwner)
              ElevatedButton.icon(
                onPressed: () async {
                  bool? result = await context
                      .push('/restaurant/${widget.restaurantId}/create_food');
                  if (result == true) setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (restaurant.foods == null || restaurant.foods!.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No menu items available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: restaurant.foods!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FoodCard(
                  food: restaurant.foods![index],
                  restaurantId: restaurant.id,
                  refreshRestaurantDetailsCallback: () => setState(() {}),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isRestaurantOwner =
        authProvider.user != null && authProvider.user!.role == "R";

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<Restaurant>(
          future: fetchRestaurantDetail(
              authProvider.cookieRequest, widget.restaurantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Restaurant not found"));
            }

            Restaurant restaurant = snapshot.data!;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 250,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(restaurant),
                  ),
                  backgroundColor: Colors.orange[700],
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategories(restaurant),
                        const SizedBox(height: 24),
                        _buildDescription(restaurant),
                        const SizedBox(height: 24),
                        _buildMenuSection(
                            restaurant, isRestaurantOwner, context),
                        const SizedBox(height: 24),
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListReview(
                          key: _reviewsSectionKey,
                          restaurantId: widget.restaurantId,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
