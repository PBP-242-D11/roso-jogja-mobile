import 'package:flutter/material.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Restaurants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: currentRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = currentRestaurants[index];
                  return _buildRestaurantCard(restaurant);
                },
              ),
            ),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, String> restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      child: ListTile(
        title: Text(
          restaurant['name']!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(restaurant['description']!),
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
