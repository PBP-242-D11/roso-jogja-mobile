import 'package:go_router/go_router.dart';
import 'package:roso_jogja_mobile/features/wishlist/pages/wishlist_page.dart';

final wishlistRoutes = [
  GoRoute(
      path: "/wishlist",
      builder: (context, state) => WishlistPage(),
      
  )
];
