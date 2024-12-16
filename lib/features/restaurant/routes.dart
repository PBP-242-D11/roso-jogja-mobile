import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/restaurant/pages/food_create.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/food_edit.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_create.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_detail.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_list.dart";
import "package:roso_jogja_mobile/features/restaurant/pages/restaurant_edit.dart";
import "package:roso_jogja_mobile/features/restaurant/models/restaurant.dart";
import "package:roso_jogja_mobile/features/restaurant/models/food.dart";

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
            path: "/:restaurantId",
            builder: (context, state) {
              final id = state.pathParameters['restaurantId'];
              return RestaurantDetailPage(restaurantId: id!);
            },
            routes: [
              GoRoute(
                  path: "/create_food",
                  builder: (context, state) {
                    final restaurantId = state.pathParameters['restaurantId'];
                    return CreateFoodPage(restaurantId: restaurantId!);
                  }),
              GoRoute(
                path: "/update_food",
                builder: (context, state) {
                  final restaurantId = state.pathParameters['restaurantId'];
                  final food = state.extra as Food;
                  return EditFoodPage(restaurantId: restaurantId!, food: food);
                },
              )
            ]),
      ])
];
