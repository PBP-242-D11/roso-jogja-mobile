import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/restaurant/models/restaurant.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  int currentPage = 1;
  int itemsPerPage = 8;
  bool hasNext = false;
  bool hasPrevious = false;

  // Define the Future as a getter
  Future<List<Restaurant>> get fetchRestaurantsFuture async {
    final request = context.watch<CookieRequest>();
    return fetchRestaurants(request);
  }

  Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    final response = await request.get(
        '${AppConfig.apiUrl}/restaurant/api/restaurants/?page=$currentPage&page_size=$itemsPerPage');

    var data = response;

    currentPage = data["current_page"];
    hasNext = data["has_next"];
    hasPrevious = data["has_previous"];

    List<Restaurant> restaurants = [];

    for (var restaurant in data["results"]) {
      if (restaurant != null) {
        restaurants.add(Restaurant.fromJson(restaurant));
      }
    }

    return restaurants;
  }

  // Pagination logic
  void loadNextPage() {
    if (hasNext) {
      setState(() {
        currentPage++;
      });
    }
  }

  void loadPreviousPage() {
    if (hasPrevious) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Restaurants'),
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future:
                fetchRestaurantsFuture, // Use the getter to trigger a new Future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No restaurants found"));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final restaurant = snapshot.data![index];
                          return _buildRestaurantCard({
                            'name': restaurant.name,
                            'description': restaurant.address,
                          });
                        },
                      ),
                    ),
                    _buildPaginationControls(currentPage, hasNext, hasPrevious,
                        currentPage - 1, currentPage + 1),
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, String> restaurant) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(8.0),
        title: Text(
          restaurant['name']!,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis, // Add this to handle overflow
          maxLines: 2,
        ),
        subtitle: Container(
          constraints: BoxConstraints(
              maxHeight: 50), // Set a fixed max height for subtitle
          child: Text(
            restaurant['description']!,
            overflow: TextOverflow.ellipsis, // Add this to handle overflow
            maxLines: 2, // Limit the number of lines for subtitle
          ),
        ),
        minTileHeight: 100,
      ),
    );
  }

  Widget _buildPaginationControls(int currentPage, bool hasNext,
      bool hasPrevious, int nextPage, int prevPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: hasPrevious
              ? () {
                  loadPreviousPage();
                }
              : null,
        ),
        Text('Page $currentPage'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: hasNext
              ? () {
                  loadNextPage();
                }
              : null,
        ),
      ],
    );
  }
}
