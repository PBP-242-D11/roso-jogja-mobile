import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/features/landing/pages/homepage.dart';
import 'package:roso_jogja_mobile/features/landing/pages/landing_page.dart';
import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/auth/routes.dart";
import "package:roso_jogja_mobile/features/restaurant/routes.dart";
import "package:roso_jogja_mobile/features/cart-and-order/routes.dart";

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

final _router = GoRouter(
    initialLocation: "/",
    redirect: (context, state) {
      final unprotectedRoutes = [
        "/",
        "/login",
        "/register",
        "/restaurant",
        "/restaurant/:restaurantId"
        "/"
      ];
      if (unprotectedRoutes.contains(state.fullPath)) {
        return null;
      }

      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn) {
        return "/login";
      } else {
        return null;
      }
    },
    routes: [
      GoRoute(path: "/", builder: (context, state) => const LandingPage()),
      GoRoute(path: "/home", builder: (context, state) => const Homepage()),
      ...authRoutes,
      ...restaurantRoutes,
      ...orderRoutes,
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
