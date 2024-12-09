import 'package:flutter/material.dart';
import 'features/auth/pages/login.dart';
import 'features/cart-and-order/pages/cart_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import "package:roso_jogja_mobile/shared/config/route_generator.dart";

void main() async {
  await dotenv.load();

  // Initialize CookieRequest and AuthProvider
  final cookieRequest = CookieRequest();
  final authProvider = AuthProvider(cookieRequest);

  // Initialize authProvider
  await authProvider.init();

  runApp(ChangeNotifierProvider(
    create: (_) => authProvider,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roso Jogja Mobile',
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
      initialRoute: '/login',
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: NavigatorKey.navigatorKey,
    );
  }
}
