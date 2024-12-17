import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/cart-and-order/pages/order_history.dart";
import "package:roso_jogja_mobile/features/cart-and-order/pages/cart_screen.dart";

final orderRoutes = [
  GoRoute(
    path: "/order_history",
    builder: (context, state) => const OrderHistoryPage(),
  ),
  GoRoute(path: "/cart", builder: (context, state) => const ShoppingCartPage()),
];