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
  Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    final response = await request.get(
        '${AppConfig.apiUrl}/restaurant/api/restaurants/?page=1&page_size=8');

    var data = response;

    List<Restaurant> restaurants = [];

    for (var restaurant in data["results"]) {
      if (restaurant != null) {
        restaurants.add(Restaurant.fromJson(restaurant));
      }
    }

    return restaurants;
  }

  // Static data for restaurants
  final List<Map<String, String>> restaurants = List.generate(
    50,
    (index) => {
      'name': 'Restaurant ${index + 1}',
      'description': 'This is the description of Restaurant ${index + 1}.',
    },
  );

  // Pagination state
  int currentPage = 0;
  int itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    // Calculate the list of restaurants to display on the current page
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (currentPage + 1) * itemsPerPage;
    final currentRestaurants = restaurants.sublist(startIndex,
        endIndex > restaurants.length ? restaurants.length : endIndex);

    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Restaurants'),
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: fetchRestaurants(request),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (!snapshot.hasData) {
                    return Center(child: Text('No data found.'));
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
                          )),
                          _buildPaginationControls(),
                        ]);
                  }
                }
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
        title: Text(restaurant['name']!,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis, // Add this to handle overflow
            maxLines: 2),
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

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 0
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        Text('Page ${currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: (currentPage + 1) * itemsPerPage < restaurants.length
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }
}
