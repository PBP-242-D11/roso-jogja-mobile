import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/restaurant/pages/create_restaurant.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_detail.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart";

final restaurantRoutes = [
  GoRoute(
      path: "/restaurant",
      builder: (context, state) => const RestaurantListPage(),
      routes: [
        GoRoute(
            path: "/create",
            builder: (context, state) => CreateRestaurantPage()),
        GoRoute(
            path: "/:id",
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return RestaurantDetailPage(restaurantId: id!);
            }),
      ])
];
