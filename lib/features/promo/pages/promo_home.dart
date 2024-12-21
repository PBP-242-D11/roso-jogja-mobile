import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_card.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_model.dart';


class PromoHome extends StatefulWidget {
  const PromoHome({super.key});

  @override
  State<PromoHome> createState() => _PromoHomePageState();
}

class _PromoHomePageState extends State<PromoHome> {
  late Future<Map<String, dynamic>> futurePromos;


  Future<Map<String, dynamic>> fetchPromo() async {
  final authProvider = context.read<AuthProvider>();
  final request = authProvider.cookieRequest;

  // Fetch the response
  final response = await request.get('${AppConfig.apiUrl}/promo/mobile_promo_home/');

  // Check the structure of the response
  if (response == null || response.isEmpty) {
    throw Exception("Empty response from the server");
  }

  // Extract promos and other_promos as List<dynamic>
  final promos = response["promos"] as List<dynamic>? ?? [];
  final otherPromos = response["other_promos"] as List<dynamic>? ?? [];

  // Extract message, ensuring it's not null or empty
  final message = (response["message"] != null && response["message"].toString().trim().isNotEmpty)
      ? response["message"]
      : 'No message available';

  return {
    'promos': promos,
    'other_promos': otherPromos,
    'message': message,
  };
}

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRestaurantOwner = user != null && user.role == "R";
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
      drawer: const LeftDrawer(),
      body: FutureBuilder<Map<String, dynamic>?>(
      future: fetchPromo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data;

          // Ensure data is not null and has the expected structure
          if (data == null || !data.containsKey('promos') || !data.containsKey('other_promos')) {
            return const Center(child: Text("Invalid data format received"));
          }

          // Extract the 'promos' and 'otherPromos' lists
          final promos = (data['promos'] as List<dynamic>?)
              ?.where((promo) => promo is Map<String, dynamic>)
              .cast<Map<String, dynamic>>()
              .toList() ?? [];

          final otherPromos = (data['other_promos'] as List<dynamic>?)
              ?.where((promo) => promo is Map<String, dynamic>)
              .cast<Map<String, dynamic>>()
              .toList() ?? [];

          if (promos.isEmpty && otherPromos.isEmpty) {
            return const Center(child: Text("No promos available"));
          }

          return Column(
            children: [
              if (isRestaurantOwner)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? result = await context.push('/promo/add');
                      if (result == true) {
                        setState(() {}); // Trigger a refresh
                      }
                    },
                    child: const Text('Create Promo'),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: promos.length + otherPromos.length,
                  itemBuilder: (context, index) {
                    final isPromo = index < promos.length;
                    final promo = isPromo
                        ? promos[index]
                        : otherPromos[index - promos.length];

                    if (promo == null || !promo.containsKey('value') || !promo.containsKey('type')) {
                      return const Card(
                        child: ListTile(
                          title: Text("Invalid promo data"),
                          subtitle: Text("This promo could not be loaded"),
                        ),
                      );
                    }

                    // Choose the appropriate card type
                    return isPromo
                    ? PromoCard(
                        promo: PromoElement.fromJson(promo),
                        isRestaurantOwner: isRestaurantOwner,
                        use: false,
                        refreshPromoCallback: () {
                          setState(() {});
                        },
                      )
                    : OtherPromoCard(
                        promo: PromoElement.fromJson(promo),
                      );
                  },
                ),
              ),
            ],
          );



  //           return ListView.builder(
  //             itemCount: (promos.length + otherPromos.length),
  //             itemBuilder: (context, index) {
  //               // Determine if the item belongs to promos or otherPromos
  //               final isPromo = index < promos.length;
  //               final promo = isPromo ? promos[index] : otherPromos[index - promos.length];

  //               // Ensure the promo has the expected fields
  //               if (!promo.containsKey('value') || !promo.containsKey('type')) {
  //                 return const Card(
  //                   child: ListTile(
  //                     title: Text("Invalid promo data"),
  //                     subtitle: Text("This promo could not be loaded"),
  //                   ),
  //                 );
  //               }

  //               return Container(
  //                 color: isPromo ? Colors.white : Colors.grey[200], // Gray background for otherPromos
  //                 child: Card(
  //                   elevation: isPromo ? 4 : 1, // Slightly different elevation for visual distinction
  //                   child: ListTile(
  //                     title: Text(
  //                       promo['type'] == 'Percentage'
  //                           ? 'Value: ${promo['value']}% - Type: ${promo['type']}'
  //                           : 'Value: Rp${promo['value']} - Type: ${promo['type']}',
  //                     ),
  //                     subtitle: Text(
  //                       'Expires: ${promo['expiry_date']}',
  //                     ),
  //                     trailing: isPromo
  //                         ? Row(
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: <Widget>[
  //                               IconButton(
  //                                 icon: const Icon(Icons.visibility),
  //                                 onPressed: () => viewPromo(CookieRequest(), promo['id']),
  //                               ),
  //                               IconButton(
  //                                 icon: const Icon(Icons.edit),
  //                                 onPressed: () => editPromo(CookieRequest(), promo['id']),
  //                               ),
  //                               IconButton(
  //                                 icon: const Icon(Icons.delete),
  //                                 onPressed: () => deletePromo(CookieRequest(), promo['id']),
  //                               ),
  //                             ],
  //                           )
  //                         : null, // No trailing buttons for otherPromos
  //                   ),
  //                 ),
  //               );
  //             },
  //           );


          } else {
            // Default fallback if none of the above conditions match
            return const Center(child: Text("No data available"));
          }
        }

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
      drawer: const LeftDrawer(),
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

