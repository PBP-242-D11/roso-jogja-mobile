import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/pages/login.dart';
import 'package:roso_jogja_mobile/features/auth/pages/register.dart';
import 'package:roso_jogja_mobile/features/landing/pages/landing_page.dart';
import 'package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) {
          CookieRequest request = CookieRequest();
          return request;
        },
        child: MaterialApp(
          title: 'Roso Jogja Mobile',
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
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/register': (context) => RegisterPage(),
            '/landing': (context) => RosoJogjaLandingPage(),
            '/restaurants': (context) => RestaurantListPage(),
          },
        ));
  }
}
