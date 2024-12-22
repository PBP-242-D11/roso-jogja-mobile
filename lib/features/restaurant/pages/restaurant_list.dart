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
import 'package:roso_jogja_mobile/features/wishlist/models/wishlist_item.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  int currentPage = 1;
  static const int itemsPerPage = 8;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchRestorantAndWishlist() async {
    final authProvider = context.read<AuthProvider>();

    final restaurantData = await fetchRestaurants(authProvider);

    if (!authProvider.isLoggedIn) {
      return {
        'restaurants': restaurantData['restaurants'],
        'wishlist': {},
        'pagination': restaurantData['pagination']
      };
    }
    final wishlist = await fetchWishlist(authProvider);

    return {
      'restaurants': restaurantData['restaurants'],
      'wishlist': wishlist,
      'pagination': restaurantData['pagination']
    };
  }

  Future<Map<String, bool>> fetchWishlist(AuthProvider authProvider) async {
    final request = authProvider.cookieRequest;
    final idToWishlistMap = <String, bool>{};
    final response =
        await request.get('${AppConfig.apiUrl}/wishlist/mobile_wishlist/');
    final wishlistItems = response['wishlist'];
    final wishlist = (wishlistItems as List)
        .map((restaurant) => WishlistItem.fromJson(restaurant))
        .toList();
    for (final item in wishlist) {
      idToWishlistMap[item.id] = true;
    }
    return idToWishlistMap;
  }

  Future<Map<String, dynamic>> fetchRestaurants(
      AuthProvider authProvider) async {
    final request = authProvider.cookieRequest;

    final String searchParam =
        _searchQuery.isNotEmpty ? '&search=$_searchQuery' : '';
    final response = await request.get(
        '${AppConfig.apiUrl}/restaurant/api/restaurants/?page=$currentPage&page_size=$itemsPerPage$searchParam');

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

  Widget _buildHeader(bool isRestaurantOwner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRestaurantOwner
                ? 'Manage Your Restaurants'
                : 'Find Your Next Favorite Place',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRestaurantOwner
                ? 'Create and manage your restaurant listings'
                : 'Discover the best dining experiences in Jogja',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search restaurants...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _isSearching = value.isNotEmpty;
                currentPage = 1; // Reset to first page when searching
              });
            },
          ),
          if (isRestaurantOwner) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                bool? result = await context.push('/restaurant/create');
                if (result == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Create New Restaurant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isRestaurantOwner) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRestaurantOwner ? Icons.restaurant_menu : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? (isRestaurantOwner
                    ? 'No Restaurants Yet'
                    : 'No Restaurants Found')
                : 'No Results Found',
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
              _searchQuery.isEmpty
                  ? (isRestaurantOwner
                      ? 'Start by creating your first restaurant!'
                      : 'Check back later for new restaurants')
                  : 'Try different search terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (isRestaurantOwner) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                bool? result = await context.push('/restaurant/create');
                if (result == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Create Restaurant'),
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
    final user = context.watch<AuthProvider>().user;
    final isRestaurantOwner = user != null && user.role == "R";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRestaurantOwner ? 'Restaurant Management' : 'Explore Restaurants',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            currentPage = 1;
          });
        },
        child: Column(
          children: [
            _buildHeader(isRestaurantOwner),
            Expanded(
              child: FutureBuilder(
                future: fetchRestorantAndWishlist(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  final List<Restaurant> restaurants = data['restaurants'];
                  final PaginationMetadata? paginationMetadata =
                      data['pagination'];

                  if (restaurants.isEmpty) {
                    return _buildEmptyState(isRestaurantOwner);
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RestaurantCard(
                                restaurant: restaurants[index],
                                isRestaurantOwner: isRestaurantOwner,
                                isOnWishlist: data['wishlist']
                                        [restaurants[index].id] ??
                                    false,
                                refreshRestaurantCallback: () {
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      PaginationControls(
                        metadata: paginationMetadata,
                        currentPage: currentPage,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
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
            ),
          ],
        ),
      ),
    );
  }
}
