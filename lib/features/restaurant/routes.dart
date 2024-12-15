import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_create.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_detail.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_edit.dart";
import "package:roso_jogja_mobile/features/restaurant/models/restaurant.dart";

final restaurantRoutes = [
  GoRoute(
      path: "/restaurant",
      builder: (context, state) => const RestaurantListPage(),
      routes: [
        GoRoute(
            path: "/create",
            builder: (context, state) => CreateRestaurantPage()),
        GoRoute(
          path: '/update',
          builder: (context, state) {
            final restaurant = state.extra as Restaurant;
            return EditRestaurantPage(restaurant: restaurant);
          },
          redirect: (context, state) {
            if (state.extra == null) {
              return "/restaurant";
            }

            return null;
          },
        ),
        GoRoute(
            path: "/:id",
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return RestaurantDetailPage(restaurantId: id!);
            }),
      ])
];
