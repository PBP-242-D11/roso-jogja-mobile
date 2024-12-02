import 'package:flutter/material.dart';
import 'features/auth/pages/login.dart';
import 'features/cart-and-order/pages/cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // Page kalian yang ingin ditampilkan waktu app dimulai
      home: const LoginPage(),
    );
  }
}
