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
import 'dart:developer';

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
      final authProvider = context.read<AuthProvider>();
      final request = authProvider.cookieRequest;
      final response = await request.get(
          '${AppConfig.apiUrl}/restaurant/api/restaurants/?page=$currentPage&page_size=$itemsPerPage');

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
          nextPage: response["current_page"] + 1,
          prevPage: response["current_page"] - 1,
        );

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final isRestaurantOwner = user != null && user.role == "R";

    return Scaffold(
      appBar: AppBar(title: const Text('Available Restaurants')),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          if (isLoading) const LoadingIndicator(),
          if (isRestaurantOwner)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => context.push('/restaurant/create'),
                child: const Text('Create Restaurant'),
              ),
            ),
          Expanded(
            child: restaurants.isEmpty && !isLoading
                ? Center(
                    child: Text(
                        'No restaurants found. ${isRestaurantOwner ? "Create one!" : ""}'))
                : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurants[index]);
                    },
                  ),
          ),
          PaginationControls(
            metadata: paginationMetadata,
            currentPage: currentPage,
            onPageChange: (newPage) {
              setState(() {
                currentPage = newPage;
              });
              fetchRestaurants();
            },
          ),
        ],
      ),
    );
  }
}
