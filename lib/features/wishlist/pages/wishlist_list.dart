import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restoran Wishlist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WishlistList(),
    );
  }
}

class WishlistList extends StatelessWidget {
  final List<Map<String, String>> wishlist = [
    {
      'name': 'Pizza Margherita',
      'image': 'assets/pizza1.jpg',
      'price': 'Rp. 50.000'
    },
    {
      'name': 'Spaghetti Bolognese',
      'image': 'assets/pasta1.jpg',
      'price': 'Rp. 40.000'
    },
    {
      'name': 'Chicken Wings',
      'image': 'assets/chicken1.jpg',
      'price': 'Rp. 30.000'
    },
    {'name': 'Burger', 'image': 'assets/burger1.jpg', 'price': 'Rp. 25.000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: ListView.builder(
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          final item = wishlist[index];
          return WishlistItem(
            name: item['name']!,
            image: item['image']!,
            price: item['price']!,
          );
        },
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final String name;
  final String image;
  final String price;

  const WishlistItem({
    required this.name,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(price, style: TextStyle(color: Colors.green)),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () {
            // Action for removing item from wishlist
            print('$name removed from wishlist');
          },
        ),
      ),
    );
  }
}
