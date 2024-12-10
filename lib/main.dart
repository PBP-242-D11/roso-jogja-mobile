import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:roso_jogja_mobile/features/auth/pages/register.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/landing/pages/landing_page.dart';
import 'package:roso_jogja_mobile/features/auth/pages/login.dart';
import 'package:roso_jogja_mobile/features/restaurant/pages/restaurant_detail.dart';
import 'package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart';
import 'package:go_router/go_router.dart';

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

final _router = GoRouter(initialLocation: "/login", routes: [
  GoRoute(path: "/", builder: (context, state) => const LandingPage()),
  GoRoute(
    path: "/login",
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(path: "/register", builder: (context, state) => const RegisterPage()),
  GoRoute(path: "/home", builder: (context, state) => const LandingPage()),
  GoRoute(
      path: "/restaurant",
      builder: (context, state) => const RestaurantListPage(),
      routes: [
        GoRoute(
            path: "/:id",
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return RestaurantDetailPage(restaurantId: id!);
            }),
      ]),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}
