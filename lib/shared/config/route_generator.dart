import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/auth/pages/login.dart';
import 'package:roso_jogja_mobile/features/auth/pages/register.dart';
import 'package:roso_jogja_mobile/features/landing/pages/landing_page.dart';
import 'package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart';
import 'package:roso_jogja_mobile/features/restaurant/pages/restaurant_detail.dart';

// Route generator
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments passed during navigation
    final args = settings.arguments;

    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(builder: (_) => LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case "/landing":
        return MaterialPageRoute(builder: (_) => RosoJogjaLandingPage());
      case "/restaurants":
        return MaterialPageRoute(builder: (_) => RestaurantListPage());
      case "/restaurant":
        // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => RestaurantDetailPage(restaurantId: args),
          );
        }
        // If args is not of the correct type, return an error page
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  // Error route for invalid navigation
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text('Navigation Error'),
        ),
      ),
    );
  }
}
