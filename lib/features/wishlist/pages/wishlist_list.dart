import 'package:flutter/material.dart';

void main() {
  // Menjalankan aplikasi dan memulai widget MyApp
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Widget utama aplikasi, menggunakan MaterialApp untuk tema dan halaman utama
    return MaterialApp(
      title:
          'Wishlist Restorant', // Nama aplikasi yang muncul di taskbar atau switcher
      theme: ThemeData(
        primarySwatch:
            Colors.blue, // Tema utama aplikasi menggunakan warna biru
      ),
      home:
          WishlistList(), // Menampilkan halaman WishlistList saat aplikasi dimulai
    );
  }
}

class WishlistList extends StatelessWidget {
  // Daftar produk dalam bentuk List<Map<String, String>> yang berisi nama, gambar, dan harga produk
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
    // Membuat tampilan utama halaman WishlistList
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'), // Judul yang muncul di AppBar
      ),
      body: ListView.builder(
        itemCount: wishlist
            .length, // Jumlah item yang ditampilkan berdasarkan jumlah produk dalam wishlist
        itemBuilder: (context, index) {
          final item = wishlist[index]; // Mengambil item pada index tertentu
          return WishlistItem(
            name: item['name']!, // Nama produk
            image: item['image']!, // Gambar produk
            price: item['price']!, // Harga produk
          );
        },
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  // Properti untuk menerima data dari WishlistList
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
    // Membuat tampilan untuk setiap item dalam wishlist
    return Card(
      margin: EdgeInsets.all(8.0), // Memberikan margin sekitar kartu
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0), // Padding di dalam ListTile
        leading: Image.asset(image,
            width: 50, height: 50, fit: BoxFit.cover), // Gambar produk di kiri
        title: Text(name, // Nama produk yang ditampilkan di bagian judul
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(price,
            style: TextStyle(
                color: Colors.green)), // Harga produk ditampilkan di bawah nama
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline,
              color: Colors.red), // Tombol untuk menghapus item
          onPressed: () {
            // Tindakan saat tombol ditekan, misalnya menghapus item
            print(
                '$name removed from wishlist'); // Menampilkan nama item yang dihapus di konsol
          },
        ),
      ),
    );
  }
}
