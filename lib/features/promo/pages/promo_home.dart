import 'package:flutter/material.dart';

void main() {
  runApp(PromoHome());
}

class PromoHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PromoOverviewPage(),
      theme: ThemeData(
        // Orange and white color scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
          backgroundColor: Colors.white,
          cardColor: Colors.white,
          errorColor: Colors.red,
          brightness: Brightness.light,
        ),
        // Default font family
        fontFamily: 'Roboto',
        // Default text theme
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}

class PromoOverviewPage extends StatelessWidget {
  // Akan diubah dengan promo yang diambil dari backend Django
  final List<Promo> promos = [
    Promo(promo_code: "SAVE20", value: 10, restaurant: "Restaurant 1", expiry_date: "2024-12-31"),
    Promo(promo_code: "FREESHIP", value: 5000, restaurant: "Restaurant 2", expiry_date: "2024-11-30"),
    Promo(promo_code: "WELCOME10", value: 5, restaurant: "Restaurant 3", expiry_date: "2024-10-05"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promo'),
        
      ),
      body: ListView.builder(
        itemCount: promos.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(promos[index].promo_code),
              subtitle: Text(promos[index].restaurant),
              trailing: Text('Valid until: ${promos[index].expiry_date}'),
            ),
          );
        },
      ),
    );
  }
}

class Promo {
  String promo_code;
  String restaurant;
  String expiry_date;
  int value;

  Promo({required this.promo_code, required this.value, required this.restaurant, required this.expiry_date});
}
