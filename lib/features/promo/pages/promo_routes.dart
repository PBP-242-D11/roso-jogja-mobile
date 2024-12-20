import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_detail.dart';
import "package:roso_jogja_mobile/features/promo/pages/promo_home.dart";
import "package:roso_jogja_mobile/features/promo/pages/promo_form.dart";

final promoRoutes = [
  GoRoute(
      path: "/promo",
      builder: (context, state) => const PromoHome(),
      routes: [
        GoRoute(
            path: "/add",
            builder: (context, state) => CreatePromoPage()),
        // GoRoute(
        //   path: '/update',
        //   builder: (context, state) {
        //     final restaurant = state.extra as Restaurant;
        //     return EditRestaurantPage(restaurant: restaurant);
        //   },
        //   redirect: (context, state) {
        //     if (state.extra == null) {
        //       return "/restaurant";
        //     }

        //     return null;
        //   },
        // ),
        GoRoute(
            path: "/:promoId",
            builder: (context, state) {
              final id = state.pathParameters['promoId'];
              return PromoDetailPage(promoId: id!);
            },
            // routes: [
            //   GoRoute(
            //       path: "/create_food",
            //       builder: (context, state) {
            //         final restaurantId = state.pathParameters['restaurantId'];
            //         return CreateFoodPage(restaurantId: restaurantId!);
            //       }),
            //   GoRoute(
            //     path: "/update_food",
            //     builder: (context, state) {
            //       final restaurantId = state.pathParameters['restaurantId'];
            //       final food = state.extra as Food;
            //       return EditFoodPage(restaurantId: restaurantId!, food: food);
            //     },
            //   )
            // ]),
        )
      ])
];
