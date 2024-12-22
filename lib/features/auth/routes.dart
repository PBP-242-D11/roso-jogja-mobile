import 'package:go_router/go_router.dart';
import "package:roso_jogja_mobile/features/auth/pages/login.dart";
import "package:roso_jogja_mobile/features/auth/pages/register.dart";

final authRoutes = [
  GoRoute(
    path: "/login",
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(path: "/register", builder: (context, state) => const RegisterPage()),
];
