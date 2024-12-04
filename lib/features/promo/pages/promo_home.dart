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
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
          backgroundColor: Colors.white,
          cardColor: Colors.white,
          errorColor: Colors.red,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
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
  final List<Promo> promos = [
    Promo(promo_code: "SAVE20", value: 10, restaurant: "Restaurant 1", expiry_date: "2024-12-31"),
    Promo(promo_code: "FREESHIP", value: 5000, restaurant: "Restaurant 2", expiry_date: "2024-11-30"),
    Promo(promo_code: "WELCOME10", value: 5, restaurant: "Restaurant 3", expiry_date: "2024-10-05"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promo Overview'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPromoPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: promos.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(promos[index].promo_code + " - " + promos[index].restaurant),
              subtitle: Text('Value: \$${promos[index].value}, Expires: ${promos[index].expiry_date}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => print('Edit ${promos[index].promo_code}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => print('Delete ${promos[index].promo_code}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () => print('View ${promos[index].promo_code}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddPromoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Promo'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Promo Code'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Value'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Restaurant'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Expiry Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Save Promo'),
            ),
          ],
        ),
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
