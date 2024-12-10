import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Improved pagination metadata class
class PaginationMetadata {
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;
  final int totalPages;

  PaginationMetadata({
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
    required this.totalPages,
  });
}

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  int currentPage = 1;
  static const int itemsPerPage = 8;
  bool isLoading = false;
  PaginationMetadata? paginationMetadata;
  List<Restaurant> restaurants = [];

  Future<void> fetchRestaurants() async {
    setState(() {
      isLoading = true;
    });

    try {
      final request = context.read<AuthProvider>().cookieRequest;
      final response =
          await request.get('${AppConfig.apiUrl}/restaurant/api/restaurants/'
              '?page=$currentPage&page_size=$itemsPerPage');

      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        restaurants = (response["results"] as List)
            .map((restaurant) => Restaurant.fromJson(restaurant))
            .toList();

        paginationMetadata = PaginationMetadata(
          currentPage: response["current_page"],
          hasNext: response["has_next"],
          hasPrevious: response["has_previous"],
          totalPages: response["num_pages"] ?? 1,
        );

        isLoading = false;
      });
    } catch (e) {
      // Check if the widget is still mounted before showing SnackBar
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // Use ScaffoldMessenger.of(context) safely
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load restaurants: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Widget _buildRestaurantCard(
      Map<String, String> restaurant, BuildContext context) {
    return Card(
        elevation: 5,
        child: GestureDetector(
          onTap: () => context.go('/restaurant/${restaurant['id']}'),
          child: ListTile(
            contentPadding: EdgeInsets.all(8.0),
            title: Text(
              restaurant['name']!,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Handle overflow
              maxLines: 2,
            ),
            subtitle: Container(
              constraints: BoxConstraints(
                  maxHeight: 50), // Set a fixed max height for subtitle
              child: Text(
                restaurant['description']!,
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 2, // Limit the number of lines for subtitle
              ),
            ),
            minTileHeight: 100,
          ),
        ));
  }

  Widget _buildPaginationControls() {
    final metadata = paginationMetadata;
    if (metadata == null) return SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.first_page),
          onPressed: metadata.hasPrevious && !isLoading
              ? () {
                  setState(() => currentPage = 1);
                  fetchRestaurants();
                }
              : null,
        ),
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: metadata.hasPrevious && !isLoading
              ? () {
                  setState(() => currentPage--);
                  fetchRestaurants();
                }
              : null,
        ),
        Text('Page ${metadata.currentPage} of ${metadata.totalPages}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: metadata.hasNext && !isLoading
              ? () {
                  setState(() => currentPage++);
                  fetchRestaurants();
                }
              : null,
        ),
        IconButton(
          icon: Icon(Icons.last_page),
          onPressed: metadata.hasNext && !isLoading
              ? () {
                  setState(() => currentPage = metadata.totalPages);
                  fetchRestaurants();
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Restaurants')),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          if (isLoading) LinearProgressIndicator(),
          Expanded(
            child: restaurants.isEmpty && !isLoading
                ? Center(child: Text('No restaurants found'))
                : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return _buildRestaurantCard({
                        'name': restaurant.name,
                        'description': restaurant.address,
                        'id': restaurant.id,
                      }, context);
                    },
                  ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}
