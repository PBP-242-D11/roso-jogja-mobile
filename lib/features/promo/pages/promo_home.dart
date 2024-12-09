import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_model.dart';


class PromoHome extends StatefulWidget {
  const PromoHome({super.key});

  @override
  State<PromoHome> createState() => _PromoHomePageState();
}

class _PromoHomePageState extends State<PromoHome> {
  late Future<List<PromoElement>> futurePromos;

  Future<List<PromoElement>> fetchPromo(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/promo/mobile_promo_home/');

    // Assuming response is correctly formatted JSON
    List<PromoElement> listPromo = (json.decode(response.body) as List)
        .map((item) => PromoElement.fromJson(item))
        .toList();
    return listPromo;
  }
  Future<void> viewPromo(CookieRequest request, String promoId) async {
    final response = await request.get('http://127.0.0.1:8000/promo/mobile_promo_details/$promoId/');
    if (response.statusCode == 200) {
      print('View Promo: ${response.body}');
    } else {
      print('Failed to load promo details');
    }
  }

  Future<void> editPromo(CookieRequest request, String promoId) async {
    // For demonstration, assuming GET request to fetch data for editing
    final response = await request.get('http://127.0.0.1:8000/promo/mobile_edit_promo/$promoId/');
    if (response.statusCode == 200) {
      print('Edit Promo: ${response.body}');
    } else {
      print('Failed to fetch promo for editing');
    }
  }

  Future<void> deletePromo(CookieRequest request, String promoId) async {
    final response = await request.get('http://127.0.0.1:8000/promo/mobile_delete_promo/$promoId/');
    if (response.statusCode == 200) {
      print('Promo Deleted Successfully');
    } else {
      print('Failed to delete promo');
    }
  }

  @override
  void initState() {
    super.initState();
    // Assuming CookieRequest is properly defined and instantiated
    futurePromos = fetchPromo(CookieRequest());
  }

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
      body: FutureBuilder<List<PromoElement>>(
        future: futurePromos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No promos available"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                PromoElement promo = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text('${promo.promoCode} - Type: ${promo.type}'),
                    subtitle: Text('Value: \$${promo.value}, Expires: ${promo.expiryDate.toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () => viewPromo(CookieRequest(), promo.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editPromo(CookieRequest(), promo.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deletePromo(CookieRequest(), promo.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No data available"));
          }
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

