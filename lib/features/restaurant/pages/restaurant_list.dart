import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/pagination_metadata.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/loading_indicator.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/widgets/left_drawer.dart';
import '../../auth/provider/auth_provider.dart';
import "package:go_router/go_router.dart";

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  int currentPage = 1;
  static const int itemsPerPage = 8;

  Future<Map<String, dynamic>> fetchRestaurants() async {
    final authProvider = context.read<AuthProvider>();
    final request = authProvider.cookieRequest;

    final response = await request.get(
        '${AppConfig.apiUrl}/restaurant/api/restaurants/?page=$currentPage&page_size=$itemsPerPage');

    return {
      'restaurants': (response["results"] as List)
          .map((restaurant) => Restaurant.fromJson(restaurant))
          .toList(),
      'pagination': PaginationMetadata(
        currentPage: response["current_page"],
        hasNext: response["has_next"],
        hasPrevious: response["has_previous"],
        totalPages: response["num_pages"] ?? 1,
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRestaurantOwner = user != null && user.role == "R";

    return Scaffold(
      appBar: AppBar(title: const Text('Available Restaurants')),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load restaurants: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final List<Restaurant> restaurants = data['restaurants'];
          final PaginationMetadata? paginationMetadata = data['pagination'];

          return Column(
            children: [
              if (isRestaurantOwner)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? result = await context.push('/restaurant/create');

                      if (result != null && result == true) {
                        setState(() {});
                      }
                    },
                    child: const Text('Create Restaurant'),
                  ),
                ),
              Expanded(
                child: restaurants.isEmpty
                    ? Center(
                        child: Text(
                            'No restaurants found. ${isRestaurantOwner ? "Create one!" : ""}'))
                    : ListView.builder(
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          return RestaurantCard(
                            restaurant: restaurants[index],
                            isRestaurantOwner: isRestaurantOwner,
                            refreshRestaurantCallback: () {
                              setState(() {}); // Trigger a refresh
                            },
                          );
                        },
                      ),
              ),
              PaginationControls(
                metadata: paginationMetadata,
                currentPage: currentPage,
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                onPageChange: (newPage) {
                  setState(() {
                    currentPage = newPage;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
